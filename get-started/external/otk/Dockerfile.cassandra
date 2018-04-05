FROM cassandra:3.11

# make directory for the get started scripts
RUN mkdir get_started

# Add cql to setup schema and test data for OTK
ADD ./customize/db/cassandra/db_scripts/*.cql /get_started/db_scripts/

# Add script to execute cql upon the start up of cassandra container 
ADD ./customize/db/cassandra/setupSchemas.sh /get_started/setupSchemas.sh
