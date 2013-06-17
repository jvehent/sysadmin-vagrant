# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # This is the path to trunk of the sysamins svn puppet repo
  puppet_base_path = '~/svn/sysadmins/puppet/trunk'
  puppet_path = '/etc/puppet'
  # The ipaddress of the host only network adapter
  # This is probably fine to be left as is
  puppetmaster_ip = '192.168.33.10'

  config.vm.define :puppetmaster do |puppetmaster_config|
    puppetmaster_config.vm.customize ["modifyvm", :id,
                                      "--memory", "1500",
                                      "--cpus", "2",
                                      "--ioapic", "on"] # fix perf issue on F19
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
    # mount shared folders
    ["hiera", "bin", "files", "modules", "vagrant_modules",
     "puppetmasterd"].each do |sharename|
      puppetmaster_config.vm.share_folder sharename,
                                          "#{puppet_path}/#{sharename}",
                                          "#{puppet_base_path}/#{sharename}"
    end
    puppetmaster_config.vm.share_folder "trunk", "/trunk", "#{puppet_base_path}"
    # specific to work in progress: puppet-autossec
    puppetmaster_config.vm.share_folder "puppet-autossec",
                                        "#{puppet_path}/modules/puppet-autossec",
                                        "/home/ulfr/Code/puppet-autossec"
    # Need to write a script here to check for the existence of this file and
    # This will fail if you do a vagrant reload puppetmaster
    puppetmaster_config.vm.provision :shell,
      :inline => "if [ ! -h #{puppet_path}/hiera.yaml ]; then " +
                 "rm #{puppet_path}/hiera.yaml; " +
                 "ln -s /trunk/hiera.yaml #{puppet_path}/hiera.yaml; fi"
    puppetmaster_config.vm.provision :shell,
      :inline => "if [ ! -e /etc/puppet/manifests/site.pp ]; then " +
                 "cp /vagrant/site.pp /etc/puppet/manifests/; fi"
  end

  config.vm.define :ossecagent do |node|
    system_hostname = 'ossecagent.vagrant.allizom.org'
    ipaddr = '192.168.33.11'
    # config flag to disable selinux
    # which appears to be our default coarse of action
    disable_se_linux = true
    node.vm.box = "moz-rhel-6.4"
    node.vm.customize ["modifyvm", :id,
                       "--memory", "1024",
                       "--cpus", "2",
                       "--ioapic", "on"]
    node.vm.host_name = system_hostname
    #
    # You might want to uncomment this for debugging
    #node.vm.boot_mode = :gui
    #
    # This is the interface that the node actually talks
    # to the puppetmaster on. It needs to be in the same
    # subnet as puppetmaster_ip
    node.vm.network :hostonly, "192.168.33.11"
    if disable_se_linux
        node.vm.provision :shell, :inline => "setenforce 0; exit 0"
    end
    # Confirm that we've got a host entry back to the puppetmaster for
    # the initial buildout since people can configure the puppetmaster_ip
    node.vm.provision :shell,
        :inline => "echo \"#{puppetmaster_ip} puppetmaster.localdomain\" " +
                   ">> /etc/hosts"

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

  config.vm.define :ossecserver do |node|
    system_hostname = 'ossecserver.vagrant.allizom.org'
    ipaddr = '192.168.33.12'
    disable_se_linux = true
    node.vm.box = "moz-rhel-6.4"
    node.vm.customize ["modifyvm", :id,
                       "--memory", "1024",
                       "--cpus", "2",
                       "--ioapic", "on"]
    node.vm.host_name = system_hostname
    node.vm.network :hostonly, ipaddr
    if disable_se_linux
        node.vm.provision :shell, :inline => "setenforce 0; exit 0"
    end
    # Confirm that we've got a host entry back to the puppetmaster for
    # the initial buildout since people can configure the puppetmaster_ip
    node.vm.provision :shell,
        :inline => "echo \"#{puppetmaster_ip} puppetmaster.localdomain\" " +
                   ">> /etc/hosts"

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

  config.vm.define :puppetm2 do |puppetmaster_config|
    puppetmaster_config.vm.customize ["modifyvm", :id,
                                      "--memory", "1500",
                                      "--cpus", "2",
                                      "--ioapic", "on"] # fix perf issue on F19
    puppetmaster_config.vm.box = "centos-puppetmaster"
    puppetmaster_config.vm.network :hostonly, '192.168.33.100'
    enc_classes = Array.new
    enc_classes << 'base::puppetclient'
    enc_classes << 'vagrantenv'
    enc_classes.each do |enc_class|
      puppetmaster_config.vm.provision :shell,
        :inline => "echo \"#{enc_class}\" >> /tmp/puppet_classes.txt"
    end
    ["hiera", "bin", "files", "modules", "vagrant_modules",
     "puppetmasterd"].each do |sharename|
      puppetmaster_config.vm.share_folder sharename,
                                          "#{puppet_path}/#{sharename}",
                                          "#{puppet_base_path}/#{sharename}"
    end
    puppetmaster_config.vm.share_folder "trunk", "/trunk", "#{puppet_base_path}"
    puppetmaster_config.vm.provision :shell,
      :inline => "if [ ! -h #{puppet_path}/hiera.yaml ]; then " +
                 "rm #{puppet_path}/hiera.yaml; " +
                 "ln -s /trunk/hiera.yaml #{puppet_path}/hiera.yaml; fi"
    puppetmaster_config.vm.provision :shell,
      :inline => "if [ ! -e /etc/puppet/manifests/site.pp ]; then " +
                 "cp /vagrant/site.pp /etc/puppet/manifests/; fi"
  end
end
