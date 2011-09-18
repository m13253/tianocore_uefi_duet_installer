#!/bin/bash

_WD="${PWD}/"
_UEFI_DUET_DIR="${_WD}/"

_SCRIPTNAME="$(basename "${0}")"

_PROCESS_CONTINUE='TRUE'

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
	echo "${_SCRIPTNAME} [PARTITION_MOUNTPOINT] [UEFI_DUET_BUILD]"
	echo "--------"
	echo "Example : ${_SCRIPTNAME} /media/UEFI_DUET UDK_X64"
	echo "--------"
	echo "The possible arguments for UEFI_DUET_BUILD are UDK_X64 and EDK_UEFI64 (in CAPS)."
	echo "--------"
	echo "You must run this script as root."
	echo "--------"
	echo
	_PROCESS_CONTINUE='FALSE'
fi


if [ "${_PROCESS_CONTINUE}" == 'TRUE' ]
then
	### check for root
	if ! [ ${UID} -eq 0 ]; then 
		echo "ERROR: Please run as root user!"
		exit 1
	fi
	
	if [ "${2}" == '' ]
	then
		echo "_UEFI_DUET_BUILD not defined"
		exit 1
	fi
fi

_UEFI_DUET_MP="${1}"
_UEFI_DUET_BUILD="${2}"

_UEFI_PROCESSOR_ARCH="X64"

[ "${_UEFI_DUET_BUILD}" = "UDK_X64" ] && _UEFI_SHELL_DIR="${_UEFI_DUET_DIR}/Shell/UDK_X64/"

[ "${_UEFI_DUET_BUILD}" = "EDK_UEFI64" ] && _UEFI_SHELL_DIR="${_UEFI_DUET_DIR}/Shell/EDK_X64/"

_UEFI_DUET_EFILDR_DIR="${_UEFI_DUET_DIR}/Efildr/${_UEFI_DUET_BUILD}/"
_UEFI_DUET_EXTRAS_DIR="${_UEFI_DUET_DIR}/Extras/${_UEFI_PROCESSOR_ARCH}/"

if [ "${_PROCESS_CONTINUE}" == 'TRUE' ]
then
	echo
	echo "--------"
	echo "PARTITION MOUNTPOINT = ${_UEFI_DUET_MP}"
	echo
	echo "PARTITION FILESYSTEM = FAT32"
	echo
	echo "UEFI-DUET FIRMWARE BUILD = ${_UEFI_DUET_BUILD}"
	echo "--------"
	echo
	
	set -x -e
	
	cp --verbose "${_UEFI_DUET_EFILDR_DIR}/Efildr20" "${_UEFI_DUET_MP}/EFILDR20"
	# cp --verbose "${_UEFI_DUET_EFILDR_DIR}"/*.fv "${_UEFI_DUET_MP}/"
	
	cp --verbose "${_UEFI_SHELL_DIR}/LoadFv.efi" "${_UEFI_DUET_MP}/LoadFv.efi" || true
	cp --verbose "${_UEFI_SHELL_DIR}/DumpBs.efi" "${_UEFI_DUET_MP}/DumpBs.efi" || true
	
	mkdir -p "${_UEFI_DUET_MP}/efi/Shell"
	cp --verbose "${_UEFI_SHELL_DIR}/Shell_Full.efi" "${_UEFI_DUET_MP}/efi/Shell/Shell.efi"
	
	mkdir -p "${_UEFI_DUET_MP}/efi/extras"
	cp --verbose "${_UEFI_DUET_EXTRAS_DIR}"/*.efi "${_UEFI_DUET_MP}/efi/extras/" || true
	
	set +x +e
	
	echo "--------"
	echo "DUET ${_UEFI_DUET_BUILD} files have been copied to the FAT32 PARTITION successfully"
	echo "--------"
	
fi

unset _WD
unset _UEFI_DUET_DIR
unset _UEFI_DUET_MP
unset _UEFI_DUET_BUILD
unset _UEFI_PROCESSOR_ARCH
unset _UEFI_SHELL_DIR
unset _UEFI_DUET_EFILDR_DIR
unset _UEFI_DUET_EXTRAS_DIR
unset _PROCESS_CONTINUE
