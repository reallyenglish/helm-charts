{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "stolon.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified store name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "store.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.store.backend | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "store.endpoint" -}}
{{- if eq .Values.store.backend "etcd" -}}
{{- $etcdService := printf "%s-%s" .Release.Name .Values.etcd.name | trunc 63 | trimSuffix "-" -}}
{{- $etcdPort := default "2379" .Values.etcd.clientPort -}}
{{- $generated := printf "http://%s:%s" $etcdService $etcdPort -}}
{{- default $generated .Values.etcd.service -}}
{{- else if eq .Values.store.backend "consul" -}}
{{- printf "http://%s-%s:2379" .Release.Name .Values.store.backend -}}
{{- end -}}
{{- end -}}

{{- define "keeper.fullname" -}}
{{- $serviceName := default "keeper" .Values.keeper.nameOverride -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name $serviceName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "sentinel.fullname" -}}
{{- $serviceName := default "sentinel" .Values.sentinel.nameOverride -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name $serviceName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "proxy.fullname" -}}
{{- $serviceName := default "proxy" .Values.proxy.nameOverride -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name $serviceName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
