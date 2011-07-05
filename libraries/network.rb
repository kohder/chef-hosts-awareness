#
# Cookbook Name:: hosts-awareness
# Library:: Network
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

require 'chef/mixin/language'
include Chef::Mixin::Language

module HostsAwareness
  class Network
    attr_reader :name
    attr_accessor :provider
    attr_accessor :node_search_query
    attr_accessor :short_hostname_parts

    def self.from_data_bag(network_name)
      network = HostsAwareness::Network.new(network_name)
      all_network_names = data_bag('networks')
      if all_network_names.include?(network_name)
        network_data_bag_item = data_bag_item('networks', network_name)
        network.provider = network_data_bag_item['provider']
        network.node_search_query = network_data_bag_item['node_search_query']
        network.short_hostname_parts = network_data_bag_item['short_hostname_parts'].to_i
      else
        Chef::Log.error("No data bag entry for network \"#{network_name}\"")
      end
      network
    end

    def initialize(network_name)
      @name = network_name
    end

    def hosts
      @hosts ||= begin
        hosts = nodes.collect{|n| HostsAwareness::Host.from_node(n, self)}
        hosts.uniq
      end
    end

    def nodes
      @nodes ||= @node_search_query.nil? ? [] : search(:node, @node_search_query)
    end

    def member?(node_or_host)
      if node_or_host.is_a?(HostsAwareness::Host)
        hosts.any?{|host| host == node_or_host}
      else
        nodes.any?{|node| node.name == node_or_host.name}
      end
    end

    def ==(other)
      other.equal?(self) || (other.instance_of?(self.class) && other.name == @name)
    end

    def eql?(other)
      self == (other)
    end
  end
end
