import os
import json
import requests

from neo4j import GraphDatabase

class RepoDependencies:
    def __init__(self, tfstate_repo_name, repo_base_url, org, file_extension, private=False):
        self._find_and_clone_repo(tfstate_repo_name, repo_base_url, org, file_extension, private)
        self.repo_name = os.listdir()[0]

    @staticmethod
    def _find_and_clone_repo(self, tfstate_repo_name, repo_base_url, org, file_extension, private):
        username = os.getEnv("USERNAME")
        pat = os.getEnv("GITHUB_ENTERPRISE_PAT")

        auth_str = f'{username}:{pat}@' if private else ''
        clone = self._create_clone_str(tfstate_repo_name, repo_base_url, org, auth_str)
        if os.system(clone) > 0:
            repo_data = requests.get(f'https://{repo_base_url}/api/v3/orgs/{org}/repos?type=all&per_page=500', auth=(username, pat)).json()
            possible_matches = [repo['name'] for repo in repo_data if tfstate_repo_name in repo['name']]
            for repo in possible_matches:
                clone = self._create_clone_str(repo, repo_base_url, org, auth_str)
                os.system(clone)
                result = [os.path.join(dp, f) for dp, dn, filenames in os.walk('./') for f in filenames if f == f'terraform{file_extension}']
                for file_path in result:
                    with open(file_path, 'r') as file:
                        data = file.read()
                    data_arr = [line.strip() for line in data.split('\n')]
                    config_object_start = data_arr.index('backend "s3" {')
                    config_object = data_arr[config_object_start:config_object_start+7]
                    s3_file_name = [s for s in config_object if ".tfstate" in s][0].split('/')[-1].split('.')[0]
                    if s3_file_name == tfstate_repo_name:
                        break
                    else:
                        os.system(f'rm -rf {repo}')
        raise ValueError(f'No repo match found for {tfstate_repo_name} in {org} remote repository.')

    @staticmethod
    def _create_clone_str(self, repo, repo_base_url, org, auth_str):
        return f'git clone https://{auth_str}{repo_base_url}/{org}/{repo}.git'



class Graph:
    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def load_repos_dependencies(self, dependencies_file_path):
        with self.driver.session() as session:
            session.write_transaction(
                self._create_repos_dependencies_as_vertices_and_edges,
                dependencies_file_path,
            )

    @staticmethod
    def _create_repos_dependencies_as_vertices_and_edges(tx, dependencies_file_path):
        tx.run(
            f""" 
                LOAD CSV WITH HEADERS FROM "file:///{dependencies_file_path}" AS row
                MERGE (parent:Repo {{repoId: row.Id, repoName: row.repoName}})
                WITH parent, row
                UNWIND split(row.Dependencies, ":") AS dependency
                MATCH (child:Repo {{repoName: dependency}})
                MERGE (parent)-[d:HAS_DEPENDENCY]->(child)
            """
        )

    def query_graph(self, query_name):
        queries = {"circular_dependencies": self._query_circular_dependencies}
        with self.driver.session() as session:
            query = queries.get(query_name)
            if query:
                return session.write_transaction(query)

    @staticmethod
    def _query_circular_dependencies(tx):
        results = []
        response = tx.run(
            f""" 
                MATCH path = (n:Repo)<-[:HAS_DEPENDENCY*]-()
                RETURN path, size((n)<--()) AS count LIMIT 25
            """
        )
        for record in response:
            print(record.data())
            # WIP: Trying to understand how to parse and return the data
            # results.append(record)
            data = record.data()
            # results.append({data.get("path")[0].get("repoName"): data.get("path")[2].get("repoName")})
        # print(results)
        return results

    def close(self):
        self.driver.close()


def main():
    enterprise_url = os.getEnv('ENTERPRISE_URL')
    os_repos = os.getEnv('OPENSOURCE_REPO_LIST')
    enterprise_repos = os.getEnv('ENTERPRISE_REPO_LIST')

    if os_repos:
        os_repos_list = os_repos.split(' ')
    else:
        print('No open source repos provided.')
        os_repos_list = []

    if enterprise_repos:
        if not enterprise_url:
            raise EnvironmentError('No enterprise URL provided')
        enterprise_repos_list = enterprise_repos.split(' ')
    else:
        print('No enterprise source repos provided.')
        enterprise_repos_list = []



if __name__ == "__main__":
    main()
