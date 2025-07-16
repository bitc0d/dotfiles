#!/bin/bash

vmName="$1"
snapshotName="$2"

if [[ -z "$vmName" ]]; then
    echo "VM name is mandatory"
    exit 100
fi

if [[ -z "$snapshotName" ]]; then
    echo "Snapshot name is mandatory"
    exit 100
fi


sudo lvcreate --noudevsync --ignoremonitoring -An -pr -s qubes_dom0/vm-${vmName}-root -n ${snapshotName}
