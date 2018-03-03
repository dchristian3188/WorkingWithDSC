[DSCLocalConfigurationManager()]
configuration PullClientConfigNames
{
    Node localhost
    {
        Settings
        {
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30
            RebootNodeIfNeeded = $true
        }
        ConfigurationRepositoryWeb CONTOSO-PullSrv
        {
            ServerURL = 'https://dscpull.socalpowershell.local'
            RegistrationKey = 'a9ce9f62-4027-4f5a-bab4-7db451932f71'
            ConfigurationNames = @('Web01')
        }
    }
}
PullClientConfigNames