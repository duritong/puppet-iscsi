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
    if ! $iscsi_initiatorname {
        fail('You must specifiy $iscsi_initiatorname for this host!')
    }
    if ! $iscsi_initiator_pwd {
        fail('You must specify $iscsi_initiator_pwd for this host!')
    }
    if ! $iscsi_target_targetname {
        fail('You must specify $iscsi_target_targetname for this host!')
    }
    if ! $iscsi_target_ip {
        fail('You must specify $iscsi_target_ip for this host!')
    }
    if ! $iscsi_target_pwd {
        fail('You must specify $iscsi_target_pwd for this host!')
    }

    package{iscsi-initiator-utils:
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
        require => Package[iscsi-initiator-utils],
    }
    service{'iscsid':
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package[iscsi-initiator-utils],
    }
    file{'/etc/iscsi/initiatorname.iscsi':
        content => "InitiatorName=$iscsi_initiatorname\nInitiatorAlias=$hostname\n",
        require => Package['iscsi-initiator-utils'],
        notify => [
            Service['iscsi'], 
            Service['iscsid'], 
            Exec['refresh_iscsi_connections'],
        ],
        owner => root, group => 0, mode => 0644;
    }
    file{'/etc/iscsi/iscsid.conf':
        content => template('iscsi/config/iscsid.conf.erb'),
        require => Package['iscsi-initiator-utils'],
        notify => [
            Service['iscsi'], 
            Service['iscsid'], 
            Exec['refresh_iscsi_connections'], 
        ],
        owner => root, group => 0, mode => 0600;
    }
    file{"/lib/udev/getlun.sh":
        source => "puppet://$server/iscsi/udev/getlun.sh",
        owner => root, group => 0, mode => 0744;
    }
    file{"/etc/udev/rules.d/10_persistant_scsi.rules":
        source => "puppet://$server/iscsi/udev/10_persistant_scsi.rules",
        owner => root, group => 0, mode => 0644;
    }
    file{'/usr/local/sbin/refresh_iscsi_connections.sh':
        source => "puppet://$server/iscsi/refresh_iscsi_connections.sh",
        owner => root, group => 0, mode => 0600;
    }
    exec{'refresh_iscsi_connections':
        command => "/usr/local/sbin/refresh_iscsi_connections.sh '$iscsi_initiatorname' '$iscsi_initiator_pwd' '$iscsi_target_targetname' '$iscsi_target_ip' '$iscsi_target_pwd'",
        before => [
            Service[iscsi],
            Service[iscsid],
        ],
        require => File['/usr/local/sbin/refresh_iscsi_connections.sh'],
        refreshonly => true,
    }
}
