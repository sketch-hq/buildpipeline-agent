
jenkins_swarm_path = File.expand_path('/Users/jenkins/Desktop')

# Variables to fill the service template
jenkins_master_url = 'http://34.244.238.42:8080' # Change when we use the final domain
jenkins_user = secrets['jenkins_swarm_master_user']
jenkins_password = secrets['jenkins_swarm_master_password']
fsroot_workspace_path = '/Users/jenkins/jm-sketchsrv-com/workspace'
executor_number = 2 # At some point we may need to set this per-machine so we can have more granular configuration

# Jenkins swarm version, used to download the proper version of the .jar
jenkins_swarm_version = '3.27'

# Agent labels
static_labels = 'office'

# node-specific labels
node_specific_labels = node['buildpipeline_agent']['additional_labels'] || ''

# All labels concatenated
all_labels = [static_labels, node_specific_labels].reject(&:empty?).join(',')

remote_file "#{jenkins_swarm_path}/swarm-client.jar" do
  source "https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/#{jenkins_swarm_version}/swarm-client-#{jenkins_swarm_version}.jar"
  mode '0755'
  owner 'jenkins'
  group 'staff'
  action :create
end

# Create the labels file (this file will be included in the jenkins swarm agent launch command)
file "#{jenkins_swarm_path}/jenkins-swarm.labels" do
  content all_labels
  mode '00644'
  owner 'jenkins'
  group 'staff'
  action :create
end

# We assume /Library/LaunchDaemons exists, we may need to check it later
template '/Library/LaunchDaemons/com.jenkins.swarm.plist' do
  source 'jenkins-swarm/com.jenkins.swarm.plist.erb'
  mode '0644'
  owner 'root'
  group 'wheel'
  variables(
    swarm_files_path: jenkins_swarm_path,
    jenkins_master_url: jenkins_master_url,
    jenkins_user: jenkins_user,
    jenkins_password: jenkins_password,
    fsroot: fsroot_workspace_path,
    executors: executor_number
  )
end

# Run the launchd service
execute 'load jenkins swarm agent' do
  command 'launchctl load /Library/LaunchDaemons/com.jenkins.swarm.plist'
  action :run
  not_if 'launchctl list | grep com.jenkins.swarm'
end
