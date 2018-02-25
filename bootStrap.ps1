$signedCertParams = @{
    'Subject' = "CN=SoCalPosh DSC Demo"
    'SAN' = "SoCalPosh DSC Demo"
    'EnhancedKeyUsage' = 'Document Encryption'
    'KeyUsage' = 'KeyEncipherment', 'DataEncipherment'
    'FriendlyName' = 'DSC Encryption Certifificate'
    'StoreLocation' = 'LocalMachine'
    'StoreName' = 'My'
    'ProviderName' = 'Microsoft Enhanced Cryptographic Provider v1.0'
    'PassThru' = $true
    'KeyLength' = 2048
    'AlgorithmName' = 'RSA'
    'SignatureAlgorithm' = 'SHA256'
    'Exportable' = $true
}
New-SelfSignedCertificateEx @signedCertParams 



Import-PfxCertificate -CertStoreLocation Cert:\LocalMachine\My -FilePath C:\SSL\dscCert.pfx -Password (ConvertTo-SecureString -AsPlainText -Force  'SoCalPosh')

Install-PackageProvider -Name Nuget -Force -Verbose
Install-Module -Name xActiveDirectory -Force -Verbose