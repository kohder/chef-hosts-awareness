name             'hosts-awareness'
maintainer       'Rob Lewis'
maintainer_email 'rob@kohder.com'
license          'Apache 2.0'
description      'Installs/Configures hosts-awareness'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          '0.0.4'

recipe 'hosts-awareness',                  'Includes all recipes'
recipe 'hosts-awareness::etc_hosts',       'Updates /etc/hosts with node entries.'
recipe 'hosts-awareness::ssh_known_hosts', 'Updates ssh/known_hosts with node entries.'

attribute 'hosts-awareness/ssh_known_hosts/file_owner',
  :display_name => 'Owner of the resulting known_hosts file.',
  :default => 'nil'

attribute 'hosts-awareness/ssh_known_hosts/file_group',
  :display_name => 'Group of the resulting known_hosts file.',
  :default => 'nil'

attribute 'hosts-awareness/ssh_known_hosts/all_users',
  :display_name => 'Should be applied to all users or only current user?',
  :description => 'Setup for all users (/etc/ssh/ssh_known_hosts) or just the current user (~/.ssh/known_hosts).',
  :default => 'false'
