#!/bin/bash

DATA_FILE="/var/log/bandwidth_usage.log"

get_bandwidth_usage() {
    RX=$(cat /sys/class/net/eth0/statistics/rx_bytes)
    TX=$(cat /sys/class/net/eth0/statistics/tx_bytes)
    BANDWIDTH_TB=$(( (RX + TX) / 1024 / 1024 / 1024 / 1024 ))  # Konversi ke TB
    echo "$BANDWIDTH_TB"
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "       INPUT BATASAN BANDWIDTH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -p "Masukkan batasan bandwidth (dalam TB): " LIMIT

if ! [[ "$LIMIT" =~ ^[0-9]+$ ]]; then
    echo "Input tidak valid. Harap masukkan angka."
    exit 1
fi

echo "Monitoring penggunaan bandwidth kumulatif... (Batas: ${LIMIT} TB)"

if [ ! -f "$DATA_FILE" ]; then
    echo "0" > "$DATA_FILE"
fi

TOTAL_USAGE=$(cat "$DATA_FILE")

while true; do
    CURRENT_USAGE=$(get_bandwidth_usage)
    BANDWIDTH_USED=$((TOTAL_USAGE + CURRENT_USAGE))

    echo "Penggunaan bandwidth saat ini: ${CURRENT_USAGE} TB"
    echo "Total penggunaan bandwidth kumulatif: ${BANDWIDTH_USED} TB"

    echo "$BANDWIDTH_USED" > "$DATA_FILE"

    if [ "$BANDWIDTH_USED" -ge "$LIMIT" ]; then
        echo "Batas bandwidth kumulatif tercapai. Sistem akan shutdown."
        shutdown -h now
        exit 0
    fi

    sleep 3600
done