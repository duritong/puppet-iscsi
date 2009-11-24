define iscsi::connection(
    $iscsi_initiator_name,
    $iscsi_initiator_pwd,
    $iscsi_target_name,
    $iscsi_target_ip,
    $iscsi_target_pwd
){
    if ! $iscsi_initiator_name {
        fail('You must specifiy $iscsi_initiator_name!')
    }
    if ! $iscsi_initiator_pwd {
        fail('You must specify $iscsi_initiator_pwd!')
    }
    if ! $iscsi_target_name {
        fail('You must specify $iscsi_target_name!')
    }
    if ! $iscsi_target_ip {
        fail('You must specify $iscsi_target_ip!')
    }
    if ! $iscsi_target_pwd {
        fail('You must specify $iscsi_target_pwd!')
    }

    file{'/etc/iscsi/initiatorname.iscsi':
        content => "InitiatorName=$iscsi_initiator_name\nInitiatorAlias=$hostname\n",
        require => Package['iscsi-initiator-utils'],
        notify => [
            Service['iscsi'], 
            Service['iscsid'], 
            Exec['refresh_iscsi_connections'],
        ],
        owner => root, group => 0, mode => 0644;
    }
    file{'/etc/iscsi/iscsid.conf':
        content => template('iscsi/iscsid.conf.erb'),
        require => Package['iscsi-initiator-utils'],
        notify => [
            Service['iscsi'], 
            Service['iscsid'], 
            Exec['refresh_iscsi_connections'], 
        ],
        owner => root, group => 0, mode => 0600;
    }
    exec{'refresh_iscsi_connections':
        command => "/usr/local/sbin/refresh_iscsi_connections.sh '$iscsi_initiator_name' '$iscsi_initiator_pwd' '$iscsi_target_name' '$iscsi_target_ip' '$iscsi_target_pwd'",
        before => [
            Service[iscsi],
            Service[iscsid],
        ],
        require => File['/usr/local/sbin/refresh_iscsi_connections.sh'],
        refreshonly => true,
    }
}
