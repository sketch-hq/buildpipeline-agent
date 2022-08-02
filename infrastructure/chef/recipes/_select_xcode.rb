xcode_selected_version = node['buildpipeline_agent']['xcode_selected_version']

execute "Select Xcode #{xcode_selected_version}" do
  command "sudo xcode-select -p /Applications/Xcode-#{xcode_selected_version}"
  only_if { ::Dir.exists?("/Applications/Xcode-#{xcode_selected_version}.app") }
end
