## Get started

Supported platforms:
- Linux
- MacOS

We are going to deploy the Gateway for micro-services, OAuth Toolkit (OTK) and
a micro-service that will be exposed on the Gateway and protected by OTK.

Three personas will be involved:
- a Gateway sysadmin
- a micro-service developer
- an external partner consuming the micro-service

Steps:

1. [Prerequisites](#prerequisites)
2. [Deploy the APIM Gateway for micro-services](#deploy)
3. [Expose a micro-service API with Basic Authentication](#expose-basic)
4. [Consume the API with Basic Authentication](#consume-basic)
5. [Protect a micro-service API with OAuth](#expose-oauth)
6. [Consume the API with OAuth](#consume-oauth)


#### 1. Prerequisites <a name="prerequisites"></a>
- A docker host

You can use Docker on your laptop or in the Cloud. Docker-machine
(https://docs.docker.com/machine/drivers/) can be used as a quick way to deploy
a remote Docker host.

Run the following command to validate that you can reach your Docker host.
```
docker info
```

- Golang to run the OAuth client

https://golang.org/doc/install

#### 2. Deploy the APIM Gateway for micro-services <a name="deploy"></a>

This step will typically be done by a Gateway sysadmin.

```
cd get-started/docker-compose
docker-compose up --build -d
```

Deployment logs command: `docker-compose logs --follow`

Deployment status command: `docker-compose ps`

Deployment remove command: `docker-compose down --volume`

#### 3. Expose a micro-service API with Basic Authentication <a name="expose-basic"></a>

This step will typically be done by a micro-service developer.

- Deploy a micro-service example
```
git clone https://github.com/harlow/go-micro-services
cd go-micro-services
touch .env
docker-compose up -d
```

- Test the micro-service is working
```
curl "http://localhost:8080/inventory?inDate=2015-04-09&outDate=2015-04-10"
```

Refer to the micro-service repository for technical details and troubleshooting:
https://github.com/harlow/go-micro-services.

- Expose the micro-service to the Gateway

  Add the file `Gatewayfile` in the micro-service source code folder `go-micro-services`
with the following content, where `IP` is your laptop ip:
```
{
  "Service": {
    "name": "HotelsInventory",
    "gatewayUri": "/hotels/inventory",
    "httpMethods": [ "get", "post" ],
    "policy": [
      {
        "Cors" : {}
      },
      {
        "CredentialSourceHttpBasic": { }
      },
      {
        "RouteHttp" : {
          "targetUrl" : "http://IP:8080/inventory${request.url.query}",
          "httpMethod" : "GET",
          "useAuthenticationHeader": "jwt"
        }
      }
    ]
  }
}
```
This file will tell the Gateway to create a service `/hotels/inventory` that
allows `GET` and `POST`, requires the OAuth scope `HOTELS_INVENTORY_READ` from
the OAuth client registered on the OTK server, and forwards with a JWT to the
micro-service at the address http://IP:8000/inventory?inDate=a&outDate=b.

  Push the Gatewayfile to the Gateway:
```
curl --insecure \
     --user "admin:password" \
     --url https://localhost/quickstart/1.0/services/ \
     --data @Gatewayfile
```
Which should return:
```
{
   "success" : true,
   "message" : "Quickstart service created successfully"
}
```

Wait for the service to be created:
```
curl --insecure \
     --user "admin:password" \
     --url https://localhost/quickstart/1.0/services/
```
Should return the following structure:
```
[{
 "ServiceName": "HotelsInventory",
 "ServiceUri": "/hotels/inventory",
 "ServiceId": "e93e67ce4a5011e7a5e80242ac150002",
 "ServiceTimeStamp": "1496709720123"
}]
```

- Test the micro-service is exposed
```
curl --insecure "https://localhost/hotels/inventory?inDate=a&outDate=b"
```
Which should return:
```
{
  "error message" : "Authentication error"
}
```

#### 4. Consume the API with Basic Authentication <a name="consume-basic"></a>
This step will typically be done by an external user like a business partner.
```
curl --insecure \
     --user "admin:password" \
     --url "https://localhost/hotels/inventory?inDate=2017-06-09&outDate=2017-06-10"
```

#### 5. Protect your service with OAuth <a name="expose-oauth"></a>
- Deploy OTK

  This step will typically be done by a Gateway sysadmin.
  ```
  cd get-started/external/otk
  docker-compose up --build -d
  ```

  Wait for OTK to be up and running:
  ```
  docker-compose logs -f
  ```
  The message `Gateway is now up and running!` will appear once the OTK is
  running.

- Configure OTK

  This step will typically be done by a Gateway sysadmin. It could be done with
  the Policy Manager (doc: https://docops.ca.com/display/OTK40/Create%20FIP%20Authentication%20for%20Dual%20Gateways)
  but we are going to do using the REST API of the OTK Gateway (RESTMAN).

  Note: Ensure the following line is fully copied.

  ```
  ./provision/add-otk-user.sh localhost:8443 "admin" 'password' "Gateway as a Client Identity Provider" "gw4ms.mycompany.com" "MIIDPjCCAiagAwIBAgIJAJxuJWOcosezMA0GCSqGSIb3DQEBCwUAMB4xHDAaBgNVBAMTE2d3NG1zLm15Y29tcGFueS5jb20wHhcNMTcwNTExMjE1OTA2WhcNMjIwNTEwMjE1OTA2WjAeMRwwGgYDVQQDExNndzRtcy5teWNvbXBhbnkuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArpHuSAMvbYHICJYWYsfhUYex67ioOEl9+rFnHJGg8v+ghSbeZ5uxuGCE/eTkI7aVFwSGRP1mDjvCPDqheQabFtVNZC/T815enQV33TAULBCz5YLKu/I0ie9+4cCwseIIT6x5kTCAla/Ex7qgWoicppROCAuNjpuSFc3F0nA4QY8h26qMwlMdupeCrHcSj76uDfS86Vn9lf7Y3hz6jC1bO8mp95mMBTVW1JDQKcJvmPfFbBjHs146uA6umkwNqDBSYiwr1oBWZiiMIdCg/bnIZgq/IdTdGKt8739MuW9j5scCZtnn1F28WGGpIncxbGFHoZS5cOGdEbyY80RutWpv/wIDAQABo38wfTAdBgNVHQ4EFgQUuiSIW6OeLqqKQOFc42lqVqt+gacwTgYDVR0jBEcwRYAUuiSIW6OeLqqKQOFc42lqVqt+gaehIqQgMB4xHDAaBgNVBAMTE2d3NG1zLm15Y29tcGFueS5jb22CCQCcbiVjnKLHszAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBRwh37Aq6o82mZXEhxaqqIRlTvK2DYjYZZmbzjCA8BAKVfAZDjPZtL/bdbQmU2oQwDpry6OHOfcoaTcTX+ZeGsWQz/Kb3g9zF9GansleYkayGGf5er9Ife7Mx9ODDg8NVdgJN8iNKjwDWz9IE9E1pIOKFbW1v/qwCMtkwhrw6pBfq39etH3aT7+TKd6YPjYekO49rpk5EAhSucxRAyGPX8JFO+YTEACkjKGUB4bgiG/0wdS/XnPkPmP/LmbN/9Pk0oAAdod1KhQ3NktnPBHfUUZwKXNzAciCi0ag2H6F0X3gragkw6en7FfGVY+hspupXuuhsYSjl8PjDoXpBsIMGk"
  ```

  The script will print `Done.` after configuring OTK.

- Update the Gateway to connect to OTK

  This step will typically be done by a Gateway sysadmin.

  Move to the Gateway folder:
  ```
  cd get-started/docker-compose
  ```

  Update `docker-compose.yml` and add the following in `environment` block of
  the `ssg` service:
  ```
  OTK_SERVER_HOST: "IP"
  OTK_SERVER_SSL_PORT: "8443"
  OTK_CERTIFICATE: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURPRENDQWlDZ0F3SUJBZ0lKQUk1V2x6RHduWkRpTUEwR0NTcUdTSWIzRFFFQkN3VUFNQnd4R2pBWUJnTlYKQkFNVEVXOTBheTV0ZVdOdmJYQmhibmt1WTI5dE1CNFhEVEUzTURVeU9URTNORGsxTWxvWERUSXlNRFV5T0RFMwpORGsxTWxvd0hERWFNQmdHQTFVRUF4TVJiM1JyTG0xNVkyOXRjR0Z1ZVM1amIyMHdnZ0VpTUEwR0NTcUdTSWIzCkRRRUJBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRQ3cyak5PVEo4ZDJnNzJ2aHpTV21nbkhESzFCRzh6dllSaGZ1NksKVWFmKzdaK2krbFV3R0cvaEk0aW5kSkNMaHRZNTE5RzlxSlJRaDMzdXExNUxqQzErZk5RK3BTQnBBU0dDODJaYgplQ1NYL3hOL21TeE9LVUg2cFErNzd5TUJRckprRXRlMUkrNzZlaGFabGVnWWNWb0NaYWl4QXhHN1hkRUhpWGQ4CjdVUDlSTk9WdUJJbFhZSlQ4Z2pPYjdVdml2VFJIRzVCaHhVOEIvcGtQUXBaWGlTYmpQOGJXbHdtN3pIeUhFVGQKMTMrb2ROYmZLUGZlU2xZT0hGSWNXRjJleVBuRTczYlc0L0lPN2k5MWIvTmR5K1cwSk4zTUdKa2Q5N3k1NWloZwpUM0xQZXdWZTVsMSt3aTFHNnR3MFpMZlVQNDg4QmxQb2k2SHc4ZEplYlFIanY3UnZBZ01CQUFHamZUQjdNQjBHCkExVWREZ1FXQkJSYVZMSFBLaXZzaDNHVjBOdFdGMzBPL0p0QXpqQk1CZ05WSFNNRVJUQkRnQlJhVkxIUEtpdnMKaDNHVjBOdFdGMzBPL0p0QXpxRWdwQjR3SERFYU1CZ0dBMVVFQXhNUmIzUnJMbTE1WTI5dGNHRnVlUzVqYjIyQwpDUUNPVnBjdzhKMlE0akFNQmdOVkhSTUVCVEFEQVFIL01BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmxxd1lCCklOdVpLcHVyNnlhU0lBUlJYOWs5d1VwSkxidjlFUHF0a0o4ekpWaVovN3dKUmlPaE5FV2MyZ2FNVTkrS1E3cTkKV3R0RWRLRElNKzRRdFl6Wjg0QUJoOFFhSU9RSWNMSnhLM2xqNzJHNTFNUDZIZ0ovRFJ1TTZ4OS9zZ092RSs4cQpBVjVDU1p2YUdVRGV4WlZZQUpYOTZIRlNzajlqM2tablBIYmU0U2xjZndqd3A4KzhVVGRQaTRGMkM4amhUQkFBCk1HVjgrQVF2TTZtSlpsaTdDVmJJYUFGZ0oxamZsY3hkb3pFMUExR2Fhb1FwSzVtYXpoLzFkMWR3azlScXVEY00KVUhPWEFnWFdtUW15VjVGZlJYYTMwbWpCcXVVSGFWU3NiR1Vidm0rd2FxMUloaG0vd3lkbnRBQS8rTUFRQXZWegpSa25HMW8xaGRiNFlQdHZqCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
  OTK_CERT_VERIFY_HOSTNAME: "false"
  ```
  Where `IP` in `OTK_SERVER_HOST: "IP"` is your laptop IP.

  Update the Gateway:
  ```
  docker-compose up -d ssg
  ```

- Update your service

  This step will typically be done by a micro-service developer.

  In your micro-service folder, open `Gatewayfile` and replace:
  ```
  {
    "CredentialSourceHttpBasic": { }
  },
  ```
  with
  ```
  {
    "RequireOauth2Token": {
      "scope_required": "HOTELS_INVENTORY_READ",
      "scope_fail": "false",
      "onetime": "false",
      "given_access_token": ""
    }
  },
  ```
  The service now requires the OAuth scope `HOTELS_INVENTORY_READ` from the OAuth client registered on the OTK server.

  Get your service ID:
  ```
  curl --insecure \
       --user "admin:password" \
       --url https://localhost/quickstart/1.0/services/
  ```

  Push the updated `Gatewayfile`:
  ```
  curl --request PUT \
       --insecure \
       --user "admin:password" \
       --url https://localhost/quickstart/1.0/services/ID \
       --data @Gatewayfile
  ```
  Where in the URL `ID` is your service ID.


#### 6. Consume the micro-service with OAuth <a name="consume-oauth"></a>

This step will typically be done by an external user like a business partner.

Let's imagine that your partner `booking.com` wants to access your hotel inventory.

<!-- - Set the OTK first login password

  Connect on `localhost:8443` (user: admin, password: password) with the Policy
  Manager v9.2.

  A popup window will ask you to set the first login password. -->

- Register an OAuth client on the OTK OAuth manager

  Open https://localhost:8443/oauth/manager in your browser then login with the
  user `arose` and password `StRonG5^)`. (See https://github.com/CAAPIM/Docker-MAS#test-users-and-groups
  for more accounts)

  Click on `Clients`, then `Register a new client`.

  Take note of the `Client Key` and `Client Secret` and fill in the following fields:
  - Client Name: Booking.com
  - Organization: Booking.com
  - Description: Access the hotel inventory
  - Scope: HOTELS_INVENTORY_READ
  - Callback URL: http://IP:8081/callback, with IP your laptop IP

  The Callback URL would normally target your partner server in order for your
  partner to receive the OAuth authorization token from OTK.

  Click `Register`.

- Configure your OAuth client

  Open the file `deploy/external/oauth-clients/tiny-oauth-client/client.go` and
  replace the variable `oauth` with the following content:
  ```
  var oauth = OAuthClient{
          config: &oauth2.Config{
                  ClientID:     "CLIENT_ID",
                  ClientSecret: "CLIENT_SECRET",
                  Scopes:       []string{"HOTELS_INVENTORY_READ"},
                  RedirectURL:  "http://IP:8081/callback",
                  Endpoint: oauth2.Endpoint{
                          AuthURL:  "https://localhost:8443/auth/oauth/v2/authorize",
                          TokenURL: "https://localhost:8443/auth/oauth/v2/token",
                  },
          },
          state: "state_oauth",
          client: &http.Client{
                  Timeout: time.Second * 10,
                  Transport: &http.Transport{
                          TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
                  },
          },
          resource: "https://localhost/hotels/inventory?inDate=a&outDate=b",
  }
  ```
  With:
    - CLIENT_ID: the OAuth client ID received during the OAuth client registration
    - CLIENT_SECRET: the OAuth client secret received during the OAuth client registration
    - IP: the IP address of your laptop

- Access the exposed micro-service
  Run the following command:
  ```
  cd get-started/external/oauth-clients/tiny-oauth-client
  export GOPATH="$(pwd)"
  cd src/client
  go get
  go run client.go
  ```
  Which will ask you to open in your browser a URL like `https://localhost:8443/auth/oauth/v2/authorize?access_type=offline&client_id=f7c232ef-0da1-4de0-a14e-23704b0bc177&redirect_uri=http%3A%2F%2F10.137.227.88%3A8081%2Fcallback&response_type=code&scope=HOTELS_INVENTORY_READ&state=state_oauth`. That is
  the URL the user will open to grant access to the OAuth application we started.

  Login with the user `cgriffin` and password `StRonG5^)`

  After you granted the OAuth application the access to `HOTELS_INVENTORY_READ`
  scope, you will see in the OAuth application terminal the JSON reply from `https://localhost/hotels/inventory`.
