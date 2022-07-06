log 'downloading XCode'
remote_file '/tmp/XCode-${version}.xip' do
  source "S3 bucket url"
  owner machine_user
  group machine_group
  notifies :extract, 'archive_file[/tmp/XCode-${version}.xip]', :immediately
end
