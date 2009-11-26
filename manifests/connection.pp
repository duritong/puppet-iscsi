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

    # connection timeouts
    if ! $iscsi_replacement_timeout {
        $iscsi_replacement_timeout = 120
    }
    if ! $iscsi_login_timeout {
        $iscsi_login_timeout = 15
    }
    if ! $iscsi_logout_timeout {
        $iscsi_noop_out_interval = 15
    }
    if ! $iscsi_noop_out_timeout {
        $iscsi_noop_out_timeout = 5
    }
    if ! $iscsi_abort_timeout {
        $iscsi_abort_timeout = 15
    }
    if ! $iscsi_reset_timeout {
        $iscsi_reset_timeout = 30
    }

    file{'/etc/iscsi/initiatorname.iscsi':
        content => "InitiatorName=$iscsi_initiator_name\nInitiatorAlias=$hostname\n",
        require => Package[iscsi-initiator-utils],
        notify => [
            Exec[restart_iscsi_before_discovery],
            Exec[discover_targets],
            Service[iscsi], 
        ],
        owner => root, group => 0, mode => 0644;
    }
    file{'/etc/iscsi/iscsid.conf':
        content => template('iscsi/iscsid.conf.erb'),
        require => Package['iscsi-initiator-utils'],
        notify => [
            Exec[restart_iscsi_before_discovery],
            Exec[discover_targets],
            Service[iscsi], 
        ],
        owner => root, group => 0, mode => 0600;
    }
    exec{'restart_iscsi_before_discovery':
        refreshonly => true,
        before => Exec[discover_targets],
        command => "/etc/init.d/iscsi restart; /bin/true",
    }
    exec{'discover_targets':
        refreshonly => true,
        before => Service[iscsi],
        command => "/sbin/iscsiadm -m discovery -t sendtargets -p '$iscsi_target_ip'",
    }
}
