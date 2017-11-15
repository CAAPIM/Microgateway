FROM caapim/microgateway:1.0.00

# If one bundle is dependent on another, make sure that the dependent loads later
# The load order is based on the bundle filename following the ASCII sort order
# e.g. a.bundle will load before b.bundle
ADD ./bundles/*.bundle /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/

# To use loading QuickStart services from JSON files, please change to
# SCALER_ENABLE: "false" and uncomment the following line
ADD ./services/*.json /opt/SecureSpan/Gateway/node/default/etc/bootstrap/qs/
