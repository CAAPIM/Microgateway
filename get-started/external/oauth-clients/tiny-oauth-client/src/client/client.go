package main

import (
	"context"
	"crypto/tls"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"time"

	"golang.org/x/oauth2"
)

// OAuthClient configure the OAuth2 client
type OAuthClient struct {
	config   *oauth2.Config
	state    string
	token    *oauth2.Token
	client   *http.Client
	resource string
}

// validateState returns true if the received state passed in argument
// matches the state configured in OAuthClient
func (c *OAuthClient) validateState(state string) bool {
	return (c.state == state)
}

var oauth = OAuthClient{
	config: &oauth2.Config{
		ClientID:     "f7c232ef-0da1-4de0-a14e-23704b0bc177",
		ClientSecret: "4f15ba20-caf5-4732-9a53-afd5ad542146",
		Scopes:       []string{"HOTELS_INVENTORY_READ"},
		RedirectURL:  "http://IP:8081/callback",
		Endpoint: oauth2.Endpoint{
			AuthURL:  "https://otk.mycompany.com:8443/auth/oauth/v2/authorize",
			TokenURL: "https://otk.mycompany.com:8443/auth/oauth/v2/token",
		},
	},
	state: "state_oauth",
	client: &http.Client{
		Timeout: time.Second * 10,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		},
	},
	resource: "https://gateway.mycompany.com/hotels/inventory?inDate=a&outDate=b",
}

// Handle the authorize callback endpoint
//TODO:
//  - check errors sent by the OAuth server to this callback
//  - check the OAuth code is not empty
func oauthCallbackHandler(w http.ResponseWriter, r *http.Request) {
	// Set the HTTP context
	var ctx = context.WithValue(context.Background(), oauth2.HTTPClient, oauth.client)

	// Parse the HTTP inputs
	r.ParseForm()

	// Validate the OAuth state
	if !oauth.validateState(r.FormValue("state")) {
		http.Error(w, "Received OAuth state mismatched", http.StatusBadRequest)
		return
	}

	// Get the OAuth token
	oauthCode := r.FormValue("code")
	log.Println("OAuth code: ", oauthCode)

	token, err := oauth.config.Exchange(ctx, oauthCode)
	if err != nil {
		log.Println(err)
		http.Error(w, "Failed to retrieve the OAuth token", http.StatusBadRequest)
		return
	}
	oauth.token = token
	log.Println("OAuth token: ", oauth.token)

	// Get the http client
	oauth.client = oauth.config.Client(ctx, oauth.token)
}

// Authorize callback server
func oauthCallbackServer() {
	redirectURL, err := url.Parse(oauth.config.RedirectURL)
	if err != nil {
		log.Fatal(err)
	}
	http.HandleFunc(redirectURL.EscapedPath(), oauthCallbackHandler)
	log.Fatal(http.ListenAndServe(":"+redirectURL.Port(), nil))
}

func main() {
	go oauthCallbackServer()

	if oauth.token == nil {
		url := oauth.config.AuthCodeURL(oauth.state, oauth2.AccessTypeOffline)
		log.Printf("Visit the URL for the auth dialog: \n%v\n", url)
	}

	log.Println("Waiting for the OAuth token from ", oauth.config.Endpoint.AuthURL)
	for oauth.token == nil {
		time.Sleep(1 * time.Second)
	}

	log.Println("Getting resource")
	resp, err := oauth.client.Get(oauth.resource)
	if err != nil {
		log.Fatal("Error getting the resource: ", err)
	}

	log.Println(resp)
	body, _ := ioutil.ReadAll(resp.Body)
	log.Println("Response headers: ", resp.Header)
	log.Printf("Response body: %s", body)
}
