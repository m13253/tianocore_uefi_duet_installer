#! /bin/sh

wd=${PWD}
EFI_DUET=${wd}

EFI_BOOT_DEVICE=$1
DUET_BUILD=$2
EFI_BOOT_DEVICE_MP=/media/EFI_DUET_/

export PROCESSOR=X64

if [ "$2" = "EDK_UEFI64" ]
then 
    SHELL_DIR=${EFI_DUET}/Shell/EDK_X64/
elif [ "$2" = "EDK2_X64" ] 
then 
    SHELL_DIR=${EFI_DUET}/Shell/EDK2_X64/
fi

LINUX_SOURCE_DIR=${EFI_DUET}/Linux_Source/C/
LINUX_BIN_DIR=${LINUX_SOURCE_DIR}/bin/

BOOTSECTOR_BIN_DIR=${EFI_DUET}/BootSector/
EFILDR_DIR=${EFI_DUET}/Efildr/${DUET_BUILD}/
Extras_DIR=${EFI_DUET}/Extras/${PROCESSOR}/
DISK_LABEL=EFI_DUET
PROCESS_CONTINUE=TRUE

echo    		              
echo USB FLASH DEVICE = ${EFI_BOOT_DEVICE}
echo 
echo USB FLASH DEVICE FILESYSTEM = FAT32
echo 


if [ \
     "$1" = "" -o \
     "$1" = "-h" -o \
     "$1" = "-u" -o \
     "$1" = "--usage" -o \
     "$1" = "--help" -o \
     "$2" = "-h" -o \
     "$2" = "-u" -o \
     "$2" = "--usage" -o \
     "$2" = "--help" \
   ]
then
    echo "--------"
	echo "Usage : ./CreateDUET.sh [DevicePath]"
	echo "Example : ./CreateDUET.sh /dev/sdc"
    echo "--------"	
    echo "Safely Remove and replug the USB flash drive and then"
	echo "--------"
    echo "Step 2 : ./CreateDUET.sh [DevicePath] [DUET_BUILD]"
    echo "Example - Step 2 : ./CreateDUET.sh /dev/sdc EDK2_X64"
	echo "--------"
    echo "The possible arguments for DUET_BUILD are EDK2_X64 and EDK_UEFI64 ."
	echo "--------"
    echo "You need to have the permission and the root password to run sudo command in order to use this script"
    echo "--------"	
    export PROCESS_CONTINUE=FALSE
fi

if [ "${PROCESS_CONTINUE}" = TRUE ]
then
	if [ "$2" = "" ]
	then
            cd ${LINUX_SOURCE_DIR}/
			echo
			
			make clean
			echo
			
			make
			echo			
			
			# echo "--------"
            # echo Formatting ${EFI_BOOT_DEVICE}1 as FAT32
            # echo "--------"
            
            set -x -e

            sudo umount ${EFI_BOOT_DEVICE}1

            # sudo parted ${EFI_BOOT_DEVICE} mklabel msdos mkpart primary 0.0  
			# maybe sfdisk can be used for creating a primary partition
            # sudo mkfs.vfat -F32 ${EFI_BOOT_DEVICE}1
                    
            echo Creating FAT32 boot sector ...
            echo "--------"
            
            sudo cp ${BOOTSECTOR_BIN_DIR}/Bs32.com ${BOOTSECTOR_BIN_DIR}/Bs32.com1

            sudo ${LINUX_BIN_DIR}/GnuGenBootSector -i ${EFI_BOOT_DEVICE}1 -o UsbBs32.com
            sudo ${LINUX_BIN_DIR}/BootSectImage -g UsbBs32.com ${BOOTSECTOR_BIN_DIR}/Bs32.com1 -f
            sudo rm UsbBs32.com
            sudo ${LINUX_BIN_DIR}/GnuGenBootSector -o ${EFI_BOOT_DEVICE}1 -i ${BOOTSECTOR_BIN_DIR}/Bs32.com1
            sudo ${LINUX_BIN_DIR}/GnuGenBootSector --mbr -o ${EFI_BOOT_DEVICE} -i ${BOOTSECTOR_BIN_DIR}/Mbr.com
            
            sudo rm ${BOOTSECTOR_BIN_DIR}/Bs32.com1
  
            set +x +e
            
			cd ${LINUX_SOURCE_DIR}/
			echo
			
			make clean
			echo
			
            echo Done.
            echo "--------"
            echo PLEASE UNPLUG USB, THEN PLUG IT AGAIN TO DO STEP2!
            echo "--------"
    else
            echo "--------"
            echo UEFI-DUET FIRMWARE ARCH = ${PROCESSOR}
            echo
            echo UEFI-DUET FIRMWARE BUILD = $2   		              
            echo "--------"
        
            set -x

            sudo umount ${EFI_BOOT_DEVICE}1

            sudo mkdir ${EFI_BOOT_DEVICE_MP}
            sudo mount ${EFI_BOOT_DEVICE}1 ${EFI_BOOT_DEVICE_MP}

            sudo cp ${EFILDR_DIR}/Efildr20 ${EFI_BOOT_DEVICE_MP}
	        sudo cp ${SHELL_DIR}/LoadFv.efi ${EFI_BOOT_DEVICE_MP}/
            sudo cp ${SHELL_DIR}/DumpBs.efi ${EFI_BOOT_DEVICE_MP}/
            sudo cp ${EFILDR_DIR}/*.fv ${EFI_BOOT_DEVICE_MP}/
            sudo mkdir ${EFI_BOOT_DEVICE_MP}/efi
            sudo mkdir ${EFI_BOOT_DEVICE_MP}/efi/Shell
            sudo cp ${SHELL_DIR}/Shell_Full.efi ${EFI_BOOT_DEVICE_MP}/efi/Shell/Shell.efi
            sudo mkdir ${EFI_BOOT_DEVICE_MP}/efi/extras
            sudo cp ${Extras_DIR}/*.efi ${EFI_BOOT_DEVICE_MP}/efi/extras/    

            sudo umount ${EFI_BOOT_DEVICE}1
            sudo rm -rf ${EFI_BOOT_DEVICE_MP}

            set +x
  
            echo "--------"
            echo Files have been copied to the USB flash drive successfully
	        echo DUET FAT32 ${DUET_BUILD} step2 Done!
            echo "--------"          
	 fi			
fi
