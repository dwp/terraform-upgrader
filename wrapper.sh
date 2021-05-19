#! /bin/bash
if [[ -z $1 ]]; then
	echo "Enterprise URL not provided... Exiting"
	exit 1
fi
id=0
echo "Id,repoName,Dependencies" > ./deps.csv
while IFS= read -r line; do
    source ./get_dependencies.sh "https://www.github.com/dwp/$line.git" $id ".j2"
    id=$(( $id + 1 ))
done < open_source_repos.txt
while IFS= read -r line; do
    source ./get_dependencies.sh "$1/$line.git" $id
    id=$(( $id + 1 ))
done < enterprise_repos.txt

