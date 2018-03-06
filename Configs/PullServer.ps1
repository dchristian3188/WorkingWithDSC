#Required DSC Modules
Install-Module xWebAdministration -Force 


configuration DscPullServer
{
    param
    (
        [Parameter(Mandatory)]            
        [pscredential]
        $domainCred    
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory     
    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xWebAdministration

    Node 'localhost'
    {
        xWaitForADDomain SocalPosh
        {
            DomainName           = "socalpowershell.local"
            DomainUserCredential = $domainCred
            RetryCount           = $Node.RetryCount
            RetryIntervalSec     = $Node.RetryIntervalSec
            DependsOn            = "[xDnsServerAddress]DnsServerAddress"
        }
        
        xComputer ComputerName
        {
            Name        = $node.ComputerName
            Description = $node.Role
            DomainName  = $node.DomainName
            Credential  = $domainCred
            DependsOn   = "[xDnsServerAddress]DnsServerAddress", "[xWaitForADDomain]SocalPosh"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = $node.DNSServers
            InterfaceAlias = 'Ethernet 2'
            AddressFamily  = 'IPv4'
        }

        WindowsFeature DSCServiceFeature
        {
            Ensure = 'Present'
            Name   = 'DSC-Service'
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                   = 'Present'
            EndpointName             = 'PSDSCPullServer'
            Port                     = 443
            PhysicalPath             = "$env:SystemDrive\inetpub\PSDSCPullServer"
            CertificateThumbPrint    = $node.PullServerCert
            ModulePath               = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath        = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                    = 'Started'
            DependsOn                = '[WindowsFeature]DSCServiceFeature'
            UseSecurityBestPractices = $false
        }

        File RegistrationKeyFile
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $node.PullServerRegKey
        }

        # IIS Tools
        WindowsFeature WebManTools
        {
            Name   = 'Web-Mgmt-Tools'
            Ensure = 'Present'
        }
        WindowsFeature WebScriptTools
        {
            Name   = 'Web-Scripting-Tools'
            Ensure = 'Present'
        }

        #Cleanup Default Site
        xWebsite RemoveDefaultSite
        {
            Name      = 'Default Web Site'
            Ensure    = 'Absent'
            DependsOn = '[xDscWebService]PSDSCPullServer'
        }

        xWebAppPool RemoveDefaultPool
        {
            Name      = 'DefaultAppPool'
            Ensure    = 'Absent'
            DependsOn = '[xWebsite]RemoveDefaultSite'
        }

    }
}

    
# Configuration Data for PullServer            
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename             = "localhost"
            ComputerName         = 'DSCPull'      
            Role                 = "DSC Pull Server"             
            DomainName           = "socalpowershell.local"
            DNSServers           = ('172.31.16.10', '172.31.16.11')
            RetryCount           = 20              
            RetryIntervalSec     = 30
            PullServerCert       = 'C1AE6AA67C5F303FB21E7409557415556647EA27'
            PullServerRegKey     = 'a9ce9f62-4027-4f5a-bab4-7db451932f71'
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
    OutputPath        = 'C:\PS'
    DomainCred        = $cred
}
DscPullServer @DSCSPlat   
                       
Start-DscConfiguration -Wait -Force -Path C:\PS -Verbose       
