{{/*
Create a name for statefulset
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "redis-ha.service" -}}
{{- $svcName := printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- default $svcName .Values.serviceName -}}
{{- end -}}

{{/*
Create a label for app
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "redis-ha.app" -}}
{{- $svcName := default .Chart.Name .Values.serviceName -}}
{{- $setName := default "rds" .Values.statefulSetName -}}
{{- printf "%s-%s-%s" .Release.Name $svcName $setName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "redis-ha.server-image" -}}
{{- printf "%s:%s" .Values.server.imageRepository .Values.server.imageTag -}}
{{- end -}}

{{- define "redis-ha.sentinel-image" -}}
{{- printf "%s:%s" .Values.sentinel.imageRepository .Values.sentinel.imageTag -}}
{{- end -}}

{{- define "redis-ha.labels" }}
labels:
  heritage: {{ .Release.Service | quote }}
  release: {{ .Release.Name | quote }}
  chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
  component: {{ .Chart.Name | quote }}
  app: {{ template "redis-ha.app" . }}
{{- end }}