#
# 🍻 Install homebrew packages
#

homebrew_package('coreutils') { action :upgrade }
homebrew_package('tree') { action :upgrade }
homebrew_package('gawk') { action :upgrade }
homebrew_package('swiftlint') { action :upgrade }
homebrew_package('php') { action :upgrade }
homebrew_package('fastlane') { version "2.208.0" }

