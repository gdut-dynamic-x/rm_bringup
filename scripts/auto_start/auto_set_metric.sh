#!/bin/bash

ECAT_IFACE=enp86s0
EXCHANGE_IFACE=enx000ec602a165

echo "Starting auto_set_metric.sh!"

while true
do
if sudo ifmetric ${ECAT_IFACE} 200; then
    echo "${ECAT_IFACE} Metric: $(route -n | grep '0.0.0.0' | grep "${ECAT_IFACE}" | awk '{print $5}')"
else
    echo "Failed to set metric for ${ECAT_IFACE}"
    exit 1
fi

if sudo ifmetric ${EXCHANGE_IFACE} 100; then
    echo "${EXCHANGE_IFACE} Metric: $(route -n | grep '0.0.0.0' | grep "${EXCHANGE_IFACE}" | awk '{print $5}')"
else
    echo "Failed to set metric for ${EXCHANGE_IFACE}"
    exit 1
fi

sleep 10
done

echo "auto_set_metric.sh executed successfully!"
