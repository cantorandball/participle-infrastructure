# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210.box"
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provision "shell",
    inline: "gem install hiera-eyaml --no-rdoc --no-ri"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.module_path = "modules"
    puppet.hiera_config_path = "hiera.yaml"
    puppet.working_directory = "/tmp/vagrant-puppet-1"
    config.vm.synced_folder "hiera/", "/tmp/vagrant-puppet-1/hiera"
    config.vm.synced_folder "keys/", "/tmp/vagrant-puppet-1/keys"
    puppet.facter = {
        "env" => "vagrant"
    }
  end

end
