# geli_remote_unlock

This RC Script automatically unlocks geli encrypted disks with
key and passphrase files obtained from a remote system via ssh.

- Encrypt your disks, store the key and passphrase files on another server.

  - You can now reboot your server with no user interaction.

- Store key and passphrase files on different servers.

  - Of course both servers must be up for a successful disk decryption.

- Encrypt key and passphrase files so they can be stored on untrusted systems.

- This script cannot be used to unlock encrypted root partitions!

## Setup

There are some steps necessary to get everything working.
You may want to adjust the following procedure according to your needs.

### Remote

*Server(s) storing the keyfiles and passphrases.*

Create a SSH-Keypair (without password), and place the public part of it
into the `~/.ssh/authorized_keys` file.

To make things work and narrow down the attack surface if that key gets lost,
prefix it with the **command** and **restrict** option:

```plain
# retrieve unlocking keys for my awesome server
command="/path/to/geliremoteprovider.sh",restrict ssh-ed25519 [...] user@hostname
```

Fore more information see contents of `remote` folder.

### Local

*(FreeBSD-)Server with your encrypted drive(s).*

Install the script itself into `/usr/local/etc/rc.d`:

```sh
fetch https://raw.githubusercontent.com/spookey/geli_remote_unlock/main/geliremoteunlock -o /usr/local/etc/rc.d/geliremoteunlock
chmod +x /usr/local/etc/rc.d/geliremoteunlock
```

#### Partitions

You need some encrypted zpool to get unlocked by **geliremoteunlock**.
In this example I'll create a zpool creatively named **tank**.

First, create the key:

```sh
mkdir /root/keys
chmod go-rwx /root/keys

dd if=/dev/random of=/root/keys/tank.key bs=256k count=1
```

If not already done, create a partition (you may want to adjust the size).
In this example it is created on the disk **ada0**:

```sh
gpart add -a 4k -s 32G -t freebsd-zfs -l tank ada0
```

Now, a `/dev/gpt/tank` partition should show up.
This is how to encrypt it:

```sh
geli init -K /root/keys/tank.key -s 4096 -l 256 /dev/gpt/tank
```

Be creative with the passphrase. Don't forget it, you'll need it to unlock
it now:

```sh
geli attach -k /root/keys/tank.key /dev/gpt/tank
```

Now, a `/dev/gpt/tank.eli` partition should show up.
Finally create the zpool and zfs volumes inside it:

```sh
zpool create tank /dev/gpt/tank.eli
```

The zpool should now be mounted as `/tank`.

#### Keys & Passphrases

The keyfile was generated as `/root/keys/tank.key`.
You should now create a passphrase file alongside:

Write your passphrase into a textfile (without newline at the end) into
`/root/keys/tank.pass`.

Optional, but very recommended - encrypt the key and passphrase files:

```sh
openssl enc -aes-256-cbc -a -pbkdf2 -salt \
    -in /root/keys/tank.key \
    -out /root/keys/tank.key.aes \
    -pass "pass:f1144647f681194a666b1f19c4eb83e1"

openssl enc -aes-256-cbc -a -pbkdf2 -salt \
    -in /root/keys/tank.pass \
    -out /root/keys/tank.pass.aes \
    -pass "pass:f600f3a243d0ce33f7bab4ad16c59e91"
```

The `*.aes` files should be uploaded to the remote server(s).
(`-pass` is just some random string, created using e.g:
`printf "tank.key" | md5` - please be more creative than that!
You'll need them later, see below)

**NOTE**: `/root/keys` is in an unencrypted location!
After transferring the `*.aes` files you should make an offsite backup of
the unencrypted keys (thumb drive in a secure location, etc.) and delete
them afterwards.

#### Configuration

This software needs some configuration inside of `/etc/rc.conf`.

Enable the script itself:

```sh
geliremoteunlock_enable="YES"
```

Define the pools which shall be unlocked:

```sh
geliremoteunlock_pools="data tank"
```

From now on every setting can be bound to a specific pool
(`geliremoteunlock_data_foo`, `geliremoteunlock_tank_foo`)
or to apply for all pools
(`geliremoteunlock_foo`).

Specify where the pools are located:

```sh
geliremoteunlock_data_devices="/dev/gpt/data"
geliremoteunlock_tank_devices="/dev/gpt/tank"
```

Specify information where to get the keyfiles:

```sh
geliremoteunlock_keyfile_host="username@keys.example.com"
geliremoteunlock_keyfile_ident="/root/.ssh/unlock_key_ed25519"

geliremoteunlock_data_keyfile_name="data.key.aes"
geliremoteunlock_data_keyfile_password="7179227046a1cdc8bb0e9a81523a6822"

geliremoteunlock_tank_keyfile_name="tank.key.aes"
geliremoteunlock_tank_keyfile_password="f1144647f681194a666b1f19c4eb83e1"
```

And now the same for the passphrases:

```sh
geliremoteunlock_passphrase_host="username@pass.example.com"
geliremoteunlock_passphrase_ident="/root/.ssh/unlock_pass_ed25519"

geliremoteunlock_data_passphrase_name="data.pass.aes"
geliremoteunlock_data_passphrase_password="46cf04febc44b6e0d956bf034f3d11aa"

geliremoteunlock_tank_passphrase_name="tank.pass.aes"
geliremoteunlock_tank_passphrase_password="f600f3a243d0ce33f7bab4ad16c59e91"
```

## Origins

This project is a loosely rewrite of
[geliUnlocker](https://github.com/clinta/geliUnlocker).

I just wanted to solve the same problems, but in a little different way.

The changes are different enough that forking was not really an option.

Thanks for that original awesome work - it helped a lot!
