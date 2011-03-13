This repo contains compiled build of tianocore.sourceforge.net EDK DUET firmware (version that of SVN repository as on 15th September 2010 - revision 236 - seems like EDK development has stopped) and tianocore.sourceforge.net EDK2 DuetPkg firmware (updated too frequently). 
The Bootsector "com" files have been taken from EDK2 DuetPkg. The Win_Bin files have also been taken from EDK2 Basetools. The CreateUSB.cmd script has been taken from EDK2 DuetPkg CreateBootDisk.bat file and modified by me.
The EDK DUET firmware supports only Legacy IDE (or IDE Compatibility) SATA mode, not AHCI mode. EDK2 DUET supports AHCI. 
Both the firmwares do not include support for reading HFS or HFS+ filesystem partitions or for reading Apple Partition Map partitioned disks.
These firmwares do not include support for reading NTFS filesystem partitions from within the firmware itself. They include support only for FAT12, FAT16 and FAT32 filesystems, and support only Master Boot Record and GUID Partition Table partitioned disks. 
They are completely unmodified (in source code level) EDK and EDK2 DUET firmware, so no features were removed, added or modified. 
I use EDK2_X64 DUET Build to boot Windows 7 Professional x86_64 Build 7600 RTM in UEFI-GPT mode in my Dell Studio 1537 Laptop.
This git repo contains 2 builds of DUET firmware :-
EDK_UEFI64 - EDK based UEFI 2.1 x86_64 64-bit
EDK2_X64 - EDK2 based UEFI 2.3 x86_64 64-bit firmware In EDK2_X64 , I replaced DuetPkg/FSVariable/FSVariable.inf with MdeModulePkg/Universal/Variable/EmuRuntimeDxe/EmuVariableRuntimeDxe.inf , otherwise it leads to Windows 7 x64 Blue Screen and Archlinux x86_64 Kernel Panic if FSVariable is used.

The Shell binary included is the Full Shell (not the minimal shell).

To setup the DUET USB flash drive, you will also need to download "HP USB Disk Storage Format Utility" from this link http://www.4shared.com/file/143511399/975c2e6/HP_USB_Disk_Storage_Format_Utility.html . This utility partitions the USB flash device as MBR, as required by DUET. Formatting the USB flash drive directly using Windows will lead to a non-partitioned USB "superfloppy" which will not boot DUET.
To launch EFI/UEFI Shell, go to (after booting DUET USB) :-
Boot Maintenance Manager -> Boot from file -> EFI_DUET -> efi -> Shell -> Shell.efi
For any queries reply in this forum link - http://www.insanelymac.com/forum/index.php?showtopic=186440 or send a mail to (skodabenz) aatt (rocketmail) ddoott (com) .