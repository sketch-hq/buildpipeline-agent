APP := buildpipeline-agent
BOOTSTRAP_PATH := infrastructure/chef/bootstrap

# General AWS config
AWS_REGION := us-east-1

# Root Cloud AWS config
ROOT_ZONE_ID := ZKMC5YFWPZ5R8

# Production: prod Cloud AWS config
CLOUD_AWS_ACCOUNT_ID_production := 707624801137
CLOUD_AWS_PROFILE_production := sketch-production
CLOUD_LOGSTASH_SECURITY_GROUP_ID_production := sg-02c832253aa0fb40c

# Env specific Cloud AWS config
CLOUD_AWS_ACCOUNT_ID := $(CLOUD_AWS_ACCOUNT_ID_$(env))
CLOUD_AWS_PROFILE := $(CLOUD_AWS_PROFILE_$(env))
CLOUD_LOGSTASH_SECURITY_GROUP_ID := $(CLOUD_LOGSTASH_SECURITY_GROUP_ID_$(env))


# buildpipeline-agent AWS and SSH config
username ?= administrator
RF_AWS_PROFILE := buildpipeline-agent
ADMIN_PUBLIC_KEY := ~/.ssh/buildpipeline_admin.pub
ADMIN_PRIVATE_KEY := ~/.ssh/buildpipeline_admin

# Functions to generate configuration to pass to the agent on bootstrap
generate_uuid = $(shell uuidgen)
generate_token = $(shell cat /dev/urandom | head -c 1024 | sha1sum | cut -d ' ' -f 1 | tr -d "\n")
generate_dynamo_record = '{"Token":{"S":"$(1)"},"ID":{"S":"$(2)"},"IP":{"S":"$(ip)"},"Name":{"S":"$(NODE_NAME)"},"Hoster":{"S":"MacStadium"},"Enabled":{"BOOL":true}}'

# Agent configuration
NODE_NAME := buildpipeline$(machine_number)
DNS_RECORD := $(NODE_NAME).sketchsrv.com
TOKEN := $(call generate_token)
UUID := $(call generate_uuid)
DYNAMO_RECORD := $(call generate_dynamo_record,$(TOKEN),$(UUID))

