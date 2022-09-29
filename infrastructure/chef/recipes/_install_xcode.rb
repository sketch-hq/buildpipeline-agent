xcode_versions = node['buildpipeline_agent']['xcode_versions']

xcode_versions.each do |version|
  log "Downloading XCode #{version}"
  aws_s3_file "/tmp/Xcode_#{version}.xip" do
    bucket 'control-center-artifacts'
    remote_path "xcode/Xcode_#{version}.xip"
    aws_access_key data_bag_item('buildpipeline-agent', 'secrets')['aws_access_key_id']
    aws_secret_access_key data_bag_item('buildpipeline-agent', 'secrets')['aws_secret_access_key']
    region 'us-east-1'
    owner machine_user
    group machine_group
    not_if do
      # Don't download .xip in the following cases
      # IF file is already downloaded
      # OR extracted in /Applications folder
      ::Dir.exist?("/Applications/Xcode-#{version}.app")
    end
    # notifies :run, "execute[Extract XCode #{version}]", :immediately
  end

  execute "Extract XCode #{version}" do
    command "cd /Applications && xip --expand /tmp/Xcode_#{version}.xip && mv Xcode.app Xcode-#{version}.app && rm -rf /tmp/Xcode_#{version}.xip"
    # Don't extract if is already extracted
    not_if { ::Dir.exist?("/Applications/Xcode-#{version}.app") }
    # action :nothing
    subscribes :run, "aws_s3_file[/tmp/Xcode_#{version}.xip]"
  end
end

execute 'Accept XCode licenses' do
  command 'sudo xcodebuild -license accept'
end
