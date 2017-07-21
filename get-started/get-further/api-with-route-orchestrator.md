## Orchestrate API/Microservice with RouteOrchestrator Template <a name="RouteOrchestrator"></a>

Table of Contents:

* [Description](#Description)
* [Example](#Example)
  * [Prerequisite - Register the Google Root TLS certificate](#register-cert)
  * [Example 1 – expose microservice API without transformation](#Example1)
  * [Example 2 - expose microservice API with transformation using Jolt](#Example2)
  * [Example 3 – expose microservice API with transformation and aggregation](#Example3)
* [RouteOrchestrator Syntax](#HowTo)
	* [aggregator](#aggregator)
	* [parameters](#parameters)
	* [headers](#headers)
	* [requestTransform](#requestTransform)
	* [responseTransform](#responseTransform)

### Description <a name="Description"></a>
RouteOrchestrator assertion provides an abstraction layer that will allow our customers to send a single query for a complex business logic without having to know many backend services API endpoints</b>.


### Example<a name="Example"></a>

#### Prerequisite - Register the Google Root TLS certificate  <a name="register-cert"></a>

Register the Google Root TLS certificate ([link](register-google-tls-certificate.md))
because the example 2 and 3 use the Google Maps APIs over HTTPS as backend services.

#### Example 1 – expose microservice API without transformation  <a name="Example1"></a>
- This is a simple example of exposing a microservice API using RouteOrchestrator with no transformation

- Create a file name RouteOrchestratorFile with the following content

```
{
  "Service": {
    "name": "Google RouteOrchestrator Service",
    "gatewayUri": "/google-with-orchestrator",
    "httpMethods": [
      "get",
      "put",
      "post",
      "delete"
    ],
    "policy": [
      {
        "RouteOrchestrator": {
          "orchestrator": {
            "orchestrator": [
              {
                "aggregator": [
                  {
                    "RouteHttp": {
                      "targetUrl": "http://www.google.com/search${request.url.query}",
                      "httpMethod": "GET",
                      "parameters": [],
                      "headers": [],
                      "requestTransform": [],
                      "responseTransform": []
                    }
                  }
                ]
              }
            ]
          }
        }
      }
    ]
  }
}
```

- Add your API to the gateway
```
curl --insecure \
     --user "admin:password" \
     --url https://localhost/quickstart/1.0/services \
     --data @RouteOrchestratorFile
```
- Verify that your API is exposed
```
curl --insecure --user "admin:password" https://localhost/quickstart/1.0/services
```
Should return a list containing your Google RouteOrchestrator Service.
- Use your exposed API
```
curl --insecure \
     --header "User-Agent: Mozilla/5.0" \
     'https://localhost/google-with-orchestrator?q=CA'
```


#### Example 2 - expose microservice API with transformation using Jolt (JSON-to-JSON-transformation) <a name="Example2"></a>
<I>NOTE: currently, we only support Jolt tranformation.  For more on the Jolt transformation, please, visit at http://jolt-demo.appspot.com/#inception</I>
- This is an example of exposing a microservice API using RouteOrchestrator with a single RouteHttp that uses Jolt transformation to do aggregation
- Create a file name RouteOrchestratorFile with the following content

```
{
  "Service": {
    "name": "findPlaceDetails RouteOrchestrator",
    "gatewayUri": "/findPlaceDetails",
    "httpMethods": [
      "get",
      "put",
      "post",
      "delete"
    ],
    "policy": [
      {
        "RouteOrchestrator": {
          "orchestrator": {
            "orchestrator": [
              {
                "aggregator": [
                  {
                    "RouteHttp": {
                      "targetUrl": "https://maps.googleapis.com/maps/api/geocode/json",
                      "httpMethod": "GET",
                      "parameters": [
                        {
                          "address": "${request.http.parameters.origins}"
                        },
                        {
                          "key": "AIzaSyCjIaHtSVulkeh1-nIgidHDaQS7ImW1Snk"
                        }
                      ],
                      "headers": [
                        {
                          "Accept": "application/json"
                        }
                      ],
                      "requestTransform": [],
                      "responseTransform": [
                        {
                          "jolt": [
                            {
                              "operation": "shift",
                              "spec": {
                                "results": {
                                  "0": {
                                    "formatted_address": "origin_address",
                                    "address_components": {
                                      "*": {
                                        "@long_name": "@(1,types[0])"
                                      }
                                    },
                                    "place_id": "place_id",
                                    "geometry": {
                                      "location": "location_coordinate"
                                    }
                                  }
                                }
                              }
                            }
                          ]
                        }
                      ]
                    }
                  }
                ]
              }
            ]
          }
        }
      }
    ]
  }
}
```

- Add your API to the gateway
```
curl --insecure \
     --user "admin:password" \
     --url https://localhost/quickstart/1.0/services \
     --data @RouteOrchestratorFile
```
- Verify that your API is exposed
```
curl --insecure --user "admin:password" https://localhost/quickstart/1.0/services
```
Should return a list containing your 'findPlaceDetails RouteOrchestrator' service.

- Use your exposed API

```
curl --insecure \
     --header "User-Agent: Mozilla/5.0" \
     'https://localhost/findPlaceDetails?origins=Vancouver,+BC,+Canada&destinations=Toronto,+ON,+Canada'

```

#### Example 3 – expose microservice API with transformation and aggregation<a name="Example3"></a>
- This is an example of exposing a microservice API using RouteOrchestrator with multiple RouteHttp that use Jolt transformation to do aggregation
- Create a file name RouteOrchestratorFile with the following content

```
{
  "Service": {
    "name": "findDistance RouteOrchestrator",
    "gatewayUri": "/findDistance",
    "httpMethods": [
      "get",
      "put",
      "post",
      "delete"
    ],
    "policy": [
      {
        "RouteOrchestrator": {
          "orchestrator": {
            "orchestrator": [
                {
                  "aggregator": [
                    {
                      "RouteHttp": {
                        "targetUrl": "https://maps.googleapis.com/maps/api/geocode/json",
                        "httpMethod": "GET",
                        "parameters": [
                          {
                            "address": "${request.http.parameters.origins}"
                          },
                          {
                            "key": "AIzaSyCjIaHtSVulkeh1-nIgidHDaQS7ImW1Snk"
                          }
                        ],
                        "headers": [
                          {
                            "Content-Type": "application/json"
                          },
                          {
                            "x-custom-header": "my-custom-header"
                          }
                        ],
                        "requestTransform": [],
                        "responseTransform": [
                          {
                            "jolt": [
                              {
                                "operation": "shift",
                                "spec": {
                                  "results": {
                                    "0": {
                                      "formatted_address": "origin_address",
                                      "address_components": {
                                        "*": {
                                          "@long_name": "@(1,types[0])"
                                        }
                                      },
                                      "place_id": "place_id",
                                      "geometry": {
                                        "location": "location_coordinate"
                                      }
                                    }
                                  }
                                }
                              }
                            ]
                          }
                        ]
                      }
                    },
                    {
                      "RouteHttp": {
                        "targetUrl": "https://maps.googleapis.com/maps/api/geocode/json",
                        "httpMethod": "GET",
                        "parameters": [
                          {
                            "address": "${request.http.parameters.destinations}"
                          },
                          {
                            "key": "AIzaSyCjIaHtSVulkeh1-nIgidHDaQS7ImW1Snk"
                          }
                        ],
                        "headers": [
                          {
                            "Content-Type": "application/json"
                          },
                          {
                            "x-custom-header": "my-custom-header"
                          }
                        ],
                        "requestTransform": [
                          {
                            "jolt": [
                              {
                                "operation": "shift",
                                "spec": {
                                  "results": {
                                    "0": {
                                      "formatted_address": "full_address",
                                      "address_components": {
                                        "*": {
                                          "@long_name": "@(1,types[0])"
                                        }
                                      },
                                      "place_id": "place_id",
                                      "geometry": {
                                        "location": "location_coordinate"
                                      }
                                    }
                                  }
                                }
                              }
                            ]
                          }
                        ],
                        "responseTransform": [
                          {
                            "jolt": [
                              {
                                "operation": "shift",
                                "spec": {
                                  "results": {
                                    "0": {
                                      "formatted_address": "destination_address",
                                      "address_components": {
                                        "*": {
                                          "@long_name": "@(1,types[0])"
                                        }
                                      },
                                      "place_id": "place_id",
                                      "geometry": {
                                        "location": "location_coordinate"
                                      }
                                    }
                                  }
                                }
                              }
                            ]
                          }
                        ]
                      }
                    },
                    {
                      "RouteHttp": {
                        "targetUrl": "https://maps.googleapis.com/maps/api/distancematrix/json",
                        "httpMethod": "GET",
                        "parameters": [
                          {
                            "origins": "${request.http.parameters.origins}"
                          },
                          {
                            "destinations": "${request.http.parameters.destinations}"
                          },
                          {
                            "mode": "driving"
                          },
                          {
                            "language": "en-EN"
                          },
                          {
                            "key": "AIzaSyCjIaHtSVulkeh1-nIgidHDaQS7ImW1Snk"
                          }
                        ],
                        "headers": [
                          {}
                        ],
                        "requestTransform": [
                          {
                            "jolt": [
                              {
                                "operation": "shift",
                                "spec": {
                                  "results": {
                                    "0": {
                                      "formatted_address": "full_address",
                                      "address_components": {
                                        "*": {
                                          "@long_name": "@(1,types[0])"
                                        }
                                      },
                                      "place_id": "place_id",
                                      "geometry": {
                                        "location": "location_coordinate"
                                      }
                                    }
                                  }
                                }
                              }
                            ]
                          }
                        ],
                        "responseTransform": [
                          {
                            "jolt": [
                              {
                                "operation": "shift",
                                "spec": {
                                  "@origin_addresses[0]": "origin",
                                  "@destination_addresses[0]": "destination",
                                  "rows": {
                                    "0": {
                                      "elements": {
                                        "*": {
                                          "distance": {
                                            "@text": "distance"
                                          },
                                          "duration": {
                                            "@text": "driving_duration"
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            ]
                          }
                        ]
                      }
                    }
                  ]
                }
            ]
          }
        }
      }
    ]
  }
}
```

- Add your API to the gateway
```
curl --insecure \
     --user "admin:password" \
     --url https://localhost/quickstart/1.0/services \
     --data @RouteOrchestratorFile
```
- Verify that your API is exposed
```
curl --insecure --user "admin:password" https://localhost/quickstart/1.0/services
```
Should return a list containing your 'findDistance RouteOrchestrator' service.

- Use your exposed API

```
curl --insecure \
     --header "User-Agent: Mozilla/5.0" \
     'https://localhost/findDistance?origins=Vancouver,+BC,+Canada&destinations=Toronto,+ON,+Canada'

```

### RouteOrchestrator Syntax<a name="HowTo"></a>

- Create/Define an API endpoint:
  The service template has the following format.

  ```
    {  
      "Service": {
        "name": "Sample to use RouteOrchestrator",
        "gatewayUri": "/findDistance",
        "httpMethods": [ "get", "put" , "post", "delete"],
        "policy": [
          {
            "RouteOrchestrator" :  <<... orchestrator meta data here ...>>

          }
        ]
      }
    }
  ```

    where the <b><<... orchestrator meta data here ...>></b>, at the high-level, has the following format

  ```
  {
    "orchestrator": {
      "orchestrator": [
      {
        "aggregator": [
          {
            "RouteHttp": {
              "targetUrl": "https://www.myurl.com",
              "httpMethod": "GET",
              "parameters": [
              ],
              "headers": [
              ],
              "requestTransform": [
              ],
              "responseTransform": [
              ]
            }
          }
        ]
      }
    }
  }
  ```

   The high-level skeleton above is the minimum/required meta data that needs to be pass-in as part of the API payload.
   - "orchestrator" can contain 1 or more 'aggregator'.  However, currently, we only support a single 'aggregator'.  

   - An "aggregator" can contain 1 or more 'RouteHttp'.  

   - Each "RouteHttp" must contain (as demonstrated above) "targetUrl", "httpMethod", "parameters", "headers", "requestTransform" and "responseTransform".  All of these are required with the exception that the "requestTransform" is currently not supported.  It can be left empty as shown above.  "requestTransform" will be available as part of the final release at a later date.  The <I>"targetUrl"</I> and <I>"httpMethod"</I> are <b>required</b> to fill with respective values.  All other such as "parameters", "headers", requestTransform and "responseTransformation" can be empty as shown.  If your API needs to use "parameters", "headers" and/or "responseTransform", the following are the format of each of the meta data.

#### aggregator:<a name="aggregator"></a>

  - Each 'aggregator' can have 1 or more RouteHttp.

  ```
  {
    "orchestrator": {
      "orchestrator": [
      {
        "aggregator": [
          {
            "RouteHttp": {}
          }
        ]
      }
    }
  }
  ```
  Each <b>'RouteHttp'</b> must contains <b>"targetUrl"</b> (value required), <b>"httpMethod"</b> (value required), <b>"parameters"</b> (can be empty, 1 or more key/value pair),
    <b>"headers"</b> (can be empty, 1 or more key/value pair), <b>"requestTransform"</b> (leave empty as show above. <b>"requestTransform"</b> will be supported in the final release), <b>"responseTransform"</b> (can be empty, 1 or more Jolt transformations)

#### parameters:<a name="parameters"></a>

  - if your api required <key=value>, as example, https://www.myhost.com/key1=value1&key2=value2   etc. then the format of the parameters as follow:

  ```
    "parameters": [
      {
        "key1":"value1"
      },
      {
        "key2":"value2"
      }
    ]
  ```

#### headers:<a name="headers"></a>
  - if your api required to pass in headers to the API call, you can do so with the following format.  These headers will be added to the list of headers from the client requests headers.

  ```
    "headers": [
    {
      "header1": "value1"
    },
    {
      "x-custom-header": "value2"
    }
    ]
  ```

#### requestTransform:<a name="requestTransform"></a>
  - The requestTransform is the transformation to be applied to the request payload.  The result of the transformation will be used as the payload for the next request.  <I>NOTE: currently, we do not support the requestTransform. So, it can be empty as specific above</I>.  

#### responseTransform:<a name="responseTransform"></a>
  - The responseTransform is the transformation to be applied to the request payload.  The result of the transformation will be concatenated as part of the result of the aggregation.  
    The format of the responseTransform is specified as follow:

  ```
  "responseTransform": [
    {
      "jolt": [
        {
          "operation": "shift",
          "spec": {
            <<...Jolt specification definition here...>>
          }
        }
      ]
    }
  ]
  ```
