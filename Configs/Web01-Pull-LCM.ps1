[DSCLocalConfigurationManager()]
configuration PullClientConfigNames
{
    Node localhost
    {
        Settings
        {
            RefreshMode          = 'Pull'
            RefreshFrequencyMins = 30
            RebootNodeIfNeeded   = $true
            CertificateID        = 'BB08E3DAA9227667D85988C55C7D6A8711226357'
        }

        ConfigurationRepositoryWeb SoCalPoshPullServer
        {
            ServerURL     = 'https://dscpull.socalpowershell.local/PSDSCPullServer.svc'
            AllowUnsecureConnection = $true
            RegistrationKey = 'a9ce9f62-4027-4f5a-bab4-7db451932f71'
            ConfigurationNames = 'SoCalPoshWebSite'
        }
    }
}
PullClientConfigNames -OutputPath C:\PS -Verbose
Set-DscLocalConfigurationManager -Path C:\PS -Verbose -Force
