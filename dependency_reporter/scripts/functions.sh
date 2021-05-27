#! /bin/bash

function check_argument() {
  argument="$1"
  message="$2"
  continue_on_fail="$3"

  if [[ -z $argument ]]; then
    echo $message
    $continue_on_fail || exit 1
  fi
}

function get_dependencies(){
  github_url="$1"
  id="$2"
  tf_file_ext="$3"
  config_file="$4"

  for repo in $config_file; do
    source ./scripts/get_dependencies.sh "$github_url/$repo.git" "$id" "$tf_file_ext"
    id=$(( $id + 1 ))
  done
}
