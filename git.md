# Cheatsheet for git

## quick git stats: LoC per author
    export LC_ALL='C'  
    git ls-tree -r HEAD | sed -re 's/^.{53}//' | while read filename; do file "$filename"; done | grep -E ': .*text' | sed -r -e 's/: .*//' | while read filename; do git blame -w "$filename"; done | sed -r -e 's/.*\((.*)[0-9]{4}-[0-9]{2}-[0-9]{2} .*/\1/' -e 's/ +$//' | sort | uniq -c

## Commits per author (requires proper mailmap)
    git shortlog -sne --no-merges
    
### ... and since a certain date for "me"
```
git shortlog -sne --no-merges --since="2020-09-01" | grep Petrick
42  Marcel Petrick <mpetrick@___.com>
```

## Create shortlog with all tickets between certain tags (early to later)
```
$ git log --pretty=oneline --abbrev-commit v1.11.2..v1.11.3
```

## list all tags
```
git tag -l
```

## Amount of changes (lines and which files) in the last commit
```
git show HEAD --stat
```

## Clean whitespace before pushing
```
git diff --name-only HEAD~1 HEAD | parallel --bar ../removeTrailing.sh
```

## Reset the state of the repo and get rid of all unversioned files (build artifacts)
```
git clean -xfd
git reset --hard
```

## Push the current commit to /refs/for/master
    git push --porcelain --progress origin refs/heads/master:refs/for/master

## Fix tracked branch (within the current repo) - local one equal to remote, but not tracked (before)
    $ git branch -u origin/Task3917  
    Branch 'Task3917' set up to track remote branch 'Task3917' from 'origin'.

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

## List all files of certain type in the repo
```git ls-files '*.svg'```

## Count the amount of commits between certain commits/tags
```
$ git rev-list --count v00.01.182 ^v00.00.167
15
```

## list all existing branches (just remote) with author and change date
```
git for-each-ref --format='%(committerdate) %09 %(authorname) %09 %(refname)' | sort -k5n -k2M -k3n -k4n | grep "/origin/"
```

## size of the repo itself (excluding files, which are maybe just compilation artifacts)
```
du -sh .git
```

## LFS (large file system): fix the mini-file-sizes
```bash
cd <repository-directory>
git lfs install
git lfs pull
```

## push without changes
```bash
git commit --amend --no-edit
git push --force
```

## Prevent that additional changes to a file are appearing in the change list (and then get committed)
```bash
git update-index --assume-unchanged config.ini
```
## Determine where the current branch branched from `development` and then create a patchfile (from head to that point) - output to stdout
```bash
git diff "$(git merge-base $(git rev-parse --abbrev-ref HEAD) development)" HEAD   
```
