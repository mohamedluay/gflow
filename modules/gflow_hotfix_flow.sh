#!/usr/bin/env bash

# avoid double inclusion
if test "${BashInclude__gflow__hotfix_flow__imported+defined}" == "defined"
then
    return 0
fi
BashInclude__gflow__hotfix_flow__imported=1

function gflow_start_hotfix_flow {
  gflow_stash_changes &> /dev/null
  switch_to_hotfix_branch || return $FALSE
  gflow_create_changelog &> /dev/null || return $FALSE
  gflow_load_if_stashed &> /dev/null
  true
}

function switch_to_hotfix_branch {
  gflow_switch_to_branch "master" &> /dev/null || return $FALSE
  gflow_config_read_current_project_version
  local tmp_v=("${current_project_version_array[@]}")
  ((tmp_v[2]++)) ## increment Patch version number    
  local new_version="${tmp_v[0]}.${tmp_v[1]}.${tmp_v[2]}"   
  local hotfix_branch_name="hotfix-$new_version"
  ## Todo: check if there is a branch with the same name exists
  ## Todo: make sure that the master branch is up to date!
  gflow_create_branch $hotfix_branch_name &> /dev/null || return $FALSE
  gflow_log_successful "created & switched to branch $hotfix_branch_name"
  pump_hotfix_version "$new_version" || return $FALSE
}

function pump_hotfix_version {
  local new_version="$1"
  gflow_config_pump_project_version $new_version || return $FALSE
  git add .
  git commit -m"Pump Version from $current_project_version_text to $new_version" &> /dev/null  || return $FALSE
  gflow_log_successful "Version $new_version pumped & commited"
}
