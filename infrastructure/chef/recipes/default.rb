# Configure how chef will run on this machine
include_recipe('sketch-buildpipeline-agent::_chef')

# Set the machine host name
include_recipe('sketch-buildpipeline-agent::_hostname')

# Configure the global MacOS system preferences, sudo, remote management and SSH access
include_recipe('sketch-buildpipeline-agent::_system_preferences')
include_recipe('sketch-buildpipeline-agent::_sudo')

# Ensure we have the xcode command line tools installed and kept up to date
include_recipe('sketch-buildpipeline-agent::_install_command_line_tools')

# Ensure XCode required versions are installed and selected
include_recipe('sketch-buildpipeline-agent::_install_xcode')
include_recipe('sketch-buildpipeline-agent::_select_xcode')

# Install homebrew and any required packages/services via it
# Swiftlint brew package requires a valid xcode installation
# that's why we put it after xcode resource
include_recipe('sketch-buildpipeline-agent::_install_homebrew')
include_recipe('sketch-buildpipeline-agent::_install_homebrew_packages')


# Download & install JAgent repo

# Download & install BCTools repo