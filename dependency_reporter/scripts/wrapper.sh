#! /bin/bash

# script requires one argument - the base URL of the enterprise github account
source ./scripts/functions.sh

check_argument $ENTERPRISE_URL "Enterprise URL not provided... Exiting"

id=0
# set up csv file with column names for Neo4J
echo "Id,repoName,Dependencies" > ./reports/deps.csv

# loop through opensouce github repos, provided in config file
get_dependencies "https://www.github.com/dwp" $id ".tf.j2" "$OPENSOURCE_REPO_LIST"

# loop through enterprise github repos, provided in config file
get_dependencies "$ENTERPRISE_URL" $id ".tf" "$ENTERPRISE_REPO_LIST"

# Call python script to pass csv & queries to Neo4J container
#python ./graph.py

#verify connection to Graph DB
#while ! nc -z $NEO4J_HOST 7687; do
#  sleep 0.1
#done

pipenv install

pwd

ls -la ./scripts

pipenv run python ./scripts/graph.py
