## Redis High Availability Helm Chart

## Installing the Chart

To install the chart with the release name `rdb`:

```bash
$ helm repo add reallyenglish https://storage.googleapis.com/re-charts
$ helm install --name rdb reallyenglish/redis-ha
```

## Configuration

The following tables lists the configurable parameters of the redis-ha chart and their default values.

| Parameter                        | Description                             | Default                               |
| -------------------------------- | --------------------------------------- | ------------------------------------- |
| `serviceName`                    | Headles service name                    |                                       |
| `statefulSetName`                | Statefulset name                        | `rds`                                 |
| `replicaCount`                   | Statefulset replica count               | `3`                                   |
| `server.imageRepository`         | Redis image repo                        | `reallyenglish/k8s-redis-ha-server`   |
| `server.imageTag`                | Redis image tag                         | `3.2.10`                               |
| `server.imagePullPolicy`         | Image pull policy                       | `IfNotPresent`                        |
| `server.port`                    | Redis port                              | `6379`                                |
| `server.dataDir`                 | Redis data directory                    | `/data`                               |
| `server.protectedMode`           | Redis protected mode                    | `no`                                  |
| `server.appendOnly`              | Redis appendonly config                 | `yes`                                 |
| `server.appendFsync`             | Redis appendfsync config                | `always`                              |
| `server.resources`               | Redis resource requests/limits          | `cpu 100m, memory 128Mi`              |
| `sentinel.imageRepository`       | Sentinel image repository               | `reallyenglish/k8s-redis-ha-sentinel` |
| `sentinel.imageTag`              | Sentinel image tag                      | `3.2.10`                               |
| `sentinel.imagePullPolicy`       | Sentinel image pull policy              | `IfNotPresent`                        |
| `sentinel.port`                  | Sentinel port                           | `26379`                               |
| `sentinel.masterName`            | Redis master name for sentinel          | `ha-master`                           |
| `sentinel.quorum`                | Sentinel quorum number                  | `2`                                   |
| `sentinel.downAfterMilliseconds` | Sentinel down-after-milliseconds config | `10000`                               |
| `sentinel.parallelSyncs`         | Sentinel parallel-syncs config          | `1`                                   |
| `sentinel.failoverTimeout`       | Sentinel failover-timeout config        | `60000`                               |
| `sentinel.resources`             | Sentinel resource requests/limits       | `cpu 100m, memory 128Mi`              |
| `persistence.enabled`            | Enables persistence using PVC           | `true`                                |
| `persistence.class`              | Persistent Volume Storage Class         |                                       |
| `persistence.accessMode`         | Persistent Volume Access Mode           | `ReadWriteOnce`                       |
| `persistence.size`               | Persistent Volume Storage Size          | `4Gi`                                 |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

```bash
$ helm install --name rdb reallyenglish/redis-ha --set serviceName=redis,persistence.enabled=false
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name rdb -f values.yaml reallyenglish/redis-ha
```
