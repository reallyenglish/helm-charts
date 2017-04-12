## Helm Charts used at Reallyenglish

### Installing charts

```console
$ helm repo add reallyenglish https://storage.googleapis.com/re-charts
$ helm search reallyenglish
$ helm install reallyenglish/stolon
```

### Debuggin charts

```console
$ helm lint ./etcd
$ helm install ./etcd --dry-run --debug
```

### Publishing charts

```console
$ helm package etcd
$ mv etcd-1.0.0.tgz pkg
$ helm repo index --merge pkg/index.yaml --url https://storage.googleapis.com/re-charts pkg
$ gsutil cp pkg/etcd-1.0.0.tgz pkg/index.yaml gs://re-charts
```

### Resources

* [Helm docs](https://github.com/kubernetes/helm/tree/master/docs)
* [Chart Repository Guide](https://github.com/kubernetes/helm/blob/master/docs/chart_repository.md)
* [Official Charts Repository](https://github.com/kubernetes/charts)
* [Charts Guide](https://github.com/kubernetes/helm/blob/master/docs/charts.md)
