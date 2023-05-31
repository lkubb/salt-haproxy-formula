# vim: ft=sls

{#-
    Installs the haproxy package only.
    If ``service:harden`` is true, also installs service overrides.
#}

include:
  - .install
