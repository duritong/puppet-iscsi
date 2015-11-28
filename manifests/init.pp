#
# iscsi module
#
# Copyright 2008, Puzzle ITC GmbH
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

# Manage default iscsi stuff
class iscsi {
  package{'iscsi-initiator-utils':
    ensure  => installed,
    require => [
      File['/lib/udev/get_persistant_iscsi_name.sh'],
      File['/etc/udev/rules.d/10_persistant_iscsi.rules'],
    ],
  }
  service{
    'iscsi':
      ensure    => running,
      enable    => true,
      hasstatus => true,
      require   => Package['iscsi-initiator-utils'];
    'iscsid':
      ensure    => running,
      enable    => true,
      hasstatus => true,
      require   => Package['iscsi-initiator-utils'];
  }
  file{
    '/lib/udev/get_persistant_iscsi_name.sh':
      source => 'puppet:///modules/iscsi/get_persistant_iscsi_name.sh',
      owner  => root,
      group  => 0,
      mode   => '0755';
    '/etc/udev/rules.d/10_persistant_iscsi.rules':
      source => 'puppet:///modules/iscsi/10_persistant_iscsi.rules',
      owner  => root,
      group  => 0,
      mode   => '0644';
    '/usr/local/sbin/update_iscsi_database.rb':
      source => 'puppet:///modules/iscsi/update_iscsi_database.rb',
      owner  => root,
      group  => 0,
      mode   => '0755';
  }
}
