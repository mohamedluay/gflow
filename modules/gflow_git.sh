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
  local branch_to_switch="$1"
  git checkout "$branch_to_switch" || return $FALSE
  current_branch="$branch_to_switch"
}

function gflow_create_branch {
  local new_branch="$1"
  local checkout_from="$2"  
  # ToDo: Ask User If he/she needs to checkout to an exisiting branch, hence won't create new changelog ... etc
  git checkout -b "$new_branch" $checkout_from || return 1    
  current_branch="$new_branch"
}

function is_protected_branch {  
  if [ "$current_branch" = "master" ] || [ "$current_branch" = "develop" ]; then
    return $TRUE
  fi
  return $FALSE
}