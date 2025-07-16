#!/bin/bash
#

revisions=$(echo $@ | tr " " "\n")


if [[ -z "$@" ]]; then
    echo "ERROR: Revision to remove is invalid"
    exit 100
fi

for revision in $revisions; do
  echo "Removing revision: $revision ..."
  sudo lvremove qubes_dom0/$revision
done


