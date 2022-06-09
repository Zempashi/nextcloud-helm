{{/*
Env vars for nextcloud pods
*/}}
{{- define "nextcloud.envs" -}}
{{- if .Values.phpClientHttpsFix.enabled }}
- name: OVERWRITEPROTOCOL
  value: {{ .Values.phpClientHttpsFix.protocol | quote }}
{{- end }}
{{- if .Values.internalDatabase.enabled }}
- name: SQLITE_DATABASE
  value: {{ .Values.internalDatabase.name | quote }}
{{- else if .Values.mariadb.enabled }}
- name: MYSQL_HOST
  value: {{ template "mariadb.primary.fullname" .Subcharts.mariadb }}
- name: MYSQL_DATABASE
  value: {{ .Values.mariadb.auth.database | quote }}
- name: MYSQL_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.existingSecret.secretName | default (printf "%s-%s" .Release.Name "db") }}
      key: {{ .Values.externalDatabase.existingSecret.usernameKey | default "db-username" }}
- name: MYSQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.existingSecret.secretName | default (printf "%s-%s" .Release.Name "db") }}
      key: {{ .Values.externalDatabase.existingSecret.passwordKey | default "db-password" }}
{{- else if .Values.postgresql.enabled }}
- name: POSTGRES_HOST
  value: {{ template "postgresql.primary.fullname" .Subcharts.postgresql }}
- name: POSTGRES_DB
  {{- if .Values.postgresql.auth.database }}
  value: {{ .Values.postgresql.auth.database | quote }}
  {{ else }}
  value: {{ .Values.postgresql.global.postgresql.auth.database | quote }}
  {{- end }}
- name: POSTGRES_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.existingSecret.secretName | default (printf "%s-%s" .Release.Name "db") }}
      key: {{ .Values.externalDatabase.existingSecret.usernameKey | default "db-username" }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.existingSecret.secretName | default (printf "%s-%s" .Release.Name "db") }}
      key: {{ .Values.externalDatabase.existingSecret.passwordKey | default "db-password" }}
{{- else }}
  {{- if eq .Values.externalDatabase.type "postgresql" }}
- name: POSTGRES_HOST
  value: {{ .Values.externalDatabase.host | quote }}
- name: POSTGRES_DB
  value: {{ .Values.externalDatabase.database | quote }}
- name: POSTGRES_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.existingSecret.secretName | default (printf "%s-%s" .Release.Name "db") }}
      key: {{ .Values.externalDatabase.existingSecret.usernameKey | default "db-username" }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.existingSecret.secretName | default (printf "%s-%s" .Release.Name "db") }}
      key: {{ .Values.externalDatabase.existingSecret.passwordKey | default "db-password" }}
  {{- else }}
- name: MYSQL_HOST
  value: {{ .Values.externalDatabase.host | quote }}
- name: MYSQL_DATABASE
  value: {{ .Values.externalDatabase.database | quote }}
- name: MYSQL_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.existingSecret.secretName | default (printf "%s-%s" .Release.Name "db") }}
      key: {{ .Values.externalDatabase.existingSecret.usernameKey | default "db-username" }}
- name: MYSQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.existingSecret.secretName | default (printf "%s-%s" .Release.Name "db") }}
      key: {{ .Values.externalDatabase.existingSecret.passwordKey | default "db-password" }}
  {{- end }}
{{- end }}
- name: NEXTCLOUD_ADMIN_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.nextcloud.existingSecret.secretName | default (include "nextcloud.fullname" .) }}
      key: {{ .Values.nextcloud.existingSecret.usernameKey | default "nextcloud-username" }}
- name: NEXTCLOUD_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.nextcloud.existingSecret.secretName | default (include "nextcloud.fullname" .) }}
      key: {{ .Values.nextcloud.existingSecret.passwordKey | default "nextcloud-password" }}
- name: NEXTCLOUD_TRUSTED_DOMAINS
  value: {{ .Values.nextcloud.host }}
{{- if ne (int .Values.nextcloud.update) 0 }}
- name: NEXTCLOUD_UPDATE
  value: {{ .Values.nextcloud.update | quote }}
{{- end }}
- name: NEXTCLOUD_DATA_DIR
  value: {{ .Values.nextcloud.datadir | quote }}
{{- if .Values.nextcloud.mail.enabled }}
- name: MAIL_FROM_ADDRESS
  value: {{ .Values.nextcloud.mail.fromAddress | quote }}
- name: MAIL_DOMAIN
  value: {{ .Values.nextcloud.mail.domain | quote }}
- name: SMTP_HOST
  value: {{ .Values.nextcloud.mail.smtp.host | quote }}
- name: SMTP_SECURE
  value: {{ .Values.nextcloud.mail.smtp.secure | quote }}
- name: SMTP_PORT
  value: {{ .Values.nextcloud.mail.smtp.port | quote }}
- name: SMTP_AUTHTYPE
  value: {{ .Values.nextcloud.mail.smtp.authtype | quote }}
- name: SMTP_NAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.nextcloud.existingSecret.secretName | default (include "nextcloud.fullname" .) }}
      key: {{ .Values.nextcloud.existingSecret.smtpUsernameKey | default "smtp-username" }}
- name: SMTP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.nextcloud.existingSecret.secretName | default (include "nextcloud.fullname" .) }}
      key: {{ .Values.nextcloud.existingSecret.smtpPasswordKey | default "smtp-password" }}
{{- end }}
{{- if .Values.redis.enabled }}
- name: REDIS_HOST
  value: {{ template "nextcloud.redis.fullname" . }}-master
- name: REDIS_HOST_PORT
  value: {{ .Values.redis.master.service.ports.redis | quote }}
{{- if and .Values.redis.auth.existingSecret .Values.redis.auth.existingSecretPasswordKey }}
- name: REDIS_HOST_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.redis.auth.existingSecret }}
      key: {{ .Values.redis.auth.existingSecretPasswordKey }}
{{- else }}
- name: REDIS_HOST_PASSWORD
  value: {{ .Values.redis.auth.password }}
{{- end }}
{{- end }}
{{- if .Values.nextcloud.extraEnv }}
{{ toYaml .Values.nextcloud.extraEnv }}
{{- end }}
{{- end -}}
