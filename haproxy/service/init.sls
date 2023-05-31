# vim: ft=sls

{#-
    Starts the haproxy service and enables it at boot time.
    Has a dependency on `haproxy.config`_.
#}

include:
  - .running
