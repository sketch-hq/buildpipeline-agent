
# Set OpenJDK url based on target OSX arch
openjdk_version = '11.0.15'
openjdk_source_url = "https://cdn.azul.com/zulu/bin/zulu11.56.19-ca-jdk#{openjdk_version}-macosx_x64.dmg"
if arm64?
  openjdk_source_url = "https://cdn.azul.com/zulu/bin/zulu11.56.19-ca-jdk#{openjdk_version}-macosx_aarch64.dmg"
end

dmg_package "Install OpenJDK #{openjdk_version}" do
  accept_eula true
  source openjdk_source_url
  owner machine_user
  type 'pkg'
  # Check this guard later in the future
  # Seems that is not properly executed
  # And java is always installed
  not_if { openjdk_version == "java --version |grep openjdk |cut -d' ' -f2" }
end
