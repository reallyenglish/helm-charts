EPS=""
for i in $(seq 0 $((${INITIAL_CLUSTER_SIZE} - 1))); do
    EPS="${EPS}${EPS:+,}http://${SET_NAME}-${i}.${SET_NAME}:2379"
done

HOSTNAME=$(hostname)

member_hash() {
    etcdctl member list | grep http://${HOSTNAME}.${SET_NAME}:2380 | cut -d':' -f1 | cut -d'[' -f1
}

echo "Removing ${HOSTNAME} from etcd cluster"

ETCDCTL_ENDPOINT=${EPS} etcdctl member remove $(member_hash)
if [ $? -eq 0 ]; then
    # Remove everything otherwise the cluster will no longer scale-up
    rm -rf /var/run/etcd/*
fi
