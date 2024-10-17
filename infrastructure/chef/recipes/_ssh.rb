# Add node ssh key
file "#{home}/.ssh/id_rsa" do
  content secrets['git_ssh_private_key']
  mode '00600'
  owner machine_user
  group machine_group
end

# auto detect github
ssh_known_hosts_entry 'github.com' do
  file_location "#{home}/.ssh/known_hosts"
  owner machine_user
  group machine_group
end

ssh_known_hosts_entry 'github.com' do
  file_location "#{home}/.ssh/known_hosts"
  owner machine_user
  owner machine_group
  action :flush
end
