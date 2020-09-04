# iDRAC7_fan_control
A simple script to control fan speeds on Dell generation 12 PowerEdge servers.<br>
If the inlet temperature is above 35deg C enable iDRAC dynamic control and exit program.<br>
If inlet temp is below 35deg C set fan control to manual and set fan speed to predetermined value.<br>
The tower servers T320, T420 & T620 inlet temperature sensor is after the HDDs so temperature will be higher than the ambient temperature.<br>

There is no warranty and you use this scrip at your own risk. Please ensure you review the temperature setpoints for your use case to ensure your hard drives are kept at your desired temperature. You can change the temperature set points in the script to suit your needs.

I use this script on a Dell T320 running TrueNAS 12 and it work great. You will need to create a dataset for the script to reside in and make it executable, this assumes that you have a pool called tank and a dataset named fan_control. 
```
chmod +x /mnt/tank/fan_control/fan_control.sh
```
Make sure you set the below variables;
```
IDRAC_IP="IP address of iDRAC"
IDRAC_USER="user"
IDRAC_PASSWORD="passowrd"
```
You will need to enable IPMI in the iDRAC and the user must have administrator privileges.


You can test the script by running ./fan_sontrol.sh from the scrips directory. If it is working you should get an output similar to this;
```
Date 04-09-2020 10:24:52
--> iDRAC IP Address: 192.168.40.140
--> Current Inlet Temp: 22
--> Temperature is below 35deg C
--> Disabled dynamic fan control

--> Setting fan speed to 20%
```
