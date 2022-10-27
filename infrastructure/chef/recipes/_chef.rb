# Enable the osx version of logrotate on the chef client logs
template "/etc/newsyslog.d/chef.conf" do
  source 'logs/chef.conf.erb'
  mode '00644'
  user 'root'
  group 'wheel'
end

# We wrap the chef-client process exec with this script due to issues with early
# versions of Rosetta which can cause it to stall
cookbook_file "/usr/local/bin/ramsey" do
  source 'chef/ramsey.sh'
  mode '00755'
  user 'root'
  group 'wheel'
end

# Set up chef as a launchd service that runs every 60 minutes
node.override['chef_client']['bin'] = "/usr/local/bin/ramsey"
include_recipe('chef-client::service')

# Delete the validation pem file that is copied to the machine on bootstrap
include_recipe('chef-client::delete_validation')

# Ensure we are running the latest version of this major release
chef_client_updater 'Install latest Chef Infra Client 16.x' do
  version '16'
end
