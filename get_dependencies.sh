#! /bin/bash
if [[ -z $1 ]]; then
	echo "Repo URL not provided... Exiting"
	exit 1
fi

if [[ -z $2 ]]; then 
	echo "ID for CSV row not provided... Exiting"
	exit 1
fi

if [[ -z $3 ]]; then
	echo "No file extension file, not using Jinja2 template."
fi
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
tf_dir=($(find . -type f -name "terraform.tf$3" | xargs dirname))
for elem in ${tf_dir[@]}; do

	possible_dep_array=( $(cat "$tf_dir/terraform.tf$3" | grep 'data "terraform_remote_state"' | awk '{print $3}' | sed -e 's/^"//' -e 's/"$//') )
	for dep in ${possible_dep_array[@]}; do 
		grep -r "data.terraform_remote_state.$dep" .
		if [[ $? -eq 0 ]]; then
			actual_dep=$(grep -A 11 "data \"terraform_remote_state\" \"$dep\"" "$tf_dir/terraform.tf$3" | grep " key " | tr '/' '\n' | tail -n 1 |  cut -f 1 -d '.')
			actual_dependencies="$actual_dependencies$actual_dep:"
		else
		  echo "Cannot find usage of \"$dep\" in repo \"$repo_name\" - this can be removed from the repo."
		  echo "$repo_name: $dep" >> unused_terraform_state_imports.txt
		fi

	done

done

cd ../../
actual_dependencies=${actual_dependencies::-1}
rm -rf current_repo
echo "$2,$repo_name,$actual_dependencies" >> deps.csv

