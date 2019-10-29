#!/usr/bin/env bash

# avoid double inclusion
if test "${BashInclude__gflow__feature_flow__imported+defined}" == "defined"
then
    return 0
fi
BashInclude__gflow__feature_flow__imported=1

function gflow_start_feature_flow {
  gflow_stash_changes &> /dev/null
  switch_to_feature_branch || return 1
  gflow_create_changelog &> /dev/null || return 1
  gflow_load_if_stashed &> /dev/null
}

function switch_to_feature_branch {
  gflow_log_highlight "What do you want to call this feature branch?"
  local feature_branch_name="$(ask_for_feature_branch_name)"
  ## Todo: check if branch name contains any restricted names  
  ## Todo: check if there is a branch with the same name exists
  gflow_create_branch $feature_branch_name develop || catch "Error Happened While Creating Your Feature Branch $feature_branch_name"
}

function ask_for_feature_branch_name {
    local __feature_branch_name
    read __feature_branch_name  
    echo "$__feature_branch_name"
}