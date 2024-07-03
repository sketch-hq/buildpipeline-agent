
# Set LoginGraceTime to 0 (value inside the template)
# as part of a mitigation fix for CVE-2024-6387
# (we can remove it once Apple fixes the issue)
# The generated file is auto imported inside /etc/ssh/sshd_config
template '/etc/ssh/sshd_config.d/custom-fix-macos.conf' do
  source 'sshd/custom.conf.erb'
end

launchd 'ssh' do
  subscribes :reload, 'template[/etc/ssh/sshd_config.d/custom-fix-macos.conf]', :immediately
end
