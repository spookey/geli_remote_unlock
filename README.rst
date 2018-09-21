geli_remote_unlock
==================

*work in progress*

Use Case
--------

tbd;


Setup
-----

There are some steps necessary to get everything working.
You may want to adjust the following procedure according to your needs.


Remote
^^^^^^

*Server(s) storing the keyfiles and passphrases.*

Create a SSH-Keypair, and place the public part of it into the
``~/.ssh/authorized_keys`` file.

To make things work and narrow down the attack surface if that key gets lost,
prefix it with the **command** and **restrict** option::

    # retrieve unlocking keys for my awesome server
    command="/path/to/geliremoteprovider.sh",restrict ssh-ed25519 [...] user@hostname

Fore more information see contents of ``remote`` folder.


Local
^^^^^

*(FreeBSD-)Server with your encrypted drive(s).*

Install the script itself into ``/etc/rc.d``::

    fetch https://github.com/spookey/geli_remote_unlock/raw/master/geliremoteunlock /usr/local/etc/rc.d/
    chmod +x /usr/local/etc/rc.d/geliremoteunlock


Partitions
~~~~~~~~~~

You need some encrypted zpool to get unlocked by **geliremoteunlock**.
In this example I'll create a zpool creatively named **data**.

First, create the key::

    mkdir /root/keys
    chmod go-rwx /root/keys

    dd if=/dev/random of=/root/keys/data.key bs=256k count=1

If not already done, create a partition (you may want to adjust the size).
In this example it is created on the disk **ada0**::

    gpart add -a 4k -s 32G -t freebsd-zfs -l data ada0

Now, a ``/dev/gpt/data`` partition should show up.
This is how to encrypt it::

    geli init -K /root/keys/data.key -s 4096 -l 256 /dev/gpt/data

Be creative with the passphrase. Don't forget it, you'll need it to unlock
it now::

    geli attach -k /root/keys/data.key /dev/gpt/data

Now, a ``/dev/gpt/data.eli`` partition should show up.
Finally create the zpool and zfs volumes inside it::

    zpool create data /dev/gpt/data.eli

This zpool should now be mounted as ``/data``.


Keys & Passphrases
~~~~~~~~~~~~~~~~~~

The keyfile was generated as ``/root/keys/data.key``.
You should now create a passphrase file alongside:

Write your passphrase into a textfile (without newline at the end) into
``/root/keys/data.pass``.

Optional, but very recommended - encrypt the key and passphrase files::

    openssl enc -aes-256-cbc -a -salt \
        -in data.key -out data.key.aes -k "7179227046a1cdc8bb0e9a81523a6822"

    openssl enc -aes-256-cbc -a -salt \
        -in data.pass -out data.pass.aes -k "46cf04febc44b6e0d956bf034f3d11aa"

The ``*.aes`` files should be uploaded to the remote server(s).


Configuration
~~~~~~~~~~~~~

This software needs some configuration inside of ``/etc/rc.conf``.

First, enable **netwait** to ensure the network is up and running::

    netwait_enable="YES"

Then, enable the script itself::

    geliremoteunlock_enable="YES"

Define the pools which shall be unlocked::

    geliremoteunlock_pools="data tank"


From now on every setting can be bound to a specific pool
(``geliremoteunlock_data_foo``, ``geliremoteunlock_tank_foo``)
or to apply for all pools
(``geliremoteunlock_foo``).

Specify where the pools are located::

    geliremoteunlock_data_devices="/dev/gpt/data"
    geliremoteunlock_tank_devices="/dev/gpt/tank"

Specify information where to get the keyfiles::

    geliremoteunlock_keyfile_host="username@keys.example.com"
    geliremoteunlock_keyfile_ident="/root/.ssh/unlock_key_ed25519"

    geliremoteunlock_data_keyfile_name="data.key.aes"
    geliremoteunlock_data_keyfile_password="7179227046a1cdc8bb0e9a81523a6822"

    geliremoteunlock_tank_keyfile_name="tank.key.aes"
    geliremoteunlock_tank_keyfile_password="f1144647f681194a666b1f19c4eb83e1"

And now the same for the passphrases::

    geliremoteunlock_passphrase_host="username@pass.example.com"
    geliremoteunlock_passphrase_ident="/root/.ssh/unlock_pass_ed25519"

    geliremoteunlock_data_passphrase_name="data.pass.aes"
    geliremoteunlock_data_passphrase_password="46cf04febc44b6e0d956bf034f3d11aa"

    geliremoteunlock_tank_passphrase_name="tank.pass.aes"
    geliremoteunlock_tank_passphrase_password="f600f3a243d0ce33f7bab4ad16c59e91"


Origins
-------

This project is a loosely rewrite of
`geliUnlocker <https://github.com/clinta/geliUnlocker>`_.

I just wanted to solve the same problems, but in a little different way.

The changes are different enough that forking was not really an option.

Thanks for that original awesome work - it helped a lot!
