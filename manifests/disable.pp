class iscsi::disable {
  # Don't remove iscsi-initiator-utils package, it is a dependency of xen
  package{'iscsi-initiator-utils':
    ensure => present,
  }
  service{['iscsi', 'iscsid']:
    ensure => stopped,
    enable => false,
    hasstatus => true,
    require => Package['iscsi-initiator-utils'],
  }
  file{['/etc/iscsi/iscsid.conf',
        '/etc/iscsi/initiatorname.iscsi',
        '/lib/udev/get_persistant_iscsi_name.sh',
        '/etc/udev/rules.d/10_persistant_iscsi.rules',
        '/usr/local/sbin/update_iscsi_database.rb']:
    ensure => absent,
    require => Service['iscsi','iscsid'],
  }
}
