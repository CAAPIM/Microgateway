## Orchestrate API/Microservice with RouteOrchestrator Template <a name="RouteOrchestrator"></a>

Table of Contents:

* [Description](#Description)
* [Example](#Example)
  * [Prerequisite - Register the Google Root TLS certificate](#register-cert)
  * [Example 1 – expose microservice API without transformation](#Example1)
  * [Example 2 - expose microservice API with transformation using Jolt](#Example2)
  * [Example 3 – expose microservice API with transformation and aggregation](#Example3)
  * [Example 4 – expose micro-service API with orchestration: reference sub-level of orchestrated data](#Example4)
  * [Example 5 – expose micro-service API with orchestration: reference top-level of orchestrated data](#Example5)

* [RouteOrchestrator Syntax](#HowTo)
	* [aggregator](#aggregator)
	* [parameters](#parameters)
	* [headers](#headers)
	* [requestTransform](#requestTransform)
	* [responseTransform](#responseTransform)

* [Additional Resources](#Resources)
  * [Jolt Transformation Test](#Jolt)



### Description <a name="Description"></a>
RouteOrchestrator assertion provides an abstraction layer that will allow our customers to send a single query for a complex business logic without having to know many backend services API endpoints</b>.


### Example<a name="Example"></a>

#### Prerequisite - Register the Google Root TLS certificate  <a name="register-cert"></a>

Register the Google Root TLS certificate ([link](register-google-tls-certificate.md))
because the example 2 and 3 use the Google Maps APIs over HTTPS as backend services.

#### Example 1 – expose microservice API without transformation  <a name="Example1"></a>
- This is a simple example of exposing a microservice API using RouteOrchestrator with no transformation

- Create a file name RouteOrchestratorFile with the following content

```json
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
          "rule": {
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

```json
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
          "rule": {
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

```json
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
          "rule": {
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

#### Example 4 – expose micro-service API with orchestration: reference sub-level of orchestrated data<a name="Example4"></a>
- This is an example of exposing a micro-service API using RouteOrchestrator with multiple aggregators, each of which produced an aggregated data.  The subsequent aggregator referencing data from the aggregated results of previous aggregators.
- The first aggregator:
  - accepts an origin and a destination locations/addresses from the request parameters (ie. ${request.http.parameters.origins} and ${request.http.parameters.destinations})
  - calling a backend Google API to resolve the locations/addresses into more details
- The <b>orchestrator_transform</b> is the transformation applied to the aggregated data of previous aggregator(s).  Part or all of the result of the "orchestrator_transform" can be used to "orchestrate" the next aggregator(s)
- The second aggregator:
  - calling backend Google API to get driving direction between the origin and destination addresses by using/referencing the "place_id" of the origin (@##@{orchestrator.intermediate.place_id[0]) and destination (@##@{orchestrator.intermediate.place_id[1]) locations/addresses from the result of the last "orchestrator_transform".  The "place_id", in this case, is the sub-level of the orchestrated data.  To access to the specific level, we reference with the index of the data.  In this case, the orchestratated data is an a array of 2 detailed addresses each of which has a "place_id".  To reference each, we use the index as "place_id[0]" and "place_id[1]"
  - calling backend Google API to calculate the distance between the origin and destination addresses by using/referencing the "place_id" of the origin and destination locations/addresses from the result of the last "orchestrator_transform".
- The <b>result_transform</b>, if existed, is the final transformation that will be applied to the result before returning as the response of the request.

- Create a file name RouteOrchestratorFile with the following content

```json
{
  "Service": {
    "name": "Get Travel Distance and Turn-by-Turn Driving Direction Between Location",
    "gatewayUri": "/findDistanceDrivingDirection",
    "httpMethods": [
      "get",
      "put",
      "post",
      "delete"
    ],
    "policy": [
      {
        "RouteOrchestrator": {
          "rule": {
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
                      "headers": [],
                      "requestTransform": [],
                      "responseTransform": [
                        {
                          "jolt": [
                            {
                              "operation": "shift",
                              "spec": {
                                "results": {
                                  "*": {
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
                      "headers": [],
                      "requestTransform": [],
                      "responseTransform": [
                        {
                          "jolt": [
                            {
                              "operation": "shift",
                              "spec": {
                                "results": {
                                  "*": {
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
                  }
                ]
              },
              {
                "orchestrator_transform": {
                  "jolt": [
                    {
                      "operation": "shift",
                      "spec": {
                        "*": {
                          "origin_address": "address",
                          "destination_address": "address",
                          "place_id": "place_id",
                          "location_coordinate": "location"
                        }
                      }
                    }
                  ]
                }
              },
              {
                "aggregator": [
                  {
                    "RouteHttp": {
                      "targetUrl": "https://maps.googleapis.com/maps/api/directions/json",
                      "httpMethod": "GET",
                      "parameters": [
                        {
                          "origin": "place_id:@##@{orchestrator.intermediate.place_id[0]}"
                        },
                        {
                          "destination": "place_id:@##@{orchestrator.intermediate.place_id[1]}"
                        },
                        {
                          "key": "AIzaSyCjIaHtSVulkeh1-nIgidHDaQS7ImW1Snk"
                        }
                      ],
                      "headers": [],
                      "requestTransform": [],
                      "responseTransform": [
                        {
                          "jolt": [
                            {
                              "operation": "shift",
                              "spec": {
                                "routes": {
                                  "*": {
                                    "legs": {
                                      "*": {
                                        "steps": {
                                          "*": {
                                            "html_instructions": "html_instructions"
                                          }
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
                  },
                  {
                    "RouteHttp": {
                      "targetUrl": "https://maps.googleapis.com/maps/api/distancematrix/json",
                      "httpMethod": "GET",
                      "parameters": [
                        {
                          "origins": "place_id:@##@{orchestrator.intermediate.place_id[0]}"
                        },
                        {
                          "destinations": "place_id:@##@{orchestrator.intermediate.place_id[1]}"
                        },
                        {
                          "key": "AIzaSyCjIaHtSVulkeh1-nIgidHDaQS7ImW1Snk"
                        }
                      ],
                      "headers": [],
                      "requestTransform": [
                        {
                          "jolt": []
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
              },
              {
                "result_transform": {
                  "jolt": [
                    {
                      "operation": "shift",
                      "spec": {
                        "*": ""
                      }
                    }
                  ]
                }
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
Should return a list containing your 'Get Travel Distance and Turn-by-Turn Driving Direction Between Location' service.

- Use your exposed API

```
curl --insecure \
     --header "User-Agent: Mozilla/5.0" \
     'https://localhost/findDistanceDrivingDirection?origins=CA+Technologies,+Vancouver,+BC,+Canada&destinations=CA+Technologies,+Toronto,+ON,+Canada'

```

#### Example 5 – expose micro-service API with orchestration: reference top-level of orchestrated data<a name="Example5"></a>

- This is an example of exposing a micro-service API using RouteOrchestrator with multiple aggregators, each of which produced an aggregated data. The subsequent aggregator referencing data from the aggregated results of previous aggregators (ie. this is the definition of 'orchestrator').  In this case, the weather routing will reference the longitude (@##@{orchestrator.intermediate.location.lng}) and latitude (@##@{orchestrator.intermediate.location.lat}) values which are part of the previous aggregator's result.  The "location.lat" and "location.lng" are the top level of the orchestrated data.

- In this example, by giving a location, it will, first, retrieve the detailed address of the given location.  From the detailed address, it will use/reference the longitude and latitude of the detailed address to retrieve the current weather of the location.  A 'location' can be an a partial or a full address; for example, 885 W Georgia Street, Vancouver.  A 'location' can be a named location such as "pacific center, vancouver, bc" or "BC stadium"..etc.  Whatever the 'location' is, this example will determine the address of the 'location'.  And, from the address, it will determine the current weather

- Create a file name RouteOrchestratorFile with the following content

```json
{
  "Service": {
    "name": "Current Weather Info",
    "gatewayUri": "/getCurrentWeather",
    "httpMethods": [
      "get",
      "put",
      "post",
      "delete"
    ],
    "policy": [
      {
        "RouteOrchestrator": {
          "rule": {
            "orchestrator": [
              {
                "aggregator": [
                  {
                    "RouteHttp": {
                      "targetUrl": "https://maps.googleapis.com/maps/api/geocode/json",
                      "httpMethod": "GET",
                      "parameters": [
                        {
                          "address": "${request.http.parameters.location}"
                        },
                        {
                          "key": "AIzaSyCjIaHtSVulkeh1-nIgidHDaQS7ImW1Snk"
                        }
                      ],
                      "headers": [],
                      "requestTransform": [],
                      "responseTransform": [
                        {
                          "jolt": [
                            {
                              "operation": "shift",
                              "spec": {
                                "results": {
                                  "*": {
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
              },
              {
                "orchestrator_transform": {
                  "jolt": [
                    {
                      "operation": "shift",
                      "spec": {
                        "*": {
                          "origin_address": "address",
                          "place_id": "place_id",
                          "location_coordinate": "location"
                        }
                      }
                    }
                  ]
                }
              },
              {
                "aggregator": [
                  {
                    "RouteHttp": {
                      "targetUrl": "http://api.openweathermap.org/data/2.5/weather",
                      "httpMethod": "GET",
                      "parameters": [
                        {
                          "lat": "@##@{orchestrator.intermediate.location.lat}"
                        },
                        {
                          "lon": "@##@{orchestrator.intermediate.location.lng}"
                        },
                        {
                          "appid": "7b967de9e82dce19f7af2e3dcefd005f"
                        },
                        {
                          "units": "metric"
                        }
                      ],
                      "headers": [],
                      "requestTransform": [],
                      "responseTransform": [
                        {
                          "jolt": [
                            {
                              "operation": "shift",
                              "spec": {
                                "name": "name",
                                "weather": {
                                  "*": {
                                    "description": "current_condition"
                                  }
                                },
                                "main": {
                                  "temp": "temp",
                                  "temp_min": "temp_min",
                                  "temp_max": "temp_max"
                                },
                                "wind": {
                                  "speed": "wind_speed"
                                },
                                "dt": "data_time",
                                "sys": {
                                  "sunset": "sunset",
                                  "sunrise": "sunrise"
                                }
                              }
                            }
                          ]
                        }
                      ]
                    }
                  }
                ]
              },
              {
                "result_transform": {
                  "jolt": [
                    {
                      "operation": "shift",
                      "spec": {
                        "*": ""
                      }
                    }
                  ]
                }
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
Should return a list containing your 'Current Weather Info' service.

- Use your exposed API

```
curl --insecure \
     --header "User-Agent: Mozilla/5.0" \
     'https://localhost/getCurrentWeather?location=CA+Technologies,+Vancouver,+BC,+Canada'

or

curl --insecure \
     --header "User-Agent: Mozilla/5.0" \
     'https://localhost/getCurrentWeather?location=Banff+National+Park,+AB,+Canada'

or
curl --insecure \
     --header "User-Agent: Mozilla/5.0" \
     'https://localhost/getCurrentWeather?location=885+W+Georgia+Street,+Vancouver,+BC,+Canada'

```



### RouteOrchestrator Syntax<a name="HowTo"></a>

- Create/Define an API endpoint:
  The service template has the following format.

  ```json
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

  ```json
  {
    "rule": {
      "orchestrator": [
        {
          "aggregator": [
            {
              "RouteHttp": {
                "targetUrl": "https:\/\/www.myurl.com",
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
      ]
    }
  }
  ```

   The high-level skeleton above is the minimum/required meta data that needs to be pass-in as part of the API payload.
   - "orchestrator" can contain 1 or more 'aggregator'.  However, currently, we only support a single 'aggregator'.  

   - An "aggregator" can contain 1 or more 'RouteHttp'.  

   - Each "RouteHttp" must contain (as demonstrated above) "targetUrl", "httpMethod", "parameters", "headers", "requestTransform" and "responseTransform".  All of these are required with the exception that the "requestTransform" is currently not supported.  It can be left empty as shown above.  "requestTransform" will be available as part of the final release at a later date.  The <I>"targetUrl"</I> and <I>"httpMethod"</I> are <b>required</b> to fill with respective values.  All other such as "parameters", "headers", requestTransform and "responseTransformation" can be empty as shown.  If your API needs to use "parameters", "headers" and/or "responseTransform", the following are the format of each of the meta data.

#### aggregator:<a name="aggregator"></a>

  - Each 'aggregator' can have 1 or more RouteHttp.

  ```json
  {
    "rule": {
      "orchestrator": [
        {
          "aggregator": [
            {
              "RouteHttp": {

              }
            }
          ]
        }
      ]
    }
  }
  ```
  Each <b>'RouteHttp'</b> must contains <b>"targetUrl"</b> (value required), <b>"httpMethod"</b> (value required), <b>"parameters"</b> (can be empty, 1 or more key/value pair),
    <b>"headers"</b> (can be empty, 1 or more key/value pair), <b>"requestTransform"</b> (leave empty as show above. <b>"requestTransform"</b> will be supported in the final release), <b>"responseTransform"</b> (can be empty, 1 or more Jolt transformations)

#### parameters:<a name="parameters"></a>

  - if your api required <key=value>, as example, https://www.myhost.com/key1=value1&key2=value2   etc. then the format of the parameters as follow:

  ```json
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

  ```json
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

  ```json
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

### Additional Resources<a name="Resources"></a>
#### Jolt Transformation <a name="Jolt"></a>
  - You can use ( http://jolt-demo.appspot.com ) to test and to try out your Jolt transformation to make sure the transformation is working as you expected.  Once the Jolt transformation is working as the way you wanted, you can copy/paste the "Jolt Spec" part into the "jolt" transform of the orchestrator.
