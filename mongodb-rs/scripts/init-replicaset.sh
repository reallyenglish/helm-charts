MASTER=""
MYSELF=""
HOSTNAME=$(hostname)

echo "rset-init: Starting mongod on ${HOSTNAME} ..."
/usr/bin/mongod --config=/config/mongod.conf &
until /usr/bin/mongo --eval 'printjson(db.serverStatus())'; do
  echo "rset-init: Waiting for mongod is up ..." && sleep 1
done

echo "rset-init: Mongod is up. Probing peers in ${SERVICE_NAME} ..."
for PEER in $(/work-dir/lookup-srv -srv=${SERVICE_NAME}); do
  if [[ "${PEER}" == *"${HOSTNAME}"* ]]; then
    MYSELF=$PEER
  elif /usr/bin/mongo --host=${PEER} --eval="rs.isMaster()['ismaster'] && 'ISMASTER'" | grep -q ISMASTER; then
    MASTER=$PEER
  fi
done

if [ -z "$MASTER" ]; then
  if /usr/bin/mongo --quiet --eval="rs.status()['set']" | grep -q ${REPLICA_SET}; then
    echo "rset-init: Replica set was already initialized on ${MYSELF} ..."
  else
    echo "rset-init: Initializing replica set for ${MYSELF} ..."
    /usr/bin/mongo --eval="printjson(rs.initiate({'_id': '${REPLICA_SET}', 'members': [{'_id': 0, 'host': '${MYSELF}'}]}))"
  fi
else
  echo "rset-init: Adding myself to the replica set at ${MASTER} ..."
  /usr/bin/mongo --host=${MASTER} --eval="printjson(rs.add('${MYSELF}'))"
fi

echo "rset-init: Stopping mongod on ${HOSTNAME} ..."
/usr/bin/mongo admin --eval 'db.shutdownServer({force: true})'
