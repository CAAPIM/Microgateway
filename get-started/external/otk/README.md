# CA OTK (OAuth)

## License agreement
Set `ACCEPT_LICENSE=true` in the file `./config/license.env`.

## Deploy
Move to the otk folder which contains the `docker-compose.yml` file.
```
cd get-started/external/otk
```
Then run the command below to bring the containers up.
```
docker-compose --project-name microgateway up --build -d
```

Wait for the OAuth server to be healthy:
```
docker ps --filter "name=otk" --format "table {{.Names}}\t{{.Status}}" --all
```
Should return:
```
NAMES                        STATUS
microgateway_otk_1           Up 5 minutes (healthy)
microgateway_otk_cassandra_1   Up 6 minutes
```

You can also verify the logs contains the message `Gateway is now up and running!`
once ready:
```
docker-compose --project-name microgateway logs -f
```
