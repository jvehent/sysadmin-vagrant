node default {
        include vagrantenv
}
node 'puppetmaster.localdomain' {
        # Configure puppetdb and its underlying database
        class { 'puppetdb': }
        # Configure the puppet master to use puppetdb
        class { 'puppetdb::master::config': }
}
node 'ossecserver.vagrant.allizom.org' {
        class {'puppet-autossec::server':
                mailserver_ip => '127.0.0.1',
                ossec_emailto => 'blackhole@example.net',
        }
}
node 'ossecagent.vagrant.allizom.org' {
        class {'puppet-autossec::agent':
                ossec_server_ip => '192.168.33.12',
        }
}
