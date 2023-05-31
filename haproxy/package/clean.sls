# vim: ft=sls

{#-
    Removes the haproxy package and service overrides, if configured.
    Has a dependency on `haproxy.config.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as haproxy with context %}

include:
  - {{ sls_config_clean }}

{%- if grains.get("selinux", {}).get("enabled") and haproxy.selinux.manage %}

HAProxy connect_any sebool is managed:
  selinux.boolean:
    - name: haproxy_connect_any
    - value: false
    - persist: true

{%-   if haproxy.selinux.ports is not true %}

HAProxy is allowed to communicate on relevant ports:
  selinux.port_policy_absent:
    - names:
{%-     for port in haproxy.selinux.ports %}
{%-       if port is string %}
      - tcp/{{ port }}
{%-       else %}
      - {{ port.get("proto", "tcp") }}/{{ port.value }}
{%-       endif %}
{%-     endfor %}
    - sel_type: http_port_t
{%-   endif %}
{%- endif %}


{%- if haproxy.service.harden %}

HAProxy service overrides are removed:
  file.absent:
    - name: {{ haproxy.lookup.service.override }}
{%- endif %}

HAProxy is removed:
  pkg.removed:
    - name: {{ haproxy.lookup.pkg.name }}
    - require:
      - sls: {{ sls_config_clean }}
