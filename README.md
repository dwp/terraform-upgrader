# terraform-upgrader 

terraform-upgrader is a tool to find terraform circular dependency paths across your Github repositories (public and private).

## How to run the tool
1. Fill out the blank `.env` file - the `<>_LIST` vars should be space separated lists
 
    `<>` needs to be replaced by either `OPENSOURCE_REPO` or `ENTERPRISE_REPO`, i.e:
    
    ```
    OPENSOURCE_REPO_LIST="repo_name_one repo_name_two repo_name_three"
    ```
    > N.B. GITHUB_ENTERPRISE_URL should not include `https://`

2. `export` both github enterprise PAT* and username using:

    ```
    export GHE_PAT=<PAT_VALUE> GHE_USERNAME=<USERNAME_VALUE>
    ```
    *[Github PAT token setup](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)

3. Run `docker-compose up`

    You should now see a csv file of dependencies appear in `./circular_dependencies_reporter/reports`
    
The result is a .json file containing a list of lists of circular dependency paths for the repositories specified in the configuration file.
Output looks like:

`[[a, b, c], [d]]` where `d` is a self referencing repo and `a` references `b`, `b` references `c`, and `c` references `a` (hence the circular dependency).

