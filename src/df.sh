#!/bin/bash

git_df() {
    "$GIT_PROGRAM" --git-dir="$GIT_DIR" --work-tree="$WORK_TREE" "$@"
    return "$?"
}

debug() {
    [ -n "$DEBUG" ] && echo_e "DEBUG: $*"
}

require_repo() {
    [ -d "$GIT_DIR" ] || error_exit "Git repo at '$GIT_DIR' does not exist"
}

require_git() {
    command -v "$GIT_PROGRAM" &>/dev/null ||
        error_exit "Git cannot be located by invoking '$GIT_PROGRAM'"
}

error_exit() {
    echo "Error: $*" >&2
    exit 1
}

ensure_up_to_date() {
    git_df fetch --all --prune
    git_df branch -r | grep -v '\->' | while read remote; do
        git_df branch --track "${remote#origin/}" "$remote"
    done

    for remote_branch in $(git branch -r | grep -v '\->'); do
        local_branch=${remote_branch#origin/}

        if [ "$local_branch" = "$MAIN_BRANCH" -o "$local_branch" = "$MAIN_BRANCH"]; then
            # handle main
            if git show-ref --quiet refs/heads/"$local_branch"; then
                local_commit=$(git rev-parse "$local_branch")
                remote_commit=$(git rev-parse "$remote_branch")

                if [ "$local_commit" != "$remote_commit" ]; then
                    error_exit "Local branch '$local_branch' is not up-to-date with '$remote_branch', could be ahead or behind"
                fi
            else
                error_exit "No local branch tracking '$remote_branch'"
            fi
        # elif [ "$local_branch" = "$current_branch" ]; then
        #     # handle this machine's branch
        # else [ ]; then
        # handle other machine's branches
        fi

    done
}

stop_if_on_main() {
    [ "$(git_df rev-parse --abbrev-ref HEAD)" = "$MAIN_BRANCH" ] && error_exit "HEAD is on $MAIN_BRANCH, switch to machine branch and try again"
}

git_command() {
    require_repo
    debug "Running git command $GIT_PROGRAM $*"
    git_df "$@"
    return "$?"
}

function help() {

    local msg
    IFS='' read -r -d '' msg <<EOF
help will go here
EOF
    printf '%s\n' "$msg"
    exit
}

main() {
    require_git
    require_repo

    # parse command line arguments
    local retval=0
    internal_commands="^(commit|help|--help)$"
    if [ -z "$*" ]; then
        # no argumnts will result in help()
        help
    elif [[ "$1" =~ $internal_commands ]]; then
        # for internal commands, process all of the arguments
        DFSH_COMMAND="${1//-/_}"
        DFSH_COMMAND="${DFSH_COMMAND/__/}"
        DFSH_ARGS=()
        shift
        $DFSH_COMMAND "${DFSH_ARGS[@]}"
    else
        # any other commands are simply passed through to git
        git_command "$@"
        retval="$?"
    fi
}

set -eEuo pipefail
trap 'echo "Error occurred at line $LINENO"' ERR
DEBUG=1

# GIT_DIR="$HOME/.cfg"
# WORK_TREE="$HOME/sandbox/dotfiles-repo"
GIT_DIR="$HOME/sandbox/dotfiles-repo/.git"
WORK_TREE="$HOME/sandbox/dotfiles-repo"
MAIN_BRANCH="main"
BRANCH="$(git_df rev-parse --abbrev-ref HEAD)"
GIT_PROGRAM="git"

main "$@"
