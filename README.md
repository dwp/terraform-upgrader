# terraform-upgrader

## A suite of tools to facilitate the upgrading of terraform across many repos.

This repo contains Makefile, and Dockerfile to fit the standard pattern.
This repo is a base to create new Docker image repos, adding the githooks submodule, making the repo ready for use.

After cloning this repo, please run:  
`make bootstrap`

## Finding dependencies
Create a `open_source_repos.txt` file with the repo names on Github that you'd like to be checked for dependencies.
Create a `enterprise_repos.txt` file with the repo names on Enterprise Github that you'd like to be checked for dependencies.

Use the `wrapper.sh` script, supplying the Github shortname of your organisation. ie `github.com/ORGNAME`
You can also supply an enterprise github FQDN link as a secondary argument.

The wrapper script will feed each repo supplied in the repos list to get_dependencies script. 
Get_dependencies will search for the terraform.tf or tf.j2 file, finds all remote state imports, then searches the code base for uses of those imports. If found, marked as a dependency and is added to the deps.csv file.
If they aren't used, they are added to the `unused_terraform_state_imports.txt` file for codebase cleanup.
