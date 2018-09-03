Remote
======

This folder contains scripts to be installed on the machine which serves the
keys and/or passphrases.

It is possible to deploy keys and passphrases onto different machines.


Setup
-----

Deploy the contents of this folder to your remote server, and copy the
``config.sample.sh`` to ``config.sh``

Adjust the settings according to your needs.


Remarks
-------

Per default, the *provider* script searches for keys and passphrases in the
subfolders ``keys`` & ``pass`` respectively.

This is not really encouraged. Please store those confidential files
somewhere save and adjust the paths in the *config*.
