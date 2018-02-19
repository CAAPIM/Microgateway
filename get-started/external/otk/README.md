# CA OTK (OAuth)

## License agreement
Set `ACCEPT_LICENSE=true` in the file `./config/license.env`.

## Licenses
Add to the folder `./customize/license/` your license files containing the
following feature sets:
- `<featureset name="set:Profile:Gateway”/>`
- `<featureset name="set:Profile:Mobile"/>`
- `<featureset name="set:Profile:MAS”/>`

Or simply an Enterprise Gateway license which contains the following feature set:
- `<featureset name="set:Profile:EnterpriseGateway"/>`

## Deploy
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
microgateway_otk_mysqldb_1   Up 6 minutes
```

You can also verify the logs contains the message `Gateway is now up and running!`
once ready:
```
docker-compose --project-name microgateway logs -f
```
