# Cheatsheet for git

## quick git stats: LoC per author
export LC_ALL='C'  
git ls-tree -r HEAD | sed -re 's/^.{53}//' | while read filename; do file "$filename"; done | grep -E ': .*text' | sed -r -e 's/: .*//' | while read filename; do git blame -w "$filename"; done | sed -r -e 's/.*\((.*)[0-9]{4}-[0-9]{2}-[0-9]{2} .*/\1/' -e 's/ +$//' | sort | uniq -c

## Commits per author (requires proper mailmap)
git shortlog -sne --no-merges

## Create shortlog with all tickets on the current releasebranch
git log --pretty=oneline --abbrev-commit RC0..HEAD > releaseTickets.txt

## Clean whitespace before pushing
git diff --name-only HEAD~1 HEAD | parallel --bar ../removeTrailing.sh