#!/bin/bash

#Flag Bits
UNDERVOLTED=0x1
CAPPED=0x2
THROTTLED=0x4
SOFT_TEMPLIMIT=0x8
HAS_UNDERVOLTED=0x10000
HAS_CAPPED=0x20000
HAS_THROTTLED=0x40000
HAS_SOFT_TEMPLIMIT=0x80000


#Text Colors
GREEN=`tput setaf 2`
RED=`tput setaf 1`
YELLOW=`tput setaf 3`
NC=`tput sgr0`

#Output Strings
GOOD="${GREEN}NO${NC}"
BAD="${RED}YES${NC}"

#Get Status, extract hex
STATUS=$(vcgencmd get_throttled)
STATUS=${STATUS#*=}

#Get clock speed
# CLOCK=$(vcgencmd measure_clock arm)
CLOCK=$(echo "scale=0; $(vcgencmd measure_clock arm | egrep -o '[0-9]{3,}') / 1000000" | bc -l)
CLOCK=${CLOCK#*=}

#Get emperature
TEMP=$(vcgencmd measure_temp | egrep -o '[0-9]{2,}')
TEMP=${TEMP#*=}

echo -n "Clock Speed: "
echo "${GREEN}${CLOCK}${NC}"

echo -n "Temperature: "
(($TEMP>=70)) && echo "${RED}${TEMP}${NC}" || ((($TEMP>=60)) && echo "${YELLOW}${TEMP}${NC}" || echo "${GREEN}${TEMP}${NC}")

echo -n "Status: "
(($STATUS!=0)) && echo "${RED}${STATUS}${NC}" || echo "${GREEN}${STATUS}${NC}"

echo "Undervolted:"
echo -n "   Now: "
((($STATUS&UNDERVOLTED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_UNDERVOLTED)!=0)) && echo "${BAD}" || echo "${GOOD}"

echo "Throttled:"
echo -n "   Now: "
((($STATUS&THROTTLED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_THROTTLED)!=0)) && echo "${BAD}" || echo "${GOOD}"

echo "Frequency Capped:"
echo -n "   Now: "
((($STATUS&CAPPED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_CAPPED)!=0)) && echo "${BAD}" || echo "${GOOD}"

echo "Softlimit:"
echo -n "   Now: "
((($STATUS&SOFT_TEMPLIMIT)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_SOFT_TEMPLIMIT)!=0)) && echo "${BAD}" || echo "${GOOD}"
