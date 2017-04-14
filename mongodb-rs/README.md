# MongoDB Replica Set Helm Chart

## Prerequisites Details
* Kubernetes 1.6+ for initContainers
* PV support on the underlying infrastructure.

## StatefulSet Details
* https://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/

## StatefulSet Caveats
* https://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/#limitations

## TODO
* Set up authorization between replica set peers.
* Add liveness probe

## Chart Details

This chart implements a dynamically scalable [MongoDB replica set](https://docs.mongodb.com/manual/tutorial/deploy-replica-set/)
using Kubernetes StatefulSets and Init Containers.

## Installing the Chart

To install the chart with the release name `my-app`:

```console
$ helm repo add reallyenglish https://storage.googleapis.com/re-charts
$ helm install --name my-app --namespace demo --set nameOverride=mongo,persistentVolume.storageClass=standard --debug reallyenglish/mongodb-rs
```

## Configuration

The following tables lists the configurable parameters of the mongodb chart and their default values.

| Parameter                       | Description                                                               | Default                                             |
| ------------------------------- | ------------------------------------------------------------------------- | --------------------------------------------------- |
| `replicaSet`                    | Name of the replica set                                                   | rs0                                                 |
| `replicas`                      | Number of replicas in the replica set                                     | 3                                                   |
| `port`                          | MongoDB port                                                              | 27017                                               |
| `installImage.name`             | Image name for the init container that establishes the replica set        | gcr.io/google_containers/mongodb-install            |
| `installImage.tag`              | Image tag for the init container that establishes the replica set         | 0.3                                                 |
| `installImage.pullPolicy`       | Image pull policy for the init container that establishes the replica set | IfNotPresent                                        |
| `image.name`                    | MongoDB image name                                                        | mongo                                               |
| `image.tag`                     | MongoDB image tag                                                         | 3.2                                                 |
| `image.pullPolicy`              | MongoDB image pull policy                                                 | IfNotPresent                                        |
| `podAnnotations`                | Annotations to be added to MongoDB pods                                   | {}                                                  |
| `resources`                     | Pod resource requests and limits                                          | {}                                                  |
| `persistentVolume.enabled`      | If `true`, persistent volume claims are created                           | `true`                                              |
| `persistentVolume.storageClass` | Persistent volume storage class                                           | `default`                                           |
| `persistentVolume.accessMode`   | Persistent volume access modes                                            | [ReadWriteOnce]                                     |
| `persistentVolume.size`         | Persistent volume size                                                    | 10Gi                                                |
| `serviceAnnotations`            | Annotations to be added to the service                                    | {}                                                  |
| `configmap`                     | Content of the MongoDB config file                                        | See below                                           |

*MongoDB config file*

The MongoDB config file `mongod.conf` is configured via the `configmap` configuration value. The defaults from
`values.yaml` are the following:

```yaml
configmap:
  storage:
    dbPath: /data/db
  net:
    port: 27017
  replication:
    replSetName: rs0
```

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-app -f values.yaml reallyenglish/mongodb-rs
```

> **Tip**: You can use the default [values.yaml](values.yaml)

Once you have all 3 nodes in running, you can run the "test.sh" script in this directory, which will insert a key into the primary and check the secondaries for output. This script requires that the `$RELEASE_NAME` environment variable be set, in order to access the pods.

# Deep dive

Because the pod names are dependent on the name chosen for it, the following examples use the
environment variable `RELEASE_NAME`. For example, if the helm release name is `my-app`, one would need to set the following before proceeding. The example scripts below assume 3 pods only.

```console
export FULLNAME=my-app-mongo
```

## Cluster Health

```console
$ for i in 0 1 2; do kubectl exec $FULLNAME-$i -- sh -c '/usr/bin/mongo --eval="printjson(db.serverStatus())"'; done
```

## Failover

One can check the roles being played by each node by using the following:
```console
$ for i in 0 1 2; do kubectl exec $FULLNAME-$i -- sh -c '/usr/bin/mongo --quiet --eval="printjson(rs.isMaster())"'; done

{
	"hosts" : [
		"my-app-mongo-0.my-app-mongo.demo.svc.cluster.local:27017",
		"my-app-mongo-1.my-app-mongo.demo.svc.cluster.local:27017",
		"my-app-mongo-2.my-app-mongo.demo.svc.cluster.local:27017"
	],
	"setName" : "rs0",
	"setVersion" : 3,
	"ismaster" : true,
	"secondary" : false,
	"primary" : "my-app-mongo-0.my-app-mongo.demo.svc.cluster.local:27017",
	"me" : "my-app-mongo-0.my-app-mongo.demo.svc.cluster.local:27017",
	...
}

```
This lets us see which member is primary.

Let us now test persistence and failover. First, we insert a key (in the below example, we assume pod 0 is the master):
```console
$ kubectl exec $FULLNAME-0 -- /usr/bin/mongo --quiet --eval="printjson(db.test.insert({key1: 'value1'}))"

{ "nInserted" : 1 }
```

Watch existing members:
```console
$ kubectl run --attach box --image=mongo:3.4 --restart=Never -- sh -c 'while true; do for i in 0 1 2; do echo $i $(mongo --host=$FULLNAME-$i.$FULLNAME --eval="printjson(rs.isMaster())" | grep primary); sleep 1; done; done';
If you don't see a command prompt, try pressing enter.
2 "primary" : "my-app-mongo-0.my-app-mongo.demo.svc.cluster.local:27017",
0 "primary" : "my-app-mongo-0.my-app-mongo.demo.svc.cluster.local:27017",
1 "primary" : "my-app-mongo-0.my-app-mongo.demo.svc.cluster.local:27017",
```

Kill the primary and watch as a new master getting elected.
```console
$ kubectl delete pod $FULLNAME-0

pod "my-app-mongo-0" deleted
```

Delete all pods and let the statefulset controller bring it up.
```console
$ kubectl delete po -l app=mongodb
$ kubectl get po --watch-only
NAME             READY     STATUS           RESTARTS  AGE
my-app-mongo-0   1/1       Terminating      0         3m
my-app-mongo-1   1/1       Terminating      0         1h
my-app-mongo-2   1/1       Terminating      0         1h
my-app-mongo-0   0/1       Terminating      0         3m
my-app-mongo-1   0/1       Terminating      0         1h
my-app-mongo-0   0/1       Terminating      0         3m
my-app-mongo-0   0/1       Terminating      0         3m
my-app-mongo-0   0/1       Pending          0         1s
my-app-mongo-0   0/1       Pending          0         1s
my-app-mongo-0   0/1       Init:0/2         0         1s
my-app-mongo-1   0/1       Terminating      0         1h
my-app-mongo-1   0/1       Terminating      0         1h
my-app-mongo-2   0/1       Terminating      0         1h
my-app-mongo-2   0/1       Terminating      0         1h
my-app-mongo-2   0/1       Terminating      0         1h
my-app-mongo-0   0/1       Init:1/2         0         19s
my-app-mongo-0   0/1       Init:1/2         0         20s
my-app-mongo-0   0/1       PodInitializing  0         23s
my-app-mongo-0   0/1       Running          0         24s
my-app-mongo-0   1/1       Running          0         31s
my-app-mongo-1   0/1       Pending          0         1s
my-app-mongo-1   0/1       Pending          0         1s
my-app-mongo-1   0/1       Init:0/2         0         1s
my-app-mongo-1   0/1       Init:1/2         0         19s
my-app-mongo-1   0/1       Init:1/2         0         20s
my-app-mongo-1   0/1       PodInitializing  0         22s
my-app-mongo-1   0/1       Running          0         23s
my-app-mongo-1   1/1       Running          0         31s
my-app-mongo-2   0/1       Pending          0         1s
my-app-mongo-2   0/1       Pending          0         1s
my-app-mongo-2   0/1       Init:0/2         0         1s
my-app-mongo-2   0/1       Init:1/2         0         19s
my-app-mongo-2   0/1       Init:1/2         0         20s
my-app-mongo-2   0/1       PodInitializing  0         21s
my-app-mongo-2   0/1       Running          0         22s
my-app-mongo-2   1/1       Running          0         31s
...
my-app-mongo-0 "primary" : "my-app-mongo-0.my-app-mongo.demo.svc.cluster.local:27017",
my-app-mongo-1 "primary" : "my-app-mongo-0.my-app-mongo.demo.svc.cluster.local:27017",
my-app-mongo-2 "primary" : "my-app-mongo-0.my-app-mongo.demo.svc.cluster.local:27017",
```

Check the previously inserted key:
```console
$ kubectl exec $FULLNAME-1 -- /usr/bin/mongo --quiet --eval="rs.slaveOk(); db.test.find({key1:{\$exists:true}}).forEach(printjson)"

{ "_id" : ObjectId("57b180b1a7311d08f2bfb617"), "key1" : "value1" }
```

## Scaling

```console
$ kubectl scale statefulsets my-app-mongo --replicas=5
statefulset "my-app-mongo" scaled
$ kubectl get po --watch-only
NAME             READY     STATUS           RESTARTS  AGE
my-app-mongo-3   0/1       Pending          0         0s
my-app-mongo-3   0/1       Pending          0         0s
my-app-mongo-3   0/1       Pending          0         7s
my-app-mongo-3   0/1       Init:0/2         0         7s
my-app-mongo-3   0/1       Init:1/2         0         25s
my-app-mongo-3   0/1       Init:1/2         0         26s
my-app-mongo-3   0/1       PodInitializing  0         27s
my-app-mongo-3   0/1       Running          0         28s
my-app-mongo-3   1/1       Running          0         37s
my-app-mongo-4   0/1       Pending          0         0s
my-app-mongo-4   0/1       Pending          0         0s
my-app-mongo-4   0/1       Pending          0         7s
my-app-mongo-4   0/1       Init:0/2         0         7s
my-app-mongo-4   0/1       Init:1/2         0         26s
my-app-mongo-4   0/1       Init:1/2         0         27s
my-app-mongo-4   0/1       PodInitializing  0         28s
my-app-mongo-4   0/1       Running          0         29s
my-app-mongo-4   1/1       Running          0         37s
$ kubectl get statefulset
NAME           DESIRED   CURRENT   AGE
my-app-mongo   5         5         1h
```
