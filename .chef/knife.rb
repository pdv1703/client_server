current_dir = File.dirname(__FILE__)
log_level                 :info
log_location              STDOUT
node_name                 "pdv"
client_key                "#{current_dir}/pdv.pem"
chef_server_url           "https://chef.server.for.test/organizations/global_test"
cookbook_path             ["#{current_dir}/../cookbooks"]
