<#
    Authentication parameters expressed as ordinary property models. Because they travel through
    the same PropertyModel pipeline as schema properties, the class emitter and the test emitter
    need no auth-specific code paths - which is what allows a single resource template to serve
    every workload.
#>

$script:M365DSCWorkloadAuthParameters = @{
    MicrosoftGraph           = @('Credential', 'ApplicationId', 'TenantId', 'ApplicationSecret', 'CertificateThumbprint', 'CertificatePassword', 'CertificatePath', 'ManagedIdentity', 'AccessTokens')
    Intune                   = @('Credential', 'ApplicationId', 'TenantId', 'ApplicationSecret', 'CertificateThumbprint', 'CertificatePassword', 'CertificatePath', 'ManagedIdentity', 'AccessTokens')
    ExchangeOnline           = @('Credential', 'ApplicationId', 'TenantId', 'CertificateThumbprint', 'CertificatePassword', 'CertificatePath', 'ManagedIdentity', 'AccessTokens')
    SecurityComplianceCenter = @('Credential', 'ApplicationId', 'TenantId', 'CertificateThumbprint', 'CertificatePassword', 'CertificatePath', 'AccessTokens')
    MicrosoftTeams           = @('Credential', 'ApplicationId', 'TenantId', 'CertificateThumbprint', 'ManagedIdentity', 'AccessTokens')
    PnP                      = @('Credential', 'ApplicationId', 'TenantId', 'ApplicationSecret', 'CertificateThumbprint', 'CertificatePassword', 'CertificatePath', 'ManagedIdentity', 'AccessTokens')
    PowerPlatforms           = @('Credential', 'ApplicationId', 'TenantId', 'ApplicationSecret', 'CertificateThumbprint', 'ManagedIdentity', 'AccessTokens')
}

$script:M365DSCAuthParameterDefinitions = @{
    Credential            = @{ Type = 'System.Management.Automation.PSCredential'; Description = 'Credentials of the workload''s Admin' }
    ApplicationId         = @{ Type = 'System.String'; Description = 'Id of the Entra ID application to authenticate with.' }
    TenantId              = @{ Type = 'System.String'; Description = 'Id of the Entra ID tenant used for authentication.' }
    ApplicationSecret     = @{ Type = 'System.Management.Automation.PSCredential'; Description = 'Secret of the Entra ID application to authenticate with.' }
    CertificateThumbprint = @{ Type = 'System.String'; Description = 'Thumbprint of the Entra ID application''s authentication certificate to use for authentication.' }
    CertificatePassword   = @{ Type = 'System.Management.Automation.PSCredential'; Description = 'Username can be made up to anything but password will be used for CertificatePassword' }
    CertificatePath       = @{ Type = 'System.String'; Description = 'Path to certificate used in service principal usually a PFX file.' }
    ManagedIdentity       = @{ Type = 'System.Boolean'; Description = 'Managed ID being used for authentication.' }
    AccessTokens          = @{ Type = 'System.String'; Description = 'Access token used for authentication.'; IsArray = $true }
}

# Workload-specific Credential wording, matching the shipped resources.
$script:M365DSCCredentialDescriptions = @{
    MicrosoftGraph           = 'Credentials for the Microsoft Graph delegated permissions.'
    Intune                   = 'Credentials of the Intune Admin'
    ExchangeOnline           = 'Credentials of the Exchange Global Admin'
    SecurityComplianceCenter = 'Credentials of the Global Admin'
    MicrosoftTeams           = 'Credentials of the Teams Admin'
    PnP                      = 'Credentials of the SharePoint Global Admin'
    PowerPlatforms           = 'Credentials of the Power Platform Admin'
}

<#
.SYNOPSIS
    Returns the authentication property models for a workload.
#>
function Get-M365DSCAuthPropertySet
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('ExchangeOnline', 'Intune', 'SecurityComplianceCenter', 'PnP', 'PowerPlatforms', 'MicrosoftTeams', 'MicrosoftGraph')]
        [System.String]
        $Workload
    )

    $models = @()
    foreach ($parameterName in $script:M365DSCWorkloadAuthParameters[$Workload])
    {
        $definition = $script:M365DSCAuthParameterDefinitions[$parameterName]

        $description = $definition.Description
        if ($parameterName -eq 'Credential')
        {
            $description = $script:M365DSCCredentialDescriptions[$Workload]
        }

        $isArray = $false
        if ($definition.ContainsKey('IsArray'))
        {
            $isArray = $definition.IsArray
        }

        $models += New-M365DSCPropertyModel -Name $parameterName `
            -Type $definition.Type `
            -Description $description `
            -IsArray $isArray `
            -IsAuth $true
    }

    return $models
}

<#
.SYNOPSIS
    Returns the Ensure property model.

.PARAMETER ResourceDescriptor
    Specifies the short human descriptor used in the description, e.g. 'policy' or 'group'.
#>
function Get-M365DSCEnsurePropertyModel
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [System.String]
        $ResourceDescriptor = 'resource'
    )

    return New-M365DSCPropertyModel -Name 'Ensure' `
        -Description "Specify if the $ResourceDescriptor should exist." `
        -EnumValues @('Present', 'Absent')
}
