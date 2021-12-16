Vagrant.configure("2") do |config|

# manticore Greenbone Vuln Scanner (Primary)
  config.vm.define "manticore" do |cfg|
    cfg.vm.box = "generic/debian11"
    cfg.vm.hostname = "manticore"
    cfg.vm.network "public_network", type: "dhcp", bridge: 'enp1s0', mac: "0020911E0007"
    cfg.vm.provision :file, source: './configfiles', destination: "/tmp/configfiles"
    cfg.vm.provision :shell, path: "bootstrap.sh"

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.gui = false
      vb.name = "manticore"
      vb.customize ["modifyvm", :id, "--memory", 5120]
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
    cfg.vm.provision :file, source: './configfiles', destination: "/tmp/configfiles"
    cfg.vm.provision :shell, path: "bootstrap.sh"

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.gui = false
      vb.name = "aboleth"
      vb.customize ["modifyvm", :id, "--memory", 2048]
      vb.customize ["modifyvm", :id, "--cpus", 4]
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
  #   cfg.vm.provision :file, source: './configfiles', destination: "/tmp/configfiles"
  #   cfg.vm.provision :shell, path: "bootstrap.sh"

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