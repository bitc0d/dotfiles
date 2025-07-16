#!/bin/bash


whatToDo="$1"
vmName="$2"
dest="$3"
session="$4"

storageLocation="qubes://amag/media/Work/backups/Wyng/"

if [[ -z "$whatToDo" ]]; then
  echo "ERROR whatToDo is mandatory"
  echo " - init <dest> -> init ubuntu22-04"
  echo " - backup <vmName> <dest> -> backup vmPersonal ubuntu22-04"
  echo " - restore <vmName> <dest> <session> -> restore vmPersonal ubuntu24-04 <session>"
  echo " - list <dest> -> list ubuntu22-04"

  exit 10
fi

if [[ -z "$dest" ]] || [[ "$whatToDo" == "init" ]] || [[ "$whatToDo" == "list" ]]; then
  dest="$vmName"
fi

if [[ -z "$dest" ]]; then
  echo "ERROR whatToDo is mandatory"
  echo " - init <dest> -> init ubuntu22-04/freshInstall"
  echo " - backup <vmName> <dest> -> backup vmPersonal ubuntu22-04/freshInstall"
  echo " - restore <vmName> <dest> <session> -> restore vmPersonal ubuntu24-04/idm-1.86.10"
  echo " - list <dest> -> list ubuntu22-04"

  exit 10
fi

if [[ "$whatToDo" == "init" ]]; then
  sudo wyng arch-init --dest=${storageLocation}${dest}
fi

if [[ "$whatToDo" == "backup" ]]; then
  sudo wyng-util-qubes backup $vmName --dest=${storageLocation}${dest}
fi

if [[ "$whatToDo" == "restore" ]]; then
  if [[ -z "$sessionn" ]]; then
    sudo wyng-util-qubes restore $vmName --dest=${storageLocation}${dest}
  else
    sudo wyng-util-qubes restore $vmName --dest=${storageLocation}${dest} --session=$session
  fi
fi

if [[ "$whatToDo" == "list" ]]; then
  sudo wyng-util-qubes list --dest=${storageLocation}${dest} --all
fi
