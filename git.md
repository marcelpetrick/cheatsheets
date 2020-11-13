# Cheatsheet for git

## quick git stats: LoC per author
export LC_ALL='C'  
git ls-tree -r HEAD | sed -re 's/^.{53}//' | while read filename; do file "$filename"; done | grep -E ': .*text' | sed -r -e 's/: .*//' | while read filename; do git blame -w "$filename"; done | sed -r -e 's/.*\((.*)[0-9]{4}-[0-9]{2}-[0-9]{2} .*/\1/' -e 's/ +$//' | sort | uniq -c

## Commits per author (requires proper mailmap)
git shortlog -sne --no-merges

## Create shortlog with all tickets on the current releasebranch
git log --pretty=oneline --abbrev-commit RC0..HEAD > releaseTickets.txt

## Amount of changes (lines and which files) in the last commit
git show HEAD --stat

## Clean whitespace before pushing
git diff --name-only HEAD~1 HEAD | parallel --bar ../removeTrailing.sh

## Reset the state of the repo and get rid of all unversioned files (build artifacts)
git clean -xfd
git reset --hard

## Push the current commit to /refs/for/master
git push --porcelain --progress origin refs/heads/master:refs/for/master

## Create a patch (file) of the last commit
$ git format-patch -n HEAD^
output: 0001-test_sdk_core-added-missing-checks-for-different-SDK.patch

## Check and apply patch file

### See what would be changed
$ git apply --stat ../LumiSuite_clean/0001-fakename.patch
 > .../Test/fakename/fakename.cpp             |   28 +++++++++++---------  
 > 1 file changed, 16 insertions(+), 12 deletions(-)

### See if there are issues (merge conflicts)
$ git apply --check ../LumiSuite_clean/0001-fakename.patch

### Apply it finally
$ git am ../LumiSuite_clean/0001-fakename.patch
> Applying: fakename: added missing checks for different SDK-method-calls; fixed some typos


