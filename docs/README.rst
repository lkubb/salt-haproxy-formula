.. _readme:

HAProxy Formula
===============

|img_sr| |img_pc|

.. |img_sr| image:: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
   :alt: Semantic Release
   :scale: 100%
   :target: https://github.com/semantic-release/semantic-release
.. |img_pc| image:: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
   :alt: pre-commit
   :scale: 100%
   :target: https://github.com/pre-commit/pre-commit

Manage HAProxy with Salt.

.. contents:: **Table of Contents**
   :depth: 1

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html>`_.

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

If you need (non-default) configuration, please refer to:

- `how to configure the formula with map.jinja <map.jinja.rst>`_
- the ``pillar.example`` file
- the `Special notes`_ section

Special notes
-------------


Configuration
-------------
An example pillar is provided, please see `pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in `map.jinja`.


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



Contributing to this repo
-------------------------

Commit messages
^^^^^^^^^^^^^^^

**Commit message formatting is significant!**

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``. ::

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.
