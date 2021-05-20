#Running the app to find dependency paths across your estate:
 - Fill out the blank `.env` file - the `<ENV>_LIST` vars should be space separated lists:
   > OPENSOURCE_REPO_LIST="repo_name_one repo_name_two repo_name_three"
 - Run `docker-compose up`

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