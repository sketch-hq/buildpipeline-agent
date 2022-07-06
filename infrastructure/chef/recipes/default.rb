# Configure how chef will run on this machine
include_recipe('sketch-buildpipeline-agent::_chef')

# Set the machine host name
include_recipe('sketch-buildpipeline-agent::_hostname')

# Configure the global MacOS system preferences, sudo, remote management and SSH access
include_recipe('sketch-buildpipeline-agent::_system_preferences')

# Ensure we have the xcode command line tools installed and kept up to date
include_recipe('sketch-buildpipeline-agent::_command_line_tools')

# Install homebrew and any required packages/services via it
include_recipe('sketch-buildpipeline-agent::_homebrew')
