#!/bin/bash

vmName="$1"

#qvm-features $vmName updates-available ''
qvm-features $vmName service.qubes-update-check ''
