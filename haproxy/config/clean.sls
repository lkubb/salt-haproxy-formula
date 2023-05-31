# vim: ft=sls

{#-
    Removes the configuration of the haproxy service and has a
    dependency on `haproxy.service.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as haproxy with context %}

include:
  - {{ sls_service_clean }}

HAProxy configuration is absent:
  file.absent:
    - names:
      - {{ haproxy.lookup.config }}
      - {{ haproxy.lookup.envfile }}
      - {{ haproxy.lookup.config_dir }}
{%- for ca_name in haproxy.tls.ca_certs %}
      - {{ haproxy.lookup.tls_dir | path_join("ca", ca_name) }}.pem
{%- endfor %}
    - require:
      - sls: {{ sls_service_clean }}

{%- if haproxy.bind_virtual_ip is not none %}

Kernel does not allow non-local IP binding:
  sysctl.present:
    - name: net.ipv4.ip_nonlocal_bind
    - value: 0
{%- endif %}
