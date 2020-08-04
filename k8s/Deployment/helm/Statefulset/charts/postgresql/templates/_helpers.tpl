{{/* vim: set filetype=mustache: */}}
{{/* https://github.com/Masterminds/sprig/blob/bf29da0d74f74aeb5c3e3e7207eab76c28ac4049/functions.go#L182 */}}

{{- define "edb.label" -}}
{{- default .Values.name .Values.label -}}
{{- end -}}

{{/*
Render a value which is containing a template.
Usage:
{{ include "edb.tplValue" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "edb.tplValue" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}
