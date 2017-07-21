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

- Deploy the CA API [Mobile App Services](https://www.ca.com/us/developers/mas) trial with OAuth Toolkit (OTK) as OAuth Server 

  *This step will typically be done by a Gateway sysadmin.*
  ```
  cd get-started/external/otk
  docker-compose up --build -d
  ```

  Wait for Mobile App Services trial (as OAuth server) to be up and running:
  ```
  docker-compose logs -f
  ```
  The message `Gateway is now up and running!` will appear once the OTK is
  running.

  Configure OAuth:

  We are going to do using the REST API of the Mobile App Services trial (RESTMAN).
  
  Run the following command:

  Note: Ensure the following line is fully copied.

  ```
  ./provision/add-otk-user.sh otk.mycompany.com:8443 "admin" 'password' "Gateway as a Client Identity Provider" "gw4ms.mycompany.com" "MIIDPjCCAiagAwIBAgIJAJxuJWOcosezMA0GCSqGSIb3DQEBCwUAMB4xHDAaBgNVBAMTE2d3NG1zLm15Y29tcGFueS5jb20wHhcNMTcwNTExMjE1OTA2WhcNMjIwNTEwMjE1OTA2WjAeMRwwGgYDVQQDExNndzRtcy5teWNvbXBhbnkuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArpHuSAMvbYHICJYWYsfhUYex67ioOEl9+rFnHJGg8v+ghSbeZ5uxuGCE/eTkI7aVFwSGRP1mDjvCPDqheQabFtVNZC/T815enQV33TAULBCz5YLKu/I0ie9+4cCwseIIT6x5kTCAla/Ex7qgWoicppROCAuNjpuSFc3F0nA4QY8h26qMwlMdupeCrHcSj76uDfS86Vn9lf7Y3hz6jC1bO8mp95mMBTVW1JDQKcJvmPfFbBjHs146uA6umkwNqDBSYiwr1oBWZiiMIdCg/bnIZgq/IdTdGKt8739MuW9j5scCZtnn1F28WGGpIncxbGFHoZS5cOGdEbyY80RutWpv/wIDAQABo38wfTAdBgNVHQ4EFgQUuiSIW6OeLqqKQOFc42lqVqt+gacwTgYDVR0jBEcwRYAUuiSIW6OeLqqKQOFc42lqVqt+gaehIqQgMB4xHDAaBgNVBAMTE2d3NG1zLm15Y29tcGFueS5jb22CCQCcbiVjnKLHszAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBRwh37Aq6o82mZXEhxaqqIRlTvK2DYjYZZmbzjCA8BAKVfAZDjPZtL/bdbQmU2oQwDpry6OHOfcoaTcTX+ZeGsWQz/Kb3g9zF9GansleYkayGGf5er9Ife7Mx9ODDg8NVdgJN8iNKjwDWz9IE9E1pIOKFbW1v/qwCMtkwhrw6pBfq39etH3aT7+TKd6YPjYekO49rpk5EAhSucxRAyGPX8JFO+YTEACkjKGUB4bgiG/0wdS/XnPkPmP/LmbN/9Pk0oAAdod1KhQ3NktnPBHfUUZwKXNzAciCi0ag2H6F0X3gragkw6en7FfGVY+hspupXuuhsYSjl8PjDoXpBsIMGk"
  ```

  The script will print `Done.` after configuring OAuth.

- Update the Gateway to connect to OAuth

  *This step will typically be done by a Gateway sysadmin.*

  Move to the Gateway folder:
  ```
  cd get-started/docker-compose
  ```

  Update `docker-compose.yml` and add the following in `environment` block of
  the `ssg` service:
  ```
  OTK_SERVER_HOST: "<IP>"
  OTK_SERVER_SSL_PORT: "8443"
  OTK_CERTIFICATE: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURPRENDQWlDZ0F3SUJBZ0lKQUk1V2x6RHduWkRpTUEwR0NTcUdTSWIzRFFFQkN3VUFNQnd4R2pBWUJnTlYKQkFNVEVXOTBheTV0ZVdOdmJYQmhibmt1WTI5dE1CNFhEVEUzTURVeU9URTNORGsxTWxvWERUSXlNRFV5T0RFMwpORGsxTWxvd0hERWFNQmdHQTFVRUF4TVJiM1JyTG0xNVkyOXRjR0Z1ZVM1amIyMHdnZ0VpTUEwR0NTcUdTSWIzCkRRRUJBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRQ3cyak5PVEo4ZDJnNzJ2aHpTV21nbkhESzFCRzh6dllSaGZ1NksKVWFmKzdaK2krbFV3R0cvaEk0aW5kSkNMaHRZNTE5RzlxSlJRaDMzdXExNUxqQzErZk5RK3BTQnBBU0dDODJaYgplQ1NYL3hOL21TeE9LVUg2cFErNzd5TUJRckprRXRlMUkrNzZlaGFabGVnWWNWb0NaYWl4QXhHN1hkRUhpWGQ4CjdVUDlSTk9WdUJJbFhZSlQ4Z2pPYjdVdml2VFJIRzVCaHhVOEIvcGtQUXBaWGlTYmpQOGJXbHdtN3pIeUhFVGQKMTMrb2ROYmZLUGZlU2xZT0hGSWNXRjJleVBuRTczYlc0L0lPN2k5MWIvTmR5K1cwSk4zTUdKa2Q5N3k1NWloZwpUM0xQZXdWZTVsMSt3aTFHNnR3MFpMZlVQNDg4QmxQb2k2SHc4ZEplYlFIanY3UnZBZ01CQUFHamZUQjdNQjBHCkExVWREZ1FXQkJSYVZMSFBLaXZzaDNHVjBOdFdGMzBPL0p0QXpqQk1CZ05WSFNNRVJUQkRnQlJhVkxIUEtpdnMKaDNHVjBOdFdGMzBPL0p0QXpxRWdwQjR3SERFYU1CZ0dBMVVFQXhNUmIzUnJMbTE1WTI5dGNHRnVlUzVqYjIyQwpDUUNPVnBjdzhKMlE0akFNQmdOVkhSTUVCVEFEQVFIL01BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmxxd1lCCklOdVpLcHVyNnlhU0lBUlJYOWs5d1VwSkxidjlFUHF0a0o4ekpWaVovN3dKUmlPaE5FV2MyZ2FNVTkrS1E3cTkKV3R0RWRLRElNKzRRdFl6Wjg0QUJoOFFhSU9RSWNMSnhLM2xqNzJHNTFNUDZIZ0ovRFJ1TTZ4OS9zZ092RSs4cQpBVjVDU1p2YUdVRGV4WlZZQUpYOTZIRlNzajlqM2tablBIYmU0U2xjZndqd3A4KzhVVGRQaTRGMkM4amhUQkFBCk1HVjgrQVF2TTZtSlpsaTdDVmJJYUFGZ0oxamZsY3hkb3pFMUExR2Fhb1FwSzVtYXpoLzFkMWR3azlScXVEY00KVUhPWEFnWFdtUW15VjVGZlJYYTMwbWpCcXVVSGFWU3NiR1Vidm0rd2FxMUloaG0vd3lkbnRBQS8rTUFRQXZWegpSa25HMW8xaGRiNFlQdHZqCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
  OTK_CERT_VERIFY_HOSTNAME: "false"
  ```
  Where `<IP>` in `OTK_SERVER_HOST: "<IP>"` is your Docker host IP which is your
  laptop IP if running this get started on your laptop.

  Update the Gateway:

  ```
  docker-compose -f docker-compose.yml -f docker-compose.dockercloudproxy.yml up -d ssg
  ```

  Wait for the Gateway to be running for about 30 seconds:

  ```
  curl --insecure --user "admin:password" https://localhost/quickstart/1.0/services
  ```
  Should return a list of services.

- Create a file named Gatewayfile with the following content:

  *This step will typically be done by a microservice developer.*

  ```
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
         --url https://localhost/quickstart/1.0/services/ \
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
  user `arose` and password `StRonG5^)`. (See https://github.com/CAAPIM/Docker-MAS#test-users-and-groups
  for more accounts)

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
       --data "username=arose" \
       --data "password=StRonG5^)" \
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
