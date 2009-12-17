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

class iscsi {
    package{'iscsi-initiator-utils':
        ensure => present,
        require => [
            File['/lib/udev/getlun.sh'], 
            File['/etc/udev/rules.d/10_persistant_scsi.rules'], 
        ],
    }
    service{'iscsi':
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package['iscsi-initiator-utils'],
    }
    service{'iscsid':
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package['iscsi-initiator-utils'],
    }
    file{'/etc/init.d/iscsi':
        source => "puppet://$server/iscsi/iscsi.init",
        require => Package['iscsi-initiator-utils'],
        before => Service['iscsi'],
        owner => root, group => 0, mode => 0755;
    }
    file{'/lib/udev/getlun.sh':
        source => "puppet://$server/iscsi/getlun.sh",
        owner => root, group => 0, mode => 0755;
    }
    file{'/etc/udev/rules.d/10_persistant_scsi.rules':
        source => "puppet://$server/iscsi/10_persistant_scsi.rules",
        owner => root, group => 0, mode => 0644;
    }
    file{'/usr/local/sbin/update_iscsi_database.rb':
        source => "puppet://$server/iscsi/update_iscsi_database.rb",
        owner => root, group => 0, mode => 0755;
    }
}
