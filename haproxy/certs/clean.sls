# vim: ft=sls

{#-
    Removes managed certificates/keys and has a
    dependency on `haproxy.service.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as haproxy with context %}

include:
  - {{ sls_service_clean }}

{%- if haproxy.tls.certs %}

HAProxy certs/keys are absent:
  file.absent:
    - names:
{%-   for name, config in haproxy.tls.certs.items() %}
      - {{ haproxy.lookup.tls_dir | path_join(name) ~ ".key" }}
      - {{ haproxy.lookup.tls_dir | path_join(name) ~ ".pem" }}
      - {{ haproxy.lookup.tls_dir | path_join(name) ~ "_concat.pem" }}
{%-   endfor %}
{%- endif %}
