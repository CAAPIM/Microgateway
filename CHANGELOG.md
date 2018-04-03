# Changelog

- [1.0.0-CR01 (2018-03-26)](#1.0.0-CR01)
- [1.0.0 (2017-09-21)](#1.0.0)

## 1.0.0-CR01 (2018-03-26) <a name="1.0.0-CR01"></a>

### Templates for API policies

- API Authentication
  - Require client TLS certificate ([documentation](https://docops.ca.com/ca-microgateway/1-0/EN/working-with-the-ca-microgateway/quickstart-templates/requireclienttlscertificate))

### Platform support

- Kubernetes ([documentation](https://docops.ca.com/ca-microgateway/1-0/EN/getting-started-with-the-ca-microgateway/run-the-ca-microgateway-in-kubernetes))

### Signed SSL/TLS certificate provisioning
- Auto-provisioning of signed SSL/TLS certificates of CA API Gateway, CA Microgateway and microservices

  - Enable Mutual TLS authentication between CA API Gateway, CA Microgateway and microservices
  - Protect API traffic flow with a JWT from CA Edge API Gateway, to CA Microgateway to microservices
  - Management of CA Microgateway nodes from a web console

### Container

- Based on API Gateway 9.3 ([documentation](https://docops.ca.com/ca-api-gateway/9-3/en))
  - *Note: Please update Policy Manager to v.9.3.00 as described in the [prerequisites](https://docops.ca.com/ca-microgateway/1-0/EN/introduction-to-the-ca-microgateway/prerequisites-for-ca-microgateway). It can be downloaded from the trial page*
- Health Check API opened to any load balancers ([documentation](https://docops.ca.com/ca-microgateway/1-0/EN/getting-started-with-the-ca-microgateway/get-the-ca-microgateway-health))
- Run custom provisioning scripts before the CA Microgateway starts ([documentation](https://docops.ca.com/ca-microgateway/1-0/EN/working-with-the-ca-microgateway/create-your-own-microgateway-image))


## 1.0.0 (2017-09-21) <a name="1.0.0"></a>

### Templates for API policies

- API Authentication
  - Basic authentication
  - OAuth
  - JWT
  - LDAP  

- API Security
  - CORS
  - Code injection protection
  - TLS enforcement

- API Traffic Control
  - Circuit breaker
  - Rate limit

- API Aggregation/Orchestration
  - JSON to JSON transformation using JOLT
  - HTTP routes

### Logging and Auditing

### Plugin support

- Load bundle files to add new templates

### Platform support

- Docker
- OpenShift
