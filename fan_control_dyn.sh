#!/bin/bash

# Variables
IDRAC_IP="IP address of iDRAC"
IDRAC_USER="user"
IDRAC_PASSWORD="passowrd"
INTERVAL_SEC=5
INITIAL_START_DELAY_SEC=60

TEMP_THRESHOLD=35
TEMP_SENSOR="04h"   # Inlet Temp
#TEMP_SENSOR="01h"  # Exhaust Temp
#TEMP_SENSOR="0Eh"  # CPU 1 Temp
#TEMP_SENSOR="0Fh"  # CPU 2 Temp

FCTRL=0 #disabled, enabled=1
LAST_PCT=0


toggle() {
    ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD raw 0x30 0x30 0x01 $1 2>&1 >/dev/null
}

reset_manual() {
    toggle 0x01
    FCTRL=0 #disabled
}

set_manual() {
    toggle 0x00
    FCTRL=1 #enabled
}

graceful_exit() {
    reset_manual
    exit 0
}

trap graceful_exit SIGINT SIGTERM


# need the reset in case the system boots up with the last set value
reset_manual

#start delay
sleep $INITIAL_START_DELAY_SEC


while [ 1 ]
do

    # Get temperature from iDARC.
    T=$(ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD sdr type temperature 2>/dev/null | grep $TEMP_SENSOR | cut -d"|" -f5 | cut -d" " -f2)

    # If ambient temperature is above 35deg C enable dynamic control and exit, if below set manual control.
    if [[ $T -ge $TEMP_THRESHOLD ]]
    then
        if [[ $FCTRL -ne 0 ]]
        then
            reset_manual
        fi
    else
        
        # This gives a Percent that is a multiple of 5 for ranges of 5 degC
        PCT=$(( 5 * ( T / 5 ) ))
        # Min PCT Allowed is 10
        PCT=$(( PCT < 10 ? 10 : PCT ))
        

        if [[ $LAST_PCT -ne $PCT ]]
        then
            if [[ $FCTRL -eq 0 ]]
            then
                set_manual
            fi
            PCTHEX=$(printf '0x%02x' $PCT)
            ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD raw 0x30 0x30 0x02 0xff $PCTHEX 2>&1 >/dev/null
            LAST_PCT=$PCT
        fi
    fi

    
    sleep $INTERVAL_SEC
done
