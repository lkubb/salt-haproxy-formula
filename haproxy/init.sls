# vim: ft=sls

{#-
    *Meta-state*.

    This installs the haproxy package,
    manages the haproxy configuration file and trusted CA certs,
    creates TLS certificates and private keys
    and then starts the associated haproxy service.
#}

include:
  - .package
  - .config
  - .certs
  - .service
