#!/bin/bash
# centos7_ip_configurations_L3 v0.001
# This script generates IPv4 configurations for L3 networking subnets on CentOS7
# It requires ipcalc to be installed on CentOS 7, which should be installed by default
#
# ============================
# If the L3 network is : 192.168.0.0/24, the script will generate the configurations as follow
# Gateway : 192.168.0.1
# Usable IPs : 192.168.0.2 - 192.168.0.254
# ============================
#
# Usage:   bash centos7_ip_configurations_L3.sh $subnet $deviceName $metricID
# Example: bash centos7_ip_configurations_L3.sh 192.168.1.0/24 eth0 2
# Example: bash centos7_ip_configurations_L3.sh 192.168.1.0/24 eth0:1 3
# 
##########################################################################################
network_input=$1
device_name=$2
metric_id=$3
DNS_1="8.8.8.8"
DNS_2="1.1.1.1"

# Get basis information
network_id=$(ipcalc -n $network_input | cut -d "=" -f2)
broadcast=$(ipcalc -b $network_input | cut -d "=" -f2)

# Get the gw information
gateway_first3_octet=$(echo $network_id | cut -d "." -f1,2,3)
gateway_last_octet=$(echo $network_id | cut -d "." -f4)
let gateway_last_octet++
full_gateway=$(echo $gateway_first3_octet.$gateway_last_octet)

# Get first and last usable IPs
firstusable_first3_octet=$(echo $network_id | cut -d "." -f1,2,3)
let gateway_last_octet++
firstusable_last_octet=$(echo $gateway_last_octet)
first_usable_ip=$(echo $firstusable_first3_octet.$firstusable_last_octet)

broadcast_last_octet=$(echo $broadcast | cut -d "." -f4)
let broadcast_last_octet--
lastusable_last_octet=$(echo $broadcast_last_octet)
last_usable_ip=$(echo $firstusable_first3_octet.$broadcast_last_octet)

# Get the network prefix
prefix=$(ipcalc -p $network_input | cut -d "=" -f2)

# Print out the network summary
echo -e "=========\nSummary\n========="
echo "Gateway: $full_gateway"
echo "Prefix: $prefix"
echo "Usable IPs: $first_usable_ip - $last_usable_ip"
echo -e "===========================\n\n"

# Generate the configurations
# You will have to copy it to your network configuration files
echo -e "Generating network configurations for : /etc/sysconfig/network-scripts/ifcfg-$device_name \n"

echo "TYPE="Ethernet"
NAME=$device_name
DEVICE=$device_name
ONBOOT=yes
METRIC=$metric_id
NM_CONTROLLED=no
DNS1=$DNS_1
DNS2=$DNS_2"
echo "GATEWAY=$full_gateway"

counter=0
for i in $(seq $firstusable_last_octet $lastusable_last_octet) ; do
	echo "IPADDR$counter=$firstusable_first3_octet.$i"
	echo "PREFIX$counter=$prefix"
	let counter++
done
