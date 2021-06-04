#Running the app to find circular dependency paths across your estate:
 1. Fill out the blank `.env` file - the `<ENV>_LIST` vars should be space separated lists:
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

 - You should now see a csv file of dependencies appear in `./circular_dependencies_reporter/reports`