from get_dependencies import RepoDependencies
import os, copy, json, itertools


def recursive(dep_dict, tuple, seen=[]):
    circles = []
    if tuple[0] in seen:
        circles.append(seen[seen.index(tuple[0]) :])
        seen = []
    else:
        seen.append(tuple[0])
        if tuple[1]:
            for item in tuple[1]:
                circles.extend(
                    recursive(dep_dict, [item, dep_dict.get(item)], seen.copy())
                )
    return circles


def do_logic(dep_dict):
    circles = []
    for key in dep_dict:
        circles.extend(recursive(dep_dict, [key, dep_dict[key]], []))
    circles.sort()
    with open("reports/output.json", "w") as output:
        json.dump(list(k for k, _ in itertools.groupby(circles)), output)


def main():
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
        print("No open source repos provided.")
        os_repos_list = []

    if enterprise_repos:
        print(f"enterprise_repos: {enterprise_repos}")
        if not enterprise_org:
            raise EnvironmentError("No github enterprise org name provided")
        if not enterprise_url:
            raise EnvironmentError("No enterprise URL provided")
        enterprise_repos_list = enterprise_repos.split(" ")
    else:
        print("No enterprise source repos provided.")
        enterprise_repos_list = []

    repo_deps = RepoDependencies()

    for repo in os_repos_list:
        repo_deps.add_repo(repo, "www.github.com", os_org, ".tf.j2")

    for repo in enterprise_repos_list:
        repo_deps.add_repo(repo, enterprise_url, enterprise_org, ".tf", True)

    dep_dict = repo_deps.get_dependencies()
    do_logic(dep_dict)


if __name__ == "__main__":
    main()
