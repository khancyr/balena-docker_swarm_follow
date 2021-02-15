#!/bin/bash
set -e
set -m

if [ -z "${NEED_START}" ]; then
    NEED_START=false
fi
echo "NEED_START ?"
echo $NEED_START
if [ "$NEED_START" = true ]; then
    echo "Starting ArduPilot instance"
else
    echo "Shutting down"
    exit 0  # Prevent docker restart
fi

if [ -z "${SITL_PARAMETER_LIST}" ]; then
    SITL_PARAMETER_LIST="/ardupilot/copter.parm"
fi

if [ -z "${SITL_MCAST}" ]; then
    SITL_MCAST="--uartA mcast:"
fi

if [ -z "${INSTANCE}" ]; then
    I_INSTANCE="-I0"
else
    I_INSTANCE="-I$(echo $INSTANCE | sed -e 's/-I//')"
fi

if [ -z "${SYSID}" ]; then
    SYSID=1
fi

if [ -z "${SITL_LOCATION}" ]; then
    BASE_LAT="-35.363261"
    BASE_LNG="149.165230"
    NUM_INSTANCE=$(echo $INSTANCE | sed -e 's/-I//')
    LAT=$(python3 -c "print($BASE_LAT + (0.00003 * $NUM_INSTANCE))")
    #LAT=$(echo "$BASE_LAT + (0.00003 * $NUM_INSTANCE)" | bc -l)
    if [ $((SYSID & 1)) -eq 1 ]; then
        #LNG=$(echo "$BASE_LNG + (0.00003 * $NUM_INSTANCE)" | bc -l)
        LNG=$(python3 -c "print($BASE_LNG + (0.00003 * $NUM_INSTANCE))")
    else
        LNG=$BASE_LNG
    fi

    SITL_LOCATION="$LAT,$LNG,584,353"
fi

if [ -z "${FOLL_ENABLE}" ]; then
    echo "Follow disabled"
    FOLLOW_STRING=""
else
    if [ -z "${FOLL_SYSID}" ]; then
        echo "Following SYSID 1"
        FOLL_SYSID="1"
    fi
    FOLLOW_STRING="FOLL_ENABLE 1\nFOLL_OFS_TYPE 1\nFOLL_SYSID ${FOLL_SYSID}\nFOLL_DIST_MAX 1000\n"
fi

printf "SYSID_THISMAV ${SYSID}\nSR0_POSITION 20\nSR0_EXTRA1 10\nSERIAL1_OPTIONS 1024\nTERRAIN_ENABLE 0\nLOG_BITMASK 0\n${FOLLOW_STRING}" > identity.parm
echo "INSTANCE:"
echo $I_INSTANCE

echo "identity.parm:"
cat identity.parm

args="-S $I_INSTANCE --home ${SITL_LOCATION} --model + --speedup 1 --defaults ${SITL_PARAMETER_LIST},identity.parm $SITL_MCAST"

echo "args:"
echo "$args"

if [ -z "${NO_LOGS}" ]; then
    NO_LOGS=1
fi

if [ "${NO_LOGS}" -eq 1 ]; then
    rm -rf /ardupilot/logs
    rm -rf /ardupilot/eeprom.bin
fi
export MAVLINK20=1
# Start Ardupilot simulator
/ardupilot/arducopter ${args} &

python3 /ardupilot/mav_follow.py

fg %1

