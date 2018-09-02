geli_remote_unlock
==================

*work in progress*

Use Case
--------

tbd;

Setup
-----

Local
^^^^^

tbd;

Remote
^^^^^^

Server(s) storing the keyfiles and passphrases.

Place the public part of your unlock ssh key into the
``~/.ssh/authorized_keys`` file.

To make things work and narrow down the attack surface if that key gets lost,
prefix it with the **command** and **restrict** option::

    # retrieve unlocking keys for my awesome server
    command="/path/to/geliremoteprovider.sh",restrict ssh-ed25519 [...] user@hostname

Also see contents of ``remote`` folder.

Origins
-------

This project is a loosely rewrite of
`geliUnlocker <https://github.com/clinta/geliUnlocker>`_.

I just wanted to solve the same problems, but in a little different way.

The changes are different enough that forking was not really an option.

Thanks for that original awesome work - it helped a lot!
