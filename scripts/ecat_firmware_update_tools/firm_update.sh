#!/bin/bash


#####################################
# Configuration
#####################################


# SOEM firm_update executable
# 注意：这里必须是文件，不是目录
ToolPath="/home/wiselook/SOEM/build/samples/firm_update/firm_update"


# 固件所在目录（脚本所在目录）
FirmwarePath=$(cd "$(dirname "$0")" && pwd)


# 固件名称（固定）
RM_FIRMWARE="rm.bin"
MIT_FIRMWARE="mit.bin"


#####################################
# Check SOEM tool
#####################################

if [ ! -f "$ToolPath" ]; then
    echo "ERROR: firm_update executable not found:"
    echo "$ToolPath"
    exit 1
fi


if [ ! -x "$ToolPath" ]; then
    echo "ERROR: firm_update is not executable"
    echo "Run:"
    echo "chmod +x $ToolPath"
    exit 1
fi


#####################################
# Select EtherCAT interface
#####################################

echo
echo "========== Available Network Interfaces =========="


mapfile -t Interfaces < <(ls /sys/class/net | grep -v lo)


if [ ${#Interfaces[@]} -eq 0 ]; then
    echo "No network interface found"
    exit 1
fi


for i in "${!Interfaces[@]}"
do
    echo "$((i+1)). ${Interfaces[$i]}"
done


echo

read -p "Select EtherCAT interface: " net_index



if ! [[ "$net_index" =~ ^[0-9]+$ ]]; then
    echo "Invalid selection"
    exit 1
fi


if [ "$net_index" -lt 1 ] || \
   [ "$net_index" -gt "${#Interfaces[@]}" ]; then

    echo "Invalid interface number"
    exit 1
fi



EthName=${Interfaces[$((net_index-1))]}


echo
echo "Selected interface:"
echo "$EthName"



#####################################
# Select slave
#####################################

echo

read -p "Input EtherCAT slave address: " SlaveAddress


if ! [[ "$SlaveAddress" =~ ^[0-9]+$ ]]; then
    echo "Invalid slave address"
    exit 1
fi



#####################################
# Select firmware
#####################################

echo
echo "========== Select Firmware =========="

echo "1. rm.bin"
echo "2. mit.bin"

echo


read -p "Select firmware: " fw_index



case "$fw_index" in

1)
    FirmwareFile="$RM_FIRMWARE"
    ;;

2)
    FirmwareFile="$MIT_FIRMWARE"
    ;;

*)
    echo "Invalid firmware selection"
    exit 1
    ;;

esac



#####################################
# Check firmware
#####################################

if [ ! -f "$FirmwarePath/$FirmwareFile" ]; then

    echo
    echo "ERROR: firmware file not found:"
    echo "$FirmwarePath/$FirmwareFile"

    exit 1

fi



#####################################
# Show information
#####################################

echo

echo "================================="
echo " EtherCAT Firmware Update"
echo "================================="
echo " Interface : $EthName"
echo " Slave     : $SlaveAddress"
echo " Firmware  : $FirmwareFile"
echo " Directory : $FirmwarePath"
echo "================================="

echo


read -p "Continue? (y/n): " confirm



if [ "$confirm" != "y" ]; then

    echo "Abort"
    exit 0

fi



#####################################
# Execute SOEM firm_update
#####################################


echo
echo "Starting firmware update..."
echo


# 进入固件目录
# 保证 SOEM fopen("rm.bin") 能找到文件

sudo bash -c "

    cd '$FirmwarePath' || exit 1

    echo 'Current directory:'
    pwd

    echo
    echo 'Firmware file:'
    ls -lh '$FirmwareFile'

    echo

    '$ToolPath' \
        '$EthName' \
        '$SlaveAddress' \
        '$FirmwareFile'
"



ret=$?



echo

if [ $ret -eq 0 ]; then

    echo "================================="
    echo " Firmware update success"
    echo "================================="

else

    echo "================================="
    echo " Firmware update failed"
    echo "================================="

fi



exit $ret
