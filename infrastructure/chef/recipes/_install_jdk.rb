
# Set OpenJDK url based on target OSX arch
openjdk_version = '21.0.4'

# Intel 
# openjdk_source_url = "https://cdn.azul.com/zulu/bin/zulu11.56.19-ca-jdk#{openjdk_version}-macosx_x64.dmg"
if arm64?
  openjdk_source_url = "https://cdn.azul.com/zulu/bin/zulu21.36.17-ca-jdk#{openjdk_version}-macosx_aarch64.dmg"

  dmg_package "Install OpenJDK #{openjdk_version}" do
    accept_eula true
    source openjdk_source_url
    owner machine_user
    type 'pkg'
    # Guard to prevent reinstallation if correct JDK version is already installed
    not_if do
      installed_version = Mixlib::ShellOut.new("java --version | grep openjdk | awk '{print $2}'").run_command.stdout.strip
      installed_version.start_with?(openjdk_version)
    end
  end
end
