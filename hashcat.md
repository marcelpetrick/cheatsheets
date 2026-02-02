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

* Result:
```
Session..........: hashcat
Status...........: Running
Hash.Mode........: 11600 (7-Zip)
Hash.Target......: $7z$1$19$0$$16$51c32737cb8abe238c225de946e25bcf$823...300000
Time.Started.....: Mon Feb  2 16:29:19 2026 (41 secs)
Time.Estimated...: Mon Feb  2 19:29:47 2026 (2 hours, 59 mins)
Kernel.Feature...: Pure Kernel (password length 0-256 bytes)
Guess.Mask.......: ?a?a?a?a [4]
Guess.Queue......: 4/5 (80.00%)
Speed.#01........:     7524 H/s (4.86ms) @ Accel:8 Loops:512 Thr:256 Vec:1
Recovered........: 0/1 (0.00%) Digests (total), 0/1 (0.00%) Digests (new)
Progress.........: 286720/81450625 (0.35%)
Rejected.........: 0/286720 (0.00%)
Restore.Point....: 0/857375 (0.00%)
Restore.Sub.#01..: Salt:0 Amplifier:7-8 Iteration:280576-281088
Candidate.Engine.: Device Generator
Candidates.#01...: pari -> p5FT
Hardware.Mon.#01.: Temp: 70c Util: 89% Core:1470MHz Mem:5501MHz Bus:8

$7z$1$19$0$$16$51c32737cb8abe238c225de946e25bcf$82372222$1184$1183$892bcefbeb9d144bf12a39bdb22067ed03a41ff28111d7f69d57478e5f3424b25df8b77bab00b367a8a325a97adff54093a9caf3932908ea9bf3708d0de48fd381d973ddcacb4ce9e265cbd6b3d47a9a3038698f9235e16d234e0f8addffff4bade46d220b274fa35dd9a862e0a9d95d5ac8feeb445fed656446cdf0c95869dc7841cd7b2ec2be8efa291f7c01eea3d7cbb0339801bc01f0aec8be80ea81f889aeb27318c2fa57476323239277ed248d6a9752c85ee4d4cc2be705cb0e2d40b60ae53786cb57f66b919301eab77631a2b041473d46cace52117def4cc0029c0ede9a1bfcca85e3f22d78004c873a4e2acd39a04fdd6826c1c1869ed9b37efe4260c394311cb077425ceeeb8a125eaedf50821329c389e15fd621e94f7d24a8980924e6b937346703c879bafa53fdf20a9f9c00e8941429b39377ce447a3ce0a2acb952673823c825b0a193c5849db9680a6f8ad73bb6dfa1622ebb8cd4a334402173455b80056aa04f3646f4e5daf89652f587b155bdee49df778463e77e047e6e141672af26f0949d350c6a3ea61533861d47d203f2094ffeb0706c2b5e5d780e8c2c8c2c19066e00f4c5c0cdd5f2e0413fb3b1bf78bcd82590d9ff17028b69652ae0f60bd670463c1c898f82339e5e0015ae17e76a7e6246bcd4d9fd88f4ac5b6553d03040c17aec53729279831009d0f3d46bb806d2a9fc2fca0f1d3d35f9b98ca5fd0eacf0f7f3128bebeaf2e72f18864102fc1312d2e8ed570b69e9b24f12b1cff6c24cabe25391f1e96cbe51ad8451aecbeab85e1178a64f07d7b8c2ed56cff100ca3a8186a09c8be71e8b31cd41bcf51786050d90d98e21d252ad76c1e57b1bcfa2c48e126925e0304280fe600fc4fe44c8132eaf910ef32016fe16ab745b40a2ec62dd7d3caed64a9b8e47aa41077a86835052b43ef73026c3de868f84b52f6c8c22b08055b58154416a3a9d35e546312bc1f6e640f5c3ada522c901036005544f324fa8bd14c41ad53222086ffdf32d80486d812ed23500b97d1018b998f1a7ff53079f151142251a530b514bd291a710178e8662e0e07a7de6defc9a158e48dc683dcd52d859fdbe197fb7a95ba5d09acb879b9132313d5f8184285736642acc4b73293de2129910146296c42d291df8a2b3285903d74e4a1f7683f009b455f44e5ad70df9b213a4472dff68a64c501cec58c92ac18e89fc398a4155d80073a5a20750a078b2398a0440e688714b3059041eb6a860451cfa59f563a1c6c4c6fad60021f2b4f55699ada5bd2d12d3113265c3736de5419a258b61be8446dbed6f54a320f85a16133a62a89b8ea653d18997e6d67d62620741a663c76ba7261b84cfa01982744ed811f634e4732ab3f02289b41bced9fe35c5e531ab0a3c2115d3c9411b23b8035b162b949f41fd58ef393a1bf328163a5279ee7d650f9b08c84cbcd4e5f4e31e8a99c0adda2e3651062199a7fdec3d0b134365dd895dabbde2c51de048558af6fcb5e718e9b858c9b1876651d395d268f19c0e0085d66f7c33e81aadb3157054feda5884eb65ad0210a2575a92071b89fa5e1bf10cb7b2d122d221eb34bc6cb2805d613d43c4bedd09f9f379dc66ce8dfea6db2b293bb4350fd5ac810bd5b593a78b02e770b4cfaf799c9d2ef6dbe779f573458be2$9838$5d00300000:eeti
                                                          
Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 11600 (7-Zip)
Hash.Target......: $7z$1$19$0$$16$51c32737cb8abe238c225de946e25bcf$823...300000
Time.Started.....: Mon Feb  2 16:29:19 2026 (1 min, 54 secs)
Time.Estimated...: Mon Feb  2 16:31:13 2026 (0 secs)
Kernel.Feature...: Pure Kernel (password length 0-256 bytes)
Guess.Mask.......: ?a?a?a?a [4]
Guess.Queue......: 4/5 (80.00%)
Speed.#01........:     7534 H/s (4.89ms) @ Accel:8 Loops:512 Thr:256 Vec:1
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 860160/81450625 (1.06%)
Rejected.........: 0/860160 (0.00%)
Restore.Point....: 0/857375 (0.00%)
Restore.Sub.#01..: Salt:0 Amplifier:20-21 Iteration:523776-524288
Candidate.Engine.: Device Generator
Candidates.#01...: eari -> e5FT
Hardware.Mon.#01.: Temp: 73c Util: 90% Core:1470MHz Mem:5501MHz Bus:8

Started: Mon Feb  2 16:25:05 2026
Stopped: Mon Feb  2 16:31:14 2026
    ~/Downloads/crack_7zip 
```
