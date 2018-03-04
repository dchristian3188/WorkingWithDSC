configuration Web01Push
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
        xComputer ComputerName
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

    
# Configuration Data Web Push            
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

$username = 'SoCalPowerShell\administrator'
$password = ConvertTo-SecureString -String 'SoCalPosh!' -AsPlainText -Force
$cred = New-Object -TypeName PSCredential -ArgumentList $username, $password


$DSCSPlat = @{
    ConfigurationData = $ConfigData
    OutputPath        = 'C:\PS\Web'
    DomainCred        = $cred
}
Web01Push @DSCSPlat   

Move-Item -Path "C:\PS\Web\localhost.mof" -Destination "C:\PS\Web\172.31.16.20.mof"
Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Verbose -Force
$remoteCred = Get-Credential -UserName Administrator -Message "Remote Cred"
Start-DscConfiguration -Wait -Force -Path C:\PS\Web -Verbose  -ComputerName "172.31.16.20" -Credential $remoteCred
