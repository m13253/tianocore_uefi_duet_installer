@set UEFI_DUET=%CD%

@set DUET_BUILD=%2
@set EFI_BOOT_DISK=%1
@set DISK_LABEL=UEFI_DUET

set PROCESSOR=X64

@set WIN_BIN_DIR=%UEFI_DUET%\Windows_Binaries
@set BOOTSECTOR_BIN_DIR=%UEFI_DUET%\BootSector
@set EFILDR_DIR=%UEFI_DUET%\Efildr\%DUET_BUILD%
@set SHELL_DIR=%UEFI_DUET%\Shell
@set EXTRAS_DIR=%UEFI_DUET%\Extras\%PROCESSOR%
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
@copy %BOOTSECTOR_BIN_DIR%\bs32.com %BOOTSECTOR_BIN_DIR%\bs32.com1
@echo --------
@%WIN_BIN_DIR%\Genbootsector.exe  --verbose -i %EFI_BOOT_DISK% -o Usbbs32.com
@echo --------
@%WIN_BIN_DIR%\Bootsectimage.exe  --verbose -g Usbbs32.com %BOOTSECTOR_BIN_DIR%\bs32.com1 -f 
@echo --------
@del Usbbs32.com
@%WIN_BIN_DIR%\Genbootsector.exe  --verbose -o %EFI_BOOT_DISK% -i %BOOTSECTOR_BIN_DIR%\bs32.com1 
@echo --------
@%WIN_BIN_DIR%\Genbootsector.exe  --verbose --mbr -o %EFI_BOOT_DISK% -i %BOOTSECTOR_BIN_DIR%\Mbr.com 
@echo --------
@del %BOOTSECTOR_BIN_DIR%\bs32.com1
@echo Done.
@echo PLEASE UNPLUG USB, THEN PLUG IT AGAIN and PROCEED WITH STEP 2
@echo -------- 
@goto end  

:CreateUSB_FAT32_step2
@copy %EFILDR_DIR%\EfiLdr20 %EFI_BOOT_DISK%\Efildr20 /y
@mkdir %EFI_BOOT_DISK%\EFI
@mkdir %EFI_BOOT_DISK%\EFI\tools
@copy %SHELL_DIR%\*.efi %EFI_BOOT_DISK%\EFI\tools\ /y
@echo --------
@goto Files

:Files
@mkdir %EFI_BOOT_DISK%\EFI\tools\extras
@copy %EXTRAS_DIR%\*.efi %EFI_BOOT_DISK%\EFI\tools\extras
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
@echo Step 2 : CreateUSB.bat [Drive_Letter]: [DUET_BUILD]
@echo Example - Step 2 : CreateUSB.bat D: UDK_X64
@echo --------     
@echo The possible arguments for DUET_BUILD are  UDK_X64 and EDK_UEFI64 (in CAPS).
@echo --------     

:end
@echo on
