#Folder Setup and Ceritifcates
New-Item -Path C:\PS -ItemType Directory -ErrorAction SilentlyContinue
New-Item -Path C:\SSL -ItemType Directory -ErrorAction SilentlyContinue

$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
Invoke-WebRequest -UseBasicParsing -Uri https://github.com/dchristian3188/WorkingWithDSC/raw/master/dscCert.pfx -OutFile C:\SSL\dscCert.pfx -Verbose
Invoke-WebRequest -UseBasicParsing -Uri https://github.com/dchristian3188/WorkingWithDSC/raw/master/dsc.cer -OutFile C:\SSL\dsc.cer -Verbose

Import-PfxCertificate -CertStoreLocation Cert:\LocalMachine\My -FilePath C:\SSL\dscCert.pfx -Password (ConvertTo-SecureString -AsPlainText -Force  'SoCalPosh')

#Required Packages
Install-PackageProvider -Name Nuget -Force
Install-Module -Name xActiveDirectory, xComputerManagement, xNetWorking, xPSDesiredStateConfiguration -Force
