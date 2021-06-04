import os
import json
import logging

from finder.get_dependencies import RepoDependencies
from finder.find_circular_dependencies import *


def main():
    logging.debug("Terraform-upgrader starts")
    enterprise_url = os.getenv("ENTERPRISE_URL")
    os_repos = os.getenv("OPENSOURCE_REPO_LIST")
    enterprise_repos = os.getenv("ENTERPRISE_REPO_LIST")
    os_org = os.getenv("GITHUB_ORG")
    enterprise_org = os.getenv("ENTERPRISE_ORG")

    if os_repos:
        if not os_org:
            raise EnvironmentError("No github.com org name provided")
        os_repos_list = os_repos.split(" ")
    else:
        logging.debug("No open source repos provided.")
        os_repos_list = []

    if enterprise_repos:
        if not enterprise_org:
            raise EnvironmentError("No github enterprise org name provided")
        if not enterprise_url:
            raise EnvironmentError("No enterprise URL provided")
        enterprise_repos_list = enterprise_repos.split(" ")
    else:
        logging.debug("No enterprise source repos provided.")
        enterprise_repos_list = []

    repo_deps = RepoDependencies()

    for repo in os_repos_list:
        repo_deps.add_repo(repo, "www.github.com", os_org, ".tf.j2")

    for repo in enterprise_repos_list:
        repo_deps.add_repo(repo, enterprise_url, enterprise_org, ".tf", True)

    dep_dict = repo_deps.get_dependencies()
    circles_without_duplicates = find_circular_dependencies(dep_dict)
    with open("reports/circular_dependencies.json", "w") as output:
        json.dump(circles_without_duplicates, output)
    logging.debug("Terraform-upgrader has completed without errors")


if __name__ == "__main__":
    main()
