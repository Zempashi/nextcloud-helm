{{- define "nextcloud.notifyPush.fullname" -}}
{{ template "nextcloud.fullname" . }}-notifypush
{{- end -}}

{{/*
Common labels
*/}}
{{- define "nextcloud.notifyPush.labels" -}}
helm.sh/chart: {{ include "nextcloud.chart" . }}
{{ include "nextcloud.notifyPush.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nextcloud.notifyPush.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nextcloud.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: notify-push
{{- end }}


{{- define "nextcloud.notifyPush.appInstall.fullname" -}}
{{ template "nextcloud.fullname" . }}-notifypush-install-{{ .Release.Revision }}
{{- end -}}

{{/*
*/}}
{{- define "nextcloud.notifyPush.appInstall.labels" -}}
helm.sh/chart: {{ include "nextcloud.chart" . }}
{{ include "nextcloud.notifyPush.install.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Nextcloud URL
*/}}
{{- define "nextcloud.url" -}}
{{- if .Values.nextcloud.host -}}
http{{- if $.Values.ingress.tls }}s{{ end }}://{{ .Values.nextcloud.host }}
{{- else -}}
http://{{ include "nextcloud.fullname" . -}}
{{- end }}
{{- end }}


{{/*
Security context
*/}}
{{- define "nextcloud.securityContext" -}}
{{- $defaultSecurityContext = .Values.nginx.enabled | ternary ( dict "fsGroup" 82 ) (dict "fsGroup" 33) -}}
{{ toYaml merge .Values.securityContext $defaultSecurityContext }}
{{- end -}}

{{/*
Default notifyPush affinity
*/}}
{{- define "nextcloud.notifyPush.defaultAffinity" -}}
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
          - key: app.kubernetes.io/component
            operator: In
            values:
              - app
      topologyKey: kubernetes.io/hostname
{{- end }}

{{/*
notifyPush affinity
*/}}
{{- define "nextcloud.notifyPush.affinity" -}}
{{- if and .Values.persistence.enabled (eq .Values.persistence.accessMode "ReadWriteOnce") }}
{{- with merge .Values.notifyPush.affinity (include "nextcloud.notifyPush.defaultAffinity" . | fromYaml) }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- else }}
{{- with .Values.notifyPush.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
