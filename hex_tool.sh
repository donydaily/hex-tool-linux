#!/bin/sh
chmod a+x ./adb
clear
echo \###########################################
echo \#hex_ tool - linux
echo \###########################################
echo Connect your phone with USB Debugging ON before proceeding. 
echo 
echo
echo press 1 to configure 
echo press 2 to remove
echo \###########################################
MODE=""

prompt(){
	in=$(stty -g)
	stty raw -echo ; command=$(head -c 1) ; stty $in
	
	case "$command" in
   		"1") 
   		MODE="enable"
   		;;
   		"2") 
   		MODE="disable"
   		;;
   		*) echo "Invalid command. Try again." 
   		prompt
   		;;
	esac

}

run(){
	clear
	echo \###########################################
	echo Starting ADB...
	./adb kill-server 2>/dev/null
	./adb start-server 2>/dev/null
	echo \###########################################
	echo Connecting to your device...
	echo \###########################################

	local devices=""
	IFS=
	for i in $(./adb devices); do devices="$devices$i"; done
	
	if echo "$devices" | grep -q "unauthorized"  
	then 
		echo Device is unauthorized for ADB connection with this PC.
		echo \###########################################
	elif echo "$devices" | grep -q "offline"  
	then 
		echo Device is offline. Unlock your phone and retry.
		echo \###########################################	
	elif [ "$devices" = "List of devices attached" ]
	then
		echo No Devices Found. Connect your phone with USB Debugging ON.
		echo \###########################################
	else
		./adb shell "hex_bin=\$(pm path project.vivid.hex.bodhi); hex_bin=\${hex_bin/\"package:\"/\"\"}; hex_bin=\${hex_bin/\"base.apk\"/\"lib\"}; abi=\$(ls \"\$hex_bin\"); hex_bin=\$hex_bin/\$abi/libhex-core.so; \$hex_bin $MODE"
		if [ "$MODE" = "enable" ] 
		then
			echo
			echo  
			echo Configuration will last till you restart or shutdown the device. 
			echo
			echo  
			echo \###########################################
		fi	
	fi
	./adb kill-server 2>/dev/null
}

prompt
run
echo "Press any key to exit."
in=$(stty -g)
stty raw -echo ; x=$(head -c 1) ; stty $in
