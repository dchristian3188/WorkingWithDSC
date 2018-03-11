$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
Install-PackageProvider -Name Nuget -Force
Install-Module xWebAdministration, xPSDesiredStateConfiguration -Force 

Configuration SoCalPoshWebSite
{
    Import-DscResource -ModuleName xWebAdministration
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Node localhost
    {
        WindowsFeature WebServer 
        {
            Name   = 'Web-Server'
            Ensure = 'Present'
        }
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

        xWebsite RemoveDefaultSite
        {
            Name      = 'Default Web Site'
            Ensure    = 'Absent'
            DependsOn = '[WindowsFeature]WebServer'
        }

        xWebAppPool RemoveDefaultPool
        {
            Name      = 'DefaultAppPool'
            Ensure    = 'Absent'
            DependsOn = '[xWebsite]RemoveDefaultSite'
        }

        file SoCalPoshRoot
        {
            Type            = 'Directory'
            DestinationPath = 'C:\SoCalPosh'
        }

        xWebAppPool SoCalPoshAppPool
        {
            Name      = 'SoCalPosh'
            startMode = 'AlwaysRunning'
            State     = 'Started'
            DependsOn = '[WindowsFeature]WebServer'
        }

        xWebsite SoCalPoshWebSite
        {
            Name            = 'SoCalPosh'
            State           = 'Started'
            PhysicalPath    = 'C:\SoCalPosh'
            ApplicationPool = 'SoCalPosh'
            DependsOn       = "[file]SoCalPoshRoot", "[xWebAppPool]SoCalPoshAppPool"
        }

        xRemoteFile SoCalPoshHome
        {
            Uri             = 'https://raw.githubusercontent.com/dchristian3188/WorkingWithDSC/master/SoCalPosh.html'
            DestinationPath = 'C:\SoCalPosh\index.html'
            DependsOn       = '[file]SoCalPoshRoot'
        }
    }
}

New-Item -Path C:\PS\Configs -ItemType Directory -ErrorAction SilentlyContinue
SoCalPoshWebSite -OutputPath C:\PS\ -Verbose

Start-DscConfiguration -Verbose -Wait -Path C:\PS -Force