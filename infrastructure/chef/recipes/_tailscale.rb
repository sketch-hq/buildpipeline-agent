# Set up Tailscale

auth_key = data_bag_item('buildpipeline-agent', 'secrets')['tailscale_auth_key']

homebrew_package "tailscale" do
  name "tailscale"
end

execute "enable Tailscale service" do
  command "sudo HOMEBREW_NO_INSTALL_FROM_API=1 #{homebrew_prefix}/bin/brew services start tailscale"
  action :run
end

bash 'tailscale up' do
  code   "#{homebrew_prefix}/bin/tailscale up --auth-key=#{auth_key} --hostname=#{node['name']} --ssh --advertise-tags=tag:buildpipeline-worker --accept-routes=true --accept-dns=true"
  not_if "#{homebrew_prefix}/bin/tailscale status"
  action :run
end
