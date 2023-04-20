execute 'Install homebrew' do
  command command_prefix + '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  environment lazy { { 'HOME' => ::Dir.home(machine_user), 'USER' => machine_user } }
  user machine_user
  not_if { ::File.exist?("#{homebrew_prefix}/bin/brew") }
end

# Those 2 script must be executed in order to have brew on the path
#(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/jenkins/.zprofile
#eval "$(/opt/homebrew/bin/brew shellenv)"

# This is needed for the homebrew_package resource to work.
# It's used to check for the brew executable owner in order to run as that user
ENV['PATH'] = "#{homebrew_prefix}/bin:#{ENV['PATH']}"
