@set EFI_DUET=%CD%

@set DUET_BUILD=%2
@set EFI_BOOT_DISK=%1
@set DISK_LABEL=EFI_DUET

set PROCESSOR=X64

@if "%2"=="EDK_UEFI64" set SHELL_DIR=%EFI_DUET%\Shell\EDK_X64
@if "%2"=="EDK2_X64" set SHELL_DIR=%EFI_DUET%\Shell\EDK2_X64

@set WIN_BIN_DIR=%EFI_DUET%\Win_Bin
@set BOOTSECTOR_BIN_DIR=%EFI_DUET%\BootSector
@set EFILDR_DIR=%EFI_DUET%\Efildr\%DUET_BUILD%
@set Extras_DIR=%EFI_DUET%\Extras\%PROCESSOR%
@echo on

@if "%1"=="" goto Help
@goto DUET_Details

:DUET_Details
@echo --------
@echo Tianocore-UEFI-DUET FIRMWARE ARCH = %PROCESSOR%
@echo Tianocore-UEFI-DUET FIRMWARE BUILD = %2 		              
@echo USB FLASH DRIVE = %1
@echo USB FLASH DRIVE FILESYSTEM = FAT32
@echo --------
@if "%2"=="" goto CreateUSB_FAT32
@goto CreateUSB_FAT32_step2

:CreateUSB_FAT32
@echo Creating Tianocore UEFI DUET USB Boot disk...
@echo --------
@echo Formatting %EFI_BOOT_DISK% as FAT32...
@echo.> FormatCommandInput.txt
@format /FS:FAT32 /v:%DISK_LABEL% /q %EFI_BOOT_DISK% < FormatCommandInput.txt > NUL
@del FormatCommandInput.txt
@echo --------
@echo %EFI_BOOT_DISK% Formatting Complete...
@echo --------
@echo Setting up FAT32 boot sector ...
@echo --------
@copy %BOOTSECTOR_BIN_DIR%\Bs32.com %BOOTSECTOR_BIN_DIR%\Bs32.com1
@echo --------
@%WIN_BIN_DIR%\Genbootsector.exe  --verbose -i %EFI_BOOT_DISK% -o UsbBs32.com
@echo --------
@%WIN_BIN_DIR%\Bootsectimage.exe  --verbose -g UsbBs32.com %BOOTSECTOR_BIN_DIR%\Bs32.com1 -f 
@echo --------
@del UsbBs32.com
@%WIN_BIN_DIR%\Genbootsector.exe  --verbose -o %EFI_BOOT_DISK% -i %BOOTSECTOR_BIN_DIR%\Bs32.com1 
@echo --------
@%WIN_BIN_DIR%\Genbootsector.exe  --verbose --mbr -o %EFI_BOOT_DISK% -i %BOOTSECTOR_BIN_DIR%\Mbr.com 
@echo --------
@del %BOOTSECTOR_BIN_DIR%\Bs32.com1
@echo Done.
@echo PLEASE UNPLUG USB, THEN PLUG IT AGAIN and PROCEED WITH STEP 2
@echo -------- 
@goto end  

:CreateUSB_FAT32_step2
@copy %EFILDR_DIR%\EfiLdr20 %EFI_BOOT_DISK%
@copy %SHELL_DIR%\LoadFv.efi %EFI_BOOT_DISK%\
@copy %SHELL_DIR%\DumpBs.efi %EFI_BOOT_DISK%\
@copy %EFILDR_DIR%\*.fv %EFI_BOOT_DISK%\
@mkdir %EFI_BOOT_DISK%\efi
@mkdir %EFI_BOOT_DISK%\efi\Shell
@copy %SHELL_DIR%\Shell_Full.efi %EFI_BOOT_DISK%\efi\Shell\Shell.efi /y
@echo --------
@goto Files

:Files
@mkdir %EFI_BOOT_DISK%\efi\extras
@copy %Extras_DIR%\*.efi %EFI_BOOT_DISK%\efi\extras\
@echo -------- 
@echo Files have been copied to the USB flash drive successfully
@echo Tianocore UEFI DUET FAT32 %DUET_BUILD% Build Done!
@echo -------- 
@goto end

:Help
@echo --------     
@echo Usage : CreateUSB.bat Drive_Letter:
@echo Example : CreateUSB.bat D:
@echo --------     
@echo This command will format your USB drive to FAT32 filesystem, set up the MBR boot code and the FAT32 bootsector.
@echo --------     
@echo Safely Remove and replug the USB flash drive and then proceed to step 2 -
@echo --------     
@echo Step 2 : CreateUSB.bat Drive_Letter: [DUET_BUILD]
@echo Example - Step 2 : CreateUSB.bat D: EDK2_X64
@echo --------     
@echo The possible arguments for DUET_BUILD are  EDK2_X64 and EDK_UEFI64 .
@echo --------     

:end
@echo on
