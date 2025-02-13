Vagrant.configure("2") do |config|

# manticore Greenbone Vuln Scanner (Primary)
  config.vm.define "manticore" do |cfg|
    cfg.vm.box = "generic/debian12"
    cfg.vm.hostname = "manticore"
    cfg.vm.network "public_network", dev: 'br0', bridge: 'br0', mode: 'bridge', type: 'bridge', mac: "0020911E0007"
    cfg.vm.provision :file, source: './installfiles', destination: "/tmp/installfiles"
    cfg.vm.provision :file, source: './installfiles/.env', destination: "/tmp/installfiles/.env"
    cfg.vm.provision :shell, path: "bootstrap.sh"
    cfg.vm.provision "reload"
    cfg.vm.provision :shell, path: "installfiles/install-gse.sh"

    cfg.vm.provider "libvirt" do |lv, override|
      lv.graphics_type = "vnc"
      lv.video_type = "vga"
      lv.input :type => "tablet", :bus => "usb"
      lv.video_vram = 4096
      lv.memory = 16384
      lv.cpus = 8
      lv.cpu_mode = "host-passthrough"
      # Which storage pool path to use. Default to /var/lib/libvirt/images or ~/.local/share/libvirt/images depending on if you are running a system or user QEMU/KVM session.
      lv.storage_pool_name = 'default'
      override.vm.synced_folder './', '/vagrant', type: 'rsync'
    end

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
      vb.customize ["modifyvm", :id, "--memory", 10240]
      vb.customize ["modifyvm", :id, "--cpus", 4]
      vb.customize ["modifyvm", :id, "--vram", "8"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end
  end

# Aboleth Greenbone Vuln Scanner (Secondary)
  config.vm.define "aboleth" do |cfg|
    cfg.vm.box = "generic/debian12"
    cfg.vm.hostname = "aboleth"
    cfg.vm.network "public_network", dev: 'br0', bridge: 'br0', mode: 'bridge', type: 'bridge', mac: "0020911E0008"
    cfg.vm.provision :file, source: './installfiles', destination: "/tmp/installfiles"
    cfg.vm.provision :file, source: './installfiles/.env', destination: "/tmp/installfiles/.env"
    cfg.vm.provision :shell, path: "bootstrap.sh"
    cfg.vm.provision "reload"
    cfg.vm.provision :shell, path: "installfiles/install-gse-secondary.sh"

    cfg.vm.provider "libvirt" do |lv, override|
      lv.graphics_type = "vnc"
      lv.video_type = "vga"
      lv.input :type => "tablet", :bus => "usb"
      lv.video_vram = 4096
      lv.memory = 4096
      lv.cpus = 4
      lv.cpu_mode = "host-passthrough"
      #libvirt.storage_pool_path = '/media/storage_nvme/system_session_vm_pool'
      lv.storage_pool_name = 'pool-1'
      override.vm.synced_folder './', '/vagrant', type: 'rsync'
    end

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
  #   cfg.vm.network "public_network", dev: 'br0', mac: "0020911E0007"
  #   cfg.vm.provision :file, source: './installfiles', destination: "/tmp/installfiles"
  #   cfg.vm.provision :shell, path: "bootstrap.sh"

  # cfg.vm.provider "libvirt" do |lv, override|
  #   lv.graphics_type = "vnc"
  #   lv.video_type = "vga"
  #   lv.input :type => "tablet", :bus => "usb"
  #   lv.video_vram = 32768
  #   lv.memory = 10240
  #   lv.cpus = 4
  #   # This is required for Vagrant to properly configure the network interfaces.
  #   # See https://github.com/clong/DetectionLab/wiki/LibVirt-Support for more information
  #   #lv.management_network_name = "VagrantMgmt"
  #   #lv.management_network_address = "172.31.0.0/24"
  #   #lv.management_network_mode = "none"
  #   lv.cpu_mode = "host-passthrough"
  #   # Which storage pool path to use. Default to /var/lib/libvirt/images or ~/.local/share/libvirt/images depending on if you are running a system or user QEMU/KVM session.
  #   #libvirt.storage_pool_path = '/media/storage_nvme/system_session_vm_pool'
  #   lv.storage_pool_name = 'pool-1'
  #   #override.vm.box = "generic/ubuntu2004"
  #   override.vm.synced_folder './', '/vagrant', type: 'rsync'
  # end

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
