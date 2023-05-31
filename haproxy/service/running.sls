# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- set sls_certs_managed = tplroot ~ ".certs.managed" %}
{%- from tplroot ~ "/map.jinja" import mapdata as haproxy with context %}

include:
  - {{ sls_config_file }}
  - {{ sls_certs_managed }}

HAProxy is running:
  service.running:
    - name: {{ haproxy.lookup.service.name }}
    - enable: true
    - reload: true
    - watch:
      - sls: {{ sls_config_file }}
      - sls: {{ sls_certs_managed }}
{%- if haproxy.service.harden %}
      - HAProxy service overrides are installed
{%- endif %}

{%- if grains.os_family == "RedHat" and haproxy.firewall.manage and haproxy.firewall.ports %}

HAProxy services are known:
  firewalld.service:
    - name: haproxy
    - ports: {{ haproxy.firewall.ports | json }}
    - require:
      - HAProxy is running

HAProxy ports are open:
  firewalld.present:
    - name: public
    - services:
      - haproxy
    - require:
      - HAProxy services are known
{%- endif %}
