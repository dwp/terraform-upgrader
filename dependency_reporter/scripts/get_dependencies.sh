#! /bin/bash

source ./scripts/functions.sh

check_argument $1 "Repo URL not provided... Exiting"
check_argument $2 "ID for CSV row not provided... Exiting"
check_argument $3 "No file extension file, not using Jinja2 template." true

REPO_LOCATION=$1
mkdir ./current_repo
cd ./current_repo

{
	git clone "$REPO_LOCATION"
} || {
	echo "Repo not available at $REPO_LOCATION"
	exit 1
}

repo_name=$(ls)
cd $repo_name
actual_dependencies=""
# find all directories that have tf config files
tf_dir=( $(for i in $(find . -type f -name "terraform${3}"); do echo $i | sed -e 's/terraform'${3}'//'; done) )

# loop through tf config directories and search for remote states imported to identify cross repo dependencies
for elem in ${tf_dir[@]}; do
  # get tf names for all remote state imports
	possible_dep_array=( $(cat "$tf_dir/terraform$3" | grep 'data "terraform_remote_state"' | awk '{print $3}' | sed -e 's/^"//' -e 's/"$//') )
	for dep in ${possible_dep_array[@]}; do
	  # grep for uses of the imports in tf codebase
		grep -r "data.terraform_remote_state.$dep" .
		if [[ $? -eq 0 ]]; then
		  # get actual repo name from state lookup, if it is being used
			actual_dep=$(grep -A 11 "data \"terraform_remote_state\" \"$dep\"" "$tf_dir/terraform$3" | grep " key " | tr '/' '\n' | tail -n 1 |  cut -f 1 -d '.')
			# add to csv row string to be used by Neo4J
			actual_dependencies="$actual_dependencies$actual_dep:"
		else
		  # add unused dependencies to list to be removed, mapped to repo they are in
		  echo "Cannot find usage of \"$dep\" in repo \"$repo_name\" - this can be removed from the repo."
		  echo "$repo_name: $dep" >> ./reports/unused_terraform_state_imports.txt
		fi

	done

done

cd ../../
# remove trailing ':'
actual_dependencies=${actual_dependencies::-1}
rm -rf current_repo
echo "$2,$repo_name,$actual_dependencies" >> ./reports/deps.csv

