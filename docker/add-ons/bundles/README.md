## Extending Quick Start Templates with Bundles
The Quick Start Solution may be extended by importing RESTMAN bundles on startup. This allows us and customers to mix-and-match solutions that they intend to use with the Gateway, producing a smaller, purpose-tailored image.

### How Does it Work?
On startup, the Gateway will look in the directory `/opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/` for files ending in `.bundle`, and loads them in natural order. For this reason, we generally name them with numbers indicating the order in which they shoulud be loaded, e.g. `60_consul.bundle`.

### How Do I Make a Bundle?
A bundle is just a RESTMAN bundle, which you can acquire using Gateway Migration Utility. For a bundle to be imported on startup, it _must not_ be encrpyted. To ensure Gateway Migration Utility does not encrypt the bundle, pass the flag indicating that encrypted secrets should be excluded.

Currently, bundles are exported by exporting the "Custom Encapsulated Assertion Fragments" folder.

An example GMU command to export the "Custom Encapsulated Assertion Fragments" folder:

  ./GatewayMigrationUtility.sh migrateOut --trustCertificate --trustHostname --encassAsPolicyDependency --excludeEncryptedSecrets --dest encass.bundle --folderName "/Quick Start Templates/Encapsulated Assertion Fragments/Custom Encapsulated Assertion Fragments" --host localhost -u admin --plaintextPassword password
  
### How Do I Bake a new image
* Drop the .bundle file in this folder. (docker/add-ons/bundles) 
* Go to ../../ folder and modify docker-compose.yml. Comment `image: <microgateway docker image>` and uncomment the 3 lines under `build:` under ssg container
* run `docker-compose up -d --build`
  
### How Do I Configure an Encapsulated Assertion From One of These Bundles?
The same way you configure any other encapsulated assertions - you provide the input values in the JSON payload sent to /quickstart/1.0/services when publishing the service. Each encass's documentation should contain information about the input names and allowed values.
