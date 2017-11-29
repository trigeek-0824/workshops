
########################
#
#  Basic Custom Resource to copy a file from source to target
#        only if the target is not already present
#
#  Note: More for experimentation that anything else
#
########################
property :source, String, default: ''
property :target, String, default: ''
property :owner, String, default: 'root'
property :group, String, default: 'root'
property :mode, String, default: '0644'

action :copy do
	file new_resource.target do
		not_if { new_resource.target=='' || new_resource.source=='' }  # Should actually error here...
		not_if { ::File.exists?(new_resource.target)}
		only_if { ::File.exist?(new_resource.source) }
		owner new_resource.owner
		group new_resource.group
		mode new_resource.mode
		content lazy { IO.read(new_resource.source) }
	        action :create
	end
end
