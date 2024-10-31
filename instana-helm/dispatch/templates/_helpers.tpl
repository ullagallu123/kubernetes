{{- define "dispatch.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name }}
{{- end }}

{{- define "dispatch.labels" -}}
project: instana
tier: backend
{{- end }}
