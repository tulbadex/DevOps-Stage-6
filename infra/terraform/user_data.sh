#!/bin/bash
# Wait for cloud-init to finish
cloud-init status --wait

# Wait for any automatic updates to finish
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "Waiting for apt lock..."
  sleep 5
done

# Kill any hanging apt processes
pkill -f apt-get || true
pkill -f dpkg || true
rm -f /var/lib/dpkg/lock-frontend
rm -f /var/lib/dpkg/lock

# Configure any interrupted packages
dpkg --configure -a

# Now proceed with installation
apt-get update
apt-get install -y python3 python3-pip
pip3 install ansible