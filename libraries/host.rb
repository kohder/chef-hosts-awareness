#
# Cookbook Name:: hosts-awareness
# Library:: Host
#
# Copyright 2021, Rob Lewis <rob@kohder.com>
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

module HostsAwareness
  class Host
    attr_reader :network
    attr_accessor :hostname
    attr_accessor :private_ipv4
    attr_accessor :public_ipv4
    attr_accessor :provider_private_hostname
    attr_accessor :provider_public_hostname

    def self.from_node(node, network=nil)
      host = new(network)
      host.hostname = node['fqdn'] || "#{node['hostname']}.#{node['domain']}"
      if node['cloud'] && node['cloud']['local_ipv4']
        host.private_ipv4 = node['cloud']['local_ipv4']
      elsif node['ec2'] && node['ec2']['local_ipv4']
        host.private_ipv4 = node['ec2']['local_ipv4']
      else
        host.private_ipv4 = node['ipaddress']
      end

      if node['cloud'] && node['cloud']['public_ipv4']
        host.public_ipv4 = node['cloud']['public_ipv4']
      elsif node['ec2'] && node['ec2']['public_ipv4']
        host.public_ipv4 = node['ec2']['public_ipv4']
      end

      if node['cloud'] && node['cloud']['local_hostname']
        host.provider_private_hostname = node['cloud']['local_hostname']
      elsif node['ec2'] && node['ec2']['local_hostname']
        host.provider_private_hostname = node['ec2']['local_hostname']
      end

      if node['cloud'] && node['cloud']['public_hostname']
        host.provider_public_hostname = node['cloud']['public_hostname']
      elsif node['ec2'] && node['ec2']['public_hostname']
        host.provider_public_hostname = node['ec2']['public_hostname']
      end
      host
    end

    def initialize(network=nil)
      @network = network
    end

    def short_hostname
      @short_hostname ||= begin
        if @network && @network.short_hostname_parts && @network.short_hostname_parts > 0
          @hostname.split('.').shift(@network.short_hostname_parts).join('.')
        else
          @hostname.split('.').first
        end
      end
    end

    def has_short_hostname?
      !hostname.eql?(short_hostname)
    end

    def domain_name
      @domain_name ||= @hostname.partition('.').last
    end

    def ==(other)
      other.equal?(self) || (other.instance_of?(self.class) && other.hostname == @hostname)
    end

    def eql?(other)
      self == (other)
    end
  end
end
