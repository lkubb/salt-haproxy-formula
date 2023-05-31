# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as haproxy with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}
{%- set user = haproxy | traverse("config:global:user", "haproxy") %}
{%- set group = haproxy | traverse("config:global:group", "haproxy") %}

include:
  - {{ sls_package_install }}

{#- TODO: add support for different key types etc.
    see https://github.com/haproxy/haproxy/issues/785
    https://www.haproxy.com/documentation/hapee/2-6r1/onepage/#5.1-crt
#}

{%- for name, config in haproxy.tls.certs.items() %}
{%-   set keyfile = haproxy.lookup.tls_dir | path_join(name) ~ ".key" %}
{%-   set certfile = haproxy.lookup.tls_dir | path_join(name) ~ ".pem" %}
{%-   set concatfile = haproxy.lookup.tls_dir | path_join(name) ~ "_concat.pem" %}

HAProxy {{ name }} private key is managed:
  x509.private_key_managed:
    - name: {{ keyfile }}
    - algo: rsa
    - keysize: 2048
    - new: true
{%-   if salt["file.file_exists"](keyfile) %}
    - prereq:
      - HAProxy {{ name }} certificate is managed
{%-   endif %}
    - makedirs: True
    - user: {{ user }}
    - group: {{ group }}
    - require:
      - sls: {{ sls_package_install }}

HAProxy {{ name }} certificate is managed:
  x509.certificate_managed:
    - name: {{ certfile }}
    - ca_server: {{ config.ca_server or "null" }}
    - signing_policy: {{ config.signing_policy or "null" }}
    - signing_cert: {{ config.signing_cert or "null" }}
    - signing_private_key: {{ config.signing_private_key or (keyfile if not config.ca_server and not config.signing_cert else "null") }}
    - private_key: {{ keyfile }}
    - authorityKeyIdentifier: keyid:always
    - basicConstraints: critical, CA:false
    - subjectKeyIdentifier: hash
{%-   if config.san %}
    - subjectAltName:  {{ config.san | json }}
{%-   else %}
    - subjectAltName:
      - dns: {{ config.cn or ([grains.fqdn] + grains.fqdns) | reject("==", "localhost.localdomain") | first | d(grains.id) }}
      - ip: {{ (grains.get("ip4_interfaces", {}).get("eth0", [""]) | first) or (grains.get("ipv4") | reject("==", "127.0.0.1") | first) }}
{%-   endif %}
    - CN: {{ config.cn or grains.fqdns | reject("==", "localhost.localdomain") | first | d(grains.id) }}
    - mode: '0640'
    - user: {{ user }}
    - group: {{ group }}
    - makedirs: True
    - append_certs: {{ config.intermediate | json }}
    - days_remaining: {{ config.days_remaining }}
    - days_valid: {{ config.days_valid }}
    - require:
      - sls: {{ sls_package_install }}
{%-   if not salt["file.file_exists"](keyfile) %}
      - HAProxy {{ name }} private key is managed
{%-   endif %}

# file.append would otherwise append the new ones to the old ones
HAProxy {{ name }} concat PEM is absent on changes:
  file.absent:
    - name: {{ concatfile }}
    - onchanges:
      - HAProxy {{ name }} private key is managed
      - HAProxy {{ name }} certificate is managed

HAProxy {{ name }} concat PEM is present:
  file.append:
    - name: {{ concatfile }}
    - sources:
      - {{ keyfile }}
      - {{ certfile }}
    - require:
      - HAProxy {{ name }} private key is managed
      - HAProxy {{ name }} certificate is managed
      - HAProxy {{ name }} concat PEM is absent on changes

HAProxy {{ name }} concat PEM has correct perms:
  file.managed:
    - name: {{ concatfile }}
    - user: {{ user }}
    - group: {{ group }}
    - mode: '0600'
    - replace: false
    - require:
      - HAProxy {{ name }} concat PEM is present
{%- endfor %}

{%- if not haproxy.tls.certs %}

Make HAProxy certs file requirable:
  test.nop
{%- endif %}
