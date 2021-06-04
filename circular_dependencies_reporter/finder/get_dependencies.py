import os
import logging


class RepoDependencies:
    def __init__(self):
        self.repo_dict = {}

    def add_repo(self, repo_name, repo_base_url, org, file_extension, private=False):
        self._find_and_clone_repo(repo_name, repo_base_url, org, private)
        config_files = self._get_config_files(file_extension, repo_name)

        remote_state_lookups = []
        for file_path in config_files:
            remote_state_lookups.extend(
                self._get_remote_state_block(file_path, 'data "terraform_remote_state"', 10)
            )

        dependencies = []
        for remote_state_lookup in remote_state_lookups:
            tf_name = remote_state_lookup[0].split(" ")[3][1:-1]
            exit_code = os.system(
                f'grep -r "data.terraform_remote_state.{tf_name}" ./{repo_name}'
            )
            if exit_code == 0:
                dep_name = (
                    [s for s in remote_state_lookup if ".tfstate" in s][0].split("/")[-1].split(".")[0]
                )
                if dep_name not in dependencies:
                    dependencies.append(dep_name)

        os.system(f"rm -rf {repo_name}")

        self.repo_dict[repo_name] = dependencies

    def get_dependencies(self):
        if self.repo_dict:
            return self.repo_dict
        else:
            logging.debug("No repo's added, use the 'add_repo()' function.")
            return {}

    @staticmethod
    def _find_and_clone_repo(repo_name, repo_base_url, org, private=False):
        username = os.getenv("USERNAME")
        pat = os.getenv("GITHUB_ENTERPRISE_PAT")
        auth_str = ""
        if private:
            auth_str = f"{username}:{pat}@"

        clone = RepoDependencies._create_clone_str(repo_name, repo_base_url, org, auth_str)
        os.system(clone)

    @staticmethod
    def _create_clone_str(repo, repo_base_url, org, auth_str=""):
        return f"git clone https://{auth_str}{repo_base_url}/{org}/{repo}.git"

    @staticmethod
    def _get_config_files(file_extension, path="./"):
        return [
            os.path.join(root, f)
            for root, dirs, files in os.walk(path)
            for f in files
            if f == f"terraform{file_extension}"
        ]

    @staticmethod
    def _get_remote_state_block(path_to_file, line_to_match, number_of_lines):
        with open(path_to_file, "r") as file:
            data = file.read()
            data_arr = data.split("\n")
            start_ind = [
                number for number, line in enumerate(data_arr) if line_to_match in line
            ]
            return [data_arr[index: index + number_of_lines] for index in start_ind]
