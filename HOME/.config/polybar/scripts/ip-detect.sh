#!/bin/bash

ETH_IFACE="enp1s0"
WIFI_IFACE="wlan0"

# Extraer IP con máscara CIDR (ejemplo: 192.168.0.15/24)
get_ip_cidr() {
  ip -o -f inet addr show "$1" | awk '{print $4}' | head -1
}

ETH_IP=$(get_ip_cidr "$ETH_IFACE")
if [[ -n "$ETH_IP" ]]; then
  echo "eth: $ETH_IP  "
else
  WIFI_IP=$(get_ip_cidr "$WIFI_IFACE")
  if [[ -n "$WIFI_IP" ]]; then
    echo "wifi: $WIFI_IP  "
  else
    echo "No conectado  "
  fi
fi
