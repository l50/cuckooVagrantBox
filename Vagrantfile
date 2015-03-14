Vagrant.configure(2) do |config|
  config.vm.box = "cyplo/ubuntu-gnome-utopic-gui"
  config.puppet_install.puppet_version = :latest

  config.vm.define :malwarrior do |malwarrior|
    malwarrior.vm.hostname = 'malwarrior'
    malwarrior.vm.network :private_network, ip: "192.168.50.20"

    malwarrior.vm.provider :virtualbox do |vm|
      vm.gui = true
      vm.customize [
                       "modifyvm", :id,
                       "--memory", 2048,
                       "--cpus", "2"
                   ]
    end
  end
  config.vm.provision :shell, :path => "scripts/cuckooautoinstall.sh"

  #config.vm.provision "shell", :inline => <<-SHELL
  # apt-get update
  #apt-get install -y puppet
  #SHELL

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.module_path    = "modules"
    puppet.manifest_file  = "site.pp"
  end
end
