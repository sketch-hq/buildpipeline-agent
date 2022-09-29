xcode_selected_version = node['buildpipeline_agent']['xcode_selected_version']

execute "Select Xcode #{xcode_selected_version}" do
  command "sudo xcode-select -s /Applications/Xcode-#{xcode_selected_version}.app"
  only_if { ::Dir.exists?("/Applications/Xcode-#{xcode_selected_version}.app") }
end
