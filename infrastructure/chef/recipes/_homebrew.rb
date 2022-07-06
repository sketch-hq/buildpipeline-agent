execute 'install homebrew' do
  command command_prefix + '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  environment lazy { { 'HOME' => ::Dir.home(machine_user), 'USER' => machine_user } }
  user machine_user
  not_if { ::File.exist?("#{homebrew_prefix}/bin/brew") }
end