bootstrap: port ?= 22
bootstrap:
	@test -n "$(env)" || (echo "💥 env variable must be set to one of: [test, development, staging, production]" && exit 1)

	@echo "#"
	@echo "# 🔑 Copying admin ssh key to agent from $(ADMIN_PUBLIC_KEY)"
	@echo "#"
	@echo "#    On first run this will prompt you for the server password"
	@echo "#"
	@echo
	ssh-copy-id -p $(port) -o "StrictHostKeyChecking=accept-new" -i $(ADMIN_PUBLIC_KEY) $(username)@$(ip)

	@echo "#"
	@echo "# 🤐 Copy the chef databag and validation secrets to the agent"
	@echo "#"
	@echo
	@aws --region $(AWS_REGION) s3 cp --profile $(CLOUD_AWS_PROFILE) s3://$(CLOUD_AWS_ACCOUNT_ID)-sketch-bootstrap/chef/sketch-validator.pem $(BOOTSTRAP_PATH)/secrets/sketch-validator.pem
	@aws --region $(AWS_REGION) s3 cp --profile $(CLOUD_AWS_PROFILE) s3://$(CLOUD_AWS_ACCOUNT_ID)-sketch-bootstrap/chef/encrypted_data_bag_secret $(BOOTSTRAP_PATH)/secrets/encrypted_data_bag_secret
	ssh -p $(port) -t -i $(ADMIN_PRIVATE_KEY) $(username)@$(ip) "mkdir -p /tmp/chef"
	scp -P $(port) -i $(ADMIN_PRIVATE_KEY) -r $(BOOTSTRAP_PATH)/secrets/* $(username)@$(ip):/tmp/chef
	@echo

	@echo "#"
	@echo "# 🌍 Ensure we have some working DNS configuration"
	@echo "#"
	@echo
	ssh -p $(port) -t -i $(ADMIN_PRIVATE_KEY) $(username)@$(ip) "networksetup -setdnsservers Ethernet 1.1.1.1 8.8.8.8 && dscacheutil -flushcache"
	@echo

	@echo "#"
	@echo "# 🌹 Install Rosetta if we're bootstrapping an Apple Silicon machine"
	@echo "#"
	@echo
	ssh -p $(port) -t -i $(ADMIN_PRIVATE_KEY) $(username)@$(ip) "sysctl -n machdep.cpu.brand_string | grep Apple && softwareupdate --install-rosetta --agree-to-license || echo '✅ Not an Apple CPU'"
	@echo

	@echo "#"
	@echo "# 👀 Remove this machine from chef if already present"
	@echo "#"
	@echo
	@knife client show $(NODE_NAME) && knife client delete -y $(NODE_NAME) || echo "✅ $(NODE_NAME) was not already a chef client"
	@knife node show $(NODE_NAME) && knife node delete -y $(NODE_NAME) || echo "✅ $(NODE_NAME) was not already a chef node"

	@echo "#"
	@echo "# 🏃 Copy the node attributes for the first run and client config onto the agent"
	@echo "#"
	@echo
	jq \
	--arg ENVIRONMENT $(env) \
	--arg MACHINE_NUMBER $(machine_number) \
	--arg MACHINE_USER $(username) \
	--arg TOKEN $(TOKEN) \
	'.buildpipeline_agent.env = $$ENVIRONMENT | .buildpipeline_agent.machine_number = $$MACHINE_NUMBER | .buildpipeline_agent.machine_user = $$MACHINE_USER | .buildpipeline_agent.token = $$TOKEN' \
	$(BOOTSTRAP_PATH)/first_run.default.json > $(BOOTSTRAP_PATH)/first_run.$(NODE_NAME).json

	scp -P $(port) -i $(ADMIN_PRIVATE_KEY) $(BOOTSTRAP_PATH)/client.rb $(username)@$(ip):/tmp/chef/client.rb
	scp -P $(port) -i $(ADMIN_PRIVATE_KEY) $(BOOTSTRAP_PATH)/first_run.$(NODE_NAME).json $(username)@$(ip):/tmp/chef/first_run.json
	@echo

	@echo "#"
	@echo "# 🍲 Install chef on the agent then run it for the first time"
	@echo "#"
	@echo "#    You will prompted for the server password as this requires sudo"
	@echo "#"
	@echo
	scp -P $(port) -i $(ADMIN_PRIVATE_KEY) -r $(BOOTSTRAP_PATH)/install.sh $(username)@$(ip):/tmp/install.sh
	ssh -p $(port) -t -i $(ADMIN_PRIVATE_KEY) $(username)@$(ip) "chmod +x /tmp/install.sh && sudo bash -c '/tmp/install.sh && \
	/usr/local/bin/chef-client \
	--environment buildpipeline-agent \
	--node-name $(NODE_NAME) \
	--runlist role[buildpipeline-agent] \
	--json-attributes /etc/chef/first_run.json'"

	#@echo "#"
	#@echo "# 🌐 Adding the $(DNS_RECORD) DNS record to Route53"
	#aws --region $(AWS_REGION) route53 change-resource-record-sets --hosted-zone-id $(ROOT_ZONE_ID) --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"$(DNS_RECORD)","Type":"A","TTL":300,"ResourceRecords":[{"Value":"$(ip)"}]}}]}'
	#@echo "#"
	#@echo
	#@echo

	#@echo "#"
	#@echo "# 🌐 Adding IP to Logstash security groups"
	#@echo "#"
	#@echo
	#@test "$(logstash)" != 'false' && aws --region $(AWS_REGION) --profile $(CLOUD_AWS_PROFILE) ec2 authorize-security-group-ingress --group-id $(CLOUD_LOGSTASH_SECURITY_GROUP_ID) --ip-permissions IpProtocol=tcp,FromPort=5044,ToPort=5044,IpRanges='[{CidrIp=$(ip)/32,Description="$(NODE_NAME)"}]' || echo "⛔️ Not configuring Logstash as requested"
	#@echo
