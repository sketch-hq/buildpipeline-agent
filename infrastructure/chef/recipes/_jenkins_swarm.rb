jenkins_swarm_path = File.expand_path('/Users/jenkins')

if node['buildpipeline_agent'] && node['buildpipeline_agent']['disable_swarm'] == "true"
  # Unload and disable the Jenkins Swarm service if it's currently loaded
  execute 'unload jenkins swarm agent' do
    command "launchctl unload #{jenkins_swarm_path}/Library/LaunchAgents/com.jenkins.swarm.plist"
    only_if 'launchctl list | grep com.jenkins.swarm'
    action :run
  end
else
  # Variables to fill the service template
  jenkins_master_url = 'https://jenkins.cc.sketchsrv.com'
  jenkins_user = secrets['jenkins_swarm_master_user']
  jenkins_password = secrets['jenkins_swarm_master_password']
  fsroot_workspace_path = '/Users/jenkins/jm-sketchsrv-com'
  executor_number = 1

  # Jenkins swarm version, used to download the proper version of the .jar
  jenkins_swarm_version = '3.47'

  # Agent labels
  static_labels = 'office'
  node_specific_labels = node['buildpipeline_agent']['additional_labels'] || ''
  all_labels = [static_labels, node_specific_labels].reject(&:empty?).join(' ')

  remote_file "#{jenkins_swarm_path}/swarm-client.jar" do
    source "https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/#{jenkins_swarm_version}/swarm-client-#{jenkins_swarm_version}.jar"
    mode '0755'
    owner machine_user
    group machine_group
    action :create
  end

  file "#{jenkins_swarm_path}/jenkins-swarm.labels" do
    content all_labels
    mode '00644'
    owner machine_user
    group machine_group
    action :create
  end

  directory "#{jenkins_swarm_path}/Library/LaunchAgents" do
    owner 'jenkins'
    group 'staff'
    mode '0755'
    action :create
    recursive true
  end

  template "#{jenkins_swarm_path}/Library/LaunchAgents/com.jenkins.swarm.plist" do
    source 'jenkins-swarm/com.jenkins.swarm.plist.erb'
    mode '0644'
    owner 'jenkins'
    group 'staff'
    notifies :run, 'execute[reload jenkins swarm agent]', :immediately
    variables(
      swarm_files_path: jenkins_swarm_path,
      jenkins_master_url: jenkins_master_url,
      jenkins_user: jenkins_user,
      jenkins_password: jenkins_password,
      fsroot: fsroot_workspace_path,
      executors: executor_number
    )
  end

  execute 'load jenkins swarm agent' do
    command "launchctl load #{jenkins_swarm_path}/Library/LaunchAgents/com.jenkins.swarm.plist"
    action :run
    not_if 'launchctl list | grep com.jenkins.swarm'
  end

  execute 'reload jenkins swarm agent' do
    command <<-EOH
      launchctl unload #{jenkins_swarm_path}/Library/LaunchAgents/com.jenkins.swarm.plist || true
      launchctl load #{jenkins_swarm_path}/Library/LaunchAgents/com.jenkins.swarm.plist
    EOH
    action :nothing
  end
end
