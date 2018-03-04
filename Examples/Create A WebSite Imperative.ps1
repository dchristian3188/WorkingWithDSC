#Install the WindowsFeatures
Install-WindowsFeature -Name Web-Server, Web-Mgmt-Tools, Web-Scripting-Tools

#Load the Web Module
Import-Module -Name WebAdministration

#Cleanup the defaults 
Remove-Website -Name "Default Web Site"
Remove-WebAppPool -Name "DefaultAppPool"

#Create the Web Root
New-Item -ItemType Directory -Path 'C:\SoCalPowerShell' -ErrorAction SilentlyContinue

#Make the App Pool if its not there
if (-not(Test-Path -Path IIS:\AppPools\SoCalPowerShell))
{
    New-WebAppPool -Name 'SoCalPowerShell' -Verbose
}

#Create the Website
$webSite = Get-Website -Name 'SoCalPowerShell'
if ($webSite -eq $null)
{
    New-Website -Name 'SoCalPowerShell' -ApplicationPool 'SoCalPowerShell' -PhysicalPath 'C:\SoCalPowerShell'
}