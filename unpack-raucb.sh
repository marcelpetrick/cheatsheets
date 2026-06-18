#!/usr/bin/env bash
# Unpack a RAUC bundle (.raucb) and extract the rootfs license directory.
#
# Usage:
#   ./unpack-raucb.sh [--verbose] [--output <directory>] <bundle.raucb>
#
# The script:
#   1. Reads the signed RAUC manifest and decrypts crypt bundles
#   2. Extracts the squashfs payload into <output-dir>/squashfs/
#   3. Lists the contents of the rootfs tar inside it
#   4. Extracts the license directory from the rootfs tar into <output-dir>/licenses/
#
# Dependencies: coreutils, openssl, unsquashfs (squashfs-tools), python3
# Crypt bundles additionally require the Python cryptography package.
#
# Verified with: job102709_p118-debug-bundle-imx8mm-p118.raucb
# Artifact source: https://git.data-modul.com/i.MX8Mm.P118/rebase-project/meta-imx8mm-data-modul-p118/-/jobs/102709/artifacts/browse/artifacts/

set -euo pipefail

LICENSE_PATH="opt/P118/bin/assets/licenses"
OUTPUT_DIR="rauc-unpacked"
VERBOSE=false
BUNDLE=""

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] <bundle.raucb>

Unpack a plain, verity, or crypt RAUC bundle and extract its license files.

Options:
  -o, --output DIR  Write extracted files to DIR (default: rauc-unpacked)
  -v, --verbose     Print detailed processing information
  -h, --help        Show this help
EOF
}

die() {
    echo "Error: $*" >&2
    exit 1
}

verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo "[verbose] $*" >&2
    fi
}

