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
  include iscsi

  if ! $iscsi_initiator_name {
    fail('You must specify $iscsi_initiator_name!')
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
  # available in puppet. Also, a much cleaner approach would be to move 
  # those default values into the template. (<%= iscsi_replacement_timeout ||= 120 %>).

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
    content => "InitiatorName=${iscsi_initiator_name}\nInitiatorAlias=${::hostname}\n",
    require => Package['iscsi-initiator-utils'],
    notify => [
      Exec['restart_iscsi_daemon_before_discovery'],
      Exec['discover_iscsi_targets'],
    ],
    owner => root, group => 0, mode => 0644;
  }
  file{'/etc/iscsi/iscsid.conf':
    content => template('iscsi/iscsid.conf.erb'),
    require => Package['iscsi-initiator-utils'],
    notify => [
      Exec['update_iscsi_database'],
      Exec['restart_iscsi_daemon_before_discovery'],
      Exec['discover_iscsi_targets'],
    ],
    owner => root, group => 0, mode => 0600;
  }
  exec{'restart_iscsi_daemon_before_discovery':
    refreshonly => true,
    before => Exec['discover_iscsi_targets'],
    command => "/bin/ls /dev/iscsi_* || /etc/init.d/iscsi restart; /bin/true",
  }
  exec{'restart_iscsi_daemon_after_discovery':
    refreshonly => true,
    require => Exec['discover_iscsi_targets'],
    command => "/bin/ls /dev/iscsi_* || /etc/init.d/iscsi restart; /bin/true",
  }
  exec{'discover_iscsi_targets':
    refreshonly => true,
    notify => Exec['restart_iscsi_daemon_after_discovery'],
    command => "/bin/ls /dev/iscsi_* && /bin/true || /sbin/iscsiadm -m discovery -t sendtargets -p $iscsi_target_ip",
  }
  exec{'update_iscsi_database':
    refreshonly => true,
    require => File['/usr/local/sbin/update_iscsi_database.rb'],
    command => "/usr/local/sbin/update_iscsi_database.rb",
  }
}
