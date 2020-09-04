# iDRAC7_fan_control
A simple script to control fan speeds on Dell generation 12 PowerEdge servers. 
If the inlet temperature is above 35deg C enable iDRAC dynamic control and exit program.
If inlet temp is below 35deg C set fan control to manual and set fan speed to predetermined value.
The tower servers T320, T420 & T620 inlet temperature sensor is after the HDDs so temperature will
be higher than the ambient temperature.
