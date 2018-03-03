configuration DscPullServer
{
    param
    (
        [Parameter(Mandatory)]            
        [pscredential]
        $domainCred    
    )

    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource -ModuleName xNetworking

    Node 'localhost'
    {
        xComputer DCName
        {
            Name        = $node.ComputerName
            Description = $node.Role
            DomainName  = $node.DomainName
            Credential  = $domainCred
            DependsOn   = "[xDnsServerAddress]DnsServerAddress"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = $node.DNSServers
            InterfaceAlias = 'Ethernet 2'
            AddressFamily  = 'IPv4'
        }
    }
}

    
# Configuration Data for AD              
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename             = "localhost"
            ComputerName         = 'Web01'      
            Role                 = "My Web Server"             
            DomainName           = "socalpowershell.local"
            DNSServers           = ('172.31.16.10', '172.31.16.11')
            RetryCount           = 20              
            RetryIntervalSec     = 30
            Thumbprint           = 'BB08E3DAA9227667D85988C55C7D6A8711226357'
            CertificateFile      = "C:\SSL\dsc.cer"
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
            ActionAfterReboot  = 'ContinueConfiguration'            
            ConfigurationMode  = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
            CertificateID      = 'BB08E3DAA9227667D85988C55C7D6A8711226357'
        }
    }
}

LCMConfig -OutputPath C:\PS

Set-DscLocalConfigurationManager -Path C:\PS -Verbose -Force

$username = 'SoCalPowerShell\administrator'
$password = ConvertTo-SecureString -String 'SoCalPosh!' -AsPlainText -Force
$cred = New-Object -TypeName PSCredential -ArgumentList $username, $password


$DSCSPlat = @{
    ConfigurationData = $ConfigData
    OutputPath        = 'C:\PS'
    DomainCred        = $cred
}
DscPullServer @DSCSPlat   
                       
Start-DscConfiguration -Wait -Force -Path C:\PS -Verbose       
