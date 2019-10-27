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
  if [ "$snapshot_branch" != "$current_branch" ]; then
    gflow_switch_to_branch "$snapshot_branch"    
  fi
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

function gflow_switch_to_branch {
  local new_branch="$1"
  local create_if_not_exists="${2-false}"
  local checkout_from="$3"
  if [ "$create_if_not_exists" = "create" ]; then
    git checkout -b "$new_branch" $checkout_from || return 1
  else
    git checkout "$new_branch" $checkout_from || return 1
  fi
   current_branch="$new_branch"
}