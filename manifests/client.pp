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
        require => [ File['/etc/udev/rules.d/10_persistant_scsi.rules'], 
                     File['/lib/udev/getlun.sh'], 
                     Package[iscsi-initiator-utils] ],
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
        owner => root, group => 0, mode => 0744;
    }

    case $iscsi_initiatorname {
        '': { fail('You have to specifiy $iscsi_initiatorname for this host!') }
        default: {
            file{'/etc/iscsi/initiatorname.iscsi':
                content => "InitiatorName=$iscsi_initiatorname
InitiatorAlias=$hostname",
                require => Package['iscsi-initiator-utils'],
                notify => [ Service['iscsi'], Service['iscsid'] ],
                owner => root, group => 0, mode => 0644;
            }

           case $iscsi_initiator_pwd {
                '': { fail('You need to specify $iscsi_initiator_pwd for this host!') }
                default: {
                    case $iscsi_target_pwd {
                        '': { fail('You need to specify $iscsi_target_pwd for this host!') }
                        default: {
                            file{'/etc/iscsi/iscsid.conf':
                                content => template('iscsi/config/iscsid.conf.erb'),
                                require => Package['iscsi-initiator-utils'],
                                notify => [ Exec['refresh_iscsi_connections'], Service['iscsi'], Service['iscsid'] ],
                                owner => root, group => 0, mode => 0600;
                            }

                            exec{'refresh_iscsi_connections':
                                command => "iscsiadm -m node -T $iscsi_target_targetname -p ${iscsi_target_ip}:3207 -U && iscsiadm -m node -T $iscsi_target_targetname -p $iscsi_target_ip -o update -n node.session.auth.authmethod -v CHAP && iscsiadm -m node -T $iscsi_target_targetname -p $iscsi_target_ip -o update -n node.session.auth.username -v $iscsi_initiatorname &&  iscsiadm -m node -T $iscsi_target_targetname -p $iscsi_target_ip -o update -n node.session.auth.username_in -v $iscsi_initiatorname &&  iscsiadm -m node -T $iscsi_target_targetname -p $iscsi_target_ip -o update -n node.session.auth.password -v $iscsi_initiator_pwd &&  iscsiadm -m node -T $iscsi_target_targetname -p $iscsi_target_ip -o update -n node.session.auth.password_in -v $iscsi_target_pwd iscsiadm -m node -T $iscsi_target_targetname -p $iscsi_target_ip -L all",
                                refreshonly => true,
                            }
                        }
                    }
                }
            }
        }
    }
}
