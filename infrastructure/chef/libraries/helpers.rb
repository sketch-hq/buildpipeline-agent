require 'zlib'

def secrets
  data_bag_item('buildpipeline-agent', node['buildpipeline_agent']['env'])
end

def machine_user
  node['buildpipeline_agent']['machine_user']
end

def machine_group
  node['buildpipeline_agent']['machine_group']
end

def home
  "/Users/#{machine_user}"
end

def arm64?
  node['kernel']['version'].include?('ARM64')
end

def homebrew_prefix
  arm64? ? '/opt/homebrew' : '/usr/local'
end

def command_prefix
  arm64? ? 'arch -arm64e ' : ''
end

# Produces a consistent int value between min and max (inclusive) for the value provided
def hash_within_range(value, min, max)
  modulus = 1 + (max - min)
  min + (Zlib::crc32(value.to_s) % modulus)
end

# Returns a zero padded string for the provided integer
def zero_pad(int)
  "%02d" % int
end

# Derive the logstash_host from the app env unless it's explicitly set
def logstash_host
  return node['buildpipeline_agent']['logstash_host'] if node.exist?('buildpipeline_agent', 'logstash_host')

  node['buildpipeline_agent']['env'] == 'production' ? 'logstash.prod.sketchsrv.com:5044' : 'logstash.non-prod.sketchsrv.com:5044'
end
