#
# Cookbook Name:: hosts-awareness
# Library:: EtcHosts
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

module HostsAwareness
  class EtcHosts
    attr_reader :etc_hosts_file
    attr_writer :block_token
    attr_accessor :use_private_addresses

    def initialize(etc_hosts_file)
      @etc_hosts_file = etc_hosts_file
      @use_private_addresses = false
    end

    def block_token
      @block_token || 'chef nodes'
    end

    def set_hosts(hosts, alias_mappings=nil)
      write_out!(hosts, alias_mappings)
    end

    def empty!
      write_out!([])
    end

    protected

    def host_entry(host, alias_mappings)
      aliases = []
      aliases << (host.has_short_hostname? ? host.short_hostname : '')
      aliases << host.provider_public_hostname
      aliases << host.provider_private_hostname
      aliases.concat(alias_mappings[host.hostname]) unless alias_mappings.nil? || alias_mappings[host.hostname].nil?

      if use_private_addresses
        [host.private_ipv4, host.hostname] + aliases
      else
        [host.public_ipv4, host.hostname] + aliases
      end
    end

    def format_host_entries(hosts, alias_mappings)
      host_entries = hosts.sort{|a,b| a.hostname <=> b.hostname}.collect{|host| host_entry(host, alias_mappings)}
      column_widths = []
      host_entries.each do |row|
        row.each_with_index do |cell, i|
          len = cell.to_s.length
          column_widths[i] = len if column_widths[i].nil? || len > column_widths[i]
        end
      end
      host_entries.map do |row|
        row.each_with_index.inject('') do |s, (cell, i)|
          s << cell.to_s.ljust(column_widths[i]+2)
          s
        end.rstrip
      end.join("\n")
    end

    def write_out!(hosts, alias_mappings=nil)
      host_entries_string = format_host_entries(hosts, alias_mappings)
      File.open(@etc_hosts_file, 'r+') do |f|
        out, over, seen_tokens = '', false, false
        f.each do |line|
          if line =~ /^#{start_token}/
            over = seen_tokens = true
            out << line << host_entries_string << "\n"
          elsif line =~ /^#{end_token}/
            over = false
          end
          out << line unless over
        end
        unless seen_tokens
          out << surround_with_tokens(host_entries_string)
        end

        f.pos = 0
        f.print out
        f.truncate(f.pos)
      end
    end

    def surround_with_tokens(str)
      "\n#{start_token}\n" + str + "\n#{end_token}\n"
    end

    def start_token()
      "## #{block_token} start"
    end

    def end_token()
      "## #{block_token} end"
    end
  end
end
