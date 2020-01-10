function Get-DriveLetter {

<#
.SYNOPSIS
Retrieves the \DosDevices\ registry information on a local computer from 
HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices
.DESCRIPTION
Get-DriveLetter parses the mounted devices registry (HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices) on the 
local computer for every \DosDevices\ entry.
Retrieves the data for each entry and translates the data into Ascii text.
.EXAMPLE
Get-DriveLetter

VolumeName     VolumeLetter AsciiData                                                      
----------     ------------ ---------                                                      
\DosDevices\C: C:           DMIO:ID:ªÄîmóK¤O@5yä                                       
\DosDevices\D: D:           DMIO:ID:¬?iBôGè_87                                       
\DosDevices\E: E:           Ö`é                                                          
\DosDevices\F: F:           :0ð                                                         
\DosDevices\G: G:           \??\SCSI#CdRom&Ven_DVD+R#RW&Prod_DX042D#4&17780f2c&0&050000#...
\DosDevices\H: H:           _??_USBSTOR#Disk&Ven_SanDisk&Prod_Cruzer_Glide&Rev_1.00#4C53...
\DosDevices\I: I:           DMIO:ID:5ÜmæBÎD®¡izm'                           
\DosDevices\J: J:           _??_USBSTOR#Disk&Ven_&Prod_USB_DISK_2.0&Rev_PMAP#C70049CB085...
#>

    $mountedDevicesPath = "HKLM:\SYSTEM\MountedDevices"
    $mountedDevices = Get-ItemProperty $mountedDevicesPath

    $drives = $mountedDevices | Get-Member | Select-Object -Property Name | 
              Where-Object -Property Name -Match "\\DosDevices\\\w:"

    foreach ($drive in $drives) {
        
        $driveName = $drive.Name
        $driveLetter = $driveName.Split('\')

        $decimalData = $mountedDevices."$driveName"
        
        #convert decimal data to Hexadecimal
        $hexadecimalData = $decimalData | foreach {"{0:x}" -f $_}
        $formatHex = ""
        foreach ($hexData in $hexadecimalData) {
            if ($hexData -ne 0) {
                $formatHex = $formatHex + " " + $hexData
            }
        }
        $hexTrim = $formatHex.Trim()
        $hexArraySplit = $hexTrim.Split(' ')
        
        #convert Hexadecimal data to Ascii
        $hexToAscii = $hexArraySplit | ForEach-Object {[char][byte]"0x$_"}
        $asciiString = $hexToAscii -join ""
        
        #create object properties
        $props = @{'VolumeName'=$driveName;
                   'DecimalData'=($decimalData -join '' + ' ');
                   'HexadecimalData'=($hexadecimalData -join '' + ' ');
                   'VolumeLetter'=$driveLetter[2];
                   'AsciiData'=$asciiString;
                   'RegistryPath'=$mountedDevicesPath;}

        #add properties to object
        $obj = New-Object -TypeName PSObject -Property $props
        $obj.PSObject.TypeNames.Insert(0,'AdamInfoSec.RegistryInfo')
        Write-Output $obj
    }
}