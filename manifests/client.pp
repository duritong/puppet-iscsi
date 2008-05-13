# manifests/client.pp

class iscsi::client {
    include iscsi::client::base 
}

class iscsi::client::base {
    package{iscsi-initiator-utils:
        ensure => present,
    }

    service{['iscsi', 'iscsid']:
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package[iscsi-initiator-utils],
    }

    # these files make some udev rules to match the
    # iscsi luns to /dev/iscsi_*
    file{"/etc/udev/rules.d/10_persistant_scsi.rules":
        source => "puppet://$server/iscsi/udev/10_persistant_scsi.rules",
        require => Package[iscsi-initiator-utils],
        owner => root, group => 0, mode => 0644;
    }
    
    file{"/lib/udev/getlun.sh":
        source => "puppet://$server/iscsi/udev/getlun.sh",
        require => Package[iscsi-initiator-utils],
        owner => root, group => 0, modei => 0744;
    }
}
