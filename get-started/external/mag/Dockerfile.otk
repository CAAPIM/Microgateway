#
#  Copyright (c) 2017 CA. All rights reserved.
#
#  This software may be modified and distributed under the terms
#  of the MIT license. See the LICENSE file for details.
#
FROM caapimcollab/mobile-app-services:4.1.00-beta

# Enable Restman and Policyman
RUN mkdir -p /opt/docker/rc.d/bootstrap/ && \
    touch /opt/docker/rc.d/bootstrap/restman  && \
    touch /opt/docker/rc.d/bootstrap/policyman

# Add solution kits
ADD ./solutionkits/*.skmult /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/

# Add MAG bundles
ADD ./customize/bundle/*.bundle /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/

# Add after start RESTMAN XML files (processed by the scripts below)
ADD ./customize/bundle/after-start/*.xml /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/
ADD ./customize/bundle/after-start/*.bundle /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/

# Add after start scripts
ADD ./customize/rc.d/*.sh /opt/docker/rc.d/after-start/

# Add OTK users and OAuth clients automatically
COPY ./customize/db/liquibase/*.xml /db/liquibase/

# Add licenses
ADD ./customize/license/*.xml /opt/SecureSpan/Gateway/node/default/etc/bootstrap/license/
