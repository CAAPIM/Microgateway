#!/usr/bin/env bash
# This script is to setup OTK schema and test data in the cassandra docker container.

set -e
export TERM=xterm

if ! hash netcat 2>/dev/null; then
    apt-get update && apt-get install -y netcat
fi

bash /docker-entrypoint.sh "cassandra"

if ! nc -z localhost 9042; then
    while ! nc -z localhost 9042; do
       sleep 1
    done
    echo "Cassandra is up and running."
fi

echo "Checking if product schemas need to be configured..."

function cqlExecution () {
    scriptName=${1}
    keyspace=${2}
    isRequired=${3}

    if [ -f /get_started/db_scripts/${scriptName} ]; then
        cqlsh --keyspace=${keyspace} -f /get_started/db_scripts/${scriptName}
        echo "${scriptName} successfully ran."
    else
        if [[ ${isRequired} == true ]]; then
            echo "ERROR: Required script ${scriptName} was not found. Verify that it exists in the mounted directory and try again."
            echo "Aborting!"
            exit 1;
        else
            echo "WARNING: ${scriptName} was not found. Set up will continue."
        fi
    fi
}

otkKeyspace="${OTK_KEYSPACE,,}"

if ! cqlsh -e "describe keyspaces" | grep -wq "${otkKeyspace}" || ! cqlsh --keyspace=${otkKeyspace} -e "describe tables" | grep -wq "otk_version" ; then
    echo "Setting up OTK schema and test data..."

    cqlsh -e "CREATE KEYSPACE IF NOT EXISTS ${otkKeyspace} WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };"

    cqlExecution "otk_db_schema_cassandra.cql"   "${otkKeyspace}" true
    cqlExecution "otk_db_testdata_cassandra.cql" "${otkKeyspace}" false
fi

echo "All setup complete."

watch -n 1 -e "tail -n 1 /var/log/cassandra/system.log"
