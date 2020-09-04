#!/bin/bash
#
# A simple script to control fan speeds on Dell generation 12 PowerEdge servers. 
# If the inlet temperature is above 35deg C enable iDRAC dynamic control and exit program.
# If inlet temp is below 35deg C set fan control to manual and set fan speed to predetermined value.
# The tower servers T320, T420 & T620 inlet temperature sensor is after the HDDs so temperature will
# be higher than the ambient temperature.

# Variables
IDRAC_IP="IP address of iDRAC"
IDRAC_USER="user"
IDRAC_PASSWORD="passowrd"
SPEED0="0x00"
SPEED5="0x05"
SPEED10="0x0a"
SPEED15="0x0f"
SPEED20="0x14"
SPEED25="0x19"
SPEED30="0x1e"
SPEED35="0x23"
TEMP_THRESHOLD="35" # iDRAC dynamic control enable thershold
TEMP_SENSOR="04h"   # Inlet Temp
#TEMP_SENSOR="01h"  # Exhaust Temp
#TEMP_SENSOR="0Eh"  # CPU 1 Temp
#TEMP_SENSOR="0Fh"  # CPU 2 Temp

# Get system date & time.
DATE=$(date +%d-%m-%Y\ %H:%M:%S)
echo "Date $DATE"

# Get temperature from iDARC.
T=$(ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD sdr type temperature | grep $TEMP_SENSOR | cut -d"|" -f5 | cut -d" " -f2)
echo "--> iDRAC IP Address: $IDRAC_IP"
echo "--> Current Inlet Temp: $T"

# If ambient temperature is above 35deg C enable dynamic control and exit, if below set manual control.
if [[ $T > $TEMP_THRESHOLD ]]
then
  echo "--> Temperature is above 35deg C"
  echo "--> Enabled dynamic fan control"
  ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD raw 0x30 0x30 0x01 0x01
  exit 1
else
  echo "--> Temperature is below 35deg C"
  echo "--> Disabled dynamic fan control"
  ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD raw 0x30 0x30 0x01 0x00
fi

# Set fan speed dependant on ambient temperature if inlet temperaturte is below 35deg C.
# If inlet temperature between 0 and 19deg C then set fans to 15%.
if [ "$T" -ge 0 ] && [ "$T" -le 19 ]
then
  echo "--> Setting fan speed to 15%"
  ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD raw 0x30 0x30 0x02 0xff $SPEED15

# If inlet temperature between 20 and 24deg C then set fans to 20%
elif [ "$T" -ge 20 ] && [ "$T" -le 24 ]
then
  echo "--> Setting fan speed to 20%"
  ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD raw 0x30 0x30 0x02 0xff $SPEED20

# If inlet temperature between 25 and 29deg C then set fans to 25%
elif [ "$T" -ge 25 ] && [ "$T" -le 29 ]
then
  echo "--> Setting fan speed to 25%"
  ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD raw 0x30 0x30 0x02 0xff $SPEED25

# If inlet temperature between 30 and 35deg C then set fans to 30%
elif [ "$T" -ge 30 ] && [ "$T" -le 34 ]
then
  echo "--> Setting fan speed to 30%"
  ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD raw 0x30 0x30 0x02 0xff $SPEED30
fi