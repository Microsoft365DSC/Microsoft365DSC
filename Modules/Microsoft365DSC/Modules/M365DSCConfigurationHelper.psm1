<#
.SYNOPSIS
    Get the evaluation rules for guarding a given configuration.

.DESCRIPTION
    This function will return all the evaluation rules for a given configuration either as a new configuration file or as a list of rules that can be used in a configuration to guard the resources.

.PARAMETER ConfigurationPath
    The path to the configuration file.

.PARAMETER OutputPath
    The path to the output file. If not provided, the function will return the evaluation rules as a string.

.PARAMETER ConnectionMode
    The connection mode to use for the evaluation rules. This parameter is mandatory and must be one of the following values:
    - ServicePrincipalWithThumbprint
    - ServicePrincipalWithSecret
    - ServicePrincipalWithPath
    - CredentialsWithTenantId
    - CredentialsWithApplicationId
    - Credentials
    - ManagedIdentity

.OUTPUTS
    If OutputPath is provided, the function will create a new configuration file with the evaluation rules. If OutputPath is not provided, the function will return the evaluation rules as a string.
    The returned rules reference the variables an exported configuration defines: $CredsCredential for the Credentials* modes and $CredsCertificatePassword for ServicePrincipalWithPath.

.EXAMPLE
    PS> Get-M365DSCEvaluationRulesForConfiguration -ConfigurationPath 'C:\DSC\M365TenantConfig.ps1' -ConnectionMode 'ServicePrincipalWithThumbprint' -OutputPath 'C:\DSC\EvaluationRules.ps1'

.FUNCTIONALITY
    Public
