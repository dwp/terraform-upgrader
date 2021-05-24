#Running the app to find dependency paths across your estate:
 1. At the time of writing there were issues pulling Neo4j image due to network restrictions. A work around is to pull on another machine, use docker save, send the tarball to the restricted machine and load it into the docker engine using docker load.
 1. Fill out the blank `.env` file - the `<ENV>_LIST` vars should be space separated lists:
    ```
    OPENSOURCE_REPO_LIST="repo_name_one repo_name_two repo_name_three"
    ```
    > N.B. GITHUB_ENTERPRISE_URL should not include `https://`
 1. `export` both github enterprise PAT* and username using:
    ```
    export GHE_PAT=<PAT_VALUE> GHE_USERNAME=<USERNAME_VALUE> 
    ```                         
    *[Github PAT token setup](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)
                                                               
 1. Run `docker-compose up`

##Running dependency finder to report dependencies locally:
 - Comment out the line `python ./graph.py` in `./scripts/wrapper.sh`
 - Open a terminal in `./dependency_finder` and run: 

```shell
docker build 
    --build-arg ENTERPRISE_URL=<url> 
    --build-arg OPENSOURCE_REPO_LIST="<repo1> <repo2> <repo3> ..." 
    -t <image_tag> .
```
 - You should now be able to run the container using 
```shell
docker run -v "$(pwd)/reports":/home/app/reports <image_tag>
```
 - You should now see a csv file of dependencies appear in `./dependency_finder/reports`