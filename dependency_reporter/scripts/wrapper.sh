#! /bin/bash

# script requires one argument - the base URL of the enterprise github account
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

check_argument $enterprise_url "Enterprise URL not provided... Exiting"

id=0
# set up csv file with column names for Neo4J
echo "Id,repoName,Dependencies" > ./deps.csv

# loop through opensouce github repos, provided in config file
get_dependencies "https://www.github.com/dwp" $id ".tf.j2" "$opensource_repo_list"

# loop through enterprise github repos, provided in config file
get_dependencies "$1" $id ".tf" "$enterprise_repo_list"

# Call python script to pass csv & queries to Neo4J container
python "${APP_HOME}/graph.py"