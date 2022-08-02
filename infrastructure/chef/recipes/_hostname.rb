# This is done manually to work around https://github.com/chef/chef/issues/8477
# The commands below were extracted from https://github.com/chef/chef/blob/master/lib/chef/resource/hostname.rb

ohai "reload hostname" do
  plugin "hostname"
  action :nothing
end

# Set the host name
execute "set HostName to buildpipeline#{node['buildpipeline_agent']['machine_number']}" do
  command %{/usr/sbin/scutil --set HostName "buildpipeline#{node['buildpipeline_agent']['machine_number']}"}
  notifies :reload, "ohai[reload hostname]"
end

# Set the computer name
execute "set ComputerName to buildpipeline#{node['buildpipeline_agent']['machine_number']}" do
  command %{/usr/sbin/scutil --set ComputerName "buildpipeline#{node['buildpipeline_agent']['machine_number']}"}
  notifies :reload, "ohai[reload hostname]"
end

# Set the local host name
execute "set LocalHostName to buildpipeline#{node['buildpipeline_agent']['machine_number']}" do
  command %{/usr/sbin/scutil --set LocalHostName "buildpipeline#{node['buildpipeline_agent']['machine_number']}"}
  notifies :reload, "ohai[reload hostname]"
end
