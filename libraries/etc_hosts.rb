#
# Cookbook Name:: hosts-awareness
# Library:: EtcHosts
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

    def set_hosts(hosts)
      write_out!(hosts)
    end

    def empty!
      write_out!([])
    end

    protected

    def host_entry(host)
      if use_private_addresses
        [host.private_ipv4, host.hostname, host.short_hostname, host.provider_public_hostname, host.provider_private_hostname]
      else
        [host.public_ipv4, host.hostname, host.short_hostname, host.provider_public_hostname, host.provider_private_hostname]
      end
    end

    def format_host_entries(hosts)
      host_entries = hosts.sort{|a,b| a.hostname <=> b.hostname}.collect{|host| host_entry(host)}
      a = host_entries.transpose
      a = a.map do |col|
        w = col.map{|cell| cell.to_s.length}.max
        col.map{|cell| cell.to_s.ljust(w)}
      end
      a.transpose.inject(''){|s, row| s << row.join('  ').rstrip + "\n"; s}
    end

    def write_out!(hosts)
      host_entries_string = format_host_entries(hosts)
      File.open(@etc_hosts_file, 'r+') do |f|
        out, over, seen_tokens = '', false, false
        f.each do |line|
          if line =~ /^#{start_token}/
            over = seen_tokens = true
            out << line << host_entries_string
          elsif line =~ /^#{end_token}/
            over = false
          end
          out << line unless over
        end
        if !seen_tokens
          out << surround_with_tokens(host_entries_string)
        end

        f.pos = 0
        f.print out
        f.truncate(f.pos)
      end
    end

    def surround_with_tokens(str)
      "\n#{start_token}\n" + str + "#{end_token}\n"
    end

    def start_token()
      "## #{block_token} start"
    end

    def end_token()
      "## #{block_token} end"
    end
  end
end
