using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAdminConsentRequestPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Determines if the policy is enabled or not.')]
    [System.Nullable[System.Boolean]] $IsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether reviewers will receive notifications.')]
    [System.Nullable[System.Boolean]] $NotifyReviewers

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether reviewers will receive reminder emails.')]
    [System.Nullable[System.Boolean]] $RemindersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the duration the request is active before it automatically expires if no decision is applied.')]
    [System.Nullable[System.UInt32]] $RequestDurationInDays

    [DscProperty()]
    [System.ComponentModel.Description('The list of reviewers for the admin consent.')]
    [MSFT_AADAdminConsentRequestPolicyReviewer[]] $Reviewers

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

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

    [AADAdminConsentRequestPolicy] Get()
    {
        $entry = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAdminConsentRequestPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration for Admin Consent Request Policy'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $instance = Get-MgBetaPolicyAdminConsentRequestPolicy -ErrorAction SilentlyContinue
            if ($null -eq $instance)
            {
                throw 'Could not retrieve the Admin Consent Request Policy'
            }

            $reviewersValue = @()
            foreach ($reviewer in $instance.Reviewers)
            {
                if ($reviewer.Query.Contains('/users/'))
                {
                    $userId = $reviewer.Query.Split('/')[3]
                    $userInfo = Get-MgUser -UserId $userId

                    $entry = @{
                        ReviewerType = 'User'
                        ReviewerId   = $userInfo.UserPrincipalName
                    }
                }
                elseif ($reviewer.Query.Contains('/groups/'))
                {
                    $groupId = $reviewer.Query.Split('/')[3]
                    try
                    {
                        $groupInfo = Get-MgGroup -GroupId $groupId -ErrorAction SilentlyContinue
                        $entry = @{
                            ReviewerType = 'Group'
                            ReviewerId   = $groupInfo.DisplayName
                        }
                    }
                    catch
                    {
                        $message = "Group with ID $groupId specified in Reviewers not found"
                        $this.LogError($_, $message)
                        continue
                    }
                }
                elseif ($reviewer.Query.Contains('directory/roleAssignments?$'))
                {
                    $roleId = $reviewer.Query.Replace("/beta/roleManagement/directory/roleAssignments?`$filter=roleDefinitionId eq ", '').Replace("'", '')
                    $roleInfo = Get-MgBetaRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $roleId
                    $entry = @{
                        ReviewerType = 'Role'
                        ReviewerId   = $roleInfo.DisplayName
                    }
                }
                $reviewersValue += $entry
            }

            $results = @{
                IsSingleInstance      = 'Yes'
                IsEnabled             = $instance.IsEnabled
                NotifyReviewers       = $instance.NotifyReviewers
                RemindersEnabled      = $instance.RemindersEnabled
                RequestDurationInDays = $instance.RequestDurationInDays
                Reviewers             = $reviewersValue
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

        Write-Verbose -Message 'Setting configuration for Admin Consent Request Policy'

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $reviewerValues = @()
        foreach ($reviewer in $this.Reviewers)
        {
            if ($reviewer.ReviewerType -eq 'User')
            {
                $userInfo = Get-MgUser -Filter "UserPrincipalName eq '$($reviewer.ReviewerId)'"
                if ($null -eq $userInfo)
                {
                    $message = "User with UPN $($reviewer.ReviewerId) specified in Reviewers not found"
                    $this.LogError($_, $message)
                    continue
                }
                $entry = @{
                    query     = "/users/$($userInfo.Id)"
                    queryType = 'MicrosoftGraph'
                }
                $reviewerValues += $entry
            }
            elseif ($reviewer.ReviewerType -eq 'Group')
            {
                $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($reviewer.ReviewerId -replace "'", "''")'"
                if ($null -eq $groupInfo)
                {
                    $message = "Group with DisplayName $($reviewer.ReviewerId) specified in Reviewers not found"
                    $this.LogError($_, $message)
                    continue
                }
                $entry = @{
                    query     = "/groups/$($groupInfo.Id)/transitiveMembers/microsoft.graph.user"
                    queryType = 'MicrosoftGraph'
                }
                $reviewerValues += $entry
            }
            elseif ($reviewer.ReviewerType -eq 'Role')
            {
                $roleInfo = Get-MgBetaRoleManagementDirectoryRoleDefinition -Filter "DisplayName eq '$($reviewer.ReviewerId -replace "'", "''")'"
                if ($null -eq $roleInfo)
                {
                    $message = "Role with DisplayName $($reviewer.ReviewerId) specified in Reviewers not found"
                    $this.LogError($_, $message)
                    continue
                }
                $entry = @{
                    query     = "/roleManagement/directory/roleAssignments?`$filter=roleDefinitionId eq '$($roleInfo.Id.Replace('\u0027', ''))'"
                    queryType = 'MicrosoftGraph'
                }
                $reviewerValues += $entry
            }
        }

        $updateParameters = @{
            isEnabled             = $this.IsEnabled
            reviewers             = $reviewerValues
            notifyReviewers       = $this.NotifyReviewers
            remindersEnabled      = $this.RemindersEnabled
            requestDurationInDays = $this.RequestDurationInDays
        }

        $updateJSON = ConvertTo-Json $updateParameters
        Write-Verbose -Message "Updating the Entra Id Admin Consent Request Policy with values: $updateJSON"
        $Uri = '/beta/policies/adminConsentRequestPolicy'
        Invoke-M365DSCGraphRequest -Method 'PUT' `
            -Uri $Uri `
            -Body $updateJSON | Out-Null
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $i = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $dscContent = [System.Text.StringBuilder]::new()
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $displayedKey = 'Policy'
            Write-M365DSCHost -Message "`r`n    |---[1/1] $displayedKey" -DeferWrite
            $params = @{
                IsSingleInstance      = 'Yes'
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

            $Results = $this.GetForExport($Params)
            if ($null -ne $Results.Reviewers)
            {
                $complexMapping = @(
                    @{
                        Name            = 'Reviewers'
                        CimInstanceName = 'AADAdminConsentRequestPolicyReviewer'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.Reviewers `
                    -CIMInstanceName 'AADAdminConsentRequestPolicyReviewer' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.Reviewers = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('Reviewers') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $Results `
                -Credential $this.Credential `
                -NoEscape @('Reviewers')
            [void]$dscContent.Append($currentDSCBlock)
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            $i++
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADAdminConsentRequestPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAdminConsentRequestPolicy])
        {
            return $Values
        }

        $result = [AADAdminConsentRequestPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADAdminConsentRequestPolicyReviewer
{
    [DscProperty()]
    [System.ComponentModel.Description('Type of reviewwer. Can be User, Group or Role')]
    [System.String] $ReviewerType

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Identifier for the reviewer instance.')]
    [System.String] $ReviewerId

    [DscProperty()]
    [System.ComponentModel.Description('Associated query.')]
    [System.String] $QueryRoot
}
