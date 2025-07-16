#!/bin/bash
#

vmName="$1"

if [[ -z "$vmName" ]]; then
  vms=$(qvm-ls | awk '{print $1}')
  for vm in ${vms[*]}; do
  	if [[ "$vm" == "NAME" ]] || [[ "$vm" == "dom0" ]]; then continue; fi
  	echo $vm
  	qvm-volume config $vm:root revisions_to_keep 0
  	qvm-volume config $vm:private revisions_to_keep 0
  done
else
  qvm-volume config ${vmName}:root revisions_to_keep 0
  qvm-volume config ${vmName}:private revisions_to_keep 0
fi
