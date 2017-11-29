###############################################################
# Cookbook:: tomcat
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Overview of the steps required
#    1. Install JDK
#    2. Create 'tomcat' group
#    3. Create 'tomcat' user
#    4. Download 'tomcat' to /tmp
#    5. Make the Target Dir
#    6. Untar to Target 
#    7. Change Perms on Target
#    8. Install Systemd
###############################################################

#####
# Step1.  Install OpenJDK 7 JDK
#####
package "java-1.7.0-openjdk-devel" do
	action :install
end

#####
# Step2. Create a group for tomcat 'tomcat'
#####
group 'tomcat' do
	action	:create
end

#####
# Step3. Create a user for tomcat in group tomcat name 'tomcat'
#####
user 'tomcat' do
	action :create
	shell '/bin/nologin'
	manage_home false
	gid 'tomcat'
	home '/opt/tomcat'
end

#####
# Step4. Download Tomcat
#        Version as of now: 8.5.23
#####
remote_file '/tmp/apache-tomcat-8.5.23.tar.gz' do
	source 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.tar.gz'
	mode '0644'
	owner 'tomcat'
	group 'tomcat'
	action :create
end

#####
# Step5. Make the target directory
#####
directory '/opt/tomcat' do
	owner 'tomcat'
	group 'tomcat'
	mode '0755'
	action :create
end

#####
# Step6. Untar the binary with strip-components=1
#        Hmm... Looks like I could use ruby or just shell it out
#        Given this is a simple one liner, I think shelling it out is best
#              as the Ruby for this looks significnatly more difficult wit
#              some quesionably up to date libraries.
#        I might be missing something.
#
#        Adding cleanup to remove tar.gz for good measure
#####
execute 'untar_tmp_tomcat_tgz_file' do
	command 'sudo tar xvf /tmp/apache-tomcat-8.5.23.tar.gz -C /opt/tomcat --strip-components=1'
	cwd '/tmp'
end

file '/tmp/apache-tomcat-8.5.23.tar.gz' do
	action :delete
end

#####
# Step7. Chgrp recursively to tomcat for /opt/tomcat
#        Chmod recursive for group +read for conf
#        Chmod group +exec for conf (not recursive)
#        Chown recursive to tomcat for webapp work temp logs
#
#        Note: If there is an easy way to do this properly in Chef diectly, it didn't appear so
#              If I knew the exact ending permissions that would be one thing but it just appears
#              easier to do this in a simple bash block than try and force it.
#####
bash 'change_perms' do
	cwd '/opt/tomcat'
	code <<-EOH
		sudo chgrp -R tomcat /opt/tomcat
		sudo chmod -R g+r /opt/tomcat/conf
		sudo chmod g+x /opt/tomcat/conf
		sudo chown -R tomcat /opt/tomcat/webapps /opt/tomcat/work /opt/tomcat/temp /opt/tomcat/logs
		EOH
end

#####
# Step 8. Install the Systemd Unit File
#
#         My first attempt was:
#		cookbook_file "/etc/systemd/system/tomcat.service" do
#			source "tomcat_systemd_file"
#			mode "0644"
#		end
#         But the systemd_unit service seems to provide not only the file, but also the update notification
#             to systemctl
#####
systemd_unit "tomcat.service" do
	content <<-EOF
	           [Unit]
	           Description=Apache Tomcat Web Application Container
	           After=syslog.target network.target

	           [Service]
	           Type=forking

	           Environment=JAVA_HOME=/usr/lib/jvm/jre
	           Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
	           Environment=CATALINA_HOME=/opt/tomcat
	           Environment=CATALINA_BASE=/opt/tomcat
	           Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
	           Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

	           ExecStart=/opt/tomcat/bin/startup.sh
	           ExecStop=/bin/kill -15 $MAINPID

	           User=tomcat
	           Group=tomcat
	           UMask=0007
	           RestartSec=10
	           Restart=always

	           [Install]
	           WantedBy=multi-user.target
	           EOF
	.gsub(/^ +/, "")

	action [:create, :enable, :start]
end

######
# At this point tomcat is up and running
#
# curl http://localhost:8080
# 
######
