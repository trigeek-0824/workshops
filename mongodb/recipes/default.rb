#
# Cookbook:: mongodb
# Recipe:: default
#

# Step0. If the node is 32bit that is no longer supported in the current MongoDB 3.4 releases
#        I am sure there is an easy way to filter for this that I am missing...
if node['kernel']['machine'] == 'i386'
	warn "Architecture is #{node['kernel']['machine']} on #{node['ipaddress']}. Mongo stopped support."
        return
end

# Step1. Enable the Mongo Repo.
#        This requires a repo file at /etc/yum.repos.d/mongodb-org-3.4.repo
#        This file is in files/defaults as mongodb-org-3_4-repo
#        As it is a repo file it only really need to be readable
cookbook_file "/etc/yum.repos.d/mongodb-org-3.4.repo" do
	source "mongodb-org-3_4-repo"
        mode "0644"
end

# Step2. Install the package via yum.
package "mongodb-org" do
	action :install
end

# Step3. Ensure it always comes up at restart.
service "mongod" do
	action [ :enable, :start ]
end