while (($#)); do
    case "$1" in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            (($# >= 2)) || die "$1 requires a directory argument."
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --output=*)
            OUTPUT_DIR="${1#*=}"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            die "unknown option: $1. Use --help for usage."
            ;;
        *)
            [[ -z "$BUNDLE" ]] || die "only one RAUC bundle path may be specified."
            BUNDLE="$1"
            shift
            ;;
    esac
done

if (($#)); then
    [[ -z "$BUNDLE" && $# -eq 1 ]] || die "only one RAUC bundle path may be specified."
    BUNDLE="$1"
fi

if [[ -z "$BUNDLE" ]]; then
    usage >&2
    exit 1
fi

[[ -n "$OUTPUT_DIR" ]] || die "output directory must not be empty."
[[ -f "$BUNDLE" ]] || die "file not found: $BUNDLE"
[[ -r "$BUNDLE" ]] || die "file is not readable: $BUNDLE"

for command in head openssl python3 sha256sum unsquashfs; do
    command -v "$command" &>/dev/null || die "$command not found."
    verbose "Using $command from $(command -v "$command")"
done

SQUASHFS_DIR="$OUTPUT_DIR/squashfs"
LICENSES_DIR="$OUTPUT_DIR/licenses"
MANIFEST="$OUTPUT_DIR/manifest.raucm"
SIGNATURE="$OUTPUT_DIR/signature.cms"
DECRYPTED_BUNDLE="$OUTPUT_DIR/decrypted.raucb"

read_bundle_signature_size() {
    python3 - "$1" <<'PYEOF'
import os
import sys

with open(sys.argv[1], "rb") as bundle:
    if os.fstat(bundle.fileno()).st_size < 8:
        sys.exit("Error: file is too small to be a RAUC bundle.")
    bundle.seek(-8, os.SEEK_END)
    print(int.from_bytes(bundle.read(8), byteorder="big"))
PYEOF
}

read_file_size() {
    python3 - "$1" <<'PYEOF'
import os
import sys

print(os.path.getsize(sys.argv[1]))
PYEOF
}

extract_bundle_manifest() {
    local bundle_size signature_offset signature_size

    bundle_size=$(read_file_size "$BUNDLE")
    signature_size=$(read_bundle_signature_size "$BUNDLE")
    signature_offset=$((bundle_size - 8 - signature_size))

    ((signature_size > 0 && signature_offset > 0)) || die "invalid RAUC signature trailer."
    verbose "Bundle size: $bundle_size bytes"
    verbose "CMS signature: $signature_size bytes at offset $signature_offset"

    verbose "Extracting the appended CMS signature to $SIGNATURE"
    dd if="$BUNDLE" of="$SIGNATURE" bs=1 skip="$signature_offset" count="$signature_size" status=none
    if ! openssl cms -cmsout -inform DER -in "$SIGNATURE" -noout 2>/dev/null; then
        die "appended data is not a valid DER-encoded CMS signature."
    fi

    verbose "Checking the CMS signature integrity and extracting its embedded manifest"
    if openssl cms -verify -inform DER -in "$SIGNATURE" -noverify -out "$MANIFEST" 2>/dev/null; then
        verbose "Found an embedded manifest in the CMS signature"
        verbose "CMS signature is internally valid; certificate trust is not checked"
    else
        rm -f "$MANIFEST"
        verbose "CMS signature has detached content; checking it against the bundle payload"
        if ! head -c "$signature_offset" "$BUNDLE" |
            openssl cms -verify -binary -inform DER -in "$SIGNATURE" -noverify \
                -content /dev/stdin -out /dev/null 2>/dev/null; then
            die "detached CMS signature does not match the bundle payload."
        fi
        verbose "Detached CMS signature is internally valid; certificate trust is not checked"
    fi

    printf '%s\n' "$signature_offset"
}

manifest_value() {
    python3 - "$MANIFEST" "$1" "$2" <<'PYEOF'
import configparser
import sys

config = configparser.ConfigParser(interpolation=None)
config.read(sys.argv[1])
print(config.get(sys.argv[2], sys.argv[3], fallback=""))
PYEOF
}

decrypt_crypt_bundle() {
    local encrypted_size="$1"
    local crypt_key="$2"

    python3 - "$BUNDLE" "$DECRYPTED_BUNDLE" "$crypt_key" "$encrypted_size" <<'PYEOF'
import struct
import sys

try:
    from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
except ImportError:
    sys.exit("Error: crypt bundles require the Python cryptography package.")

source_path, destination_path, key_hex, size_text = sys.argv[1:]
try:
    key = bytes.fromhex(key_hex)
except ValueError:
    sys.exit("Error: the RAUC crypt key is not valid hexadecimal.")
encrypted_size = int(size_text)
sector_size = 4096

if len(key) != 32:
    sys.exit("Error: the RAUC crypt key must be 32 bytes.")
if encrypted_size <= 0 or encrypted_size % sector_size:
    sys.exit(f"Error: encrypted payload size must be a positive multiple of {sector_size}.")

with open(source_path, "rb") as source, open(destination_path, "wb") as destination:
    for sector in range(encrypted_size // sector_size):
        encrypted = source.read(sector_size)
        if len(encrypted) != sector_size:
            sys.exit("Error: unexpected end of encrypted RAUC payload.")

        # RAUC uses aes-cbc-plain64 with a 4096-byte encryption sector.
        # plain64 counts 512-byte sectors and stores the IV counter little-endian.
        iv = struct.pack("<Q", sector * (sector_size // 512)) + bytes(8)
        decryptor = Cipher(algorithms.AES(key), modes.CBC(iv)).decryptor()
        destination.write(decryptor.update(encrypted) + decryptor.finalize())
PYEOF
}

validate_squashfs() {
    local source="$1"

    python3 - "$source" <<'PYEOF'
import sys

with open(sys.argv[1], "rb") as source:
    if source.read(4) != b"hsqs":
        sys.exit("Error: decoded bundle payload is not a SquashFS filesystem.")
PYEOF
}

verify_rootfs() {
    local rootfs_tar="$1"
    local expected_hash expected_size actual_hash actual_size

    expected_hash=$(manifest_value image.rootfs sha256)
    expected_size=$(manifest_value image.rootfs size)
    actual_size=$(read_file_size "$rootfs_tar")

    if [[ -n "$expected_size" ]]; then
        [[ "$expected_size" =~ ^[0-9]+$ ]] || die "manifest contains an invalid rootfs size."
        [[ "$actual_size" == "$expected_size" ]] ||
            die "rootfs size mismatch: expected $expected_size bytes, got $actual_size bytes."
        verbose "Rootfs size matches the manifest: $actual_size bytes"
    fi

    if [[ -n "$expected_hash" ]]; then
        [[ "$expected_hash" =~ ^[[:xdigit:]]{64}$ ]] || die "manifest contains an invalid rootfs SHA-256."
        verbose "Calculating the rootfs SHA-256 checksum"
        actual_hash=$(sha256sum "$rootfs_tar")
        actual_hash=${actual_hash%% *}
        [[ "${actual_hash,,}" == "${expected_hash,,}" ]] ||
            die "rootfs SHA-256 mismatch: expected $expected_hash, got $actual_hash."
        verbose "Rootfs SHA-256 matches the manifest: $actual_hash"
    fi
}

show_manifest() {
    echo "=== manifest.raucm ==="
    cat "$MANIFEST"
    echo ""
}

verbose "Input bundle: $BUNDLE"
verbose "Output directory: $OUTPUT_DIR"
echo "=== Step 1: Reading RAUC bundle metadata ==="
mkdir -p "$OUTPUT_DIR"
rm -rf "$SQUASHFS_DIR" "$LICENSES_DIR"
rm -f "$MANIFEST" "$SIGNATURE" "$DECRYPTED_BUNDLE"

PAYLOAD_SIZE=$(extract_bundle_manifest)
SQUASHFS_SOURCE="$BUNDLE"

if [[ -f "$MANIFEST" ]]; then
    BUNDLE_FORMAT=$(manifest_value bundle format)
    BUNDLE_FORMAT=${BUNDLE_FORMAT:-plain}
    echo "Bundle format: $BUNDLE_FORMAT"
    echo ""
    show_manifest
else
    BUNDLE_FORMAT="plain"
    echo "Bundle format: plain (detached signature)"
    echo ""
fi

case "$BUNDLE_FORMAT" in
    plain|verity)
        verbose "The $BUNDLE_FORMAT bundle payload is directly readable as SquashFS"
        ;;
    crypt)
        CRYPT_KEY=$(manifest_value bundle crypt-key)
        VERITY_SIZE=$(manifest_value bundle verity-size)
        if [[ -z "$CRYPT_KEY" || ! "$VERITY_SIZE" =~ ^[0-9]+$ ]]; then
            die "crypt bundle manifest lacks a valid crypt-key or verity-size."
        fi

        ENCRYPTED_SIZE=$((PAYLOAD_SIZE - VERITY_SIZE))
        ((ENCRYPTED_SIZE > 0)) || die "calculated encrypted payload size is invalid."
        echo "=== Step 2: Decrypting RAUC bundle payload ==="
        verbose "Signed payload size: $PAYLOAD_SIZE bytes"
        verbose "dm-verity data size: $VERITY_SIZE bytes"
        verbose "Encrypted SquashFS size: $ENCRYPTED_SIZE bytes"
        verbose "Decrypting AES-256-CBC plain64 sectors to $DECRYPTED_BUNDLE"
        decrypt_crypt_bundle "$ENCRYPTED_SIZE" "$CRYPT_KEY"
        SQUASHFS_SOURCE="$DECRYPTED_BUNDLE"
        echo "Decrypted payload: $DECRYPTED_BUNDLE"
        echo ""
        ;;
    *)
        die "unsupported RAUC bundle format: $BUNDLE_FORMAT"
        ;;
esac

verbose "Validating the SquashFS magic in $SQUASHFS_SOURCE"
validate_squashfs "$SQUASHFS_SOURCE"

echo "=== Step 3: Extracting squashfs payload ==="
verbose "Removing old extraction results before unpacking"
verbose "Running unsquashfs with source $SQUASHFS_SOURCE"
unsquashfs -d "$SQUASHFS_DIR" "$SQUASHFS_SOURCE"
echo ""

echo "=== Bundle contents ==="
ls -lh "$SQUASHFS_DIR/"
echo ""

if [[ ! -f "$MANIFEST" ]]; then
    mapfile -d '' INNER_MANIFESTS < <(find "$SQUASHFS_DIR" -type f -name "manifest.raucm" -print0)
    ((${#INNER_MANIFESTS[@]} == 1)) ||
        die "expected exactly one manifest.raucm in the SquashFS payload."

    verbose "Copying the manifest from ${INNER_MANIFESTS[0]}"
    cp "${INNER_MANIFESTS[0]}" "$MANIFEST"
    BUNDLE_FORMAT=$(manifest_value bundle format)
    BUNDLE_FORMAT=${BUNDLE_FORMAT:-plain}
    [[ "$BUNDLE_FORMAT" == plain ]] ||
        die "unexpected $BUNDLE_FORMAT format in a bundle with a detached signature."
    echo "Bundle format from manifest: $BUNDLE_FORMAT"
    echo ""
    show_manifest
fi

mapfile -d '' ROOTFS_TARS < <(find "$SQUASHFS_DIR" -type f -name "*.rootfs.tar" -print0)
((${#ROOTFS_TARS[@]} > 0)) || die "no *.rootfs.tar found in bundle; cannot extract licenses."
((${#ROOTFS_TARS[@]} == 1)) ||
    die "multiple *.rootfs.tar files found; refusing to choose one implicitly."
ROOTFS_TAR="${ROOTFS_TARS[0]}"
verbose "Found rootfs archive: $ROOTFS_TAR"
verify_rootfs "$ROOTFS_TAR"

echo "=== Step 4: Listing license files in rootfs tar ==="
verbose "Searching the rootfs archive below ./$LICENSE_PATH/"
tar -tf "$ROOTFS_TAR" --wildcards "*/$LICENSE_PATH/*" 2>/dev/null | sort

echo ""
echo "=== Step 5: Extracting license files to $LICENSES_DIR ==="
mkdir -p "$LICENSES_DIR"
verbose "Resolving tar hardlinks and copying license files into a flat directory"
# The license files are hardlinks in the tar (content-deduplicated by the Yocto recipe).
# Plain tar extraction breaks hardlinks when stripping path components, so we use Python
# to resolve each hardlink back to its content and write a plain copy.
python3 - "$ROOTFS_TAR" "$LICENSES_DIR" "./$LICENSE_PATH/" <<'PYEOF'
import sys, os, shutil, tarfile

tar_path, out_dir, prefix = sys.argv[1], sys.argv[2], sys.argv[3]
extracted = {}  # archive path -> extracted file path

with tarfile.open(tar_path, 'r') as tf:
    count = 0
    for member in tf.getmembers():
        if not member.name.startswith(prefix) or member.isdir():
            continue
        dest = os.path.join(out_dir, os.path.basename(member.name))
        if member.islnk():
            link_key = './' + member.linkname if not member.linkname.startswith('./') else member.linkname
            if link_key in extracted:
                shutil.copy2(extracted[link_key], dest)
            else:
                f = tf.extractfile(tf.getmember(member.linkname))
                with open(dest, 'wb') as fh:
                    fh.write(f.read())
        else:
            f = tf.extractfile(member)
            with open(dest, 'wb') as fh:
                fh.write(f.read())
        extracted[member.name] = dest
        count += 1
    print(f"Extracted {count} files")
PYEOF

COUNT=$(find "$LICENSES_DIR" -maxdepth 1 -type f | wc -l)
echo "$COUNT license files in: $LICENSES_DIR"
echo ""

echo "=== GPLv3 / LGPLv3 files still present ==="
find "$LICENSES_DIR" -maxdepth 1 -type f \( -name "*GPL-3*" -o -name "*LGPL-3*" \) | sort

echo ""
echo "Done. Review license files in: $LICENSES_DIR"
