
# status_pages_password = secrets['status_pages_password']

# execute 'Install Bo' do
#  command "curl -sLS -u status:#{status_pages_password} https://jm.sketchsrv.com/status/install-bo.sh | zsh"
#  not_if { ::File.exist?('/usr/local/bin/bo') }
# end

execute 'git clone git@github.com:sketch-hq/BCTools.git' do
  cwd '/tmp'
  user machine_user
  not_if do
    ::Dir.exist?("/tmp/BCTools")
  end
  notifies :run, 'execute[sudo ./bootstrap.sh]', :immediately
end

execute 'sudo ./bootstrap.sh' do
  cwd '/tmp/BCTools'
  action :nothing
end

execute "bo symlink XCODE_VERSION" do


# GIT PULL the repo if it is already installed

execute 'git pull' do
  cwd '/'
end


end
