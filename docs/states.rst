Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``haproxy``
^^^^^^^^^^^
*Meta-state*.

This installs the haproxy package,
manages the haproxy configuration file and trusted CA certs,
creates TLS certificates and private keys
and then starts the associated haproxy service.


``haproxy.package``
^^^^^^^^^^^^^^^^^^^
Installs the haproxy package only.
If ``service:harden`` is true, also installs service overrides.


``haproxy.config``
^^^^^^^^^^^^^^^^^^
Manages the haproxy service configuration.
Has a dependency on `haproxy.package`_.


``haproxy.certs``
^^^^^^^^^^^^^^^^^
Manages x509 certificates in `lookup:cert_dir`.
Has a dependency on `haproxy.package`_.


``haproxy.service``
^^^^^^^^^^^^^^^^^^^
Starts the haproxy service and enables it at boot time.
Has a dependency on `haproxy.config`_.


``haproxy.clean``
^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``haproxy`` meta-state
in reverse order, i.e.
stops the service,
removes created certificates, private keys,
removes the configuration file and trusted CA certs and then
uninstalls the package.


``haproxy.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the haproxy package and service overrides, if configured.
Has a dependency on `haproxy.config.clean`_.


``haproxy.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the haproxy service and has a
dependency on `haproxy.service.clean`_.


``haproxy.certs.clean``
^^^^^^^^^^^^^^^^^^^^^^^
Removes managed certificates/keys and has a
dependency on `haproxy.service.clean`_.


``haproxy.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the haproxy service and disables it at boot time.


