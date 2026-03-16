# Hints to run ollama

## Simple benchmark
```
ollama run --verbose llama3.1:8b "Write exactly 1000 tokens about GPUs."
```
 
Mit Nvidia A2000:
```
total duration:       24.781038176s
load duration:        118.372805ms
prompt eval count:    19 token(s)
prompt eval duration: 31.467443ms
prompt eval rate:     603.80 tokens/s
eval count:           633 token(s)
eval duration:        24.167125058s
eval rate:            26.19 tokens/s
```

## problem running Qwen3.5 models - update ollama itself; not managed by package managers
```
   ~  ollama run --verbose qwen3.5:9b "Write exactly 1000 tokens about GPUs."                                                                                                                                                                                                      ✔ 

pulling manifest 
Error: pull model manifest: 412: 
The model you are attempting to pull requires a newer version of Ollama.

Please download the latest version at:

        https://ollama.com/download

    ~  ollama --version                                                                                                                                                                                                                                                        1 ✘ 
ollama version is 0.14.3
    ~  curl -fsSL https://ollama.com/install.sh | sh                                                                                                                                                                                                                             ✔ 
>>> Cleaning up old version at /usr/local/lib/ollama
[sudo] password for mpetrick: 
>>> Installing ollama to /usr/local
>>> Downloading ollama-linux-amd64.tar.zst
######################################################################## 100.0%
>>> Adding ollama user to render group...
>>> Adding ollama user to video group...
>>> Adding current user to ollama group...
>>> Creating ollama systemd service...
>>> Enabling and starting ollama service...
>>> NVIDIA GPU installed.
    ~  ollama --version                                                                                                                                                                                                                                               ✔  1m 45s  
ollama version is 0.17.5
    ~  ollama run --verbose qwen3.5:9b "Write exactly 1000 tokes about GPU" 
```

## log analysis possible?
* `ollama run --verbose qwen3.5:0.8b "$(journalctl -n 20 --no-pager -o short-iso | sed 's/"/\\"/g' | awk 'BEGIN{print "Analyze the following journalctl logs. Identify errors or warnings. If everything looks normal, explicitly state that no issues are detected.\n\nLogs:\n"} {print}')"`
  *  does never finish - neither with 20 or 5 lines ..
