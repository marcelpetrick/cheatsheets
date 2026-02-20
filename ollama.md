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
