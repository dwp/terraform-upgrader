from unittest import TestCase, main
from unittest.mock import patch
from finder.find_circular_dependencies import find_circular_dependencies
from finder.get_dependencies import RepoDependencies
import re


class MockResponse:
    def __init__(self, json_data, status_code):
        self.json_data = json_data
        self.status_code = status_code

    def json(self):
        return self.json_data


# Test Circular dependencies detection logic
class TestCircularDependencies(TestCase):
    def test_no_circular_dependencies(self):
        dependencies = {"a": ["b", "c", "d"], "b": [], "c": ["e"]}
        result = find_circular_dependencies(dependencies)
        expected_result = []
        self.assertEqual(result, expected_result)

    def test_with_circular_dependencies(self):
        dependencies = {"a": ["b", "c", "d"], "b": ["b"], "c": ["e"], "d": ["a", "b"]}
        result = find_circular_dependencies(dependencies)
        expected_result = [["a", "d"], ["b"]]
        self.assertEqual(result, expected_result)

    def test_empty_dict(self):
        dependencies = {}
        result = find_circular_dependencies(dependencies)
        expected_result = []
        self.assertEqual(result, expected_result)

    def test_terraform_config_files(self):
        files = [
            "./.DS_Store",
            "./requirements.txt",
            "./Dockerfile",
            "./__init__.py",
            "./README.md",
            "./setup.py",
            "./.env",
            "./app.py",
            "./docker-compose.yml",
            "./tests/test_circular_dependencies.py",
            "./tests/__init__.py",
            "./example/terraform.tf",
            "./finder/get_dependencies.py",
            "./finder/__init__.py",
            "./finder/find_circular_dependencies.py",
        ]
        with patch.object(
            RepoDependencies, "_get_config_files", return_value=files
        ) as mock_method:
            terraform_files = RepoDependencies._get_config_files(".tf")
            self.assertIn("./example/terraform.tf", terraform_files)

    def test_get_remote_state_block(self):
        block = RepoDependencies._get_remote_state_block(
            "test/resources/terraform_example.tf", 'data "terraform_remote_state"', 10
        )
        with open(
            "test/resources/terraform_state_block_example.tf", "r"
        ) as terraform_state_block_example_file:
            expected_output = terraform_state_block_example_file.readlines()
        block = re.sub(r"\W+", "", "".join(block[0]))
        expected_output = re.sub(r"\W+", "", "".join(expected_output))
        self.assertEqual(block, expected_output)


if __name__ == "__main__":
    main()
