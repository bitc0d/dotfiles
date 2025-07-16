#!/bin/bash


snapshotName="$1"

if [[ -z "$snapshotName" ]]; then
    echo "Snapshot name is mandatory"
    exit 100
fi

sudo lvconvert --merge qubes_dom0/${snapshotName}
