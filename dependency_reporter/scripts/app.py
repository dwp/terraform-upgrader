from get_dependencies import RepoDependencies
from dep_resolve import Node, dep_resolve, ANSIColors
import os

def main():
    enterprise_url = os.getenv('ENTERPRISE_URL')
    os_repos = os.getenv('OPENSOURCE_REPO_LIST')
    enterprise_repos = os.getenv('ENTERPRISE_REPO_LIST')
    os_org = os.getenv('GITHUB_ORG')
    enterprise_org = os.getenv('ENTERPRISE_ORG')

    if os_repos:
        if not os_org:
            raise EnvironmentError('No github.com org name provided')
        os_repos_list = os_repos.split(' ')
    else:
        print('No open source repos provided.')
        os_repos_list = []

    if enterprise_repos:
        print(f'enterprise_repos: {enterprise_repos}')
        if not enterprise_org:
            raise EnvironmentError('No github enterprise org name provided')
        if not enterprise_url:
            raise EnvironmentError('No enterprise URL provided')
        enterprise_repos_list = enterprise_repos.split(' ')
    else:
        print('No enterprise source repos provided.')
        enterprise_repos_list = []

    repo_deps = RepoDependencies()

    for repo in os_repos_list:
        print(f'repo = {repo}')
        repo_deps.add_repo(repo, 'www.github.com', os_org, '.tf.j2')

    for repo in enterprise_repos_list:
        repo_deps.add_repo(repo, enterprise_url, enterprise_org, '.tf', True)

    dependency_dict = repo_deps.get_dependencies()
    nodes = {}
    for repo in dependency_dict:
        dependencies = dependency_dict[repo]
        node = Node(repo)
        node.raw_edges = dependencies
        nodes[repo] = node

    for k, v in nodes.items():
        if len(v.raw_edges) != 0:
            for e in v.raw_edges:
                edge = nodes.get(e)
                if edge:
                    v.add_edge(edge)

        resolve = []
    for node in nodes.values():
        seen = []
        print("-----------------------------")
        if node.edges:
            dep_resolve(node, resolve, seen)
        else:
            print(f"{ANSIColors.SUCCESS}{node.name} is orphan.{ANSIColors.RESET}")
        print("-----------------------------")
        print("\n")


if __name__ == "__main__":
    main()
