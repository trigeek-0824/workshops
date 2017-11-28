########################
#
# Cookbook:: mongodb_xplat
# Recipe:: install-mongoddb-debian
#
# Install on debian distribution platforms
#
# Verfied on: Ubuntu 16.04 only
########################

#####
# Step0. If the node is 32bit that is no longer supported in the current MongoDB 3.4 releases
#        I am sure there is an easy way to filter for this that I am missing...
#####
if node['kernel']['machine'] == 'i386'
	warn "Architecture is #{node['kernel']['machine']} on #{node['ipaddress']}. Mongo stopped support."
        return
end

log "Platform Version #{node['platform_version']}"

######
# Step0b.
# Setup the various apt values that are different between each release for MongoDB
######
case node['platform']
when 'debian'
	warn 'Not yet setup for correct values of wheezy vs. Jessie'
	return
when 'ubuntu'
	case node['platform_version']
	when '12.04'
		node.default['apt_distribution_val'] = 'precise/mongodb-org/3.4'
		node.default['apt_arch_val'] = 'amd64'
	when '14.04'
		node.default['apt_distribution_val'] = 'trusty/mongodb-org/3.4'
		node.default['apt_arch_val'] = 'amd64'
	when '16.04'
		node.default['apt_distribution_val'] = 'xenial/mongodb-org/3.4'
		node.default['apt_arch_val'] = 'amd64,arm64'
	else
		warn "Unsupported Ubuntu Platform Version #{node['platform_version']}"
		return
	end
else
	warn "Incorrect platform type for this cookbook #{node['platform']} only debian and ubuntu supported."
	return
end

#####
# Step1.  Update Apt-Get for Mongo
#####
apt_repository "mongodb" do
	uri "http://repo.mongodb.org/apt/ubuntu"
	distribution "#{node['apt_distribution_val']}"
	components ['multiverse']
	arch "#{node['apt_arch_val']}"
	keyserver "hkp://keyserver.ubuntu.com:80"
	key "0C49F3730359A14518585931BC711F9BA15703C6"
	cache_rebuild true
end

#####
## Step2. Install the mongo package via apt-get.
#####
package "mongodb-org" do
	action :install
end

#####
## Step3. Ensure it always comes up at restart.
#####
service "mongod" do
	action [ :enable, :start ]
end
