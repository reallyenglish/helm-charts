# MongoDB

[MongoDB](https://www.mongodb.com/) is a cross-platform document-oriented database. Classified as a NoSQL database, MongoDB eschews the traditional table-based relational database structure in favor of JSON-like documents with dynamic schemas, making the integration of data in certain types of applications easier and faster.

## TL;DR;

```bash
$ helm repo add reallyenglish https://storage.googleapis.com/re-charts
$ helm install reallyenglish/mongodb
```

## Introduction

This chart bootstraps a [MongoDB](https://github.com/docker-library/mongo) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.6+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release reallyenglish/mongodb
```

The command deploys MongoDB on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the MongoDB chart and their default values.

|         Parameter          |             Description             |                         Default                          |
|----------------------------|-------------------------------------|----------------------------------------------------------|
| `image`                    | MongoDB image repo                  | `mongo`                                                  |
| `imageTag`                 | MongoDB image tag                   | `3.4.4`                                                  |
| `imagePullPolicy`          | Image pull policy                   | `Always` if `imageTag` is `latest`, else `IfNotPresent`. |
| `persistence.enabled`      | Use a PVC to persist data           | `true`                                                   |
| `persistence.storageClass` | Storage class of backing PVC        | `nil`                                                    |
| `persistence.accessMode`   | Use volume as ReadOnly or ReadWrite | `ReadWriteOnce`                                          |
| `persistence.size`         | Size of data volume                 | `8Gi`                                                    |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set persistence.storageClass=fast,persistence.size=50Gi \
    reallyenglish/mongodb
```

The above command sets the MongoDB `root` account password to `secretpassword`. Additionally it creates a standard database user named `my-user`, with the password `my-password`, who has access to a database named `my-database`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml reallyenglish/mongodb
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

The [MongoDB](https://github.com/docker-library/mongo) image stores the MongoDB data and configurations at the `/data/db` and `/data/configdb` path of the container.

The chart mounts a [Persistent Volume](kubernetes.io/docs/user-guide/persistent-volumes/) volumes at these locations. The volume is created using dynamic volume provisioning.
