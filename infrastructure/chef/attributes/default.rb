# These attributes need to be passed when bootstrapping the machine
default['buildpipeline_agent']['machine_number'] = 0
default['buildpipeline_agent']['env'] = 'unknown' # [test, development, staging, production]
default['buildpipeline_agent']['token'] = 'unknown'

# General system config
default['buildpipeline_agent']['machine_user'] = 'administrator' # Assumed to exist already, override if necessary
default['buildpipeline_agent']['machine_group'] = 'admin'        # Assumed to exist already, override if necessary
default['buildpipeline_agent']['network_interface'] = 'Ethernet'
default['buildpipeline_agent']['dns_servers'] = ['1.1.1.1', '8.8.8.8', '9.9.9.9']
default['buildpipeline_agent']['ssh_port'] = '23754'
default['buildpipeline_agent']['ssh_plist'] = '/System/Library/LaunchDaemons/ssh.plist'

# Agent application config
default['buildpipeline_agent']['autostart'] = false
default['buildpipeline_agent']['num_processes'] = node['cpu']['total']
default['buildpipeline_agent']['config_dir'] = '/usr/local/etc/.buildpipeline'
default['buildpipeline_agent']['config_file'] = '/usr/local/etc/.buildpipeline/config.yml'
default['buildpipeline_agent']['token_file'] = "#{default['buildpipeline_agent']['config_dir']}/token"
default['buildpipeline_agent']['log_folder_path'] = '/usr/local/var/log'

# Xcode installed and selected version(s)s
default['buildpipeline_agent']['xcode_versions'] = ['13.4.1']
default['buildpipeline_agent']['xcode_selected_version'] = '13.4.1'
