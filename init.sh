#!/bin/sh

sudo su -

echo "Updating packages ..."
apt-get update && apt-get upgrade -y && apt-get autoremove
apt-get install openjdk-8-jre -y

echo "Mounting data drive ..."
mkdir /minecraft
mount /dev/sdc1 /minecraft
echo '/dev/sdc1 /minecraft ext4 defaults 0 0' >> /etc/fstab

echo "Setting up Minecraft user ..."
adduser --system
addgroup --system minecraft
adduser minecraft minecraft
chown -R minecraft:minecraft /minecraft

echo "Downloading REVOLUTION|4 ..."
# <todo>

echo "Enable the service ..."
cd /minecraft
cp minecraft.service /etc/systemd/system/minecraft.service
systemctl enable minecraft.service
systemctl start minecraft
journalctl -u minecraft -f