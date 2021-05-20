#! /bin/bash

# script requires one argument - the base URL of the enterprise github account
if [[ -z $1 ]]; then
	echo "Enterprise URL not provided... Exiting"
	exit 1
fi


id=0
# set up csv file with column names for Neo4J
echo "Id,repoName,Dependencies" > ./deps.csv

# loop through opensouce github repos, provided in config file
while IFS= read -r line; do
    source ./get_dependencies.sh "https://www.github.com/dwp/$line.git" $id ".j2"
    id=$(( $id + 1 ))
done < open_source_repos.txt

# loop through enterprise github repos, provided in config file
while IFS= read -r line; do
    source ./get_dependencies.sh "$1/$line.git" $id
    id=$(( $id + 1 ))
done < enterprise_repos.txt

