maintainers_public_keys = secrets['maintainers_ssh_public_keys']

# Maintainers will also contain the jenkins server public key
file "#{home}/.ssh/authorized_keys" do
  content maintainers_public_keys.join("\n")
  mode '00644'
  owner machine_user
  group machine_group
  action :create
end
