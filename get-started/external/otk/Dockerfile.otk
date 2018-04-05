#
#  Copyright (c) 2017 CA. All rights reserved.
#
#  This software may be modified and distributed under the terms
#  of the MIT license. See the LICENSE file for details.
#
FROM caapim/oauth-toolkit:4.2.00

# Enable Restman and Policyman
RUN mkdir -p /opt/docker/rc.d/bootstrap/ && \
    touch /opt/docker/rc.d/bootstrap/restman  && \
    touch /opt/docker/rc.d/bootstrap/policyman

# Add after start RESTMAN XML files (processed by the scripts below)
ADD ./customize/bundle/after-start/*.xml /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/
ADD ./customize/bundle/after-start/*.bundle /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/
