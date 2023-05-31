# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as haproxy with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

HAProxy is installed:
  pkg.installed:
    - name: {{ haproxy.lookup.pkg.name }}

{%- if haproxy.service.harden %}

HAProxy service overrides are installed:
  file.managed:
    - name: {{ haproxy.lookup.service.override | path_join("salt.conf") }}
    - source: {{ files_switch(
                    ["haproxy.service", "haproxy.service.j2"],
                    config=haproxy,
                    lookup="HAProxy service overrides are installed",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ haproxy.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - pkg: {{ haproxy.lookup.pkg.name }}
    - context:
        haproxy: {{ haproxy | json }}
{%- endif %}

{%- if grains.get("selinux", {}).get("enabled") and haproxy.selinux.manage %}

HAProxy connect_any sebool is managed:
  selinux.boolean:
    - name: haproxy_connect_any
    - value: {{ haproxy.selinux.ports is true }}
    - persist: true

{%-   if haproxy.selinux.ports is not true %}

HAProxy is allowed to communicate on relevant ports:
  selinux.port_policy_present:
    - names:
{%-     for port in haproxy.selinux.ports %}
{%-       if port is not mapping %}
      - tcp/{{ port }}
{%-       else %}
      - {{ port.get("proto", "tcp") }}/{{ port.value }}
{%-       endif %}
{%-     endfor %}
    - sel_type: http_port_t
{%-   endif %}
{%- endif %}
