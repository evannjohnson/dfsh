a dotfiles tool

structure of the script is inspired by yadm

# added commands
- `ls`: lists tracked files under the current directory
  - `--all`: list all files instead of under current dir
    - like `cd`ing to `$DFSH_WORK` and running `dfsh ls`
  - `--untracked`: list untracked files instead of tracked files 

# tasks
Script implemented as a wrapper for git that demonstrates how to add new commands and wrap existing ones to modify their functionality. Very little additional functionality present at this point.

to do:
- [ ] commit onto main and pull changes into machine branch without affecting working tree
  - do this by copying files, doing git operations in the copy
- [ ] document script in the README
- [ ] write help output
