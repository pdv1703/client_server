# -*- mode: ruby -*-
# vi: set ft=ruby :
server_ip = '192.100.0.5'
client_ip = '192.100.0.10'

CHEF_SERVER_INSTALL = <<-EOF
#!/bin/sh
  echo "Installing chef-server"
  yum install -y wget curl
  wget 'https://packages.chef.io/files/stable/chef-server/12.17.3/el/6/chef-server-core-12.17.3-1.el6.x86_64.rpm'
  sudo rpm -ivh /home/vagrant/chef-server-core-12.17.3-1.el6.x86_64.rpm
  sudo chef-server-ctl reconfigure
  chef-server-ctl user-create pdv Dmytro Horavskyi p.d.v.1703@i.ua 'password' --filename /home/vagrant/pdv.pem
  chef-server-ctl org-create global_test 'For test globallogic tasks' --association_user pdv --filename /home/vagrant/global_test.pem
  sudo chef-server-ctl install chef-manage
  sudo chef-server-ctl reconfigure
  sudo chef-manage-ctl reconfigure --accept-license
  sudo cp /home/vagrant/pdv.pem /vagrant/shared_folder/.chef/pdv.pem
EOF

MODIFY_HOSTS = <<-EOF
#!/bin/sh
sudo echo "#{server_ip} chef.server.for.test" >> /etc/hosts
EOF

unless Vagrant.has_plugin?("vagrant-triggers")
  raise "\nvagrant-triggers plugin is not installed! \nPlease install using 'vagrant plugin install vagrant-triggers\nhttps://github.com/emyl/vagrant-triggers\n'"
end

Vagrant.configure('2') do |config|

  config.vm.define "test_server" do |test_server|
    test_server.vm.box = 'bento/centos-6.9'
    test_server.vm.hostname = 'chef.server.for.test'
    test_server.vm.network 'private_network', ip: server_ip
    test_server.vm.network "forwarded_port", guest: 22, host: 2233
    test_server.vm.synced_folder ".", "/vagrant/shared_folder"
    test_server.vm.provision :shell, :inline => CHEF_SERVER_INSTALL
    test_server.vbguest.auto_update = false
    test_server.vm.provider :virtualbox do |vb|
      vb.name = 'chef_server'
    end
    test_server.trigger.after :up do
      system("echo 192.100.0.5 chef.server.for.test >>  C:/Windows/System32/drivers/etc/hosts")
    end
  end

  config.vm.define "test_client" do |test_client|
    test_client.vm.box = 'bento/centos-6.9'
    test_client.vm.hostname = 'chef.client.test'
    test_client.vm.network 'private_network', ip: client_ip
    test_client.vm.network "forwarded_port", guest: 22, host: 2234
	  test_client.vm.provision :shell, :inline => MODIFY_HOSTS
    test_client.vbguest.auto_update = false
    test_client.vm.provider :virtualbox do |vb|
      vb.name = 'chef_client'
    end
    test_client.trigger.after :up do
      system ('pwd')
      system ('mkdir cookbooks')
      system ('mkdir data_bags')
      system ('git clone https://portal-ua.globallogic.com/gitlab/dmytro.horavskyi/task_6')
      system ('mv ./task_6 ./cookbooks/jenkins_task')
      system ('mv ./cookbooks/jenkins_task/test/data_bags/jenkins_users  ./data_bags')
      system ('knife ssl fetch')
      system ('knife ssl check')
      system ('berks install --berksfile .\cookbooks\jenkins_task\Berksfile')
      system ('berks upload --berksfile .\cookbooks\jenkins_task\Berksfile --no-ssl-verify')
      system ('knife upload /')
      system ("knife bootstrap --bootstrap-version 13.5.3 localhost --ssh-port 2234 --ssh-user vagrant --sudo --identity-file ./.vagrant/machines/test_client/virtualbox/private_key --node-name node1-centos --run-list 'recipe[jenkins::java], recipe[jenkins_task]'")
    end
  end
end
