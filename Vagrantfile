# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # This is the path to trunk of the sysamins svn puppet repo
  # I've left my path here as an exmaple, but you will need to
  # update this for your local system
  
  puppet_base_path = '/Users/jabba/svn/puppet/trunk'
  puppet_path = '/etc/puppet'
  # The ipaddress of the host only network adapter
  # This is probably fine to be left as is
  puppetmaster_ip = '192.168.33.10'

  config.vm.define :puppetmaster do |puppetmaster_config|
    puppetmaster_config.vm.customize ["modifyvm", :id, "--memory", 2048]
    puppetmaster_config.vm.box = "centos-puppetmaster"
    puppetmaster_config.vm.network :hostonly, puppetmaster_ip

    # enc_classes is a way to apply classes to a node
    # base::puppetclient
    # vagrantenv are requirements and should not be removed
    enc_classes = Array.new
    enc_classes << 'base::puppetclient'
    enc_classes << 'vagrantenv'
    enc_classes.each do |enc_class|
    puppetmaster_config.vm.provision :shell,
        :inline => "echo \"#{enc_class}\" >> /tmp/puppet_classes.txt"
    end
    puppetmaster_config.vm.share_folder "hiera", "#{puppet_path}/hiera", "#{puppet_base_path}/hiera"
    puppetmaster_config.vm.share_folder "bin", "#{puppet_path}/bin", "#{puppet_base_path}/bin"
    puppetmaster_config.vm.share_folder "files", "#{puppet_path}/files", "#{puppet_base_path}/files"
    puppetmaster_config.vm.share_folder "modules", "#{puppet_path}/modules", "#{puppet_base_path}/modules"
    puppetmaster_config.vm.share_folder "vagrant_modules", "#{puppet_path}/vagrant_modules", "#{puppet_base_path}/vagrant_modules"
    puppetmaster_config.vm.share_folder "puppetmasterd", "#{puppet_path}/puppetmasterd", "#{puppet_base_path}/puppetmasterd"
    puppetmaster_config.vm.share_folder "trunk", "/trunk", "#{puppet_base_path}"

    # Need to write a script here to check for the existance of this file and
    # This will fail if you do a vagrant reload puppetmaster
    puppetmaster_config.vm.provision :shell, :inline => "test -e #{puppet_path}/hiera.yaml || ln -s /trunk/hiera.yaml #{puppet_path}/hiera.yaml"
    puppetmaster_config.vm.provision :shell, :inline => "cp /vagrant/site.pp /etc/puppet/manifests/"
  end

  config.vm.define :node do |node|
    system_hostname = 'vagrant-test.dmz.scl3.mozilla.com'
    ipaddr = '192.168.33.11'
    # config flag to disable selinux
    # which appears to be our default coarse of action
    disable_se_linux = true
    node.vm.box = "moz-rhel-6.4"
    node.vm.customize ["modifyvm", :id, "--memory", 2048]
    node.vm.host_name = system_hostname
    #
    # You might want to uncomment this for debugging
    #node.vm.boot_mode = :gui
    #
    # This is the itnerface that the node actually talks
    # to the puppetmaster on. It needs to be in the same
    # subnet as puppetmaster_ip
    node.vm.network :hostonly, "192.168.33.11"
    if disable_se_linux
        node.vm.provision :shell, :inline => "setenforce 0"
    end
    # Confirm that we've got a host entry back to the puppetmaster for
    # the initial buildout since people can configure the puppetmaster_ip
    node.vm.provision :shell,
        :inline => "echo \"#{puppetmaster_ip} puppetmaster.localdomain\" >> /etc/hosts"

    node.vm.provision :puppet_server do |puppet|
        puppet.puppet_server = "puppetmaster.localdomain"
        puppet.puppet_node = system_hostname
        puppet.options = [
            "--test",
            "--server=puppetmaster.localdomain",
            "--configtimeout=300",
            "--waitforcert=300",
            "--certname=#{system_hostname}",
        ]
    end
  end

end
