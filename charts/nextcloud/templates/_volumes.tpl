{{/*
common Volume mounts
*/}}
{{- define "nextcloud.volumeMounts.common" -}}
- name: nextcloud-main
  mountPath: /var/www/
  subPath: {{ ternary "root" (printf "%s/%s" .Values.nextcloud.persistence.subPath "root") (empty .Values.nextcloud.persistence.subPath) }}
- name: nextcloud-main
  mountPath: /var/www/html
  subPath: {{ ternary "html" (printf "%s/%s" .Values.nextcloud.persistence.subPath "html") (empty .Values.nextcloud.persistence.subPath) }}
{{- if and .Values.persistence.nextcloudData.enabled .Values.persistence.enabled }}
- name: nextcloud-data
  mountPath: {{ .Values.nextcloud.datadir }}
  subPath: {{ ternary "data" (printf "%s/%s" .Values.persistence.nextcloudData.subPath "data") (empty .Values.persistence.nextcloudData.subPath) }}
{{- else }}
- name: nextcloud-main
  mountPath: {{ .Values.nextcloud.datadir }}
  subPath: {{ ternary "data" (printf "%s/%s" .Values.persistence.subPath "data") (empty .Values.persistence.subPath) }}
{{- end }}
- name: nextcloud-main
  mountPath: /var/www/html/config
  subPath: {{ ternary "config" (printf "%s/%s" .Values.nextcloud.persistence.subPath "config") (empty .Values.nextcloud.persistence.subPath) }}
- name: nextcloud-main
  mountPath: /var/www/html/custom_apps
  subPath: {{ ternary "custom_apps" (printf "%s/%s" .Values.nextcloud.persistence.subPath "custom_apps") (empty .Values.nextcloud.persistence.subPath) }}
- name: nextcloud-main
  mountPath: /var/www/tmp
  subPath: {{ ternary "tmp" (printf "%s/%s" .Values.nextcloud.persistence.subPath "tmp") (empty .Values.nextcloud.persistence.subPath) }}
- name: nextcloud-main
  mountPath: /var/www/html/themes
  subPath: {{ ternary "themes" (printf "%s/%s" .Values.nextcloud.persistence.subPath "themes") (empty .Values.nextcloud.persistence.subPath) }}
{{- end -}}

{{- define "nextcloud.volumeMounts.config" -}}
{{- range $key, $value := .Values.nextcloud.configs }}
- name: nextcloud-config
  mountPath: /var/www/html/config/{{ $key }}
  subPath: {{ $key }}
{{- end }}
{{- if .Values.nextcloud.configs }}
{{- range $key, $value := .Values.nextcloud.defaultConfigs }}
{{- if $value }}
- name: nextcloud-config
  mountPath: /var/www/html/config/{{ $key }}
  subPath: {{ $key }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "nextcloud.volumes" -}}
- name: nextcloud-main
{{- if .Values.persistence.enabled }}
  persistentVolumeClaim:
    claimName: {{ if .Values.persistence.existingClaim }}{{ .Values.persistence.existingClaim }}{{- else }}{{ template "nextcloud.fullname" . }}-nextcloud{{- end }}
{{- else }}
  emptyDir: {}
{{- end }}
{{- if and .Values.persistence.nextcloudData.enabled .Values.persistence.enabled }}
- name: nextcloud-data
  persistentVolumeClaim:
    claimName: {{ if .Values.persistence.nextcloudData.existingClaim }}{{ .Values.persistence.nextcloudData.existingClaim }}{{- else }}{{ template "nextcloud.fullname" . }}-nextcloud-data{{- end }}
{{- end }}
{{- if .Values.nextcloud.configs }}
- name: nextcloud-config
  configMap:
    name: {{ template "nextcloud.fullname" . }}-config
{{- end }}
{{- if .Values.nextcloud.phpConfigs }}
- name: nextcloud-phpconfig
  configMap:
    name: {{ template "nextcloud.fullname" . }}-phpconfig
{{- end }}
{{- if .Values.nginx.enabled }}
- name: nextcloud-nginx-config
  configMap:
    name: {{ template "nextcloud.fullname" . }}-nginxconfig
{{- end }}
{{- if .Values.nextcloud.extraVolumes }}
{{ toYaml .Values.nextcloud.extraVolumes }}
{{- end }}
{{- end -}}
