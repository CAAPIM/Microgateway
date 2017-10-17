# Microgateway API samples

- Gatewayfile-with-route
    - route the http request the a microservice
    
- Gatewayfile-with-basic-auth-route
    - Basic authentication
    - **then** route the http request the a microservice

- Gatewayfile-with-oauth-route
    - OAuth
    - **then** route the http request the a microservice

- Gatewayfile-with-frontoauth-orchestrator-oauth-route
    - OAuth
    - **then** orchestrate two backend microservices
      - OAuth at the microservice level
      - aggregate their results

- Gatewayfile-with-frontoauth-orchestrator-oauth-route-with-params
    - OAuth
    - **then** orchestrate
      - OAuth at the microservice level
      - one microservice with OAuth and filter its result
      - a second microservice using the filtered result of the previous microservice
