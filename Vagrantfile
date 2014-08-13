# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210.box"

  config.vm.synced_folder "hiera/", "/tmp/vagrant-puppet-1/hiera"
  config.vm.synced_folder "keys/", "/tmp/vagrant-puppet-1/keys"

  config.vm.provision "shell",
    inline: "gem install hiera-eyaml --no-rdoc --no-ri"

  config.vm.define "platform" do |platform|
    platform.vm.network "private_network", ip: "192.168.33.10"
    platform.vm.provision :puppet do |puppet|
      puppet.manifest_file = "platform.pp"
      common_provision(puppet)
      puppet.facter = {
        "env" => "vagrant",
        "application" => "platform"
      }
    end
  end

  config.vm.define "measures" do |measures|
    measures.vm.network "private_network", ip: "192.168.33.11"
    measures.vm.provision :puppet do |puppet|
      puppet.manifest_file = "measures.pp"
      common_provision(puppet)
      puppet.facter = {
        "env" => "vagrant",
        "application" => "measures"
      }
    end
  end

end

def common_provision(puppet)
  puppet.manifests_path = "manifests"
  puppet.module_path = "modules"
  puppet.hiera_config_path = "hiera.yaml"
  puppet.working_directory = "/tmp/vagrant-puppet-1"
end
