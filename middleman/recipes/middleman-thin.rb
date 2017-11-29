#
# Cookbook:: middleman
# Recipe:: middleman-thin
#
# Copyright:: 2017, The Authors, All Rights Reserved.

###
# Setup thin service
####
#
# Two vars used in the template files
node.default['project_home_dir'] = '/home/middleman'
node.default['project_install_directory'] = '/home/middleman/middleman-blog'

bash 'setup_thin' do
        cwd '/home/middleman/middleman-blog'
        code <<-EOH
                thin install
                /usr/sbin/update-rc.d -f thin defaults
	        EOH
end

template '/etc/thin/blog.yml' do
	source 'thin.blog.yml.erb'
	owner  'root'
	group  'root'
	mode   '0644'
end

template '/etc/init.d/thin' do
	source 'thin.initd.erb'
	owner  'root'
	group  'root'
	mode   '0755'
end

service 'thin' do
	action :restart
end
