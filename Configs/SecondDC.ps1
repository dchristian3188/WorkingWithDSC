configuration NewDomainController             
{             
   param             
    (             
        [Parameter(Mandatory)]            
        [pscredential]
        $domainCred            
    )             
            
    Import-DscResource -ModuleName xActiveDirectory             
    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource -ModuleName xNetWorking
            
    Node localhost             
    { 
        User LocalAdmin
        {
            UserName = 'Administrator'
            Password = $domainCred
        }

        xComputer DCName
        {
            Name = "DC02"
            Description = "Second Domain Controller"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = '172.31.16.10','172.31.16.11'
            InterfaceAlias = 'Ethernet 2'
            AddressFamily  = 'IPv4'
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
        
                
        xWaitForADDomain SocalPosh
        {
            DomainName = "socalpowershell.local"
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall","[xComputer]DCName"
        }

        xADDomainController NewDC
        {
            DomainName = "socalpowershell.local"
            DomainAdministratorCredential = $domainCred             
            SafemodeAdministratorPassword = $domainCred            
            DatabasePath = 'C:\NTDS'            
            LogPath = 'C:\NTDS'            
            DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles","[User]LocalAdmin","[xComputer]DCName","[xDnsServerAddress]DnsServerAddress"
        }           
    }             
}            
            
# Configuration Data for AD              
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = "localhost"
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

$username = 'SoCalPowerShell\administrator'
$password = ConvertTo-SecureString -String 'SoCalPosh!' -AsPlainText -Force
$cred = New-Object -TypeName PSCredential -ArgumentList $username,$password


$DSCSPlat = @{
    ConfigurationData = $ConfigData
    OutputPath = 'C:\PS'
    DomainCred = $cred
}
NewDomainController @DSCSPlat   
                       
     
Start-DscConfiguration -Wait -Force -Path C:\PS -Verbose       