#!/bin/bash
USER=$(grep ^user sysadmin-vagrant-dl.conf|awk '{print $2}')
PASS=$(grep ^password sysadmin-vagrant-dl.conf|awk '{print $2}')
LOC=$(grep ^location sysadmin-vagrant-dl.conf|awk '{print $2}')
for file in Vagrantfile site.pp moz-rhel-6.4.box centos-puppetmaster-6.4.box; do
  if [ ! -e $file ]; then
    wget --user=$USER --password=$PASS $LOC/$file
  else
    echo "$file already exist"
  fi
done
for box in moz-rhel-6.4 centos-puppetmaster-6.4; do
  echo "Loading box $box into vagrant"
  vagrant box add $box ./$box.box --provider virtualbox
done
