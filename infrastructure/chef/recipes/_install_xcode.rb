xcode_versions = node['buildpipeline_agent']['xcode_versions']

xcode_versions.each do | version |
  log "Downloading XCode #{version}"
  aws_s3_file "/tmp/Xcode_#{version}.xip" do
    bucket 'control-center-artifacts'
    remote_path "xcode/Xcode_#{version}.xip"
    aws_access_key data_bag_item('buildpipeline-agent', 'secrets')['aws_access_key_id']
    aws_secret_access_key data_bag_item('buildpipeline-agent', 'secrets')['aws_secret_access_key']
    region 'us-east-1'
    owner machine_user
    group machine_group
    not_if {
      # Don't download .xip in the following cases
      # IF file is already downloaded
      # OR extracted in /Applications folder
      ::Dir.exists?("/tmp/Xcode_#{version}.xip") ||
      ::Dir.exists?("/Applications/Xcode-#{version}.app")
    }
    notifies :run, "execute[Extract XCode #{version}]", :immediate
  end

  execute "Extract XCode #{version}" do
    command "xip --expand /tmp/Xcode_#{version}.xip"
    # Don't extract if is already extracted
    not_if { ::Dir.exists?("/Applications/Xcode-#{version}.app") }
    action :nothing
  end
end
