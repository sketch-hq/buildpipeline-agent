name 'sketch-buildpipeline-agent'
maintainer 'Control Center'
maintainer_email 'control-center@sketch.com'
license 'All Rights Reserved'
description 'Installs/Configures a Build Pipeline Agent'
version '0.1.158'
chef_version '>= 16.0'

supports 'mac_os_x'

depends 'chef-client'
depends 'chef_client_updater'
depends 'macos', '~> 4.2.2'
depends 'aws', '~> 9.0.2'
