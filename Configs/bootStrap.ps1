#Folder Setup and Ceritifcates
New-Item -Path C:\PS -ItemType Directory -ErrorAction SilentlyContinue
New-Item -Path C:\SSL -ItemType Directory -ErrorAction SilentlyContinue

$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
Invoke-WebRequest -UseBasicParsing -Uri https://github.com/dchristian3188/WorkingWithDSC/raw/master/dscCert.pfx -OutFile C:\SSL\dscCert.pfx -Verbose
Invoke-WebRequest -UseBasicParsing -Uri https://github.com/dchristian3188/WorkingWithDSC/raw/master/dsc.cer -OutFile C:\SSL\dsc.cer -Verbose
Invoke-WebRequest -UseBasicParsing -Uri https://github.com/dchristian3188/WorkingWithDSC/raw/master/pullServer.pfx -OutFile C:\SSL\PullServer.pfx -Verbose

Import-PfxCertificate -CertStoreLocation Cert:\LocalMachine\My -FilePath C:\SSL\dscCert.pfx -Password (ConvertTo-SecureString -AsPlainText -Force  'SoCalPosh')
Import-PfxCertificate -CertStoreLocation Cert:\LocalMachine\My -FilePath C:\SSL\PullServer.pfx -Password (ConvertTo-SecureString -AsPlainText -Force  'SoCalPosh')
Import-PfxCertificate -CertStoreLocation Cert:\LocalMachine\Root -FilePath C:\SSL\PullServer.pfx -Password (ConvertTo-SecureString -AsPlainText -Force  'SoCalPosh')

#Required Packages
Install-PackageProvider -Name Nuget -Force
Install-Module -Name xActiveDirectory, xComputerManagement, xNetWorking, xPSDesiredStateConfiguration -Force

[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node localhost
    {
        Settings
        {
            ActionAfterReboot  = 'ContinueConfiguration'            
            ConfigurationMode  = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
            CertificateID      = 'BB08E3DAA9227667D85988C55C7D6A8711226357'
        }
    }
}

LCMConfig -OutputPath C:\PS

Set-DscLocalConfigurationManager -Path C:\PS -Verbose -Force

