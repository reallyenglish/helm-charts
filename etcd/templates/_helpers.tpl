{{/*
Create a default fully qualified etcd name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "etcd.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "etcd.labels" }}
  labels:
    heritage: {{ .Release.Service | quote }}
    release: {{ .Release.Name | quote }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    component: {{ .Values.component | quote }}
    app: {{ default .Chart.Name .Values.name | quote }}
{{- end }}