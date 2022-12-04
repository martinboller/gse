Vagrant.configure("2") do |config|

# manticore Greenbone Vuln Scanner (Primary)
  config.vm.define "manticore" do |cfg|
    cfg.vm.box = "generic/debian11"
    cfg.vm.hostname = "manticore"
    cfg.vm.network "public_network", type: "dhcp", bridge: 'enp1s0', mac: "0020911E0007"
    cfg.vm.provision :file, source: './installfiles', destination: "/tmp/installfiles"
    cfg.vm.provision :shell, path: "bootstrap.sh"
    cfg.vm.provision "reload"
    cfg.vm.provision :shell, path: "installfiles/install-GSE-2021.sh"

    cfg.vm.provider "vmware_fusion" do |v, override|
      v.vmx["displayname"] = "manticore"
      v.memory = 5120
      v.cpus = 4
      v.gui = false
    end

    cfg.vm.provider "vmware_desktop" do |v, override|
      v.vmx["displayname"] = "manticore"
      v.memory = 5120
      v.cpus = 4
      v.gui = false
    end

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.gui = false
      vb.name = "manticore"
      vb.customize ["modifyvm", :id, "--memory", 6144]
      vb.customize ["modifyvm", :id, "--cpus", 4]
      vb.customize ["modifyvm", :id, "--vram", "4"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end
  end

# Aboleth Greenbone Vuln Scanner (Secondary)
  config.vm.define "aboleth" do |cfg|
    cfg.vm.box = "generic/debian11"
    cfg.vm.hostname = "aboleth"
    cfg.vm.network "public_network", type: "dhcp", bridge: 'enp1s0', mac: "0020911E0008"
    cfg.vm.provision :file, source: './installfiles', destination: "/tmp/installfiles"
    cfg.vm.provision :shell, path: "bootstrap.sh"
    cfg.vm.provision "reload"
    cfg.vm.provision :shell, path: "installfiles/install-GSE-2021-secondary.sh"

    cfg.vm.provider "vmware_fusion" do |v, override|
      v.vmx["displayname"] = "aboleth"
      v.memory = 2048
      v.cpus = 2
      v.gui = false
    end

    cfg.vm.provider "vmware_desktop" do |v, override|
      v.vmx["displayname"] = "aboleth"
      v.memory = 2048
      v.cpus = 2
      v.gui = false
    end

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.gui = false
      vb.name = "aboleth"
      vb.customize ["modifyvm", :id, "--memory", 2048]
      vb.customize ["modifyvm", :id, "--cpus", 2]
      vb.customize ["modifyvm", :id, "--vram", "4"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end
  end

# Nessie Nessus Pro Vuln Scanner
  # config.vm.define "nessie" do |cfg|
  #   cfg.vm.box = "generic/debian11"
  #   cfg.vm.hostname = "nessie"
  #   cfg.vm.network "public_network", type: "dhcp", bridge: 'enp1s0', mac: "0020911E0009"
  #   cfg.vm.provision :file, source: './installfiles', destination: "/tmp/installfiles"
  #   cfg.vm.provision :shell, path: "bootstrap.sh"

  #cfg.vm.provider "vmware_fusion" do |v, override|
  #  v.vmx["displayname"] = "nessie"
  #  v.memory = 2048
  #  v.cpus = 2
  #  v.gui = false
  #end

  #cfg.vm.provider "vmware_desktop" do |v, override|
  #  v.vmx["displayname"] = "nessie"
  #  v.memory = 2048
  #  v.cpus = 2
  #  v.gui = false
  #end

  #   cfg.vm.provider "virtualbox" do |vb, override|
  #     vb.gui = false
  #     vb.name = "nessie"
  #     vb.customize ["modifyvm", :id, "--memory", 2048]
  #     vb.customize ["modifyvm", :id, "--cpus", 4]
  #     vb.customize ["modifyvm", :id, "--vram", "4"]
  #     vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
  #     vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
  #   end
  # end

end
