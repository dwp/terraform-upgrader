#! /bin/bash
# script requires one argument (github org name) and can be supplied a second argument for enterprise repo link.

id=0
# set up csv file with column names for Neo4J
echo "Id,repoName,Dependencies" > ./deps.csv

# loop through opensouce github repos, with supplied org, and repos provided in config file
while IFS= read -r line; do
    source ./get_dependencies.sh "https://www.github.com/$1/$line.git" $id ".j2"
    id=$(( $id + 1 ))
done < open_source_repos.txt

# loop through enterprise github repos if provided
if [[ -z $2 ]]; then
	echo "Enterprise URL not provided... Exiting"
	exit 1
else
  while IFS= read -r line; do
    source ./get_dependencies.sh "$2/$line.git" $id
    id=$(( $id + 1 ))
  done < enterprise_repos.txt
fi



