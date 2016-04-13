# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  shell_args = [
    "APP_ENV=development",
    "DBHOST=localhost",
    "DBNAME=boltcms",
    "DBUSER=admin",
    "DBPASSWD=admin"
  ].join(" ")

  config.vm.provider :virtualbox do |virtualbox|
    virtualbox.name = "bolt-cms-development"
    virtualbox.memory = "2048"
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  config.vm.synced_folder "./development-stage", "/vagrant/development-stage", create: true
  config.vm.network "private_network", ip: "192.168.33.12"
  config.ssh.insert_key = false
  config.vm.provision "shell", path: "./provisioning/setup.sh", args: shell_args
end
