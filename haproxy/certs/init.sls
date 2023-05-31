# vim: ft=sls

{#-
    Manages x509 certificates in `lookup:cert_dir`.
    Has a dependency on `haproxy.package`_.
#}

include:
  - .managed
