# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``haproxy`` meta-state
    in reverse order, i.e.
    stops the service,
    removes created certificates, private keys,
    removes the configuration file and trusted CA certs and then
    uninstalls the package.
#}

include:
  - .service.clean
  - .certs.clean
  - .config.clean
  - .package.clean
