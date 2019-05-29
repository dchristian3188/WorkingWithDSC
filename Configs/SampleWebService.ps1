Configuration WebApp1WebSite
{
    Import-DscResource -ModuleName xWebAdministration
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

        xWebAppPool WebApp1AppPool
        {
            Name      = 'WebApp1'
            startMode = 'AlwaysRunning'
            State     = 'Started'
            DependsOn = '[WindowsFeature]WebServer'
        }

        xWebsite WebApp1WebSite
        {
            Name            = 'WebApp1'
            State           = 'Started'
            PhysicalPath    = 'C:\WebApp1'
            ApplicationPool = 'WebApp1'
            DependsOn       = "[xWebAppPool]WebApp1AppPool"
        }
    }
}
