## Secure a microservice API with OAuth <a name="api-oauth"></a>

The exercise sets up a microgateway as an OAuth enforcement point with a central OAuth service using [CA MAS trial](http://developer.ca.com) for a microservice API.

```
(microservice A)-----CA microgateway <-
                          |            \
                          |             \
               CA MAS with OAuth ToolKit --------> [firewall] (Edge API gateway) <--------->
                          |             /
                          |            /
(microservice B)-----(microgateway) <--
```

- Deploy the [CA Containerized API Gateway](https://docops.ca.com/ca-api-gateway/9-3/en/other-gateway-form-factors/using-the-container-gateway) with OAuth Toolkit (OTK) as OAuth Server

  *This step will typically be done by a Gateway sysadmin.*

  See [tutorial](../external/otk).

- Update the Gateway to connect to OAuth

  *This step will typically be done by a Gateway sysadmin.*

  Move to the Gateway folder:
  ```
  cd get-started/docker-compose
  ```

  Confirm the OTK configuration file `config/otk.env` has the following content:
  ```
  OTK_SERVER_HOST=otk
  OTK_SERVER_SSL_PORT=8443
  ```

  Update the Gateway:

  ```
  docker-compose --project-name microgateway \
               --file docker-compose.yml \
               --file docker-compose.db.consul.yml \
               --file docker-compose.lb.dockercloud.yml \
               up -d ssg
  ```

  Wait for the Gateway to be running for about 30 seconds:

  ```
  curl --insecure --user "admin:password" https://localhost/quickstart/1.0/services
  ```
  Should return a list of services.

- Create a file named Gatewayfile with the following content:

  *This step will typically be done by a microservice developer.*

  ```json
  {
    "Service": {
    "name": "Google Search With OAuth",
    "gatewayUri": "/google-with-oauth",
    "httpMethods": [ "get" ],
    "policy": [
        {
          "RequireOauth2Token": {
            "scope_required": "GOOGLE_SEARCH",
            "scope_fail": "false",
            "onetime": "false",
            "given_access_token": ""
          }
        },
        {
          "RouteHttp" : {
            "targetUrl" : "http://www.google.com/search${request.url.query}",
            "httpMethod" : "Automatic"
          }
        }
      ]
    }
  }
  ```

  In this example, the service will require the OAuth scope `GOOGLE_SEARCH`
  from OAuth clients registered on the OTK server.

- Add your API to the Gateway:

    ```
    curl --insecure \
         --user "admin:password" \
         --url https://localhost/quickstart/1.0/services \
         --data @Gatewayfile
    ```

- Verify that your API is exposed:

    ```
    curl --insecure --user "admin:password" https://localhost/quickstart/1.0/services
    ```
    Should return a list containing your Google Search With OAuth service.

### Consume the API with OAuth <a name="api-oauth-consume"></a>

This step will typically be done by an external user like a business partner or
another microservice developer willing to connect to our microservice.

- Register an OAuth client on the OTK OAuth manager, a web client to configure OAuth resources

  Open https://localhost:8443/oauth/manager in your browser then login with the
  user `admin` and password `password`. 

  Click on `Clients`, then `Register a new client`.

  Fill in the following fields:
  - Client Name: MyOAuthClient
  - Organization: MyOAuthClient
  - Description: Access the Google search
  - Scope: GOOGLE_SEARCH

  :warning: Take note of the `Client Key` and `Client Secret`

  Click `Register`.

- Retrieve your OAuth access token:

  ```
  curl --insecure \
       --data "client_id=<client_key>" \
       --data "client_secret=<client_secret>" \
       --data "scope=GOOGLE_SEARCH" \
       --data "grant_type=password" \
       --data "username=admin" \
       --data "password=password" \
      'https://localhost:8443/auth/oauth/v2/token'
  ```

  With:
    - `<client_key>`: the client key received in the previous step (e.g. c0bb8838-dc91-4296-8ccc-1a263bb28169)
    - `<client_secret>`: the client secret received in the previous step (e.g. 1ca6bbf4-ddb6-4a9d-8136-b5a26da96f8b)

  And you should get a result back as following:

  ```
  {
    "access_token":"d17b00bb-f299-440f-aed7-f47ff1e7f85c",
    "token_type":"Bearer",
    "expires_in":3600,
    "refresh_token":"46b70935-b580-49b0-8cea-a4f4217ba7c7",
    "scope":"GOOGLE_SEARCH"
  }
  ```

- Use your exposed API:

  ```
  curl --insecure \
       --header "User-Agent: Mozilla/5.0" \
       --header "Authorization: Bearer <access_token>" \
       'https://localhost/google-with-oauth?q=CA'
  ```
  With `<access_token>` the value received from the previous curl command.

  And you should get HTML content as a result like this:

  ```
  <!doctype html><html itemscope="" itemtype="http://schema.org/SearchResultsPage" lang="en"><head>
  ```
