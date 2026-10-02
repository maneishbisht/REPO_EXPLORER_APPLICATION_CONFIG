{{- define "repo-explorer-application-config.name" -}}
{{- default .Chart.Name .Values.target.key | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "repo-explorer-application-config.fullname" -}}
{{- printf "%s-application-config" (include "repo-explorer-application-config.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "repo-explorer-application-config.target-server" -}}
{{- if eq .Values.target.key "test" -}}
{{ .Values.target.endpoint | quote }}
{{- else -}}
"https://kubernetes.default.svc"
{{- end -}}
{{- end -}}
