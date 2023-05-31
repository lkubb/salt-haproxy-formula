# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as haproxy with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

HAProxy environment overrides are managed:
  file.managed:
    - name: {{ haproxy.lookup.envfile }}
    - source: {{ files_switch(
                    ["haproxy.env", "haproxy.env.j2"],
                    config=haproxy,
                    lookup="HAProxy environment overrides are managed",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ haproxy.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        haproxy: {{ haproxy | json }}

HAProxy configuration is managed:
  file.managed:
    - name: {{ haproxy.lookup.config }}
    - source: {{ files_switch(
                    ["haproxy.cfg", "haproxy.cfg.j2"],
                    config=haproxy,
                    lookup="HAProxy configuration is managed",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ haproxy.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        haproxy: {{ haproxy | json }}

HAProxy config dir is synced:
  file.recurse:
    - name: {{ haproxy.lookup.config_dir }}
    - source: {{ files_switch(
                    ["haproxy.cfg.d"],
                    config=haproxy,
                    lookup="HAProxy config dir is synced",
                 )
              }}
    - file_mode: '0644'
    - dir_mode: '0755'
    - user: root
    - group: {{ haproxy.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - exclude_pat:
      - '.gitkeep'
    - require:
      - sls: {{ sls_package_install }}
    - context:
        haproxy: {{ haproxy | json }}

{%- for ca_name, ca_cert in haproxy.tls.ca_certs.items() %}

CA cert for {{ ca_name }} is managed:
  file.managed:
    - name: {{ haproxy.lookup.tls_dir | path_join("ca", ca_name) }}.pem
    - contents: {{ ((ca_cert | join("\n")) if ca_cert | is_list else ca_cert) | json }}
    - makedirs: True
    - require:
      - sls: {{ sls_package_install }}
{%- endfor %}

{%- if haproxy.bind_virtual_ip is not none %}

Kernel non-local IP binding setting is managed:
  sysctl.present:
    - name: net.ipv4.ip_nonlocal_bind
    - value: {{ haproxy.bind_virtual_ip | int }}
{%- endif %}
