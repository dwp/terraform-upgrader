#! /bin/bash

# script requires one argument - the base URL of the enterprise github account
source ./scripts/functions.sh

check_argument $enterprise_url "Enterprise URL not provided... Exiting"

id=0
# set up csv file with column names for Neo4J
echo "Id,repoName,Dependencies" > ./deps.csv

# loop through opensouce github repos, provided in config file
get_dependencies "https://www.github.com/dwp" $id ".tf.j2" "$opensource_repo_list"

# loop through enterprise github repos, provided in config file
get_dependencies "$1" $id ".tf" "$enterprise_repo_list"

# Call python script to pass csv & queries to Neo4J container
#python ./graph.py
