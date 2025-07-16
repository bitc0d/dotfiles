#!/bin/bash
#

vm1="$1"
vm2="$2"

firewallVM="sys-firewall"

if [[ -z "$vm1" ]] || [[ -z "$vm2" ]]; then
  clear
  echo "vm1 and vm2 are mandatory"
  echo "vm1 - usually amag vm"
  echo "vm2 - usually the standalone vm"
  exit 100
fi

# find vm ip
vm1IP=$(qvm-ls -n | grep $vm1 | awk '{print $4}')
vm2IP=$(qvm-ls -n | grep $vm2 | awk '{print $4}')

# Allow inside firewallVM
qvm-run $firewallVM "sudo nft add rule ip qubes custom-forward ip saddr $vm1IP ip daddr $vm2IP ct state new,established,related counter accept"

qvm-run $firewallVM "sudo nft add rule ip qubes custom-forward ip saddr $vm2IP ip daddr $vm1IP ct state new,established,related counter accept"

# Allow inside qube itself
qvm-run $vm2 "sudo nft add rule qubes custom-input ip saddr $vm2IP ct state new,established,related counter accept"
qvm-run $vm2 "sudo nft add rule qubes custom-input ip saddr $vm1IP ct state new,established,related counter accept"
qvm-run $vm1 "sudo nft add rule qubes custom-input ip saddr $vm1IP ct state new,established,related counter accept"
qvm-run $vm1 "sudo nft add rule qubes custom-input ip saddr $vm2IP ct state new,established,related counter accept"
