#!/bin/bash

test $# -lt 6 && exit 1

iscsi_initiatorname = "$1"
iscsi_initiator_pwd = "$2"
iscsi_target_targetname = "$3"
iscsi_target_ip = "$4"
iscsi_target_pwd = "$5"

/sbin/iscsiadm -m node -T "$iscsi_target_targetname" -p "$iscsi_target_ip":3207 -U all
/sbin/iscsiadm -m discovery -t sendtargets -p "$iscsi_target_ip" && 
/sbin/iscsiadm -m node -T "$iscsi_target_targetname" -p "$iscsi_target_ip" -o update -n node.session.auth.authmethod -v CHAP && 
/sbin/iscsiadm -m node -T "$iscsi_target_targetname" -p "$iscsi_target_ip" -o update -n node.session.auth.username -v "$iscsi_initiatorname" && 
/sbin/iscsiadm -m node -T "$iscsi_target_targetname" -p "$iscsi_target_ip" -o update -n node.session.auth.username_in -v "$iscsi_initiatorname" && 
/sbin/iscsiadm -m node -T "$iscsi_target_targetname" -p "$iscsi_target_ip" -o update -n node.session.auth.password -v "$iscsi_target_pwd" && 
/sbin/iscsiadm -m node -T "$iscsi_target_targetname" -p "$iscsi_target_ip" -o update -n node.session.auth.password_in -v "$iscsi_initiator_pwd" &&
/sbin/iscsiadm -m node -T "$iscsi_target_targetname" -p "$iscsi_target_ip" -L all &&
/sbin/iscsiadm -m session -R
