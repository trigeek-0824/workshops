#
# Cookbook:: middleman
# Recipe:: middleman-ruby
#
# Copyright:: 2017, The Authors, All Rights Reserved.

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
####
ruby_runtime 'middleman' do
        version '2.3'
        options dev_package: false
end


###
# Copy files if installed in /usr/local/bin to /usr/bin
#       /usr/local/bin/ruby
#       /usr/local/bin/gem
#
# Note: Implemented a custom resource to only copy if
#       not already present.  Mostly as a learning exercise
####
middleman_cp '/usr/bin/ruby' do
        source "/usr/local/bin/ruby"
        target "/usr/bin/ruby"
        mode "0755"
end

middleman_cp '/usr/bin/gem' do
        source "/usr/local/bin/gem"
        target "/usr/bin/gem"
        mode "0755"
end
