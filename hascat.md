## hashcat.md

## How to get it running?

* todo!
  * install hashcat and the perl and the lzma lib
  * the wordlist are still missing
  


## output
```
   ~/Downloads/crack_7zip  hashcat -m 11600 -a 3 toCrack.7z.hash '?a?a?a?a?a' --increment --increment-min=1 --increment-max=5                                                                                                                                      2 ✘  2m 11s  

hashcat (v7.1.2) starting

This hash-mode is known to emit multiple valid candidates for the same hash.
Use --keep-guessing to continue attack after finding the first crack.

nvmlDeviceGetFanSpeed(): Not Supported

CUDA API (CUDA 13.1)
====================
* Device #01: NVIDIA RTX A2000 8GB Laptop GPU, 7747/7844 MB, 20MCU

OpenCL API (OpenCL 3.0 CUDA 13.1.112) - Platform #1 [NVIDIA Corporation]
========================================================================
* Device #02: NVIDIA RTX A2000 8GB Laptop GPU, skipped

This hash-mode is known to emit multiple valid candidates for the same hash.
Use --keep-guessing to continue attack after finding the first crack.

Minimum password length supported by kernel: 0
Maximum password length supported by kernel: 256
Minimum salt length supported by kernel: 0
Maximum salt length supported by kernel: 256

Hashes: 1 digests; 1 unique digests, 1 unique salts
Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates

Optimizers applied:
* Zero-Byte
* Single-Hash
* Single-Salt
* Brute-Force

ATTENTION! Pure (unoptimized) backend kernels selected.
Pure kernels can crack longer passwords, but drastically reduce performance.
If you want to switch to optimized kernels, append -O to your commandline.
See the above message to find out about the exact limits.

Watchdog: Temperature abort trigger set to 90c

Host memory allocated for this attack: 2336 MB (20891 MB free)

The wordlist or mask that you are using is too small.
This means that hashcat cannot use the full parallel power of your device(s).
Hashcat is expecting at least 61440 base words but only got 0.0% of that.
Unless you supply more work, your cracking speed will drop.
For tips on supplying more work, see: https://hashcat.net/faq/morework

Approaching final keyspace - workload adjusted.           

Session..........: hashcat                                
Status...........: Exhausted
Hash.Mode........: 11600 (7-Zip)
Hash.Target......: $7z$1$19$0$$16$51c32737cb8abe238c225de946e25bcf$823...300000
Time.Started.....: Mon Feb  2 16:25:06 2026 (46 secs)
Time.Estimated...: Mon Feb  2 16:25:52 2026 (0 secs)
Kernel.Feature...: Pure Kernel (password length 0-256 bytes)
Guess.Mask.......: ?a [1]
Guess.Queue......: 1/5 (20.00%)
Speed.#01........:        2 H/s (0.18ms) @ Accel:3 Loops:256 Thr:1024 Vec:1
Recovered........: 0/1 (0.00%) Digests (total), 0/1 (0.00%) Digests (new)
Progress.........: 95/95 (100.00%)
Rejected.........: 0/95 (0.00%)
Restore.Point....: 1/1 (100.00%)
Restore.Sub.#01..: Salt:0 Amplifier:94-95 Iteration:524032-524288
Candidate.Engine.: Device Generator
Candidates.#01...: $HEX[20] -> $HEX[20]
Hardware.Mon.#01.: Temp: 61c Util: 81% Core:1762MHz Mem:5501MHz Bus:8

The wordlist or mask that you are using is too small.
This means that hashcat cannot use the full parallel power of your device(s).
Hashcat is expecting at least 40960 base words but only got 0.2% of that.
Unless you supply more work, your cracking speed will drop.
For tips on supplying more work, see: https://hashcat.net/faq/morework

Approaching final keyspace - workload adjusted.           

[s]tatus [p]ause [b]ypass [c]heckpoint [f]inish [q]uit => 

```
