#
# 🍻 Install homebrew packages
#

def macos_version
  `sw_vers -productVersion`.strip
end

def macos_version_at_least?(required_version)
  Gem::Version.new(macos_version) >= Gem::Version.new(required_version)
end

homebrew_package('coreutils') { action :upgrade }
homebrew_package('tree') { action :upgrade }
homebrew_package('gawk') { action :upgrade }
homebrew_package('jq') { action :upgrade }

# Upgrade PHP only if macOS version is at least 13.0
if macos_version_at_least?('13.0')
  homebrew_package('php') { action :upgrade }
else
  Chef::Log.warn("Skipping PHP upgrade: macOS version is below 13.0")
end

# Install Fastlane only if macOS version is at least 13.0
if macos_version_at_least?('13.0')
  homebrew_package('fastlane') { version "2.225.0" }
else
  Chef::Log.warn("Skipping Fastlane install: macOS version is below 13.0")
end

# Install xcbeautify only if macOS version is at least 13.0
if macos_version_at_least?('13.0')
  homebrew_package('xcbeautify') { action :upgrade }
else
  Chef::Log.warn("Skipping xcbeautify install: macOS version is below 13.0")
end

# Install check-jsonschema only if macOS version is at least 13.0
if macos_version_at_least?('13.0')
  homebrew_package('check-jsonschema') { action :upgrade }
else
  Chef::Log.warn("Skipping check-jsonschema install: macOS version is below 13.0")
end
