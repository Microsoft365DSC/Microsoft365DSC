using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADClaimsMappingPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('A string collection containing a JSON string that defines the rules and settings for a policy. The syntax for the definition differs for each derived policy type. Required.')]
    [MSFT_AADClaimsMappingPolicyDefinition[]] $Definition

    [DscProperty()]
    [System.ComponentModel.Description('If set to true, activates this policy. There can be many policies for the same policy type, but only one can be activated as the organization default. Optional, default value is false.')]
    [System.Nullable[System.Boolean]] $IsOrganizationDefault

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name for this policy. Required.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [AADClaimsMappingPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADClaimsMappingPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Azure AD Claims Mapping Policy for DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                $getValue = Get-MgBetaPolicyClaimMappingPolicy -ClaimsMappingPolicyId $this.Id -ErrorAction SilentlyContinue

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Claims Mapping Policy with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaPolicyClaimMappingPolicy `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Claims Mapping Policy with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Azure AD Claims Mapping Policy with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            $complexDefinition = @()
            foreach ($getDefinitionJson in $getValue.Definition)
            {
                $getDefinition = ($getDefinitionJson | ConvertFrom-Json)
                $ClaimsSchema = @()
                foreach ($claimschema in $getDefinition.ClaimsMappingPolicy.ClaimsSchema)
                {
                    $ClaimsSchema += @{
                        Source        = $claimschema.Source
                        Id            = $claimschema.Id
                        SamlClaimType = $claimschema.SamlClaimType
                    }
                }

                $ClaimsTransformation = @()
                foreach ($claimtransformation in $getDefinition.ClaimsMappingPolicy.ClaimsTransformation)
                {
                    $inputparams = @()
                    foreach ($inputparam in $claimtransformation.InputParameters)
                    {
                        $inputparams += @{
                            Value    = $inputparam.Value
                            Id       = $inputparam.Id
                            DataType = $inputparam.DataType
                        }
                    }

                    $outputClaimsObj = @()
                    foreach ($outclaim in $claimtransformation.OutputClaims)
                    {
                        $outputClaimsObj += @{
                            ClaimTypeReferenceId    = $outclaim.ClaimTypeReferenceId
                            TransformationClaimType = $outclaim.TransformationClaimType
                        }
                    }
                    $ClaimsTransformation += @{
                        Id                   = $claimtransformation.Id
                        TransformationMethod = $claimtransformation.TransformationMethod
                        InputParameters      = $inputparams
                        OutputClaims         = $outputClaimsObj
                    }
                }

                $complexDefinition += @{
                    ClaimsMappingPolicy = @{
                        Version              = $getDefinition.ClaimsMappingPolicy.Version
                        IncludeBasicClaimSet = [bool]$getDefinition.ClaimsMappingPolicy.IncludeBasicClaimSet
                        ClaimsSchema         = $ClaimsSchema
                        ClaimsTransformation = $ClaimsTransformation
                    }
                }
            }

            $results = @{
                #region resource generator code
                Definition            = $complexDefinition
                IsOrganizationDefault = $getValue.IsOrganizationDefault
                DisplayName           = $getValue.DisplayName
                Id                    = $getValue.Id
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                #endregion
            }

            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting the Azure AD Claims Mapping Policy for DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Azure AD Claims Mapping Policy with DisplayName {$($this.DisplayName)}"

            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null

            $complexDefinitions = $createParameters.Definition
            $createParameters.Remove('Definition') | Out-Null
            $definitions = @()
            foreach ($definition in $complexDefinitions)
            {
                $definitions += ConvertTo-Json -InputObject $definition -Depth 10 -Compress
            }
            $createParameters.Definition = $definitions

            $policy = New-MgBetaPolicyClaimMappingPolicy -BodyParameter $createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Claims Mapping Policy with Id {$($currentInstance.Id)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null

            $complexDefinitions = $updateParameters.Definition
            $updateParameters.Remove('Definition') | Out-Null
            $definitions = @()
            foreach ($definition in $complexDefinitions)
            {
                $definitions += ConvertTo-Json -InputObject $definition -Depth 10 -Compress
            }
            $updateParameters.Definition = $definitions

            #region resource generator code
            Update-MgBetaPolicyClaimMappingPolicy `
                -ClaimsMappingPolicyId $currentInstance.Id `
                -BodyParameter $updateParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Claims Mapping Policy with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaPolicyClaimMappingPolicy -ClaimsMappingPolicyId $currentInstance.Id
            #endregion
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            #region resource generator code
            [array]$getValue = Get-MgBetaPolicyClaimMappingPolicy `
                -Filter $this.Filter `
                -All `
                -ErrorAction Stop
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                if ($null -ne $Results.Definition)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'ClaimsMappingPolicy'
                            CimInstanceName = 'MSFT_AADClaimsMappingPolicyDefinitionMappingPolicy'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'ClaimsSchema'
                            CimInstanceName = 'AADClaimsMappingPolicyDefinitionMappingPolicyClaimsSchema'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'ClaimsTransformation'
                            CimInstanceName = 'AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformation'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'InputParameters'
                            CimInstanceName = 'AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationInputParameter'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'OutputClaims'
                            CimInstanceName = 'AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationOutputClaims'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Definition `
                        -CIMInstanceName 'MSFT_AADClaimsMappingPolicyDefinition' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Definition = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Definition') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Definition')

                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADClaimsMappingPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADClaimsMappingPolicy])
        {
            return $Values
        }

        $result = [AADClaimsMappingPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADClaimsMappingPolicyDefinition
{
    [DscProperty()]
    [System.ComponentModel.Description('Rules and settings of the policy.')]
    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicy] $ClaimsMappingPolicy
}

class MSFT_AADClaimsMappingPolicyDefinitionMappingPolicy
{
    [DscProperty()]
    [System.ComponentModel.Description('Set value of 1. Required.')]
    [System.Nullable[System.UInt32]] $Version

    [DscProperty()]
    [System.ComponentModel.Description('If set to true, all claims in the basic claim set are emitted in tokens affected by the policy. If set to false, claims in the basic claim set are not in the tokens, unless they are individually added in the ClaimsSchema property of the same policy.')]
    [System.Nullable[System.Boolean]] $IncludeBasicClaimSet

    [DscProperty()]
    [System.ComponentModel.Description('Defines which claims are present in the tokens affected by the policy, in addition to the basic claim set and the core claim set.')]
    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsSchema[]] $ClaimsSchema

    [DscProperty()]
    [System.ComponentModel.Description('Defines common transformations that can be applied to source data, to generate the output data for claims specified in the ClaimsSchema.')]
    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformation[]] $ClaimsTransformation
}

class MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsSchema
{
    [DscProperty()]
    [System.ComponentModel.Description('The source name of the claims schema in the claims mapping policy.')]
    [System.String] $Source

    [DscProperty()]
    [System.ComponentModel.Description('The object identifier of the claims schema in the claims mapping policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The SAML claims type of the claims schema in the claims mapping policy.')]
    [System.String] $SamlClaimType
}

class MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformation
{
    [DscProperty()]
    [System.ComponentModel.Description('The object identifier of the claims transformation in the claims mapping policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The transformation method of the claims transformation in the claims mapping policy.')]
    [System.String] $TransformationMethod

    [DscProperty()]
    [System.ComponentModel.Description('The list of input parameters of the claims transformation in the claims mapping policy.')]
    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationInputParameter[]] $InputParameters

    [DscProperty()]
    [System.ComponentModel.Description('The list of output claims of the claims transformation in the claims mapping policy.')]
    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationOutputClaims[]] $OutputClaims
}

class MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationInputParameter
{
    [DscProperty()]
    [System.ComponentModel.Description('The value of the input parameters of the claims transformation in the claims mapping policy.')]
    [System.String] $Value

    [DscProperty()]
    [System.ComponentModel.Description('The object identifier of the input parameters of the claims transformation in the claims mapping policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The data type of the input parameters of the claims transformation in the claims mapping policy.')]
    [System.String] $DataType
}

class MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationOutputClaims
{
    [DscProperty()]
    [System.ComponentModel.Description('The claim type reference ID of the output claims of the claims transformation in the claims mapping policy.')]
    [System.String] $ClaimTypeReferenceId

    [DscProperty()]
    [System.ComponentModel.Description('The transformation type of the output claims of the claims transformation in the claims mapping policy.')]
    [System.String] $TransformationClaimType
}
