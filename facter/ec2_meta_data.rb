# Copyright 2008 Tim Dysinger
# Distributed under the same license as Facter
# 27.02.09 KurtBe
# Added a can_connect? function so that this fact can safely be distributed to non-ec2 instances
# otherwise the script hangs if the amazon-ip is not reachable
# 13.03.09 Francois Deppierraz
# Fixed the timeout handling code because which was not actually working. A
# file named "169.254.169.254" was created instead.
# Modified by jloope 2010

require 'open-uri'
require 'timeout'

def metadata(id = "")
  begin
    open("http://169.254.169.254/latest/meta-data/#{id||=''}").read.
    split("\n").each do |o|
      key = "#{id}#{o.gsub(/\=.*$/, '/')}"
      if key[-1..-1] != '/'
        value = open("http://169.254.169.254/latest/meta-data/#{key}").read.sub("\n", " ")
        symbol = "ec2_#{key.gsub(/\-|\//, '_')}".to_sym
        Facter.add(symbol) { setcode { value } }
      else
        metadata(key)
      end
    end
  rescue
    puts "ec2-metadata not loaded"
  end
end

begin
  Timeout::timeout(1) { metadata }
rescue Timeout::Error
  puts "ec2-metadata not loaded"
end

Facter.add("puppet_master") do
	setcode do
	 %x{puppetd --configprint server}.chomp
	end
end
