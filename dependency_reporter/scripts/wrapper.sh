#! /bin/bash

# script requires one argument - the base URL of the enterprise github account
source ./scripts/functions.sh

check_argument $ENTERPRISE_URL "Enterprise URL not provided... Exiting"

export GIT_SSL_NO_VERIFY=1

id=0
# set up csv file with column names for Neo4J
echo "Id,repoName,Dependencies" > ./reports/deps.csv

# loop through opensouce github repos, provided in config file
get_dependencies "https://www.github.com/dwp" $id ".tf.j2" "$OPENSOURCE_REPO_LIST"

# loop through enterprise github repos, provided in config file
get_dependencies "https://$USERNAME:$GITHUB_ENTERPRISE_PAT@$ENTERPRISE_URL" $id ".tf" "$ENTERPRISE_REPO_LIST"

# Call python script to pass csv & queries to Neo4J container
python ./scripts/graph.py
