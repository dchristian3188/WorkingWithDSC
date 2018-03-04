Configuration ResourceExample
{

    node 'localhost'
    {
        File HelloWorld
        {
            DestinationPath = 'C:\DSCExample.txt'
            Contents        = 'Hello World for DSC!'
            Ensure          = 'Present'
        }
    }
}

ResourceExample -OutputPath C:\PS
Start-DscConfiguration -Force -Wait -Verbose -Path C:\PS

#List All of your resources
Get-DSCResource 

#Information About a Specific resource
Get-DSCResource -Name xService -Syntax

