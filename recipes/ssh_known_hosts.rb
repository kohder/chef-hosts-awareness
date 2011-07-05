#
# Cookbook Name:: hosts-awareness
# Recipe:: ssh_known_hosts
#
# Copyright 2011, Rob Lewis <rob@kohder.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

sleep 2
nodes = []
search(:node, "*:*") do |z|
  # Prior to first chef-client run, the current node may not have attributes from search
  if z.name == node.name
    z["hostname"] = node["hostname"]
    z["ipaddress"] = node["ipaddress"]
    z["keys"] = node["keys"]
  end

  # Skip the node if it doesn't have one or more of these attributes
  if z["hostname"].nil? || z["ipaddress"].nil? || z["keys"].nil?
    Chef::Log.warn("Could not find one or more of these attributes on node #{z.name}: hostname, ipaddress, keys. Skipping node.")
  else
    nodes << z
  end
end

known_hosts_file = node['hosts_aware']['ssh_known_hosts']['all_users'] ? "/etc/ssh/ssh_known_hosts" : "#{ENV['HOME']}/.ssh/known_hosts"

file known_hosts_file do
  mode 0644
  owner node['hosts_aware']['ssh_known_hosts']['file_owner']
  group node['hosts_aware']['ssh_known_hosts']['file_group']
  backup false
end

# ToDo: Customize the start/end tokens to scope by something like organization name:
#   Chef::Config['chef_server_url'] = "https://api.opscode.com/organizations/gf-dev"

ruby_block 'write_ssh_known_hosts' do
  block do
    HostsAwareness::SshKnownHosts.new(known_hosts_file).set_hosts(nodes)
  end
end
