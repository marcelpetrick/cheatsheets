# Cheat sheet for bash (should work with most other shells and unix-like toolbox)

## create tree-like folder-structure (if ther is no 'tree')
```
find . | sed -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/|-\1/"
```

## show current load (periodically; 1/sec)
```
while true; do cat /proc/loadavg; sleep 1; done
```

## sort a file in place
Useful for a proper listing for the mailmap for git -.-
```
sort -o .mailmap .mailmap
```

## find a file and suppress the error messages (like 'Permission denied ..')
```
$ find / -name libSpellChecker.so 2> /dev/null
/home/mp/Documents/p118/Qt/Tools/QtCreator/lib/qtcreator/plugins/libSpellChecker.so
/home/mp/Downloads/lib/qtcreator/plugins/libSpellChecker.so
```
