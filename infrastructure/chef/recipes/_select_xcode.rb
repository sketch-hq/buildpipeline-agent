xcode_selected_version = node['buildpipeline_agent']['xcode_selected_version']

execute "Select Xcode #{xcode_selected_version}" do
  command "sudo xcode-select -s /Applications/Xcode-#{xcode_selected_version}.app"
  only_if { ::Dir.exists?("/Applications/Xcode-#{xcode_selected_version}.app") }
end

execute "Symlink bo python binary inside Xcode #{xcode_selected_version}" do
  command "bo symlink /Applications/Xcode-#{xcode_selected_version}.app/Contents/Developer/usr/bin/python3"
  only_if { ::Dir.exists?("/Applications/Xcode-#{xcode_selected_version}.app") }
end

execute "Run first XCode launch" do
  command "sudo xcodebuild -runFirstLaunch"
end
