#!/usr/bin/env bash

# avoid double inclusion
if test "${BashInclude__gflow_changelog__imported+defined}" == "defined"
then
    return 0
fi
BashInclude__gflow_changelog__imported=1

function gflow_create_changelog {
    gflow_config_read_current_project_version
    create_temp_changelog_file || return $FALSE
    git add .
    git commit -m"Create Changelog for this new branch"
}

function create_temp_changelog_file {
  create_file "$temp_changelog_file"
  # Todo: create changelogs folder to through each branch changelog in it.
     echo "
## Changelog For [$current_branch] | From ($(date +%F_%H:%M:%S)) To () - ***Unreleased***
Items in this change log will be added to your commit message by default

### Added
[A]-   
[A]-   
[A]-  
[A]-  

### Changed
[C]-   
[C]-  
[C]-  
[C]-  

### Removed
[R]-   
[R]-  
[R]-  
[R]-  

### Deprecated
[D]-   
[D]-  
[D]-  
[D]-  

### Fixed
[F]-  
[F]-  
[F]-  
[F]-  

### Security
[S]-  
[S]-  
[S]-  
[S]-  
         
    " > $temp_changelog_file || return 1
}

function does_temp_changelog_exists {
    if [ -e "$temp_changelog_file" ]; then
        return 0
    else
        return 1
    fi
}

