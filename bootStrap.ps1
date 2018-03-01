$signedCertParams = @{
    'Subject' = "CN=SoCalPosh DSC Demo"
    'SAN' = "SoCalPosh DSC Demo"
    'EnhancedKeyUsage' = 'Document Encryption'
    'KeyUsage' = 'KeyEncipherment', 'DataEncipherment'
    'FriendlyName' = 'DSC Encryption Certifificate'
    'StoreLocation' = 'LocalMachine'
    'StoreName' = 'My'
    'ProviderName' = 'Microsoft Enhanced Cryptographic Provider v1.0'
    'PassThru' = $true
    'KeyLength' = 2048
    'AlgorithmName' = 'RSA'
    'SignatureAlgorithm' = 'SHA256'
    'Exportable' = $true
}
New-SelfSignedCertificateEx @signedCertParams 

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
Install-Module -Name xActiveDirectory, xComputerManagement -Force

configuration NewDomain             
{             
   param             
    (             
        [Parameter(Mandatory)]            
        [pscredential]
        $domainCred            
    )             
            
    Import-DscResource -ModuleName xActiveDirectory             
    Import-DscResource -ModuleName xComputerManagement
            
    Node localhost             
    { 
        User LocalAdmin
        {
            UserName = 'Administrator'
            Password = $domainCred
        }

        xComputer DCName
        {
            Name = $Node.ComputerName
            Description = $Node.Role
        }

        File ADFiles            
        {            
            DestinationPath = 'C:\NTDS'            
            Type = 'Directory'            
            Ensure = 'Present'            
        }            
                    
        WindowsFeature ADDSInstall             
        {             
            Ensure = "Present"             
            Name = "AD-Domain-Services"             
        }            
            
        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name = "RSAT-ADDS"             
        }            
            
        xADDomain FirstDS             
        {             
            DomainName = $Node.DomainName             
            DomainAdministratorCredential = $domainCred             
            SafemodeAdministratorPassword = $domainCred            
            DatabasePath = 'C:\NTDS'            
            LogPath = 'C:\NTDS'            
            DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles","[User]LocalAdmin","[xComputer]DCName" 
        }            
            
    }             
}            
            
# Configuration Data for AD              
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = "localhost"
            ComputerName = 'DC01'      
            Role = "Primary DC"             
            DomainName = "socalpowershell.local"             
            RetryCount = 20              
            RetryIntervalSec = 30
            Thumbprint = 'BB08E3DAA9227667D85988C55C7D6A8711226357'
            CertificateFile  = "C:\SSL\dsc.cer"
            PSDscAllowDomainUser = $true              
        }            
    )             
}             

[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node localhost
    {
        Settings
        {
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
            CertificateID = 'BB08E3DAA9227667D85988C55C7D6A8711226357'
        }
    }
}

LCMConfig -OutputPath C:\PS

Set-DscLocalConfigurationManager -Path C:\PS -Verbose -Force

$username = 'socalPosh\administrator'
$password = ConvertTo-SecureString -String 'SoCalPosh!' -AsPlainText -Force
$cred = New-Object -TypeName PSCredential -ArgumentList $username,$password


$DSCSPlat = @{
    ConfigurationData = $ConfigData
    OutputPath = 'C:\PS'
    DomainCred = $cred
}
NewDomain @DSCSPlat   
                       
     
Start-DscConfiguration -Wait -Force -Path C:\PS -Verbose       