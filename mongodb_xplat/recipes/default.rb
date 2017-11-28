#######################
# Cookbook:: mongodb_xplat
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
#######################

###################
# Switch on platform type
#
# We will be installing a MongoDB Server
# 
# Here we want to first determint the platform we are dealing with and
#      use the appropriate cookbook for that platform.
###################
case node['platform']
when 'debian', 'ubuntu' 
	include_recipe 'mongodb_xplat::install-mongodb-debian'
when 'redhat', 'centos'
	include_recipe 'mongodb_xplat::install-mongodb-rhel'
when 'windows'
	warn "We are not installing MongodDB on windows in this organization!"
	return
else
	warn "Unknown platform type: #{node['platform']}"
	return
end
