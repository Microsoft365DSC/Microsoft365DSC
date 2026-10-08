using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADIdentityB2XUserFlow : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Configuration for enabling an API connector for use as part of the self-service sign-up user flow. You can only obtain the value of this object using Get userFlowApiConnectorConfiguration.')]
    [MSFT_MicrosoftGraphuserFlowApiConnectorConfiguration] $ApiConnectorConfiguration

    [DscProperty(Key)]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The identity providers included in the user flow.')]
    [System.String[]] $IdentityProviders

    [DscProperty()]
    [System.ComponentModel.Description('The user attribute assignments included in the user flow.')]
    [MSFT_MicrosoftGraphuserFlowUserAttributeAssignment[]] $UserAttributeAssignments

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

    [AADIdentityB2XUserFlow] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADIdentityB2XUserFlow]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Azure AD Identity B2X User Flow with Id {$($this.Id)}"

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
                $getValue = Get-MgBetaIdentityB2XUserFlow -B2XIdentityUserFlowId $this.Id -ErrorAction SilentlyContinue
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Azure AD Identity B2 X User Flow with Id {$($this.Id)}"
                return $this.AsResult($nullResult)
            }
            #endregion

            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Azure AD Identity B2 X User Flow with Id {$($resolvedId)} was found"

            #region Get ApiConnectorConfiguration
            $connectorConfiguration = Get-MgBetaIdentityB2XUserFlowApiConnectorConfiguration -B2XIdentityUserFlowId $resolvedId `
                -ExpandProperty 'postFederationSignup,postAttributeCollection'

            $complexApiConnectorConfiguration = @{
                postFederationSignupConnectorName    = $this.GetConnectorName($connectorConfiguration.PostFederationSignup.DisplayName)
                postAttributeCollectionConnectorName = $this.GetConnectorName($connectorConfiguration.PostAttributeCollection.DisplayName)
            }
            #endregion

            #region Get IdentityProviders
            $getIdentityProviders = (Get-MgBetaIdentityB2XUserFlowIdentityProvider -B2XIdentityUserFlowId $resolvedId).id
            if ($getIdentityProviders.Count -eq 0)
            {
                $getIdentityProviders = @()
            }
            #endregion

            $complexUserAttributeAssignments = @()
            $getUserAttributeAssignments = Get-MgBetaIdentityB2XUserFlowUserAttributeAssignment -B2XIdentityUserFlowId $resolvedId -ExpandProperty UserAttribute
            foreach ($getUserAttributeAssignment in $getUserAttributeAssignments)
            {
                $getuserAttributeValues = @()
                foreach ($getUserAttributeAssignmentAttributeValue in $getUserAttributeAssignment.UserAttributeValues)
                {
                    $getuserAttributeValues += @{
                        Name      = $getUserAttributeAssignmentAttributeValue.Name
                        Value     = $getUserAttributeAssignmentAttributeValue.Value
                        IsDefault = $getUserAttributeAssignmentAttributeValue.IsDefault
                    }
                }
                $complexUserAttributeAssignments += @{
                    Id                  = $getUserAttributeAssignment.Id
                    DisplayName         = $getUserAttributeAssignment.DisplayName
                    IsOptional          = $getUserAttributeAssignment.IsOptional
                    UserInputType       = $getUserAttributeAssignment.UserInputType
                    UserAttributeValues = $getuserAttributeValues
                }
            }

            $results = @{
                #region resource generator code
                ApiConnectorConfiguration = $complexApiConnectorConfiguration
                Id                        = $getValue.Id
                IdentityProviders         = $getIdentityProviders
                UserAttributeAssignments  = $complexUserAttributeAssignments
                Ensure                    = 'Present'
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                TenantId                  = $this.TenantId
                ApplicationSecret         = $this.ApplicationSecret
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Azure AD Identity B2 X User Flow with Id {$($this.Id)}"

            #region Create ApiConnectorConfiguration object
            $newApiConnectorConfiguration = @{}
            if (-not [string]::IsNullOrEmpty($this.ApiConnectorConfiguration.postFederationSignupConnectorName))
            {
                $getConnector = Get-MgBetaIdentityApiConnector -Filter "DisplayName eq '$($this.ApiConnectorConfiguration.postFederationSignupConnectorName -replace "'", "''")'"
                $newApiConnectorConfiguration['PostFederationSignup'] = @{
                    'Id' = $getConnector.Id
                }
            }

            if (-not [string]::IsNullOrEmpty($this.ApiConnectorConfiguration.postAttributeCollectionConnectorName))
            {
                $getConnector = Get-MgBetaIdentityApiConnector -Filter "DisplayName eq '$($this.ApiConnectorConfiguration.postAttributeCollectionConnectorName -replace "'", "''")'"
                $newApiConnectorConfiguration['PostAttributeCollection'] = @{
                    'Id' = $getConnector.Id
                }
            }
            #endregion

            $params = @{
                id                        = $this.Id
                userFlowType              = 'signUpOrSignIn'
                userFlowTypeVersion       = 1
                apiConnectorConfiguration = $newApiConnectorConfiguration
            }

            Write-Verbose -Message "Creating instance with:`r`n$(ConvertTo-Json $params -Depth 5)"
            $newObj = New-MgBetaIdentityB2XUserFlow -BodyParameter $params

            #region Add IdentityProvider objects to the newly created object
            foreach ($provider in $this.IdentityProviders)
            {
                $params = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/identityProviders/$($provider)"
                }

                Write-Verbose -Message "Adding the Identity Provider with Id {$provider} to the newly created Azure AD Identity B2X User Flow with Id {$($newObj.Id)}"
                New-MgBetaIdentityB2XUserFlowIdentityProviderByRef -B2XIdentityUserFlowId $newObj.Id -BodyParameter $params
            }
            #endregion

            #region Add UserAtrributeAssignments to the newly created object
            $currentAttributes = Get-MgBetaIdentityB2XUserFlowUserAttributeAssignment -B2XIdentityUserFlowId $newObj.Id | Select-Object -ExpandProperty Id
            $attributesToAdd = $this.UserAttributeAssignments | Where-Object { $_.Id -notin $currentAttributes }

            foreach ($userAttributeAssignment in $attributesToAdd)
            {
                $params = @{
                    displayName         = $userAttributeAssignment.DisplayName
                    isOptional          = $userAttributeAssignment.IsOptional
                    userInputType       = $userAttributeAssignment.UserInputType
                    userAttributeValues = @()
                    userAttribute       = @{
                        id = $userAttributeAssignment.Id
                    }
                }

                foreach ($userAttributeValue in $userAttributeAssignment.UserAttributeValues)
                {
                    $params['userAttributeValues'] += @{
                        'Name'      = $userAttributeValue.Name
                        'Value'     = $userAttributeValue.Value
                        'IsDefault' = $userAttributeValue.IsDefault
                    }
                }

                Write-Verbose -Message "Adding the User Attribute Assignment with Id {$($userAttributeAssignment.Id)} to the newly created Azure AD Identity B2X User Flow with Id {$($newObj.Id)}"
                New-MgBetaIdentityB2XUserFlowUserAttributeAssignment -B2XIdentityUserFlowId $newObj.Id -BodyParameter $params
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Identity B2X User Flow with Id {$($currentInstance.Id)}"

            #region Update ApiConnectorConfiguration object
            if (-not [string]::IsNullOrEmpty($this.ApiConnectorConfiguration.postFederationSignupConnectorName))
            {
                $getConnector = Get-MgBetaIdentityApiConnector -Filter "DisplayName eq '$($this.ApiConnectorConfiguration.postFederationSignupConnectorName -replace "'", "''")'"
                $params = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/identity/apiConnectors/$($getConnector.Id)"
                }

                Write-Verbose -Message "Updating the Post Federation Signup connector for Azure AD Identity B2X User Flow with Id {$($currentInstance.Id)}"

                Set-MgBetaIdentityB2XUserFlowPostFederationSignupByRef -B2XIdentityUserFlowId $currentInstance.Id -BodyParameter $params
            }

            if (-not [string]::IsNullOrEmpty($this.ApiConnectorConfiguration.postAttributeCollectionConnectorName))
            {
                $getConnector = Get-MgBetaIdentityApiConnector -Filter "DisplayName eq '$($this.ApiConnectorConfiguration.postAttributeCollectionConnectorName -replace "'", "''")'"
                $params = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/identity/apiConnectors/$($getConnector.Id)"
                }

                Write-Verbose -Message "Updating the Post Attribute Collection connector for Azure AD Identity B2X User Flow with Id {$($currentInstance.Id)}"

                Set-MgBetaIdentityB2XUserFlowPostAttributeCollectionByRef -B2XIdentityUserFlowId $currentInstance.Id -BodyParameter $params
            }
            #endregion

            #region Add or Remove Identity Providers on the current instance
            $providersToAdd = $this.IdentityProviders | Where-Object { $_ -notin $currentInstance.IdentityProviders }
            foreach ($provider in $providersToAdd)
            {
                $params = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/identityProviders/$($provider)"
                }

                Write-Verbose -Message "Adding the Identity Provider with Id {$provider} to the Azure AD Identity B2X User Flow with Id {$($currentInstance.Id)}"

                New-MgBetaIdentityB2XUserFlowIdentityProviderByRef -B2XIdentityUserFlowId $currentInstance.Id -BodyParameter $params
            }

            $providersToRemove = $currentInstance.IdentityProviders | Where-Object { $_ -notin $this.IdentityProviders }
            foreach ($provider in $providersToRemove)
            {
                Write-Verbose -Message "Removing the Identity Provider with Id {$provider} from the Azure AD Identity B2X User Flow with Id {$($currentInstance.Id)}"

                Remove-MgBetaIdentityB2XUserFlowIdentityProviderBaseByRef -B2XIdentityUserFlowId $currentInstance.Id -IdentityProviderBaseId $provider
            }
            #endregion

            #region Add, remove or update User Attribute Assignments on the current instance
            $attributesToRemove = $currentInstance.UserAttributeAssignments | Where-Object { $_.Id -notin $this.UserAttributeAssignments.Id }

            #Remove
            foreach ($userAttributeAssignment in $attributesToRemove)
            {
                Write-Verbose -Message "Removing the User Attribute Assignment with Id {$($userAttributeAssignment.Id)} from the Azure AD Identity B2X User Flow with Id {$($currentInstance.Id)}"

                Remove-MgBetaIdentityB2XUserFlowUserAttributeAssignment -B2XIdentityUserFlowId $currentInstance.Id -IdentityUserFlowAttributeAssignmentId $userAttributeAssignment.Id
            }

            #Add/Update
            foreach ($userAttributeAssignment in $this.UserAttributeAssignments)
            {
                $params = @{
                    displayName         = $userAttributeAssignment.DisplayName
                    isOptional          = $userAttributeAssignment.IsOptional
                    userInputType       = $userAttributeAssignment.UserInputType
                    userAttributeValues = @()
                }

                foreach ($userAttributeValue in $userAttributeAssignment.UserAttributeValues)
                {
                    $params['userAttributeValues'] += @{
                        'Name'      = $userAttributeValue.Name
                        'Value'     = $userAttributeValue.Value
                        'IsDefault' = $userAttributeValue.IsDefault
                    }
                }

                if ($userAttributeAssignment.Id -notin $currentInstance.UserAttributeAssignments.Id)
                {
                    $params['userAttribute'] = @{
                        id = $userAttributeAssignment.Id
                    }

                    Write-Verbose -Message "Adding the User Attribute Assignment with Id {$($userAttributeAssignment.Id)} to the Azure AD Identity B2X User Flow with Id {$($currentInstance.Id)}"

                    New-MgBetaIdentityB2XUserFlowUserAttributeAssignment -B2XIdentityUserFlowId $currentInstance.Id -BodyParameter $params
                }
                else
                {
                    Write-Verbose -Message "Updating the User Attribute Assignment with Id {$($userAttributeAssignment.Id)} in the Azure AD Identity B2X User Flow with Id {$($currentInstance.Id)}"

                    Update-MgBetaIdentityB2XUserFlowUserAttributeAssignment -B2XIdentityUserFlowId $currentInstance.Id -IdentityUserFlowAttributeAssignmentId $userAttributeAssignment.Id -BodyParameter $params
                }
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Identity B2 X User Flow with Id {$($currentInstance.Id)}"
            Remove-MgBetaIdentityB2XUserFlow -B2XIdentityUserFlowId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaIdentityB2XUserFlow `
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
                if ($null -ne $Results.ApiConnectorConfiguration)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ApiConnectorConfiguration `
                        -CIMInstanceName 'MicrosoftGraphuserFlowApiConnectorConfiguration'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ApiConnectorConfiguration = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ApiConnectorConfiguration') | Out-Null
                    }
                }

                if ($null -ne $Results.UserAttributeAssignments)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserAttributeValues'
                            CimInstanceName = 'MicrosoftGraphuserFlowUserAttributeAssignmentUserAttributeValues'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserAttributeAssignments `
                        -CIMInstanceName 'MicrosoftGraphuserFlowUserAttributeAssignment' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserAttributeAssignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserAttributeAssignments') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ApiConnectorConfiguration', 'UserAttributeAssignments')

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

    hidden [System.String] GetConnectorName([System.Object] $ConnectorName)
    {
        if ($null -ne $ConnectorName)
        {
            return $ConnectorName
        }
        else
        {
            return ''
        }
    }

    hidden [AADIdentityB2XUserFlow] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADIdentityB2XUserFlow])
        {
            return $Values
        }

        $result = [AADIdentityB2XUserFlow]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphuserFlowApiConnectorConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('The name of the connector used for post federation signup step.')]
    [System.String] $postFederationSignupConnectorName

    [DscProperty()]
    [System.ComponentModel.Description('The name of the connector used for post attribute collection step.')]
    [System.String] $postAttributeCollectionConnectorName
}

class MSFT_MicrosoftGraphuserFlowUserAttributeAssignment
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of identityUserFlowAttributeAssignment.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the identityUserFlowAttribute within a user flow.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether the identityUserFlowAttribute is optional.')]
    [System.Nullable[System.Boolean]] $IsOptional

    [DscProperty()]
    [System.ComponentModel.Description('User Flow Attribute Input Type.')]
    [ValidateSet('textBox', 'dateTimeDropdown', 'radioSingleSelect', 'dropdownSingleSelect', 'emailBox', 'checkboxMultiSelect')]
    [System.String] $UserInputType

    [DscProperty()]
    [System.ComponentModel.Description('The list of user attribute values for this assignment.')]
    [MSFT_MicrosoftGraphuserFlowUserAttributeAssignmentUserAttributeValues[]] $UserAttributeValues
}

class MSFT_MicrosoftGraphuserFlowUserAttributeAssignmentUserAttributeValues
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The display name of the property displayed to the end user in the user flow.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The value that is set when this item is selected.')]
    [System.String] $Value

    [DscProperty()]
    [System.ComponentModel.Description('Used to set the value as the default.')]
    [System.Nullable[System.Boolean]] $IsDefault
}
