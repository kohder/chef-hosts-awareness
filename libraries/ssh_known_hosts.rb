#
# Cookbook Name:: hosts-awareness
# Library:: SshKnownHosts
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
  class SshKnownHosts
    attr_reader :known_hosts_file
    attr_accessor :start_token
    attr_accessor :end_token

    def initialize(known_hosts_file, start_token=nil, end_token=nil)
      @known_hosts_file = known_hosts_file
      @start_token = start_token || '# chef nodes start'
      @end_token = end_token || '# chef nodes end'
    end

    def set_hosts(hosts)
      write_out!(hosts)
    end

    def empty!
      write_out!([])
    end

    protected

    def write_out!(hosts)
      new_ghosts = hosts.inject('') do |s, host|
        fqdn = host['fqdn']
        unless fqdn.nil?
          rsa_public_ssh_key = host['keys']['ssh']['host_rsa_public']
          s += "#{fqdn},#{host['ipaddress']} ssh-rsa #{rsa_public_ssh_key}\n" unless rsa_public_ssh_key.nil?
          dsa_public_ssh_key = host['keys']['ssh']['host_rsa_public']
          s += "#{fqdn},#{host['ipaddress']} ssh-dsa #{dsa_public_ssh_key}\n" unless dsa_public_ssh_key.nil?
        end
        s
      end

      File.open(@known_hosts_file, 'r+') do |f|
        out, over, seen_tokens = '', false, false
        f.each do |line|
          if line =~ /^#{@start_token}/o
            over = seen_tokens = true
            out << line << new_ghosts
          elsif line =~ /^#{@end_token}/o
            over = false
          end
          out << line unless over
        end
        if !seen_tokens
          out << surround_with_tokens(new_ghosts)
        end

        f.pos = 0
        f.print out
        f.truncate(f.pos)
      end
    end

    def surround_with_tokens(str)
      "\n#{@start_token}\n" + str + "#{@end_token}\n"
    end
  end
end
