#!/bin/bash

# Airpods.sh
# Output connected Airpods battery levels to BitBar
#
# Modified script from https://gist.github.com/Jahhein/45b8e8c9c36a0932189a5037f990bcdd

AIRPOD_ICON=$'🎧';

BATTERY_INFO=(
  "BatteryPercentCombined" 
  "HeadsetBattery" 
  "BatteryPercentSingle" 
  "BatteryPercentLeft" 
  "BatteryPercentRight"
)

BT_DEFAULTS=$(defaults read /Library/Preferences/com.apple.Bluetooth)
SYS_PROFILE=$(system_profiler SPBluetoothDataType 2>/dev/null)
MAC_ADDR=$(grep -b2 "Minor Type: Headphones"<<<"${SYS_PROFILE}"|awk '/Address/{print $3}')
CONNECTED=$(grep -ia6 "${MAC_ADDR}"<<<"${SYS_PROFILE}"|awk '/Connected: Yes/{print 1}')
BT_DATA=$(grep -ia6 '"'"${MAC_ADDR}"'"'<<<"${BT_DEFAULTS}")

if [[ "${CONNECTED}" ]]; then
  for info in "${BATTERY_INFO[@]}"; do
    declare -x "${info}"="$(awk -v pat="${info}" '$0~pat{gsub (";",""); print $3 }'<<<"${BT_DATA}")"
    [[ ! -z "${!info}" ]] && OUTPUT="${OUTPUT} $(awk '/BatteryPercent/{print substr($0,15)": "}'<<<"${info}")${!info}%"
  done
   printf "%s\\n" "${AIRPOD_ICON} ${OUTPUT}"
fi

exit 0