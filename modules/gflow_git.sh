#!/usr/bin/env bash

# avoid double inclusion
if test "${BashInclude__gflow_git__imported+defined}" == "defined"
then
    return 0
fi
BashInclude__gflow_git__imported=1

readonly snapshot_branch="$(git symbolic-ref --short -q HEAD)"

if [ -z "$(git status --porcelain)" ]; then 
    readonly snapshot_has_changes=false
else
    readonly snapshot_has_changes=true
fi  
  
current_branch="$snapshot_branch"
is_changes_stashed=false

function gflow_load_snapshopt {
  git checkout "$snapshot_branch"
  gflow_load_if_stashed
}

function gflow_stash_changes {
  if [ $snapshot_has_changes = true ]; then
    git stash save -u # to stash untracked files
    is_changes_stashed=true
  fi
}

function gflow_load_if_stashed {
  if [ $is_changes_stashed = true ]; then
        do_load_stashed        
  fi     
}

function do_load_stashed {
     git stash apply # apply the last stash without deleting it
     is_changes_stashed=false
}