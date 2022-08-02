directory '/etc/sudoers.d' do
  mode '00755'
  owner 'root'
  group 'wheel'
end

file "/etc/sudoers.d/#{machine_user}" do
  content "#{machine_user} ALL=(ALL) NOPASSWD: ALL"
  mode '00644'
  user 'root'
  group 'wheel'
end
