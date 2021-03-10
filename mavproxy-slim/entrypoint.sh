#!/bin/bash
set -e
set -m

if [ -z "${MAVPROXY}" ]; then
    MAVPROXY=false
fi
echo "MAVPROXY ?"
echo $MAVPROXY
if [ "$MAVPROXY" = true ]; then
    echo "Starting MAVPROXY instance"
else
    echo "Shutting down"
    exit 0  # Prevent docker restart
fi
export MAVLINK20=1
mavproxy.py --master=mcast: --cmd "module load cesium_map" --daemon --out 0.0.0.0:14550
exit 1
