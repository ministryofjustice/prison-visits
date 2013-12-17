Vagrant.configure("2") do |config|

    # select distribution
    config.vm.box = "centos6.4c"
    config.vm.box_url = "http://static.dsd.io/vagrant/centos6.4c.box"

    # for masterless salt: mount your salt file root and minion config
    config.vm.synced_folder "../salty-dsd/salt/roots/", "/srv/salt/"
    config.vm.synced_folder "../salty-dsd/default/pillar/", "/srv/pillar/"

    config.vm.network :forwarded_port, guest: 80, host: 8080
    config.vm.synced_folder ".", "/srv/prisonvisits/application/current", :mount_options => ["dmode=775,fmode=664"]

    # To bootstrap machine using salt let's push role before salt.highstate runs
    config.vm.provision :fabric do |fabric|
        fabric.fabfile_path = "../salty-dsd/fabfile.py"
        fabric.tasks = [
            "provider:vagrant",
            "vagrant_bootstrap",
            "pushrole:prisonvisits:ssl:haproxy:varnish:postgresql:devsmtp",
        ]
    end

    # Time to execute salt state.highstate
    config.vm.provision :salt do |salt|
        salt.minion_config = "../salty-dsd/salt/minion"
        salt.verbose = true
        salt.run_highstate = true
    end
end
