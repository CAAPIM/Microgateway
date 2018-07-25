## Register the Google Root TLS certificate in the Gateway

1. Open the Docker Compose file of the Gateway: `get-started/docker-compose/docker-compose.yml`
2. Add the following environment variables to the `ssg` service under the `environment` section:
  ```
      CERT_0: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUVYRENDQTBTZ0F3SUJBZ0lOQWVPcE1CejhjZ1k0UDVwVEhUQU5CZ2txaGtpRzl3MEJBUXNGQURCTU1TQXcKSGdZRFZRUUxFeGRIYkc5aVlXeFRhV2R1SUZKdmIzUWdRMEVnTFNCU01qRVRNQkVHQTFVRUNoTUtSMnh2WW1GcwpVMmxuYmpFVE1CRUdBMVVFQXhNS1IyeHZZbUZzVTJsbmJqQWVGdzB4TnpBMk1UVXdNREF3TkRKYUZ3MHlNVEV5Ck1UVXdNREF3TkRKYU1GUXhDekFKQmdOVkJBWVRBbFZUTVI0d0hBWURWUVFLRXhWSGIyOW5iR1VnVkhKMWMzUWcKVTJWeWRtbGpaWE14SlRBakJnTlZCQU1USEVkdmIyZHNaU0JKYm5SbGNtNWxkQ0JCZFhSb2IzSnBkSGtnUnpNdwpnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFES1VrdnFIdi9PSkd1bzJuSVlhTlZXClhRNUlXaTAxQ1haYXo2VElITEdwL2xPSis2MDAvNGhibjd2bjZBQUIzRFZ6ZFFPdHM3RzVwSDBySm5uT0ZVQUsKNzFHNG56S01mSENHVWtzVy9tb25hK1kyZW1KUTJOK2FpY3dKS2V0UEtSU0lnQXVQT0I2QWFoaDhIYjJYTzNoOQpSVWsyVDBITm91QjJWenhvTVhsa3lXN1hVUjVtdzZKa0xIbkE1MlhEVm9SVFdrTnR5NW9DSU5MdkdtblJzSjF6Cm91QXFZR1ZRTWMvN3N5Ky9FWWhBTHJWSkVBOEtidHlYK3I4c253VTVDMWhVcndhVzZNV09BUmE4cUJwTlFjV1QKa2FJZW9Zdnkvc0dJSkVtalIwdkZFd0hkcDFjU2FXSXI2LzRnNzJuN09xWHdmaW51N1pZVzk3RWZvT1NRSmVBegpBZ01CQUFHamdnRXpNSUlCTHpBT0JnTlZIUThCQWY4RUJBTUNBWVl3SFFZRFZSMGxCQll3RkFZSUt3WUJCUVVICkF3RUdDQ3NHQVFVRkJ3TUNNQklHQTFVZEV3RUIvd1FJTUFZQkFmOENBUUF3SFFZRFZSME9CQllFRkhmQ3VGQ2EKWjNaMnNTM0NodENEb0g2bWZycExNQjhHQTFVZEl3UVlNQmFBRkp2aUIxZG5IQjdBYWdiZVdiU2FMZC9jR1lZdQpNRFVHQ0NzR0FRVUZCd0VCQkNrd0p6QWxCZ2dyQmdFRkJRY3dBWVlaYUhSMGNEb3ZMMjlqYzNBdWNHdHBMbWR2CmIyY3ZaM055TWpBeUJnTlZIUjhFS3pBcE1DZWdKYUFqaGlGb2RIUndPaTh2WTNKc0xuQnJhUzVuYjI5bkwyZHoKY2pJdlozTnlNaTVqY213d1B3WURWUjBnQkRnd05qQTBCZ1puZ1F3QkFnSXdLakFvQmdnckJnRUZCUWNDQVJZYwphSFIwY0hNNkx5OXdhMmt1WjI5dlp5OXlaWEJ2YzJsMGIzSjVMekFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBCkhMZUpsdVJUN2J2czI2Z3lBWjhzbzgxdHJVSVNkN080NXNrRFVtQWdlMWNueGhHMVAyY05tU3hiV3NvaUN0MmUKdXg5TFNEK1BBajJMSVlSRkhXMzEvNnhvaWMxazR0YldYa0RDamlyMzd4VFROcVJBTVBVeUZSV1NkdnQrbmxQcQp3bmI4T2EySS9tYVNKdWtjeERqTlNmcERoL0JkMWxaTmdkZC84Y0xkc0UzK3d5cHVmSjl1WE8xaVFwbmg5emJ1CkZJd3NJT05HbDFwM0E4Q2d4a3FJL1VBaWgzSmFHT3FjcGNkYUNJemtCYVI5dVlRMVg0azJWZzVBUFJMb3V6VnkKN2E4SVZrNnd1eTZwbStUN0hUNExZOGliUzVGRVpsZkFGTFNXOE53c1Z6OVNCSzJWcW4xTjBQSU1uNXhBNk5aVgpjN284MzVETEFGc2hFV2ZDN1RJZTNnPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
      CERT_0_TRUST_ANCHOR: "true"
      CERT_0_TRUSTED_FOR_SIGNING_SERVER_CERTS: "true"
      CERT_0_VERIFY_HOSTNAME: "false"
  ```

  *Note: CERT_0 contains the Google Internet Authority G3 certificate encoded in base64*

  *Note 2: the certificate will expire on December 14, 2021. You can download a
  newer version from https://pki.goog/

  *Note 3: use below command to extract fingerprint of newly downloaded certificate
  ```
    cat <CERT_NAME>.pem | base64
  ```
  Replace the fingerprint extracted under CERT_0 key  
  
3. Update the Gateway with the new configuration:
  ```
  docker-compose --project-name microgateway \
                 --file docker-compose.yml \
                 --file docker-compose.db.consul.yml \
                 --file docker-compose.lb.dockercloud.yml \
                 up -d --build
  ```
