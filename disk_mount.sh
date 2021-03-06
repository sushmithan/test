######################################################################################################
#	File         : data-disk-mount.sh
#	Description  : This script will identyfy the new disk and mount it with a single primary partition
#   Usage        : sh filename.sh user
######################################################################################################

#!/bin/bash

# Disks to ignore from partitioning and formatting
DISKS_TO_IGNORE="/dev/sda|/dev/sdb"

# Base directory to hold the data* files
BASE_DIR="/media"

#Log file to record all the activities
NOW=$(date +"%Y-%m-%d")
LOGFILEDIR=$1
mkdir /home/$LOGFILEDIR/logfiles
check_for_new_disks() {

    echo "Checking for new disks started..........." >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
    # Looks for unpartitioned disks
    declare -a RET
    DEVS=($(ls -1 /dev/sd*|egrep -v "${DISKS_TO_IGNORE}"|egrep -v "[0-9]$"))
    for DEV in "${DEVS[@]}";
    do
        # Check each device if there is a "1" partition.  If not,
        # "assume" it is not partitioned.
        if [ ! -b ${DEV}1 ];
        then
            RET+="${DEV} "
        fi
    done
    echo "${RET}"
}

check_next_mountpoint() {
    echo "Checking for next mount point  started..........." >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
    DIRS=($(ls -1d ${BASE_DIR}/data* 2>&1| sort --version-sort))
    if [ -z "${DIRS[0]}" ];
    then
        echo "${BASE_DIR}/data1"
        return
    else
        IDX=$(echo "${DIRS[${#DIRS[@]}-1]}"|tr -d "[a-zA-Z/]" )
        IDX=$(( ${IDX} + 1 ))
        echo "${BASE_DIR}/data${IDX}"
    fi
	
}

insert_to_fstab() {
    echo "inserting the UUID to /etc/fstab  started..........." >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
    UUID=${1}
    MOUNTPOINT=${2}
    grep "${UUID}" /etc/fstab >/dev/null 2>&1
    if [ ${?} -eq 0 ];
    then
        echo "Not adding ${UUID} to fstab again (it's already there!)"
    else
        LINE="UUID=${UUID}        ${MOUNTPOINT}        ext4        defaults,nofail        1 2"
		echo "inserting the following entry to /etc/fstab..............." >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
		echo "${LINE}" >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
        echo -e "${LINE}" >> /etc/fstab
    fi

	 
}

is_partitioned() {
# Checks if there is a valid partition table on the
# specified disk
    OUTPUT=$(sfdisk -l ${1} 2>&1)
    grep "No partitions found" "${OUTPUT}" >/dev/null 2>&1
    return "${?}"       
}

has_filesystem() {
    DEVICE=${1}
    OUTPUT=$(file -L -s ${DEVICE})
    grep filesystem <<< "${OUTPUT}" > /dev/null 2>&1
    return ${?}
}

do_partition() {
echo "Partitioning the disk started..................." >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
# This function creates one (1) primary partition on the
# disk, using all available space
    DISK=${1}
    echo "n
p
1


w"| fdisk "${DISK}" > /dev/null 2>&1

#
# Use the bash-specific $PIPESTATUS to ensure we get the correct exit code
# from fdisk and not from echo
if [ ${PIPESTATUS[1]} -ne 0 ];
then
    echo "An error occurred partitioning ${DISK}" >&2 >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
    echo "I cannot continue" >&2 >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
    exit 2
fi

}

echo "#############################################################################" >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
echo "                                                                    " >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
echo "					 Log file: Data Disk Mount                        " >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
echo "The data-disk mount script is started at:  `date`" >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
echo "                                                                    " >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
echo "#############################################################################" >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
echo "                                                                    " >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
echo "                                                                    " >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log

DISKS=($(check_for_new_disks))
if [ "$DISKS" == "" ]
then 
    echo "There are no new disks" >>/home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
else
echo "Disks are ${DISKS[@]}" >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
for DISK in "${DISKS[@]}";
do
    echo "Working on ${DISK}" >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
    is_partitioned ${DISK}
    if [ ${?} -ne 0 ];
    then
	
        echo "${DISK} is not partitioned, partitioning" >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
        do_partition ${DISK}
		echo "Partitioning the disk ended..................." >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
    fi
    PARTITION=$(fdisk -l ${DISK}|grep -A 1 Device|tail -n 1|awk '{print $1}')
    has_filesystem ${PARTITION}
    
	if [ ${?} -ne 0 ];
    then
        echo "Creating filesystem on ${PARTITION}." >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
        #echo "Press Ctrl-C if you don't want to destroy all data on ${PARTITION}"
        #sleep 5
        mkfs -j -t ext4 ${PARTITION}
    fi
	
    MOUNTPOINT=$(check_next_mountpoint)
    echo "Next mount point appears to be ${MOUNTPOINT}" >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
    [ -d "${MOUNTPOINT}" ] || mkdir "${MOUNTPOINT}"
	UUID=$(blkid -u filesystem ${PARTITION}|awk -F "[= ]" '{print $3}'|tr -d "\"")
    insert_to_fstab "${UUID}" "${MOUNTPOINT}"
    echo "Mounting disk ${PARTITION} on ${MOUNTPOINT}" >> /home/$LOGFILEDIR/logfiles/data-disk-mount-$NOW.log
    mount "${MOUNTPOINT}"
	
	#making the drive writable
    chmod go+w "${MOUNTPOINT}"
done
fi