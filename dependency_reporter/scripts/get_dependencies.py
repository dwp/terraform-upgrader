import os
import requests

class RepoDependencies:
    def __init__(self, repo_dict={}):
        self.repo_dict = repo_dict

    def add_repo(self, tfstate_repo_name, repo_base_url, org, file_extension, private=False):
        repo_name = self._find_and_clone_repo(tfstate_repo_name, repo_base_url, org, file_extension, private)
        config_files = self._get_config_files(file_extension, repo_name)

        remote_state_lookups = []
        for file_path in config_files:
             remote_state_lookups.extend(self._get_remote_state_block(file_path, 'data "terraform_remote_state"', 10))

        dependencies = []
        for remote_state_lookup in remote_state_lookups:
            tf_name = remote_state_lookup[0].split(' ')[3][1:-1]
            exit_code = os.system(f'grep -r "data.terraform_remote_state.{tf_name}" ./{repo_name}')
            if exit_code == 0:
                dep_name = [s for s in remote_state_lookup if ".tfstate" in s][0].split('/')[-1].split('.')[0]
                if dep_name not in dependencies: dependencies.append(dep_name)

        os.system(f'rm -rf {repo_name}')

        self.repo_dict[repo_name] = dependencies


    def _find_and_clone_repo(self, tfstate_repo_name, repo_base_url, org, file_extension, private=False):
        username = os.getenv("USERNAME")
        pat = os.getenv("GITHUB_ENTERPRISE_PAT")
        auth_str = ''
        if private:
            auth_str = f'{username}:{pat}@'

        clone = self._create_clone_str(tfstate_repo_name, repo_base_url, org, auth_str)
        if os.system(clone) > 0:
            req_str = f'https://{repo_base_url}/api/v3' if private \
                else f'https://api.github.com'
            auth = (username, pat) if private else ''
            repo_data = requests.get(f'{req_str}/orgs/{org}/repos?type=all&per_page=500', auth=auth).json()
            possible_matches = [repo['name'] for repo in repo_data if tfstate_repo_name in repo['name']]
            for repo in possible_matches:
                clone = self._create_clone_str(repo, repo_base_url, org, auth_str)
                os.system(clone)
                result = self._get_config_files(file_extension, f'{repo}/')
                for file_path in result:
                    config_object = self._get_remote_state_block(f'{repo}/{file_path}', 'backend "s3" {', 7)[0]
                    s3_file_name = [s for s in config_object if ".tfstate" in s][0].split('/')[-1].split('.')[0]
                    if s3_file_name == tfstate_repo_name:
                        return repo
                    else:
                        os.system(f'rm -rf {repo}')
            raise ValueError(f'No repo match found for {tfstate_repo_name} in {org} remote repository.')
        else:
            return tfstate_repo_name

    @staticmethod
    def _create_clone_str(repo, repo_base_url, org, auth_str=''):
        return f'git clone https://{auth_str}{repo_base_url}/{org}/{repo}.git'

    def _get_config_files(self, file_extension, path='./'):
        return [os.path.join(dp, f) for dp, dn, filenames in os.walk(path) for f in filenames if f == f'terraform{file_extension}']

    def _get_remote_state_block(self, path_to_file, line_to_match, number_of_lines):
        with open(path_to_file, 'r') as file:
            data = file.read()
            data_arr = data.split('\n')
            start_ind = [number for number, line in enumerate(data_arr) if line_to_match in line]
            return [data_arr[index:index+number_of_lines] for index in start_ind]

    def get_dependencies(self):
        if self.repo_dict:
            return self.repo_dict
        else:
            print("No repo's added, use the 'add_repo()' function.")
            return {}


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
        repo_deps.add_repo(repo, 'www.github.com', os_org, '.tf.j2')

    for repo in enterprise_repos_list:
        repo_deps.add_repo(repo, enterprise_url, enterprise_org, '.tf', True)


if __name__ == "__main__":
    main()
