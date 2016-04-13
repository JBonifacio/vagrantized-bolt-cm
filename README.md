# vagrantized-bolt-cm

Provides a [shell script](provisioning/setup.sh) provisioned [Vagrant](https://www.vagrantup.com) box to jump into the development with [Bolt.cm](http://bolt.cm). It's based upon `PHP 5.6`, `MySQL 5.5`, and `Apache2 2.4`.

The database related configurations can be customised by modifying the `shell_args` elements in the [Vagrantfile](Vagrantfile).

# Start the Vagrant box

```bash
git clone https://github.com/raphaelstolt/vagrantized-bolt-cm.git
cd vagrantized-bolt-cm
vagrant up
```
When having trouble to get the Vagrant box up and running start it with `vagrant up > vagrant-up.log`, and try to resolve the issues by scanning the now available log file `vagrant-up.log` for errors.

# Access bolt.cm
Add an IP hostname mapping to the `hosts` file.

```text
192.168.33.12 bolt-dev.io
```

Now point your browser of choice to `http://bolt-dev.io`, follow the given instructions, and enjoy your dive into the world of `Bolt.cm`.

To access and use the `Bolt.cm` development relevant filesystem part of the Vagrant box simply use the synced `./dev-stage/boltcms` folder.
