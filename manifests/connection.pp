define iscsi::connection(
    $iscsi_initiator_name,
    $iscsi_initiator_pwd,
    $iscsi_target_name,
    $iscsi_target_ip,
    $iscsi_target_pwd,
    $iscsi_replacement_timeout,
    $iscsi_noop_out_interval,
    $iscsi_noop_out_timeout
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

    # For now, we only implement those parameters we need to, hashes would 
    # be much more appropriate for such a case, so we wait until they are 
    # available in puppet.

    if ! $iscsi_replacement_timeout {
        $iscsi_replacement_timeout = 120
    }
    if ! $iscsi_noop_out_interval {
        $iscsi_noop_out_interval = 5
    }
    if ! $iscsi_noop_out_timeout {
        $iscsi_noop_out_timeout = 5
    }

    file{'/etc/iscsi/initiatorname.iscsi':
        content => "InitiatorName=$iscsi_initiator_name\nInitiatorAlias=$hostname\n",
        require => Package[iscsi-initiator-utils],
        notify => [
            Exec[update_iscsi_replacement_timeout],
            Exec[update_iscsi_noop_out_interval],
            Exec[update_iscsi_noop_out_timeout],
            Exec[restart_iscsi_daemon_before_discovery],
            Exec[discover_iscsi_targets],
        ],
        owner => root, group => 0, mode => 0644;
    }
    file{'/etc/iscsi/iscsid.conf':
        content => template('iscsi/iscsid.conf.erb'),
        require => Package['iscsi-initiator-utils'],
        notify => [
            Exec[update_iscsi_replacement_timeout],
            Exec[update_iscsi_noop_out_interval],
            Exec[update_iscsi_noop_out_timeout],
            Exec[restart_iscsi_daemon_before_discovery],
            Exec[discover_iscsi_targets],
        ],
        owner => root, group => 0, mode => 0600;
    }
    exec{'restart_iscsi_daemon_before_discovery':
        refreshonly => true,
        before => Exec[discover_iscsi_targets],
        onlyif => "test `ls -1 /dev/iscsi* | wc -l` -eq 0",
        command => "/etc/init.d/iscsi restart; /bin/true",
    }
    exec{'discover_iscsi_targets':
        refreshonly => true,
        notify => Service[iscsi],
        onlyif => "test `ls -1 /dev/iscsi* | wc -l` -eq 0",
        command => "/sbin/iscsiadm -m discovery -t sendtargets -p $iscsi_target_ip",
    }
    exec{'update_iscsi_replacement_timeout':
        refreshonly => true,
        command => "iscsiadm -m node -T $iscsi_target_name -o update -n node.session.timeo.replacement_timeout -v $iscsi_replacement_timeout",

    }
    exec{'update_iscsi_noop_out_interval':
        refreshonly => true,
        command => "iscsiadm -m node -T $iscsi_target_name -o update -n node.conn[0].timeo.noop_out_interval -v $iscsi_noop_out_interval",

    }
    exec{'update_iscsi_noop_out_timeout':
        refreshonly => true,
        command => "iscsiadm -m node -T $iscsi_target_name -o update -n node.conn[0].timeo.noop_out_timeout -v $iscsi_noop_out_timeout",

    }
}
