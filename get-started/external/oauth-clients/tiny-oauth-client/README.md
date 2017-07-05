#### Tiny OAuth client

##### Dependencies
- golang (https://golang.org/doc/install)

##### Configure
Edit the variable `oauth` in the file `client.go`.

##### Run
```
export GOPATH="$(pwd)"
cd src/client
go get
go run client.go
```

##### What it does:
1. The client will print the OAuth Authorization url that you will need to open in your browser in order to grant `client.go`
2. The client will:
  - receive the OAuth code from the OAuth server
  - exchange the OAuth code with the OAuth token
  - HTTP GET the protected resource using the OAuth token and print its body
