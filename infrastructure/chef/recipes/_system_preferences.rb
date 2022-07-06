# Based on: https://github.com/microsoft/macos-cookbook/blob/835b8168ce397d89c0caf6d7a78f55d9664b7f81/recipes/keep_awake.rb
environment = MacOS::System::Environment.new(node['virtualization']['systems'])
screensaver = MacOS::System::ScreenSaver.new(node['macos']['admin_user'])

#
# Keep the Mac running constantly
#

system_preference 'disable computer sleep' do
  preference :computersleep
  setting 'Never'
end

system_preference 'disable display sleep' do
  preference :displaysleep
  setting 'Never'
end

system_preference 'disable hard disk sleep' do
  preference :harddisksleep
  setting 'Never'
end

system_preference 'restart if the computer becomes unresponsive' do
  preference :restartfreeze
  setting 'On'
end

system_preference 'wake the computer when accessed using a network connection' do
  preference :wakeonnetworkaccess
  setting 'On'
  not_if { environment.vm? }
end

system_preference 'restart after a power failure' do
  preference :restartpowerfailure
  setting 'On'
  not_if { environment.vm? }
end

system_preference 'pressing power button does not sleep computer' do
  preference :allowpowerbuttontosleepcomputer
  setting 'Off'
end

defaults 'com.apple.screensaver' do
  option '-currentHost write'
  settings 'idleTime' => 0
  not_if { screensaver.disabled? }
  user machine_user
end

#
# Time Settings
#

system_preference 'set using network time' do
  preference :usingnetworktime
  setting 'on'
end

system_preference 'set the network time server' do
  preference :networktimeserver
  setting 'time.apple.com'
end

system_preference 'set the time zone' do
  preference :timezone
  setting 'GMT'
end

#
# DNS
#

network_interface = node['buildpipeline_agent']['network_interface']
dns_servers = node['buildpipeline_agent']['dns_servers'].join(' ')
execute 'Override DNS settings to use Cloudflare, Google, Quad9' do
  command "networksetup -setdnsservers #{network_interface} #{dns_servers} && dscacheutil -flushcache"
  not_if "networksetup -getdnsservers #{network_interface} | xargs | grep -q '#{dns_servers}'"
end

#
# Spotlight
#

spotlight '/' do
  indexed false
  searchable false
end

#
# Stop all automatic update installation but critical ones
#

automatic_software_updates "enables automatic check, download, and install of software updates" do
  check true
  download true
  install_os false
  install_app_store false
  install_critical true
end
