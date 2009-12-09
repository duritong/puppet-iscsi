#!/usr/bin/env ruby

target = String.new
target = "-T #{ARGV[0]}" if ARGV[0]
ignore = [ 'discovery.sendtargets.iscsi.MaxRecvDataSegmentLength', ]

File.open('/etc/iscsi/iscsid.conf').each do |line|
  unless line[/^ *(#|$)/]
    setting, value = line.match(/\s*(\S+)\s*=\s*(\S+)\s*/)[1..2]
    next if ignore.any? { |ignore_regex| setting.match ignore_regex }
    print `/sbin/iscsiadm -m node #{target} -o update -n #{setting} -v #{value}`
  end
end
