#!/bin/sh

WD="${PWD}/"
EFI_DUET_DIR="${WD}/"

PROCESS_CONTINUE="TRUE"

if [ \
	"${1}" = "" -o \
	"${1}" = "-h" -o \
	"${1}" = "-u" -o \
	"${1}" = "--usage" -o \
	"${1}" = "--help" -o \
	"${2}" = "-h" -o \
	"${2}" = "-u" -o \
	"${2}" = "--usage" -o \
	"${2}" = "--help" \
	]
then
	echo
	echo "--------"
	echo "${0} [PARTITION_MOUNTPOINT] [DUET_BUILD]"
	echo "--------"
	echo "Example : ${0} /media/EFI_DUET UDK_X64"
	echo "--------"
	echo "The possible arguments for DUET_BUILD are UDK_X64 and EDK_UEFI64 (in CAPS)."
	echo "--------"
	echo "You must run this script as root."
	echo "--------"
	echo
	PROCESS_CONTINUE=FALSE
fi


if [ "${PROCESS_CONTINUE}" = "TRUE" ]
then
	### check for root
	if ! [ ${UID} -eq 0 ]; then 
		echo "ERROR: Please run as root user!"
		exit 1
	fi
	
	if [ "${2}" = "" ]
	then
		echo "DUET_BUILD not defined"
	fi
fi

EFI_DUET_MP="${1}"
DUET_BUILD="${2}"

PROCESSOR="X64"

[ "${DUET_BUILD}" = "UDK_X64" ] && SHELL_DIR="${EFI_DUET_DIR}/Shell/UDK_X64/"

[ "${DUET_BUILD}" = "EDK_UEFI64" ] && SHELL_DIR="${EFI_DUET_DIR}/Shell/EDK_X64/"

EFILDR_DIR="${EFI_DUET_DIR}/Efildr/${DUET_BUILD}/"
EXTRAS_DIR="${EFI_DUET_DIR}/Extras/${PROCESSOR}/"

if [ "${PROCESS_CONTINUE}" = TRUE ]
then
	echo
	echo "--------"
	echo "PARTITION MOUNTPOINT = ${EFI_DUET_MP}"
	echo
	echo "PARTITION FILESYSTEM = FAT32"
	echo
	echo "UEFI-DUET FIRMWARE BUILD = ${DUET_BUILD}"
	echo "--------"
	echo
	
	set -x -e
	
	cp --verbose "${EFILDR_DIR}/Efildr20" "${EFI_DUET_MP}/EFILDR20"
	# cp --verbose "${EFILDR_DIR}"/*.fv "${EFI_DUET_MP}/"
	
	cp --verbose "${SHELL_DIR}/LoadFv.efi" "${EFI_DUET_MP}/LoadFv.efi" || true
	cp --verbose "${SHELL_DIR}/DumpBs.efi" "${EFI_DUET_MP}/DumpBs.efi" || true
	
	mkdir -p "${EFI_DUET_MP}/efi/Shell"
	cp --verbose "${SHELL_DIR}/Shell_Full.efi" "${EFI_DUET_MP}/efi/Shell/Shell.efi"
	
	mkdir -p "${EFI_DUET_MP}/efi/extras"
	cp --verbose "${EXTRAS_DIR}"/*.efi "${EFI_DUET_MP}/efi/extras/" || true
	
	set +x +e
	
	echo "--------"
	echo "DUET ${DUET_BUILD} files have been copied to the FAT32 PARTITION successfully"
	echo "--------"
	
fi

unset WD
unset EFI_DUET_DIR
unset EFI_DUET_MP
unset DUET_BUILD
unset PROCESSOR
unset SHELL_DIR
unset EFILDR_DIR
unset EXTRAS_DIR
unset PROCESS_CONTINUE