#>
function Get-M365DSCEvaluationRulesForConfiguration
{
    [CmdletBinding(DefaultParameterSetName = 'Plaintext')]
    [OutputType([System.String], ParameterSetName = 'Plaintext')]
    [OutputType([System.Void], ParameterSetName = 'Configuration')]
    param (
        [Parameter(ParameterSetName = 'Configuration', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Plaintext', Mandatory = $true)]
        [System.String]
        $ConfigurationPath,

        [Parameter(ParameterSetName = 'Configuration', Mandatory = $true)]
        [System.String]
        $OutputPath,

        [Parameter(ParameterSetName = 'Configuration', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Plaintext', Mandatory = $true)]
        [ValidateSet('ServicePrincipalWithThumbprint', 'ServicePrincipalWithSecret', 'ServicePrincipalWithPath', 'CredentialsWithTenantId', 'CredentialsWithApplicationId', 'Credentials', 'ManagedIdentity')]
        [System.String]
        $ConnectionMode
    )

    $configurationAsObject = ConvertTo-DSCObject -Path $ConfigurationPath

    $groupCondition = {
        $_.ResourceName
    }

    $groupedObjects = $configurationAsObject | Group-Object $groupCondition

    $M365DSCRuleEvaluationBlock = @'
    # region Evaluation Rules
    # This block contains the evaluation rules for the configuration.
    # It is used to guard the resources in the configuration.
    <INSERT_RULES_HERE>
    # endregion
'@

    switch ($ConnectionMode)
    {
        'ServicePrincipalWithThumbprint'
        {
            $authentication = @"
        ApplicationId           = `$ConfigurationData.NonNodeData.ApplicationId
        TenantId                = `$ConfigurationData.NonNodeData.OrganizationName
        CertificateThumbprint   = `$ConfigurationData.NonNodeData.CertificateThumbprint
"@
        }
        'ServicePrincipalWithSecret'
        {
            $authentication = @"
        ApplicationId           = `$ConfigurationData.NonNodeData.ApplicationId
        TenantId                = `$ConfigurationData.NonNodeData.OrganizationName
        ApplicationSecret       = New-Object System.Management.Automation.PSCredential ('ApplicationSecret', (ConvertTo-SecureString `$ConfigurationData.NonNodeData.ApplicationSecret -AsPlainText -Force))
"@
        }
        'ServicePrincipalWithPath'
        {
            $authentication = @"
        ApplicationId           = `$ConfigurationData.NonNodeData.ApplicationId
        TenantId                = `$ConfigurationData.NonNodeData.OrganizationName
        CertificatePath         = `$ConfigurationData.NonNodeData.CertificatePath
        CertificatePassword     = `$CredsCertificatePassword
"@
        }
        'CredentialsWithTenantId'
        {
            $authentication = @"
        Credential              = `$CredsCredential
        TenantId                = `$ConfigurationData.NonNodeData.OrganizationName
"@
        }
        'CredentialsWithApplicationId'
        {
            $authentication = @"
        Credential              = `$CredsCredential
        ApplicationId           = `$ConfigurationData.NonNodeData.ApplicationId
        TenantId                = `$ConfigurationData.NonNodeData.OrganizationName
"@
        }
        'ManagedIdentity'
        {
            $authentication = @"
        ManagedIdentity         = `$true
"@
        }
        'Credentials'
        {
            $authentication = @"
        Credential              = `$CredsCredential
"@
        }
    }

    $M365DSCRuleEvaluationResourceBlock = @'
    M365DSCRuleEvaluation '<ResourceName>'
    {
        ResourceTypeName        = '<ResourceName>'
        RuleDefinition          = "*"
        AfterRuleCountQuery     = "-eq <Count>"
<Authentication>
    }
'@

    $resultConfiguration = @()
    foreach ($group in $groupedObjects)
    {
        $resultConfiguration += $M365DSCRuleEvaluationResourceBlock.Replace('<ResourceName>', $group.Name).Replace('<Count>', [System.String]$group.Count).Replace('<Authentication>', $authentication)
    }

    $M365DSCRuleEvaluationString = $M365DSCRuleEvaluationBlock.Replace('<INSERT_RULES_HERE>', ($resultConfiguration -join "`n"))

    if ($PSCmdlet.ParameterSetName -eq 'Configuration')
    {
        if (-not (Test-Path -Path $OutputPath))
        {
            New-Item -Path $OutputPath -ItemType File -Force | Out-Null
        }

        # Declare and resolve the PSCredential the rule blocks reference, the same way exported configurations do.
        $parameterName = $null
        switch ($ConnectionMode)
        {
            'ServicePrincipalWithPath'
            {
                $parameterName = 'CertificatePassword'
                $variableName = 'CredsCertificatePassword'
                $promptMessage = 'Certificate Password'
            }
            { $_ -in 'Credentials', 'CredentialsWithTenantId', 'CredentialsWithApplicationId' }
            {
                $parameterName = 'Credential'
                $variableName = 'CredsCredential'
                $promptMessage = 'Credentials'
            }
        }

        $scriptParameters = ''
        $configurationParameters = ''
        $credentialResolution = ''
        $launchArguments = ''
        if ($null -ne $parameterName)
        {
            $scriptParameters = "            [Parameter()]`n            [System.Management.Automation.PSCredential]`n            `$$parameterName"
            $configurationParameters = "                [Parameter()]`n                [System.Management.Automation.PSCredential]`n                `$$parameterName"
            $credentialResolution = @"
            if (`$null -eq `$$parameterName)
            {
                `$$variableName = Get-Credential -Message "$promptMessage"
            }
            else
            {
                `$$variableName = `$$parameterName
            }

"@
            $launchArguments = " -$parameterName `$$parameterName"
        }

        $DSCString = @"
        # Generated with Microsoft365DSC
        # For additional information on how to use Microsoft365DSC, please visit https://aka.ms/M365DSC
        param (
$scriptParameters
        )

        Configuration M365TenantConfig
        {
            param (
$configurationParameters
            )

$credentialResolution
            `$OrganizationName = `$ConfigurationData.NonNodeData.OrganizationName

            Import-DscResource -ModuleName 'Microsoft365DSC'

            Node localhost
            {
               <Instances>
            }
        }

        M365TenantConfig -ConfigurationData .\ConfigurationData.psd1$launchArguments
"@

        $M365DSCRuleEvaluationString = $DSCString.Replace('<Instances>', $M365DSCRuleEvaluationString)

        $M365DSCRuleEvaluationString | Out-File -FilePath $OutputPath
    }
    else
    {
        return $M365DSCRuleEvaluationString
    }
}

Export-ModuleMember -Function Get-M365DSCEvaluationRulesForConfiguration
