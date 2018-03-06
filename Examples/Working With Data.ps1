#HardCoded DC
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
            Name        = "DC02"
            Description = "Second Domain Controller"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = '172.31.16.10', '172.31.16.11'
            InterfaceAlias = 'Ethernet 2'
            AddressFamily  = 'IPv4'
        }

        File ADFiles            
        {            
            DestinationPath = 'C:\NTDS'            
            Type            = 'Directory'            
            Ensure          = 'Present'            
        }            
                    
        WindowsFeature ADDSInstall             
        {             
            Ensure = "Present"             
            Name   = "AD-Domain-Services"             
        }            
            
        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name   = "RSAT-ADDS"             
        }
        
                
        xWaitForADDomain SocalPosh
        {
            DomainName           = "socalpowershell.local"
            DomainUserCredential = $domainCred
            RetryCount           = $Node.RetryCount
            RetryIntervalSec     = $Node.RetryIntervalSec
            DependsOn            = "[WindowsFeature]ADDSInstall", "[xComputer]DCName"
        }

        xADDomainController NewDC
        {
            DomainName                    = "socalpowershell.local"
            DomainAdministratorCredential = $domainCred             
            SafemodeAdministratorPassword = $domainCred            
            DatabasePath                  = 'C:\NTDS'            
            LogPath                       = 'C:\NTDS'            
            DependsOn                     = "[WindowsFeature]ADDSInstall", "[File]ADFiles", "[User]LocalAdmin", "[xComputer]DCName", "[xDnsServerAddress]DnsServerAddress"
        }           
    }             
}            



#Using Configuration Data
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
            Name        = $Node.ComputerName
            Description = $Node.Role
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = $Node.DNSServers
            InterfaceAlias = 'Ethernet 2'
            AddressFamily  = 'IPv4'
        }

        File ADFiles            
        {            
            DestinationPath = 'C:\NTDS'            
            Type            = 'Directory'            
            Ensure          = 'Present'            
        }            
                    
        WindowsFeature ADDSInstall             
        {             
            Ensure = "Present"             
            Name   = "AD-Domain-Services"             
        }            
            
        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name   = "RSAT-ADDS"             
        }
        
                
        xWaitForADDomain SocalPosh
        {
            DomainName           = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount           = $Node.RetryCount
            RetryIntervalSec     = $Node.RetryIntervalSec
            DependsOn            = "[WindowsFeature]ADDSInstall", "[xComputer]DCName"
        }

        xADDomainController NewDC
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred             
            SafemodeAdministratorPassword = $domainCred            
            DatabasePath                  = 'C:\NTDS'            
            LogPath                       = 'C:\NTDS'            
            DependsOn                     = "[WindowsFeature]ADDSInstall", "[File]ADFiles", "[User]LocalAdmin", "[xComputer]DCName", "[xDnsServerAddress]DnsServerAddress"
        }           
    }             
}       

# Configuration Data for AD              
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename             = "localhost"
            ComputerName         = 'DC02'      
            Role                 = "Irvine DC"             
            DomainName           = "socalpowershelldev.local"          
            DNSServers           = ('172.31.16.10', '172.31.16.11')   
            RetryCount           = 20              
            RetryIntervalSec     = 30
            Thumbprint           = 'BB08E3DAA9227667D85988C55C7D6A8711226357'
            CertificateFile      = "C:\SSL\dsc.cer"
            PSDscAllowDomainUser = $true              
        }            
    )             
}             
