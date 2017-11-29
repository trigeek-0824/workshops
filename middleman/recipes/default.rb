#
# Cookbook:: middleman
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
include_recipe "poise-ruby"

###
# Install base packages
#
# Note: While not mentioned in the instructions 'build-essential' is required
#       as some of the gems require C++ compilation
#
###
package [ 'openssl', 'curl', 'git-core', 'zlib1g-dev', 'bison' ]
package [ 'libxml2-dev', 'libxslt1-dev', 'libcurl4-openssl-dev' ]
package [ 'nodejs', 'libsqlite3-dev', 'sqlite3', 'build-essential' ]

###
# Install Ruby Runtime
#
# Note:  Using a 'supermarket' cookbook per other 'optional' exercise.
# Note2: The instructions are to install Ruby2.1 but that is EOL/EOS
#        I am going to use 2.3 instead
#        However, this requires updating some of the gems in the app itself
#              specifically eventmachine needs to be at least 1.0.4
#                           json needs to be 1.8.3
#        As defined the app will not work with Ruby 2.2+
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
###
# Configure Middleman
#   -install Bundler
#   -create a new user (middleman)
#   -clone the repo https://github.com/learnchef/middleman-blog.git
#   -modify Gemfile.lock for Ruby 2.3 compatibility 
#   -bundle install 
###
gem_package "bundler"

user 'middleman' do
	comment 'User to specifically run middleman app'
	home '/home/middleman'
	shell '/bin/bash'
	manage_home true
	group 'sudo'    # Should grant sudo which seems to be necessary for bundle-install
	                # Not exactly the best solution.
end

git '/home/middleman/middleman-blog' do
	repository 'https://github.com/learnchef/middleman-blog.git'
	user 'middleman'
	action :sync
end

cookbook_file '/home/middleman/middleman-blog/Gemfile.lock' do
	source 'middleman-gemfilelock'
	owner 'middleman'
end

execute "bundle-install" do
  	user "middleman"
	cwd "/home/middleman/middleman-blog/"
	command "bundle install"
        action :run
end

####
# Setup thin service
####

