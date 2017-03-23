#!/bin/bash

#PCI BUS Stuff, using nvidia-smi to support BusIDs
rm -Rf /etc/X11/xorg.conf
MAIN_ARRAY=( `nvidia-smi --query-gpu=gpu_bus_id --format=csv,noheader` )
nvidia-xconfig --virtual=4096x2160 --use-display-device=none --no-busid  -o /etc/X11/xorg.conf

#Check Occurences
FILE_OCCURENCES=$(cat /etc/X11/xorg.conf | grep -o "NVIDIA Corporation" | wc -l)

#Cound Array Length
COUNT=${#MAIN_ARRAY[@]}

if [ -z "$COUNT" ]; then
        echo "No NVIDIA CARDS found, maybe you forgot the --device=/dev/nvidiaX in your Docker run command?"
        exit
fi


#Add more device Sections if needed
if [ $COUNT != $FILE_OCCURENCES ]; then
        echo "Mismatch of Array and File Occurences, Problems with xorg.file and nvidia-smi output. Trying to fix..."
        for ((i=1;i<$COUNT;i++))
        do
                echo 'Section "Device"' >> /etc/X11/xorg.conf
                echo '  Identifier      "Device'$i'"' >> /etc/X11/xorg.conf
                echo '  Driver          "nvidia"' >> /etc/X11/xorg.conf
                echo '  VendorName      "NVIDIA Corporation"' >> /etc/X11/xorg.conf
                echo 'EndSection' >> /etc/X11/xorg.conf
        done
fi


#Begin looping for BUSID
for ((i=0; i<$COUNT; i++))
do
        TEMP=${MAIN_ARRAY[i]}
        IFS=':|.' read -ra array_1 <<< "$TEMP"
        BUSID_0=${array_1[1]}
        BUSID_1=${array_1[2]}
        BUSID_2=${array_1[3]}
        BUSIDS="PCI:$((0x${BUSID_0})):$((0x${BUSID_1})):$((0x${BUSID_2}))"

        #Add Bus IDs to xorg.conf, because nvidia-xconfig does not work in docker-containers
        TEMP_COUNTER=$((i+1))
        sed -i ':a;$!{N;ba};s/\("NVIDIA Corporation"\)/\1 \n''  BusID   "'${BUSIDS}'"/'${TEMP_COUNTER}'' /etc/X11/xorg.conf
done

#Add/CheckPass for User
if [ -z "$USERPASS" ]; then
    USERPASS=testgeheim
fi

if [ -z "$USERVNC" ]; then
    USERVNC=testing
fi

adduser ${USERVNC}
echo $USERPASS | passwd  --stdin ${USERVNC}


#Get TTYs
AVAILABLE_TTY=($(ls -d /dev/tty*[0-9]*))
TTY_COUNT=${#AVAILABLE_TTY[@]}

if [ $TTY_COUNT -ne 1 ]; then
	echo "No TTY found or multiple TTYs found for Xorg. Please run container with one free TTY, e.g. --device=/dev/tty60"
	exit
fi

#Manipulate Strings and export
USEVT=$(echo "vt${AVAILABLE_TTY[0]:8}")

#Run VNC and Xorg
sudo -S -u ${USERVNC} vncserver & Xorg :0 -keeptty -novtswitch -sharevts ${USEVT}
