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

  check_argument $1 "Repo URL not provided... Exiting"
  check_argument $2 "ID for CSV row not provided... Exiting"
  check_argument $3 "No file extension file, not using Jinja2 template." true
  mkdir "$APP_PATH/repos"
  # shellcheck disable=SC2164

  for repo in $config_file; do
    fetch_repo "$github_url/$repo.git"
    search_for_remotes "$repo" "$id" "$tf_file_ext"
    id=$(( $id + 1 ))
  done
}

function fetch_repo() {
  REPO_LOCATION="$1"
  echo "Fetching repo ${REPO_LOCATION}"
  # shellcheck disable=SC2164
  cd "$APP_PATH/repos"
  {
    git clone "$REPO_LOCATION"
  } || {
    echo "Repo not available at $REPO_LOCATION"
  }
}

function search_for_remotes() {
#  Search remote state entries for a given repo
  REPO_NAME=$1
  ID=$2
  TF_FILE_EXT=$3
  echo "Searching remotes for ${REPO_NAME}"
  # shellcheck disable=SC2164
  cd "$APP_PATH/repos/$REPO_NAME"
  actual_dependencies=""
  # find all directories that have tf config files
  # shellcheck disable=SC2207
  # shellcheck disable=SC2038
  tf_dir=($(find . -type f -name "terraform$3" | xargs dirname))

  # loop through tf config directories and search for remote states imported to identify cross repo dependencies
  for elem in "${tf_dir[@]}"; do
    # get tf names for all remote state imports
    # shellcheck disable=SC2207
    # shellcheck disable=SC2002
    possible_dep_array=( $(cat "$tf_dir/terraform${TF_FILE_EXT}" | grep 'data "terraform_remote_state"' | awk '{print $3}' | sed -e 's/^"//' -e 's/"$//') )
    for dep in "${possible_dep_array[@]}"; do
      # grep for uses of the imports in tf codebase
      grep -r "data.terraform_remote_state.$dep" .
      # shellcheck disable=SC2181
      if [[ $? -eq 0 ]]; then
        # get actual repo name from state lookup, if it is being used
        actual_dep=$(grep -A 11 "data \"terraform_remote_state\" \"$dep\"" "$tf_dir/terraform$3" | grep " key " | tr '/' '\n' | tail -n 1 |  cut -f 1 -d '.')
        # add to csv row string to be used by Neo4J
        actual_dependencies="$actual_dependencies$actual_dep:"
      else
        # add unused dependencies to list to be removed, mapped to repo they are in
        echo "Cannot find usage of \"$dep\" in repo \"$repo_name\" - this can be removed from the repo."
        echo "$repo_name: $dep" >> "$APP_PATH/reports/unused_terraform_state_imports.txt"
      fi
    done
  done
  # remove trailing ':'
  actual_dependencies=${actual_dependencies::-1}
  echo "Recording dependencies for $REPO_NAME. pwd $(pwd)"
  echo "${ID},$repo_name,$actual_dependencies" >> "$APP_PATH/reports/deps.csv"
}

# script requires one argument - the base URL of the enterprise github account
echo "Anything"
check_argument $enterprise_url "Enterprise URL not provided... Exiting"

id=0
# set up csv file with column names for Neo4J
echo "Id,repoName,Dependencies" > "$APP_PATH/deps.csv"

# loop through opensource github repos, provided in config file
echo "Getting dependencies github.com"
get_dependencies "https://www.github.com/dwp" $id ".tf.j2" "$opensource_repo_list"

# loop through enterprise github repos, provided in config file
echo "Getting dependencies from enterprise github"
get_dependencies "$1" $id ".tf" "$enterprise_repo_list"

# Call python script to pass csv & queries to Neo4J container

#verify connection to Graph DB
#while ! nc -z $NEO4J_HOST 7687; do
#  sleep 0.1
#done

pipenv install --quiet

pwd

ls -laR ./

#pipenv run python ./scripts/graph.py
