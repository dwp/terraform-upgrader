#! /bin/bash

if [[ -z $1 ]]; then
	echo "Repo URL not provided... Exiting"
	exit 1
fi

REPO_LOCATION=$1
export REPO_LOCATION

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

last_commit=$(git log -n 1 master | grep commit | awk '{print $2}')
tf_dirs=$(find . -name '*.tf' | xargs -n1 dirname | sort | uniq)

git checkout -b upgrade13 || {
	echo "updgrade13 branch already exists for $repo_name... Exiting"
	exit 1
}

# look in concourse dir for version and replace
if [[ -d "./ci" ]]; then
	grep -rl 'terraform_version' ./ci | xargs sed -i 's/terraform_version/terraform_13_version/g'
	grep -rl '0.12.9' ./ci | xargs sed -i 's/0\.12\.9/\(\(dataworks.terraform_version\)\)/g'
fi

# look in github actions dir for version and replace
if [[ -d "./.github/workflows" ]]; then
	grep -rl 'tf_actions_version' ./.github/workflows | tee >(sed -i 's/0\.12\.9/0\.13\.0/g') >(sed -i 's/terraform_version/terraform_13_version/g')
fi

# look in tf for mentions of versions, run tf update command and replace tf 11 syntax
for dir in $tf_dirs; do
	terraform 0.13upgrade -yes $dir
	start_dir=$(pwd)
	cd $dir
	grep -rl 'required_version' . | tee >(sed -i  's/0\.12\.9/0\.\13\.0/g') >(sed -i  's/terraform_12_version/terraform_13_version/g')
	tf_files=$(find . -type f -name '*.tf')
	for file in $tf_files; do
	  # find all files with HereDocs being used to avoid invalid substitutions
		eof_locations=$(cat $file | grep '<<[A-Z]*')
		# if files don't have HereDocs, replace all tf 11 syntax
		if [[ $? -eq 1 ]]; then
			perl -pi -e 's!\"\$\{([^\}]+?)\}\"!\1!' $file # tf11 = "${<anything>}" -> tf12+ = <anything>
		else
		  # if there are HereDocs used in the file, read it line by line and replace tf 11 syntax in swap file
			touch swap.txt
			# flag for HereDoc blocks
			eof_block=false
			IFS=''; while read -r line; do
				check_here_doc=$(echo "$line" | perl -ne 'print if s!<<([A-Z]+)!\1!' | awk '{print $NF}')
				if [[ "$check_here_doc" != "" ]]; then
					here_doc="$check_here_doc"
				fi
			 	echo "$line" | grep here_doc
			 	if [[ $? -eq 0 ]] || [[ here_doc != "" ]]; then
			 		echo "$line" >> swap.txt
			 		if [[ eof_block ]]; then
			 			eof_block=false
			 		else
			 			eof_block=true
			 		fi
				elif [[ eof_block ]]; then
					echo "$line" >> swap.txt
				else
					echo $(echo "$line" | perl -pi -e 's!\"\$\{([^\}]+?)\}\"!\1!') >> swap.txt
				fi
			done <$file
			mv swap.txt $file
		fi
	done
	cd $start_dir
done

terraform fmt -recursive

git add .
git commit -m "upgrade13"
git diff
git push -u origin upgrade13
git request-pull $last_commit $REPO_LOCATION master

cd ../../
rm -rf ./current_repo
