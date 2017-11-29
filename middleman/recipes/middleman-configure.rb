#
# Cookbook:: middleman
# Recipe:: middleman-configure
#
# Copyright:: 2017, The Authors, All Rights Reserved.

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
        shell '/usr/sbin/nologin'
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
