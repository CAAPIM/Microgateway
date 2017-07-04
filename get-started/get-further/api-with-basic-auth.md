## Secure a microservice API with Basic Authentication <a name="api-basic-auth"></a>

This step will typically be done by a microservice developer.

- Create a file named Gatewayfile with the following content:

  ```
  {
    "Service": {
    "name": "Google Search With Basic Auth",
    "gatewayUri": "/google-with-basic-auth",
    "httpMethods": [ "get" ],
    "policy": [
        {
          "CredentialSourceHttpBasic": { }
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
  Should return a list containing your Google Search With Basic Auth service.

- Use your exposed API:

  ```
  curl --insecure \
       --user "admin:password" \
       --header "User-Agent: Mozilla/5.0" \
       'https://localhost/google-with-basic-auth?q=CA'
  ```
