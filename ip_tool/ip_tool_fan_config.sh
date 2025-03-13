# ----------------------------------------------------------------------------------
# Script for checking the temperature reported by the temperature sensor,
# and disabling 3rd party cooling profile under normal circumstances
#
# Requires:
# ipmitool –apt-get install ipmitool
# ----------------------------------------------------------------------------------

IPMIHOST=192.168.0.120
IPMIUSER=admin
IPMIPW=admin
MAXTEMP=65
TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW sdr type temperature | grep degrees | awk '{if ($(NF-2) ~ /[0-9]+/) {temps[++i] = $(NF-2)}} END {max = temps[1]; for (i = 2; i <= length(temps); i++) if (temps[i] > max) max = temps[i]; print max}')
if [[ $TEMP > $MAXTEMP ]];
  then
    echo "ERROR: Temperature above $MAXTEMP! Activating dynamic fan control & 3rd party cooling profile! ($TEMP C)"
    echo "ERROR: Temperature above $MAXTEMP! Activating dynamic fan control & 3rd party cooling profile! ($TEMP C)"
    # Before uncommenting, make sure you know what you are doing. Also,
    # we will be enabling 3rd party cooling profile (below) if you have 3rd party adapter installed, so fans might run at full speed.
    # make sure to set the fan control mode back to automatic
    # ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x01

	  # Note: Since a non-dell PCIE adapter is installed, fans wll run at max speed. There is no need for above cmd
    # enable 3rd party fan cooling profile
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x00 0x00 0x00
    # Output: 16 05 00 00 00 05 00 00 00 00
    echo "Enabling 3rd party cooling profile! ($TEMP C)"
	echo "ERROR: System Temperature HIGH! ($TEMP C)"
  else
    echo "Temperature is OK "
    # Before uncommenting, make sure you know what you are doing.
    # use https://www.rapidtables.com/convert/number/decimal-to-hex.html to find other hex codes

    # setting the fan control to manual mode
    # ipmitool -I lanplus  -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
    # run at 20% of their total capability
    # ipmitool -I lanplus  -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x14
    # run at 50% of their total capability
    # ipmitool -I lanplus  -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x32
    # run at 80% of their total capability
    # ipmitool -I lanplus  -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x50

    # disable 3rd party fan cooling profile
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x01 0x00 0x00
    # Output: 16 05 00 00 00 05 00 01 00 00
    echo "Disabling 3rd party cooling profile! ($TEMP C)"
    echo "System Temperature OK! ($TEMP C)"
    echo "System Temperature OK! ($TEMP C)"
fi