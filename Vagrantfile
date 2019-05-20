# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/debian9"
  config.vm.provision "shell", path: "provision.sh"
  config.vm.provision "shell", inline: "sudo usermod -aG docker vagrant"
end
