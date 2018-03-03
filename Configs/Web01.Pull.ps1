Install-Module xWebAdministration -Force 

Configuration SoCalPoshWebSite
{
    Import-DscResource -ModuleName xWebAdministration
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node localhost
    {
        WindowsFeature WebServer 
        {
            Name = 'Web-Server'
            Ensure = 'Present'
        }
         WindowsFeature WebManTools
         {
             Name = 'Web-Mgmt-Tools'
             Ensure = 'Present'
         }
         WindowsFeature WebScriptTools
         {
             Name = 'Web-Scripting-Tools'
             Ensure = 'Present'
         }

         xWebsite RemoveDefaultSite
         {
             Name = 'Default Web Site'
             Ensure = 'Absent'
             DependsOn = '[WindowsFeature]WebServer'
         }

         xWebApplication RemoveDefaultPool
         {
             Name = 'DefaultAppPool'
             Ensure = 'Absent'
             DependsOn = '[xWebsite]RemoveDefaultSite'
         }

         file SoCalPoshRoot
         {
             Type = 'Directory'
             DestinationPath = 'C:\SoCalPosh'
         }

         xWebAppPool SoCalPoshAppPool
         {
             Name = 'SoCalPosh'
             startMode = 'AlwaysRunning'
             State = 'Started'
             DependsOn = '[WindowsFeature]WebServer'
         }

         xWebsite SoCalPoshWebSite
         {
             Name = 'SoCalPosh'
             State = 'Started'
             PhysicalPath = 'C:\SoCalPosh'
             ApplicationPool = 'SoCalPosh'
             DependsOn = "[file]SoCalPoshRoot","[xWebAppPool]SoCalPoshAppPool"
         }
    }
}

New-Item -Path C:\PS\Configs -ItemType Directory -ErrorAction SilentlyContinue
SoCalPoshWebSite -OutputPath C:\PS\Configs\ -Verbose


Move-Item -Path "C:\PS\Configs\localhost.mof" -Destination "C:\PS\Configs\SoCalPoshWebSite.mof" -Force
Publish-DSCModuleAndMof -Source C:\PS\Configs\ -ModuleNameList 'xWebAdministration' -Verbose