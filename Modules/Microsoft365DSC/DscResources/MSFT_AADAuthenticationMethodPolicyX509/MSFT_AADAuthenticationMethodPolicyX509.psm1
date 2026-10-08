using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAuthenticationMethodPolicyX509 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines strong authentication configurations. This configuration includes the default authentication mode and the different rules for strong authentication bindings.')]
    [MSFT_MicrosoftGraphx509CertificateAuthenticationModeConfiguration] $AuthenticationModeConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Defines configuration to allow a group of users to use certificates from specific issuing certificate authorities to successfully authenticate.')]
    [MSFT_MicrosoftGraphx509CertificateAuthorityScope[]] $CertificateAuthorityScopes

    [DscProperty()]
    [System.ComponentModel.Description('Defines fields in the X.509 certificate that map to attributes of the Azure AD user object in order to bind the certificate to the user. The priority of the object determines the order in which the binding is carried out. The first binding that matches will be used and the rest ignored.')]
    [MSFT_MicrosoftGraphx509CertificateUserBinding[]] $CertificateUserBindings

    [DscProperty()]
    [System.ComponentModel.Description('Displayname of the groups of users that are excluded from a policy.')]
    [MSFT_AADAuthenticationMethodPolicyX509ExcludeTarget[]] $ExcludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Displayname of the groups of users that are included from a policy.')]
    [MSFT_AADAuthenticationMethodPolicyX509IncludeTarget[]] $IncludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether issuer(CA) hints are sent back to the client side to filter the certificates shown in certificate picker.')]
    [MSFT_MicrosoftGraphx509CertificateIssuerHintsConfiguration] $IssuerHintsConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('The state of the policy. Possible values are: enabled, disabled.')]
    [ValidateSet('enabled', 'disabled')]
    [System.String] $State

    [DscProperty(Key)]
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

    [AADAuthenticationMethodPolicyX509] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAuthenticationMethodPolicyX509]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Azure AD Authentication Method Policy X509 with Id {$($this.Id)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                $getValue = Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId $this.Id -ErrorAction SilentlyContinue

                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Authentication Method Policy X509 with id {$($this.id)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Azure AD Authentication Method Policy X509 with Id {$($resolvedId)} was found."

            #region resource generator code
            $complexAuthenticationModeConfiguration = [ordered]@{}
            $complexRules = @()
            if ($getValue.authenticationModeConfiguration.rules.Count -gt 0)
            {
                foreach ($currentRules in $getValue.authenticationModeConfiguration.rules)
                {
                    $myRules = [ordered]@{}
                    $myRules.Add('Identifier', $currentRules.identifier)
                    if ($null -ne $currentRules.x509CertificateAuthenticationMode)
                    {
                        $myRules.Add('X509CertificateAuthenticationMode', $currentRules.x509CertificateAuthenticationMode)
                    }
                    if ($null -ne $currentRules.x509CertificateRuleType)
                    {
                        $myRules.Add('X509CertificateRuleType', $currentRules.x509CertificateRuleType)
                    }
                    if ($myRules.values.Where({ $null -ne $_ }).Count -gt 0 -and $myRules.Keys.Length -gt 0)
                    {
                        $complexRules += $myRules
                    }
                }
            }
            $complexAuthenticationModeConfiguration.Add('Rules', $complexRules)

            if ($null -ne $getValue.authenticationModeConfiguration.x509CertificateAuthenticationDefaultMode)
            {
                $complexAuthenticationModeConfiguration.Add('X509CertificateAuthenticationDefaultMode', $getValue.authenticationModeConfiguration.x509CertificateAuthenticationDefaultMode)
            }
            if ($complexAuthenticationModeConfiguration.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexAuthenticationModeConfiguration = $null
            }

            $complexCertificateAuthorityScopes = @()
            foreach ($currentCertificateAuthorityScopes in $getValue.certificateAuthorityScopes)
            {
                $myCertificateAuthorityScopes = [ordered]@{}
                $complexScopeIncludeTargets = @()
                foreach ($currentScopeIncludeTargets in $currentCertificateAuthorityScopes.includeTargets)
                {
                    $myScopeIncludeTargets = [ordered]@{}
                    $myScopeIncludeTargetsName = $null
                    if ($currentScopeIncludeTargets.targetType -eq 'Group')
                    {
                        $myScopeIncludeTargetsName = Get-M365DSCGroupDisplayNameById -GroupId $currentScopeIncludeTargets.id
                    }
                    elseif ($currentScopeIncludeTargets.targetType -eq 'User')
                    {
                        $myScopeIncludeTargetsName = Get-M365DSCUserPrincipalNameById -UserId $currentScopeIncludeTargets.id
                    }
                    if ($null -eq $myScopeIncludeTargetsName)
                    {
                        continue
                    }
                    $myScopeIncludeTargets.Add('Id', $myScopeIncludeTargetsName)

                    if ($null -ne $currentScopeIncludeTargets.targetType)
                    {
                        $myScopeIncludeTargets.Add('TargetType', $currentScopeIncludeTargets.targetType)
                    }

                    if ($myScopeIncludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexScopeIncludeTargets += $myScopeIncludeTargets
                    }
                }
                $myCertificateAuthorityScopes.Add('IncludeTargets', $complexScopeIncludeTargets)
                $myCertificateAuthorityScopes.Add('PublicKeyInfrastructureIdentifier', $currentCertificateAuthorityScopes.publicKeyInfrastructureIdentifier)
                $myCertificateAuthorityScopes.Add('SubjectKeyIdentifier', $currentCertificateAuthorityScopes.subjectKeyIdentifier)
                if ($myCertificateAuthorityScopes.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexCertificateAuthorityScopes += $myCertificateAuthorityScopes
                }
            }

            $complexCertificateUserBindings = @()
            foreach ($currentcertificateUserBindings in $getValue.certificateUserBindings)
            {
                $mycertificateUserBindings = [ordered]@{}
                $mycertificateUserBindings.Add('Priority', $currentcertificateUserBindings.priority)
                $mycertificateUserBindings.Add('UserProperty', $currentcertificateUserBindings.userProperty)
                $mycertificateUserBindings.Add('X509CertificateField', $currentcertificateUserBindings.x509CertificateField)
                if ($mycertificateUserBindings.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexCertificateUserBindings += $mycertificateUserBindings
                }
            }

            Write-Verbose 'Processing ExcludeTargets'
            $complexExcludeTargets = @()
            foreach ($currentExcludeTargets in $getValue.excludeTargets)
            {
                $myExcludeTargets = [ordered]@{}
                if ($currentExcludeTargets.id -ne 'all_users')
                {
                    $myExcludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentExcludeTargets.id
                    if ($null -eq $myExcludeTargetsDisplayName)
                    {
                        continue
                    }
                    $myExcludeTargets.Add('Id', $myExcludeTargetsDisplayName)
                }
                else
                {
                    $myExcludeTargets.Add('Id', $currentExcludeTargets.id)
                }

                if ($null -ne $currentExcludeTargets.targetType)
                {
                    $myExcludeTargets.Add('TargetType', $currentExcludeTargets.targetType)
                }

                if ($myExcludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexExcludeTargets += $myExcludeTargets
                }
            }
            #endregion

            Write-Verbose 'Processing IncludeTargets'
            $complexIncludeTargets = @()
            foreach ($currentIncludeTargets in $getValue.includeTargets)
            {
                $myIncludeTargets = [ordered]@{}
                if ($currentIncludeTargets.id -ne 'all_users')
                {
                    $myIncludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentIncludeTargets.id
                    if ($null -eq $myIncludeTargetsDisplayName)
                    {
                        continue
                    }
                    $myIncludeTargets.Add('Id', $myIncludeTargetsDisplayName)
                }
                else
                {
                    $myIncludeTargets.Add('Id', $currentIncludeTargets.id)
                }

                if ($null -ne $currentIncludeTargets.targetType)
                {
                    $myIncludeTargets.Add('TargetType', $currentIncludeTargets.targetType)
                }

                if ($null -ne $currentIncludeTargets.isRegistrationRequired)
                {
                    $myIncludeTargets.Add('isRegistrationRequired', [Boolean]$currentIncludeTargets.isRegistrationRequired)
                }

                if ($myIncludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexIncludeTargets += $myIncludeTargets
                }
            }
            #region resource generator code
            $complexIssuerHintsConfiguration = [ordered]@{}
            if ($null -ne $getValue.issuerHintsConfiguration.state)
            {
                $complexIssuerHintsConfiguration.Add('State', $getValue.issuerHintsConfiguration.state)
            }
            if ($complexIssuerHintsConfiguration.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexIssuerHintsConfiguration = $null
            }

            #endregion

            $results = @{
                #region resource generator code
                AuthenticationModeConfiguration = $complexAuthenticationModeConfiguration
                CertificateAuthorityScopes      = $complexCertificateAuthorityScopes
                CertificateUserBindings         = $complexCertificateUserBindings
                ExcludeTargets                  = $complexExcludeTargets
                IncludeTargets                  = $complexIncludeTargets
                IssuerHintsConfiguration        = $complexIssuerHintsConfiguration
                State                           = $getValue.State
                Id                              = $getValue.Id
                Ensure                          = 'Present'
                Credential                      = $this.Credential
                ApplicationId                   = $this.ApplicationId
                TenantId                        = $this.TenantId
                ApplicationSecret               = $this.ApplicationSecret
                CertificateThumbprint           = $this.CertificateThumbprint
                CertificatePath                 = $this.CertificatePath
                CertificatePassword             = $this.CertificatePassword
                ManagedIdentity                 = $this.ManagedIdentity
                AccessTokens                    = $this.AccessTokens
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

        Write-Verbose -Message "Setting the Azure AD Authentication Method Policy X509 with Id {$($this.Id)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Authentication Method Policy X509 with Id {$($currentInstance.Id)}"

            $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
            $updateParameters.Remove('Id') | Out-Null

            Update-M365DSCAuthenticationTargets -Targets $updateParameters.ExcludeTargets
            Update-M365DSCAuthenticationTargets -Targets $updateParameters.IncludeTargets
            foreach ($certificateAuthorityScope in $updateParameters.CertificateAuthorityScopes)
            {
                Update-M365DSCAuthenticationTargets -Targets $certificateAuthorityScope.IncludeTargets
            }

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.x509CertificateAuthenticationMethodConfiguration')
            Write-Verbose -Message "Updating with Values: $(Convert-M365DscHashtableToString -Hashtable $updateParameters)"
            Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
                -AuthenticationMethodConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Authentication Method Policy X509 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
                -AuthenticationMethodConfigurationId X509Certificate `
                -ErrorAction Stop | Where-Object -FilterScript { $null -ne $_.Id }
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
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
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
                if ($null -ne $Results.AuthenticationModeConfiguration)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'AuthenticationModeConfiguration'
                            CimInstanceName = 'MicrosoftGraphX509CertificateAuthenticationModeConfiguration'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Rules'
                            CimInstanceName = 'MicrosoftGraphX509CertificateRule'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AuthenticationModeConfiguration `
                        -CIMInstanceName 'MicrosoftGraphx509CertificateAuthenticationModeConfiguration' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AuthenticationModeConfiguration = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AuthenticationModeConfiguration') | Out-Null
                    }
                }
                if ($null -ne $Results.CertificateAuthorityScopes)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'CertificateAuthorityScopes'
                            CimInstanceName = 'MicrosoftGraphx509CertificateAuthorityScope'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'IncludeTargets'
                            CimInstanceName = 'MicrosoftGraphIncludeTarget'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CertificateAuthorityScopes `
                        -CIMInstanceName 'MicrosoftGraphx509CertificateAuthorityScope' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.CertificateAuthorityScopes = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CertificateAuthorityScopes') | Out-Null
                    }
                }
                if ($null -ne $Results.CertificateUserBindings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CertificateUserBindings `
                        -CIMInstanceName 'MicrosoftGraphx509CertificateUserBinding'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.CertificateUserBindings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CertificateUserBindings') | Out-Null
                    }
                }
                if ($null -ne $Results.ExcludeTargets)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ExcludeTargets `
                        -CIMInstanceName 'AADAuthenticationMethodPolicyX509ExcludeTarget'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ExcludeTargets = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ExcludeTargets') | Out-Null
                    }
                }

                if ($null -ne $Results.IncludeTargets)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.IncludeTargets `
                        -CIMInstanceName 'AADAuthenticationMethodPolicyX509IncludeTarget'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.IncludeTargets = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('IncludeTargets') | Out-Null
                    }
                }

                if ($null -ne $Results.IssuerHintsConfiguration)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.IssuerHintsConfiguration `
                        -CIMInstanceName 'MicrosoftGraphx509CertificateIssuerHintsConfiguration'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.IssuerHintsConfiguration = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('IssuerHintsConfiguration') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AuthenticationModeConfiguration', 'CertificateAuthorityScopes', 'CertificateUserBindings', 'ExcludeTargets', 'IncludeTargets', 'IssuerHintsConfiguration')

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

    hidden [AADAuthenticationMethodPolicyX509] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAuthenticationMethodPolicyX509])
        {
            return $Values
        }

        $result = [AADAuthenticationMethodPolicyX509]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphx509CertificateAuthenticationModeConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Rules are configured in addition to the authentication mode to bind a specific x509CertificateRuleType to an x509CertificateAuthenticationMode. For example, bind the policyOID with identifier 1.32.132.343 to x509CertificateMultiFactor authentication mode.')]
    [MSFT_MicrosoftGraphX509CertificateRule[]] $Rules

    [DscProperty()]
    [System.ComponentModel.Description('The type of strong authentication mode. The possible values are: x509CertificateSingleFactor, x509CertificateMultiFactor, unknownFutureValue.')]
    [ValidateSet('x509CertificateSingleFactor', 'x509CertificateMultiFactor', 'unknownFutureValue')]
    [System.String] $X509CertificateAuthenticationDefaultMode
}

class MSFT_MicrosoftGraphx509CertificateAuthorityScope
{
    [DscProperty()]
    [System.ComponentModel.Description('A collection of groups that are enabled to be in scope to use certificates issued by specific certificate authority.')]
    [MSFT_MicrosoftGraphIncludeTarget[]] $IncludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Public Key Infrastructure container object under which the certificate authorities are stored in the Entra PKI based trust store.')]
    [System.String] $PublicKeyInfrastructureIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('Subject Key Identifier that identifies the certificate authority uniquely.')]
    [System.String] $SubjectKeyIdentifier
}

class MSFT_MicrosoftGraphx509CertificateUserBinding
{
    [DscProperty()]
    [System.ComponentModel.Description('The priority of the binding. Azure AD uses the binding with the highest priority. This value must be a non-negative integer and unique in the collection of objects in the certificateUserBindings property of an x509CertificateAuthenticationMethodConfiguration object. Required')]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Defines the Azure AD user property of the user object to use for the binding. The possible values are: userPrincipalName, onPremisesUserPrincipalName, email. Required.')]
    [System.String] $UserProperty

    [DscProperty()]
    [System.ComponentModel.Description('The field on the X.509 certificate to use for the binding. The possible values are: PrincipalName, RFC822Name.')]
    [System.String] $X509CertificateField
}

class MSFT_AADAuthenticationMethodPolicyX509ExcludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD group.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: group and unknownFutureValue.')]
    [ValidateSet('group', 'unknownFutureValue')]
    [System.String] $TargetType
}

class MSFT_AADAuthenticationMethodPolicyX509IncludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD group.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Determines if the user is enforced to register the authentication method.')]
    [System.Nullable[System.Boolean]] $isRegistrationRequired

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: group and unknownFutureValue.')]
    [ValidateSet('group', 'unknownFutureValue')]
    [System.String] $TargetType
}

class MSFT_MicrosoftGraphx509CertificateIssuerHintsConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('The possible values are: disabled, enabled.')]
    [ValidateSet('disabled', 'enabled')]
    [System.String] $State
}

class MSFT_MicrosoftGraphIncludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The ID of the entity targeted.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The kind of entity targeted. The possible values are: user, group.')]
    [ValidateSet('user', 'group')]
    [System.String] $TargetType
}

class MSFT_MicrosoftGraphX509CertificateRule
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The identifier of the X.509 certificate. Required.')]
    [System.String] $Identifier

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of strong authentication mode. The possible values are: x509CertificateSingleFactor, x509CertificateMultiFactor, unknownFutureValue. Required.')]
    [ValidateSet('x509CertificateSingleFactor', 'x509CertificateMultiFactor', 'unknownFutureValue')]
    [System.String] $X509CertificateAuthenticationMode

    [DscProperty()]
    [System.ComponentModel.Description('The type of the X.509 certificate mode configuration rule. The possible values are: issuerSubject, policyOID, unknownFutureValue. Required.')]
    [ValidateSet('issuerSubject', 'policyOID', 'unknownFutureValue')]
    [System.String] $X509CertificateRuleType
}
