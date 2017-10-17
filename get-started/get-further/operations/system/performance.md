## Performance tuning

### Gateway tuning

- SSG_HTTP_CORE_CONCURRENCY: "500"

The initial number of threads

- SSG_HTTP_MAX_CONCURRENCY: "750"

The maximum number of threads

- SSG_JVM_HEAP: "2560m"

Specifies the maximum size, in bytes, of the memory allocation pool (Java XMX
memory allocation) for the gateway process. See more info at http://docs.oracle.com/javase/7/docs/technotes/tools/solaris/java.html

### Tune the Java parameters

The `JVM_ARGS` environment variable will set custom Java parameters when starting
the Microgateway.

### Manage remotely the Gateway resources with JMX (Java Management Extensions)

The JMX parameters is passed to the `JVM_ARGS` environment variable.
```
JVM_ARGS: "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9010 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.rmi.port=9010 -Djava.rmi.server.hostname=apis.mycompany.com"
```
In the above example, the JMX server will listen on port `9010` with no
authentication and SSL. The option `java.rmi.server.hostname` is the hostname
of your container.

In production, authentication and ssl should be enabled.

Details about JMX parameters can be found at
http://docs.oracle.com/javase/7/docs/technotes/guides/management/agent.html

A good blog post about monitoring JVM apps in Docker at
http://mintbeans.com/jvm-monitoring-docker/
