#
# Cookbook:: middleman
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
include_recipe "poise-ruby"

###
# Install base packages
#
###
package [ 'openssl', 'curl', 'git-core', 'zlib1g-dev', 'bison' ]
package [ 'libxml2-dev', 'libxslt1-dev', 'libcurl4-openssl-dev' ]
package [ 'nodejs', 'libsqlite3-dev', 'sqlite3' ]

###
# Install Ruby Runtime
#
# Note: Trying out a 'supermarket' cookbook per other 'optional' exercise.
#       Not 100% clear if this is the correct way to do that
###
ruby_runtime 'middleman' do
	version '2.3'
	options dev_package: false
end

###
# Copy files if installed in /usr/local/bin to /usr/bin
# 	/usr/local/bin/ruby
# 	/usr/local/bin/gem
#
# TODO: Probably a better way to do this. 
#       The checking I am using here is not great as it just
#           checks that the file is in /usr/local/bin and not in /usr/bin
#             does not guarantee it is desired files
# TODO: Make this something I can call instead of have here twice
###
file "/usr/bin/ruby" do
	not_if { ::File.exists?('/usr/bin/ruby')}
	only_if { ::File.exist?('/usr/local/bin/ruby') }
	owner 'root'
	group 'root'
	mode 0755
	content lazy { IO.read("/usr/local/bin/ruby") }
	action :create
end

file "/usr/bin/gem" do
	not_if { ::File.exists?('/usr/bin/gem')}
	only_if { ::File.exist?('/usr/local/bin/gem') }
	owner 'root'
	group 'root'
	mode 0755
	content lazy { IO.read("/usr/local/bin/gem") }
	action :create
end


###
# Install Apache and configure 
#    -install
#    -a3enmod for proxy_http and rewrite
#    -put blog.conf at /etc/apache2/sites-enabled/blog.conf
#    -remove /etc/apache2/sites-enabled/000-default.conf
#    -restart apache
#
#    TODO: make this a recipe of its own 
###
package 'apache2'

execute "a2enmod proxy_http" do       
	command "/usr/sbin/a2enmod proxy_http"
end

execute "a2enmod rewrite" do       
	command "/usr/sbin/a2enmod rewrite"
end

cookbook_file '/etc/apache2/sites-enabled/blog.conf' do
	source 'middleman-blog.conf'
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





