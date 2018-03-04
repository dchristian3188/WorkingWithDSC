Configuration ResourceExample
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    node 'localhost'
    {
        File HelloWorld
        {
            DestinationPath = 'C:\DSCExample.txt'
            Contents        = 'Hello World for DSC!'
            Ensure          = 'Present'
        }

        Service Spooler
        {
            Name        = 'Spooler'
            State       = 'Running'
            StartupType = 'Automatic'
        }
    }
}

#Generates the Config
ResourceExample -OutputPath C:\PS -Verbose

#Actually Runs the Config
Start-DscConfiguration -Force -Verbose -Wait -Path C:\PS

#Run the Current Configuration
Start-DscConfiguration -Force -Verbose -Wait -UseExisting



#Configs can also take parameters

#Audiosrv - Windows Audio
Configuration ParamaeterExample
{
    param
    (
        [Parameter(Mandatory)]            
        [string]
        $ServiceName    
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    node 'localhost'
    {
        File HelloWorld
        {
            DestinationPath = 'C:\DSCExample.txt'
            Contents        = 'Hello World for DSC!'
            Ensure          = 'Present'
        }

        Service $ServiceName
        {
            Name        = $ServiceName
            State       = 'Running'
            StartupType = 'Automatic'
        }
    }
}

#Run the Configuration
ParamaeterExample -ServiceName Audiosrv -Verbose -OutputPath C:\PS

#Start the configuration
Start-DscConfiguration -Force -Verbose -Wait -Path C:\PS