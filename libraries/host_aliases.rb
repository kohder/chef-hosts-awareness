#
# Cookbook Name:: hosts-awareness
# Library:: HostAliases
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

require 'chef/mixin/language'
include Chef::Mixin::Language

module HostsAwareness
  class HostAliases
    attr_accessor :alias_mappings

    def self.from_data_bags(mapping_names)
      all_host_alias_mappings = data_bag('host_aliases')
      host_aliases = HostsAwareness::HostAliases.new
      mapping_names.each do |mapping_name|
        if all_host_alias_mappings.include?(mapping_name)
          mapping_data_bag_item = data_bag_item('host_aliases', mapping_name)
          alias_mappings = mapping_data_bag_item['alias_mappings']
          unless alias_mappings.nil?
            alias_mappings.each do |hostname, hostname_aliases|
              if host_aliases.alias_mappings[hostname].nil?
                host_aliases.alias_mappings[hostname] = Array(hostname_aliases)
              else
                host_aliases.alias_mappings[hostname].concat(Array(hostname_aliases))
              end
            end
          end
        else
          Chef::Log.error("No data bag entry for host alias mappings \"#{mapping_name}\"")
        end
      end
      host_aliases
    end

    def initialize
      @alias_mappings = {}
    end
  end
end
