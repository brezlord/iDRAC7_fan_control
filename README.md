# iDRAC7_fan_control
<p>A simple script to control fan speeds on Dell generation 12 PowerEdge servers.<br>
If the inlet temperature is above 35deg C enable iDRAC dynamic control and exit program.<br>
If inlet temp is below 35deg C set fan control to manual and set fan speed to predetermined value.<br>
The tower servers T320, T420 & T620 inlet temperature sensor is after the HDDs so temperature will be higher than the ambient temperature.</p>

<p>There is no warenty and you use this scrip at your own risk. Please ensure you review the temperature setpoints for your use case to ensure your hard drives are kept at your desiered temperature. You can change the temperature set points in the script to sute your needs.</p>

<p>I use this script on a Dell T320 running TrueNAS 12 and it work great. You will need to create a dataset for the script to recide in and make it excicutable, run chmod +x /mnt/tank/fan_control/fan_control.sh this assumes that you have a pool called tank and an dataset named fan_control.</p>

<p>You can test the script by running ./fan_sontrol.sh from the scrips directory. If it is working you should get an output similar to this;<br>
<br>
Date 04-09-2020 10:24:52<br>
--> iDRAC IP Address: 192.168.40.140<br>
--> Current Inlet Temp: 22<br>
--> Temperature is below 35deg C<br>
--> Disabled dynamic fan control<br>
<br>
--> Setting fan speed to 20%</p>
