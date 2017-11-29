#
# Cookbook:: middleman
# Recipe:: middleman-apache
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#

###
# Install Apache and configure
#    -install
#    -a3enmod for proxy_http and rewrite
#    -put blog.conf at /etc/apache2/sites-enabled/blog.conf
#    -remove /etc/apache2/sites-enabled/000-default.conf
#    -restart apache
#
####
package 'apache2'

execute "a2enmod proxy_http" do
        command "/usr/sbin/a2enmod proxy_http"
end

execute "a2enmod rewrite" do
        command "/usr/sbin/a2enmod rewrite"
end

template '/etc/apache2/sites-enabled/blog.conf' do
        source 'middleman-blog.conf.erb'
	owner  'root'
	group  'root'
	mode   '0644'
end

file '/etc/apache2/sites-enabled/000-default.conf' do
	action :delete
end

service 'apache2' do
	action [:enable, :start, :restart]
end
