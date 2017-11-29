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
package [ 'nodejs', 'libsqlite3-dev', 'sqlite3' ]
package [ 'build-essential' ]  # This seems to be required even though not specified

# Installs ruby 2.3
include_recipe 'middleman::middleman-ruby'

# Installs and configures apache
include_recipe 'middleman::middleman-apache'

# Gets and Installs middleman
include_recipe 'middleman::middleman-configure'

# Installs and configures thin
include_recipe 'middleman::middleman-thin'

