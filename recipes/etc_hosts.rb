#
# Cookbook Name:: hosts-awareness
# Recipe:: etc_hosts
#
# Copyright 2012, Rob Lewis <rob@kohder.com>
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

ruby_block 'update_etc_hosts' do
  block do
    all_host_alias_mappings = data_bag('host_aliases')
    host_alias_mappings = node['hosts_awareness'].nil? ? [] : Array(node['hosts_awareness']['host_aliases'])
    host_alias_mappings = all_host_alias_mappings if host_alias_mappings.first == 'all'
    alias_mappings = HostsAwareness::HostAliases.from_data_bags(host_alias_mappings).alias_mappings
    all_network_names = data_bag('networks')
    networks = node['hosts_awareness'].nil? ? [] : Array(node['hosts_awareness']['networks'])
    networks = all_network_names if networks.first == 'all'
    networks.each do |network_name|
      network = HostsAwareness::Network.from_data_bag(network_name)
      etc_hosts = HostsAwareness::EtcHosts.new('/etc/hosts')
      etc_hosts.block_token = network_name
      etc_hosts.use_private_addresses = network.member?(node)
      etc_hosts.set_hosts(network.hosts, alias_mappings)
    end
  end
end
