## Helm Charts used at Reallyenglish

### Installing charts

```console
helm repo add reallyenglish https://storage.googleapis.com/re-charts
helm install ...
```

### Publishing charts

```console
mkdir pkg
helm package etcd
mv etcd-0.2.0.tgz pkg
helm repo index pkg --merge --url https://storage.googleapis.com/re-charts
gsutil cp pkg/* gs://re-charts
```

### Resources

* [Helm docs](https://github.com/kubernetes/helm/tree/master/docs)
* [Chart Repository Guide](https://github.com/kubernetes/helm/blob/master/docs/chart_repository.md)
* [Official Charts Repository](https://github.com/kubernetes/charts)
* [Charts Guide](https://github.com/kubernetes/helm/blob/master/docs/charts.md)
