# vim: ft=sls

{#-
    Stops the haproxy service and disables it at boot time.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as haproxy with context %}

HAProxy is dead:
  service.dead:
    - name: {{ haproxy.lookup.service.name }}
    - enable: false
