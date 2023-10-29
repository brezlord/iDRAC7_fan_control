# iDRAC7 fan control
A simple script to control fan speeds on Dell generation 12 PowerEdge servers.<br>
If the monitored temperature is above 35deg C enable iDRAC dynamic control and exit program.<br>
If monitored temperature is below 35deg C set fan control to manual and set fan speed to predetermined value.<br>
The tower servers T320, T420 & T620 inlet temperature sensor is after the HDDs so temperature will be higher than the ambient temperature.<br>

As you may have discovered, when you cross flash a Dell H310 raid controller to IT mode and as soon as the iDRAC detects that a drive has been inserted the fans spin up and get loud even when the ambient temperature is low, say 20deg  C. This is as designed by Dell, which sucks.

#### Directly from page 30 PowerEdge T320 Technical Guide

*RAID Setup with PERC H310: A system configured as non-RAID has a higher noise level than a system configured as RAID. With non-RAID, the temperature of the hard disk drives is not monitored, which causes the fan speed to be higher to ensure sufficient cooling resulting in higher noise level*


There is no warranty provided and you use this scrip at your own risk. Please ensure you review the temperature set points for your use case to ensure your hard drives are kept at your desired temperature, change the set points as needed. I suggest that you trend you HDD temps to validate your setting and that you setup alarms in TrueNAS so that you get warnings if the HDD temperatures get to high.

I use this script on a Dell T320 running TrueNAS 12 and it work great. The server lives in my garage, which in Western Australia can get into the low 40s deg C. 

You will need to create a data set for the script to reside in and make it executable, this assumes that you have a pool called tank and a dataset named fan_control. 
```
chmod +x /mnt/tank/fan_control/fan_control.sh
```
Make sure you set the below variables;
```
IDRAC_IP="IP address of iDRAC"
IDRAC_USER="user"
IDRAC_PASSWORD="passowrd"
```
There are multiple temperature sensors that you can choose to use. Just uncomment the one you would like the script to monitor. Not all temperature sensors are available in some models. You can run the following command from the shel to list all of the available temperature sensors on you generation 12 Dell sever.
```
ipmitool -I lanplus -H <ip address> -U <username> -P <password> sdr type temperature
```
Output from a Dell T320
```
Inlet Temp       | 04h | ok  |  7.1 | 23 degrees C
Temp             | 0Eh | ok  |  3.1 | 33 degrees C
Temp             | 0Fh | ns  |  3.2 | Disabled
```
Output from a Dell R720
```
Inlet Temp       | 04h | ok  |  7.1 | 20 degrees C
Exhaust Temp     | 01h | ok  |  7.1 | 31 degrees C
Temp             | 0Eh | ok  |  3.1 | 50 degrees C
Temp             | 0Fh | ok  |  3.2 | 45 degrees C
```
You will need to enable IPMI in the iDRAC and the user must have administrator privileges.

You can test the script by running ./fan_control.sh from the scrips directory. If it is working you should get an output similar to this;
```
Date 04-09-2020 10:24:52
--> iDRAC IP Address: 192.168.40.140
--> Current Inlet Temp: 22
--> Temperature is below 35deg C
--> Disabled dynamic fan control

--> Setting fan speed to 20%
```
Once you have verified the script is working you can set it to run every 5 minutes via cron.

On TrueNAS Core this can be found under the Tasks menu --> Cron Jobs.

On TrueNAS Scale this can be found under the System menu --> Advanced Cron Jobs tab.

## Systemd

## Running as a service

Once the service is up and running, the temprature will be checked every `INTERVAL_SEC` seconds. Fan speed will change if the temprature has changed and warrants a speed change. 

There is a delay before the temprature monitoring begins and is controlled by the variable `INITIAL_START_DELAY_SEC`. After this initial delay the time between checks is governed by the `INTERVAL_SEC` value.

When the server is shutdown/rebooted or started, the manual control is reset, this is to avoid any left over low fan speeds from previous power outage/powerdown/shutdown etc.

The files required to run the service are `fan_control_dyn.sh` `fancontrol.service`


Simply execute the following to get the service set up.
```
sudo cp fan_control_dyn.sh /usr/local/sbin/fan_control_dyn.sh
sudo chmod 755 /usr/local/sbin/fan_control_dyn.sh
sudo cp fancontrol.service /etc/systemd/system/fancontrol.service
sudo systemctl enable fancontrol.service
sudo systemctl start fancontrol.service
```

If you are using a location other than `/usr/local/sbin/fan_control_dyn.sh` then you'll need to modify the location in the `fancontrol.service` file as well 
```
ExecStart=/MY_ABSOLUTE_PATH/fan_control_dyn.sh
```
