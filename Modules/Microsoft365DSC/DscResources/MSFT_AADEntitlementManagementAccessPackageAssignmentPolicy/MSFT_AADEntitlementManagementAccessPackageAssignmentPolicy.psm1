using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADEntitlementManagementAccessPackageAssignmentPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Id of the access package assignment policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Identifier of the access package.')]
    [System.String] $AccessPackageId

    [DscProperty()]
    [System.ComponentModel.Description('Represents the settings for email notifications for requests to an access package.')]
    [MSFT_MicrosoftGraphaccessPackageNotificationSettings] $AccessPackageNotificationSettings

    [DscProperty()]
    [System.ComponentModel.Description('Who must review, and how often, the assignments to the access package from this policy. This property is null if reviews are not required.')]
    [MSFT_MicrosoftGraphassignmentreviewsettings] $AccessReviewSettings

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether a user can extend the access package assignment duration after approval.')]
    [System.Nullable[System.Boolean]] $CanExtend

    [DscProperty()]
    [System.ComponentModel.Description('The description of the policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The number of days in which assignments from this policy last until they are expired.')]
    [System.Nullable[System.UInt32]] $DurationInDays

    [DscProperty()]
    [System.ComponentModel.Description('The expiration date for assignments created in this policy. The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z')]
    [System.String] $ExpirationDateTime

    [DscProperty()]
    [System.ComponentModel.Description('Questions that are posed to the requestor.')]
    [MSFT_MicrosoftGraphaccesspackagequestion[]] $Questions

    [DscProperty()]
    [System.ComponentModel.Description('Who must approve requests for access package in this policy.')]
    [MSFT_MicrosoftGraphapprovalsettings] $RequestApprovalSettings

    [DscProperty()]
    [System.ComponentModel.Description('Who can request this access package from this policy.')]
    [MSFT_MicrosoftGraphrequestorsettings] $RequestorSettings

    [DscProperty()]
    [System.ComponentModel.Description('The settings for verifiable credentials that a requestor must present to be granted access from this policy.')]
    [MSFT_MicrosoftGraphverifiableCredentialSettings] $VerifiableCredentialSettings

    [DscProperty()]
    [System.ComponentModel.Description('The collection of stages when to execute one or more custom access package workflow extensions.')]
    [MSFT_MicrosoftGraphcustomextensionhandler[]] $CustomExtensionHandlers

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
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

    [AADEntitlementManagementAccessPackageAssignmentPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADEntitlementManagementAccessPackageAssignmentPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure AD Entitlement Management Access Package Assignment Policy with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $getValue = $null
            if (-not [System.String]::IsNullOrEmpty($this.id))
            {
                $getValue = Get-MgBetaEntitlementManagementAccessPackageAssignmentPolicy `
                    -AccessPackageAssignmentPolicyId $this.id `
                    -ExpandProperty "customExtensionHandlers(`$expand=customExtension)" `
                    -ErrorAction SilentlyContinue
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "The access package assignment policy with id {$($this.id)} was not found"
                $getValue = Get-MgBetaEntitlementManagementAccessPackageAssignmentPolicy `
                    -Filter "displayName eq '$($this.DisplayName -replace "'", "''")'" `
                    -ExpandProperty "customExtensionHandlers(`$expand=customExtension)" `
                    -ErrorAction SilentlyContinue
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "The access package assignment policy with displayName {$($this.DisplayName)} was not found"
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found access package assignment policy with id {$($getValue.Id)} and DisplayName {$($this.DisplayName)}"

            #region Format AccessReviewSettings
            $formattedAccessReviewSettings = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $getValue.AccessReviewSettings
            if ($null -ne $formattedAccessReviewSettings -and $formattedAccessReviewSettings.Count -ne 0)
            {
                if (-not [System.String]::IsNullOrEmpty($formattedAccessReviewSettings.StartDateTime))
                {
                    $formattedAccessReviewSettings.StartDateTime = [M365DSCResourceBase]::FormatDateTime($getValue.AccessReviewSettings.StartDateTime)
                }
            }
            else
            {
                $formattedAccessReviewSettings = $null
            }

            if ($null -ne $formattedAccessReviewSettings.Reviewers -and $formattedAccessReviewSettings.Reviewers.Count -gt 0 )
            {
                foreach ($setting in $formattedAccessReviewSettings.Reviewers)
                {
                    $setting.Add('odataType', $setting.'@odata.type')
                    $setting.Remove('@odata.type') | Out-Null
                    $setting.Remove('description') | Out-Null
                    if (-not [System.String]::IsNullOrEmpty($setting.id))
                    {
                        $user = Get-MgUser -UserId $setting.id -ErrorAction SilentlyContinue
                        if ($null -ne $user)
                        {
                            $setting.Id = $user.UserPrincipalName
                        }
                    }
                }
            }
            #endregion

            #region Format RequestApprovalSettings
            $formattedRequestApprovalSettings = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $getValue.RequestApprovalSettings
            if ($null -ne $formattedRequestApprovalSettings.approvalStages -and $formattedRequestApprovalSettings.approvalStages.Count -gt 0 )
            {
                foreach ($approvalStage in $formattedRequestApprovalSettings.approvalStages)
                {
                    if ($null -ne $approvalStage.PrimaryApprovers -and $approvalStage.PrimaryApprovers.Count -gt 0)
                    {
                        foreach ($setting in $approvalStage.PrimaryApprovers)
                        {
                            $setting.Add('odataType', $setting.'@odata.type')
                            $setting.Remove('@odata.type') | Out-Null
                            $setting.Remove('description') | Out-Null
                            if (-not [System.String]::IsNullOrEmpty($setting.id))
                            {
                                $user = Get-MgUser -UserId $setting.id -ErrorAction SilentlyContinue
                                if ($null -ne $user)
                                {
                                    $setting.Id = $user.UserPrincipalName
                                }
                            }
                        }
                    }

                    if ($null -ne $approvalStage.EscalationApprovers -and $approvalStage.EscalationApprovers.Count -gt 0)
                    {
                        foreach ($setting in $approvalStage.EscalationApprovers)
                        {
                            $setting.Add('odataType', $setting.'@odata.type')
                            $setting.Remove('@odata.type') | Out-Null
                            $setting.Remove('description') | Out-Null
                            if (-not [System.String]::IsNullOrEmpty($setting.id))
                            {
                                $user = Get-MgUser -UserId $setting.id -ErrorAction SilentlyContinue
                                if ($null -ne $user)
                                {
                                    $setting.Id = $user.UserPrincipalName
                                }
                            }
                        }
                    }
                }
            }
            #endregion

            #region Format RequestorSettings
            $formattedRequestorSettings = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $getValue.RequestorSettings
            if ($null -ne $formattedRequestorSettings.allowedRequestors -and $formattedRequestorSettings.allowedRequestors.Count -gt 0 )
            {
                foreach ($setting in $formattedRequestorSettings.allowedRequestors)
                {
                    $setting.Remove('description') | Out-Null
                    if (-not $setting.ContainsKey('odataType'))
                    {
                        $setting.Add('odataType', $setting.'@odata.type')
                        $setting.Remove('@odata.type') | Out-Null
                    }
                    if (-not [System.String]::IsNullOrEmpty($setting.id))
                    {
                        # Check the @odata.type to determine if this is a user or group
                        $odataType = $setting.'odataType'
                        if ($odataType -eq '#microsoft.graph.singleUser')
                        {
                            # Handle single user - try to resolve to UserPrincipalName
                            $user = Get-MgUser -UserId $setting.id -ErrorAction SilentlyContinue
                            if ($null -ne $user)
                            {
                                $setting.Id = $user.UserPrincipalName
                            }
                        }
                        elseif ($odataType -eq '#microsoft.graph.groupMembers')
                        {
                            # Handle group members - try to resolve group to DisplayName, fallback to GUID
                            $group = Get-MgGroup -GroupId $setting.id -ErrorAction SilentlyContinue
                            if ($null -ne $group)
                            {
                                $setting.Id = $group.DisplayName
                            }
                        }
                    }
                }
            }
            #endregion

            #region Format Questions
            [array]$formattedQuestions = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $getValue.Questions
            foreach ($question in $formattedQuestions)
            {
                if (-not $question.ContainsKey('odataType'))
                {
                    $question.Add('odataType', $question.'@odata.type')
                    $question.Remove('@odata.type') | Out-Null
                }
                if ($null -ne $question.Text)
                {
                    $question.Add('QuestionText', $question.Text)
                    $question.Remove('Text') | Out-Null
                }
                # Rename Sequence to SequencePosition to avoid conflicts with the reserved word "Sequence" in PowerShell
                if ($question.ContainsKey('Sequence'))
                {
                    $question.Add('SequencePosition', $question.Sequence)
                    $question.Remove('Sequence') | Out-Null
                }
                # TODO: Remove this once the documentation is updated on the Graph page
                # Periodically check for new releases or if the property is still being returned from the API
                # See https://learn.microsoft.com/en-us/graph/api/resources/accesspackagemultiplechoicequestion?view=graph-rest-beta
                if ($question.ContainsKey('attribute'))
                {
                    $question.Remove('attribute') | Out-Null
                }
            }
            #endregion

            #region Format CustomExtensionHandlers
            $formattedCustomExtensionHandlers = @()
            foreach ($customExtensionHandler in $getValue.CustomExtensionHandlers)
            {
                $customExt = @{
                    #Id              = $customExtensionHandler.Id #Read Only
                    Stage             = $customExtensionHandler.Stage
                    CustomExtensionId = $customExtensionHandler.CustomExtension.Id
                }
                $formattedCustomExtensionHandlers += $customExt
            }
            #endregion

            #region Format AccessPackageNotificationSettings
            $formattedAccessPackageNotificationSettings = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $getValue.AccessPackageNotificationSettings
            if ($null -eq $formattedAccessPackageNotificationSettings -or $formattedAccessPackageNotificationSettings.Count -eq 0)
            {
                $formattedAccessPackageNotificationSettings = $null
            }
            #endregion

            #region Format VerifiableCredentialSettings
            $formattedVerifiableCredentialSettings = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $getValue.VerifiableCredentialSettings
            if ($null -eq $formattedVerifiableCredentialSettings -or $formattedVerifiableCredentialSettings.Count -eq 0)
            {
                $formattedVerifiableCredentialSettings = $null
            }
            #endregion

            $AccessPackageIdValue = $getValue.AccessPackageId
            $isGUID = [System.Guid]::TryParse($AccessPackageIdValue, [ref][System.Guid]::Empty)
            if ($isGUID)
            {
                $accesspackage = Get-MgBetaEntitlementManagementAccessPackage -AccessPackageId $AccessPackageIdValue
                $AccessPackageIdValue = $accesspackage.DisplayName
            }

            $results = @{
                Id                                = $getValue.Id
                AccessPackageId                   = $AccessPackageIdValue
                AccessPackageNotificationSettings = $formattedAccessPackageNotificationSettings
                AccessReviewSettings              = $formattedAccessReviewSettings
                CanExtend                         = $getValue.CanExtend
                CustomExtensionHandlers           = $formattedCustomExtensionHandlers
                Description                       = $getValue.Description
                DisplayName                       = $getValue.DisplayName
                DurationInDays                    = $getValue.DurationInDays
                ExpirationDateTime                = $getValue.ExpirationDateTime
                Questions                         = $formattedQuestions
                RequestApprovalSettings           = $formattedRequestApprovalSettings
                RequestorSettings                 = $formattedRequestorSettings
                VerifiableCredentialSettings      = $formattedVerifiableCredentialSettings
                Ensure                            = 'Present'
                Credential                        = $this.Credential
                ApplicationId                     = $this.ApplicationId
                TenantId                          = $this.TenantId
                ApplicationSecret                 = $this.ApplicationSecret
                CertificateThumbprint             = $this.CertificateThumbprint
                CertificatePath                   = $this.CertificatePath
                CertificatePassword               = $this.CertificatePassword
                ManagedIdentity                   = $this.ManagedIdentity
                AccessTokens                      = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of AzureAD Entitlement Management Access Package Assignment Policy for DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $keyToRename = @{
            'odataType'        = '@odata.type'
            'QuestionText'     = 'text'
            'SequencePosition' = 'sequence'
        }

        $commonParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $commonParameters = Rename-M365DSCCimInstanceParameter -Properties $commonParameters -KeyMapping $keyToRename

        if ($null -ne $commonParameters.AccessReviewSettings -and $null -ne $commonParameters.AccessReviewSettings.Reviewers)
        {
            for ($i = 0; $i -lt $commonParameters.AccessReviewSettings.Reviewers.Length; $i++)
            {
                $reviewer = $commonParameters.AccessReviewSettings.Reviewers[$i]
                $user = Get-MgUser -Filter "startswith(UserPrincipalName, '$($reviewer.Id.Split('@')[0])')" -ErrorAction SilentlyContinue
                if ($null -ne $user)
                {
                    $commonParameters.AccessReviewSettings.Reviewers[$i].Id = $user.Id
                }
            }
        }

        if ($null -ne $commonParameters.RequestApprovalSettings.ApprovalStages.PrimaryApprovers)
        {
            for ($i = 0; $i -lt $commonParameters.RequestApprovalSettings.ApprovalStages.PrimaryApprovers.Length; $i++)
            {
                $primaryApprover = $commonParameters.RequestApprovalSettings.ApprovalStages.PrimaryApprovers[$i]
                if ($null -ne $primaryApprover.id)
                {
                    $user = Get-MgUser -Filter "startswith(UserPrincipalName, '$($primaryApprover.Id.Split('@')[0])')" -ErrorAction SilentlyContinue
                    if ($null -ne $user)
                    {
                        $commonParameters.RequestApprovalSettings.ApprovalStages.PrimaryApprovers[$i].Id = $user.Id
                    }
                }
            }
        }

        if ($null -ne $commonParameters.RequestApprovalSettings.ApprovalStages.EscalationApprovers)
        {
            for ($i = 0; $i -lt $commonParameters.RequestApprovalSettings.ApprovalStages.EscalationApprovers.Length; $i++)
            {
                $escalationApprover = $commonParameters.RequestApprovalSettings.ApprovalStages.EscalationApprovers[$i]
                if ($null -ne $escalationApprover.id)
                {
                    $user = Get-MgUser -Filter "startswith(UserPrincipalName, '$($escalationApprover.Id.Split('@')[0])')" -ErrorAction SilentlyContinue
                    if ($null -ne $user)
                    {
                        $commonParameters.RequestApprovalSettings.ApprovalStages.EscalationApprovers[$i].Id = $user.Id
                    }
                }
            }
        }

        if ($null -ne $commonParameters.RequestorSettings -and $null -ne $commonParameters.RequestorSettings.AllowedRequestors)
        {
            for ($i = 0; $i -lt $commonParameters.RequestorSettings.AllowedRequestors.Length; $i++)
            {
                $requestor = $commonParameters.RequestorSettings.AllowedRequestors[$i]
                $odataType = $requestor.'@odata.type'

                if ($odataType -eq '#microsoft.graph.singleUser')
                {
                    # Handle single user - convert UPN to GUID
                    if ($requestor.Id -like '*@*')
                    {
                        $user = Get-MgUser -Filter "startswith(UserPrincipalName, '$($requestor.Id.Split('@')[0])')" -ErrorAction SilentlyContinue
                        if ($null -ne $user)
                        {
                            $commonParameters.RequestorSettings.AllowedRequestors[$i].Id = $user.Id
                        }
                    }
                    # If already a GUID, leave as-is
                }
                elseif ($odataType -eq '#microsoft.graph.groupMembers')
                {
                    # Handle group members - convert DisplayName to GUID if needed
                    $isGUID = [System.Guid]::TryParse($requestor.Id, [ref][System.Guid]::Empty)

                    if (-not $isGUID)
                    {
                        # Try to resolve by DisplayName
                        $group = Get-MgGroup -Filter "displayName eq '$($requestor.Id.Replace("'", "''"))'" -ErrorAction SilentlyContinue
                        if ($null -ne $group)
                        {
                            $commonParameters.RequestorSettings.AllowedRequestors[$i].Id = $group.Id
                        }
                    }
                    # If already a GUID, leave as-is
                }
                # For other types (requestorManager, etc.), leave ID as-is
            }
        }

        if ($null -ne $commonParameters.CustomExtensionHandlers -and $commonParameters.CustomExtensionHandlers.Count -gt 0 )
        {
            $formattedCustomExtensionHandlers = @()
            foreach ($customExtensionHandler in $commonParameters.CustomExtensionHandlers)
            {
                $extensionId = $customExtensionHandler.CustomExtensionId
                $formattedCustomExtensionHandlers += @{
                    stage           = $customExtensionHandler.Stage
                    customExtension = @{
                        id = $extensionId
                    }
                }
            }
            $commonParameters.CustomExtensionHandlers = $formattedCustomExtensionHandlers
        }

        # Check to see if the AccessPackageId is in GUID form. If not, resolve it by name.
        if (-not [System.String]::IsNullOrEmpty($this.AccessPackageId))
        {
            $resolvedAccessPackageId = $this.AccessPackageId
            $isGUID = [System.Guid]::TryParse($resolvedAccessPackageId, [ref][System.Guid]::Empty)
            if (-not $isGUID)
            {
                # Retrieve by name
                Write-Verbose -Message "Retrieving Entitlement Management Access Package by Name {$($resolvedAccessPackageId)}"
                $package = Get-MgBetaEntitlementManagementAccessPackage -Filter "DisplayName eq '$($resolvedAccessPackageId -replace "'", "''")'"
                if ($null -eq $package)
                {
                    throw "Could not retrieve the Access Package using identifier {$($resolvedAccessPackageId)}"
                }
                $resolvedAccessPackageId = $package.Id
            }
            $commonParameters.AccessPackageId = $resolvedAccessPackageId
        }

        if ($null -ne $commonParameters.AccessReviewSettings -and $null -ne $commonParameters.AccessReviewSettings.StartDateTime)
        {
            $parsedTime = [M365DSCResourceBase]::ConvertToDateTimeOffset($commonParameters.AccessReviewSettings.StartDateTime)
            if ($null -eq $parsedTime)
            {
                throw "AccessReviewSettings.StartDateTime {$($commonParameters.AccessReviewSettings.StartDateTime)} is not a valid date and time. Use the ISO 8601 format, for example 2030-01-01T00:00:00Z."
            }
            $commonParameters.AccessReviewSettings.StartDateTime = [M365DSCResourceBase]::FormatDateTime($parsedTime)
            if ($parsedTime -lt [System.DateTimeOffset]::UtcNow)
            {
                Write-Verbose -Message "The provided AccessReviewSettings.StartDateTime {$($commonParameters.AccessReviewSettings.StartDateTime)} is in the past. Setting it to 1 minute in the future from now."
                $commonParameters.AccessReviewSettings.StartDateTime = [M365DSCResourceBase]::FormatDateTime([System.DateTimeOffset]::UtcNow.AddMinutes(1))
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new access package assignment policy {$($this.DisplayName)}"

            $createParameters = $commonParameters
            $createParameters.Remove('Id') | Out-Null

            New-MgBetaEntitlementManagementAccessPackageAssignmentPolicy `
                -BodyParameter $createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the access package assignment policy {$($this.DisplayName)}"

            $updateParameters = $commonParameters
            $updateParameters.Remove('Id') | Out-Null

            Set-MgBetaEntitlementManagementAccessPackageAssignmentPolicy `
                -BodyParameter $updateParameters `
                -AccessPackageAssignmentPolicyId $currentInstance.Id
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the access package assignment policy {$($this.DisplayName)}"
            Remove-MgBetaEntitlementManagementAccessPackageAssignmentPolicy -AccessPackageAssignmentPolicyId $currentInstance.Id
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $complexMapping = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$getValue = Get-MgBetaEntitlementManagementAccessPackageAssignmentPolicy `
                -All `
                -Filter $this.Filter `
                -ErrorAction Stop

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

                $displayedKey = $config.id
                if (-not [System.String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    id                    = $config.id
                    DisplayName           = $config.displayName
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

                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.AccessReviewSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Reviewers'
                            CimInstanceName = 'MicrosoftGraphuserset'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AccessReviewSettings `
                        -CIMInstanceName MicrosoftGraphassignmentreviewsettings `
                        -ComplexTypeMapping $complexMapping
                    if ($complexTypeStringResult)
                    {
                        $Results.AccessReviewSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AccessReviewSettings') | Out-Null
                    }
                }
                if ($null -ne $Results.Questions)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'QuestionText'
                            CimInstanceName = 'MicrosoftGraphaccessPackageLocalizedContent'
                            IsRequired      = $false
                        }
                        @{
                            Name            = 'Choices'
                            CimInstanceName = 'MicrosoftGraphaccessPackageAnswerChoice'
                            IsRequired      = $false
                        }
                        @{
                            Name            = 'DisplayValue'
                            CimInstanceName = 'MicrosoftGraphaccessPackageLocalizedContent'
                            IsRequired      = $false
                        }
                        @{
                            Name            = 'localizedTexts'
                            CimInstanceName = 'MicrosoftGraphaccessPackageLocalizedText'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Questions `
                        -CIMInstanceName MicrosoftGraphaccesspackagequestion `
                        -ComplexTypeMapping $complexMapping

                    if ($complexTypeStringResult)
                    {
                        $Results.Questions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Questions') | Out-Null
                    }
                }
                if ($null -ne $Results.RequestApprovalSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'ApprovalStages'
                            CimInstanceName = 'MicrosoftGraphapprovalstage1'
                            IsRequired      = $false
                        }
                        @{
                            Name            = 'PrimaryApprovers'
                            CimInstanceName = 'MicrosoftGraphuserset'
                            IsRequired      = $false
                        }
                        @{
                            Name            = 'EscalationApprovers'
                            CimInstanceName = 'MicrosoftGraphuserset'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.RequestApprovalSettings `
                        -CIMInstanceName MicrosoftGraphapprovalsettings `
                        -ComplexTypeMapping $complexMapping
                    if ($complexTypeStringResult)
                    {
                        $Results.RequestApprovalSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('RequestApprovalSettings') | Out-Null
                    }
                }
                if ($null -ne $Results.RequestorSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'AllowedRequestors'
                            CimInstanceName = 'MicrosoftGraphuserset'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.RequestorSettings `
                        -CIMInstanceName MicrosoftGraphrequestorsettings `
                        -ComplexTypeMapping $complexMapping

                    if ($complexTypeStringResult)
                    {
                        $Results.RequestorSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('RequestorSettings') | Out-Null
                    }
                }
                if ($null -ne $Results.CustomExtensionHandlers )
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CustomExtensionHandlers `
                        -CIMInstanceName MicrosoftGraphcustomextensionhandler `
                        -ComplexTypeMapping $complexMapping

                    if ($complexTypeStringResult)
                    {
                        $Results.CustomExtensionHandlers = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CustomExtensionHandlers') | Out-Null
                    }
                }
                if ($null -ne $Results.AccessPackageNotificationSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AccessPackageNotificationSettings `
                        -CIMInstanceName MicrosoftGraphaccessPackageNotificationSettings

                    if ($complexTypeStringResult)
                    {
                        $Results.AccessPackageNotificationSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AccessPackageNotificationSettings') | Out-Null
                    }
                }
                if ($null -ne $Results.VerifiableCredentialSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'CredentialTypes'
                            CimInstanceName = 'MicrosoftGraphverifiableCredentialType'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.VerifiableCredentialSettings `
                        -CIMInstanceName MicrosoftGraphverifiableCredentialSettings `
                        -ComplexTypeMapping $complexMapping

                    if ($complexTypeStringResult)
                    {
                        $Results.VerifiableCredentialSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('VerifiableCredentialSettings') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AccessReviewSettings', 'Questions', 'RequestApprovalSettings', 'RequestorSettings', 'CustomExtensionHandlers', 'AccessPackageNotificationSettings', 'VerifiableCredentialSettings') `
                    -RawResults $rawResults

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
            if ($_.ErrorDetails.Message -like '*User is not authorized to perform the operation.*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) Tenant does not meet license requirement to extract this component."
                return ''
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if (-not [System.String]::IsNullOrEmpty($DesiredValues.AccessReviewSettings.StartDateTime))
                {
                    $parsedDesiredDate = [M365DSCResourceBase]::ConvertToDateTimeOffset($DesiredValues.AccessReviewSettings.StartDateTime)
                    $parsedCurrentDate = [M365DSCResourceBase]::ConvertToDateTimeOffset($CurrentValues.AccessReviewSettings.StartDateTime)

                    if ($null -ne $parsedDesiredDate -and $null -ne $parsedCurrentDate)
                    {
                        Write-Verbose -Message "Parsed Desired StartDateTime: $parsedDesiredDate, Parsed Current StartDateTime: $parsedCurrentDate"
                        if ($parsedDesiredDate -eq $parsedCurrentDate)
                        {
                            $DesiredValues.AccessReviewSettings.StartDateTime = $CurrentValues.AccessReviewSettings.StartDateTime
                        }
                        elseif ($parsedDesiredDate -lt [System.DateTimeOffset]::UtcNow)
                        {
                            Write-Verbose -Message 'Ignoring StartDateTime in ScheduleInfo as it is in the past. StartDateTime cannot be set to a past date.'
                            Write-Verbose -Message 'Aligning the Desired and Current StartDateTime values for comparison.'
                            $DesiredValues.AccessReviewSettings.StartDateTime = $CurrentValues.AccessReviewSettings.StartDateTime
                        }
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [AADEntitlementManagementAccessPackageAssignmentPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADEntitlementManagementAccessPackageAssignmentPolicy])
        {
            return $Values
        }

        $result = [AADEntitlementManagementAccessPackageAssignmentPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphassignmentreviewsettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The default decision to apply if the request is not reviewed within the period specified in durationInDays.')]
    [ValidateSet('acceptAccessRecommendation', 'keepAccess', 'removeAccess', 'unknownFutureValue')]
    [System.String] $AccessReviewTimeoutBehavior

    [DscProperty()]
    [System.ComponentModel.Description('The number of days within which reviewers should provide input.')]
    [System.Nullable[System.UInt32]] $DurationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to display recommendations to the reviewer. The default value is true')]
    [System.Nullable[System.Boolean]] $IsAccessRecommendationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the agentic experience is enabled for this policy.')]
    [System.Nullable[System.Boolean]] $IsAgenticExperienceEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the reviewer must provide justification for the approval. The default value is true.')]
    [System.Nullable[System.Boolean]] $IsApprovalJustificationRequired

    [DscProperty()]
    [System.ComponentModel.Description('If true, access reviews are required for assignments from this policy.')]
    [System.Nullable[System.Boolean]] $IsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The interval for recurrence, such as monthly or quarterly.')]
    [System.String] $RecurrenceType

    [DscProperty()]
    [System.ComponentModel.Description('Who should be asked to do the review, either Self or Reviewers.')]
    [System.String] $ReviewerType

    [DscProperty()]
    [System.ComponentModel.Description('If the reviewerType is Reviewers, this collection specifies the users who will be reviewers, either by ID or as members of a group, using a collection of singleUser and groupMembers.')]
    [MSFT_MicrosoftGraphuserset[]] $Reviewers

    [DscProperty()]
    [System.ComponentModel.Description('When the first review should start.')]
    [System.String] $StartDateTime
}

class MSFT_MicrosoftGraphaccesspackagequestion
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the resource')]
    [ValidateSet('#microsoft.graph.accessPackageMultipleChoiceQuestion', '#microsoft.graph.accessPackageTextInputQuestion')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('ID of the question.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the requestor is allowed to edit answers to questions.')]
    [System.Nullable[System.Boolean]] $IsAnswerEditable

    [DscProperty()]
    [System.ComponentModel.Description('Whether the requestor is required to supply an answer or not.')]
    [System.Nullable[System.Boolean]] $IsRequired

    [DscProperty()]
    [System.ComponentModel.Description('Relative position of this question when displaying a list of questions to the requestor.')]
    [System.Nullable[System.UInt32]] $SequencePosition

    [DscProperty()]
    [System.ComponentModel.Description('The text of the question to show to the requestor.')]
    [MSFT_MicrosoftGraphaccessPackageLocalizedContent] $QuestionText

    [DscProperty()]
    [System.ComponentModel.Description('List of answer choices.')]
    [MSFT_MicrosoftGraphaccessPackageAnswerChoice[]] $Choices

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether requestor can select multiple choices as their answer.')]
    [System.Nullable[System.Boolean]] $AllowsMultipleSelection

    [DscProperty()]
    [System.ComponentModel.Description('This is the regex pattern that the corresponding text answer must follow.')]
    [System.String] $RegexPattern

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the answer will be in single or multiple line format.')]
    [System.Nullable[System.Boolean]] $IsSingleLineQuestion
}

class MSFT_MicrosoftGraphapprovalsettings
{
    [DscProperty()]
    [System.ComponentModel.Description('One of SingleStage, Serial, Parallel, NoApproval (default). NoApproval is used when isApprovalRequired is false.')]
    [ValidateSet('SingleStage', 'Serial', 'Parallel', 'NoApproval')]
    [System.String] $ApprovalMode

    [DscProperty()]
    [System.ComponentModel.Description('If approval is required, the one or two elements of this collection define each of the stages of approval. An empty array if no approval is required.')]
    [MSFT_MicrosoftGraphapprovalstage1[]] $ApprovalStages

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether approval is required for requests in this policy.')]
    [System.Nullable[System.Boolean]] $IsApprovalRequired

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether approval is required for a user to extend their assignment.')]
    [System.Nullable[System.Boolean]] $IsApprovalRequiredForExtension

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the requestor is required to supply a justification in their request.')]
    [System.Nullable[System.Boolean]] $IsRequestorJustificationRequired
}

class MSFT_MicrosoftGraphrequestorsettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether new requests are accepted on this policy.')]
    [System.Nullable[System.Boolean]] $AcceptRequests

    [DscProperty()]
    [System.ComponentModel.Description('The users who are allowed to request on this policy, which can be singleUser, groupMembers, and connectedOrganizationMembers.')]
    [MSFT_MicrosoftGraphuserset[]] $AllowedRequestors

    [DscProperty()]
    [System.ComponentModel.Description('Who can request.')]
    [ValidateSet('NoSubjects', 'SpecificDirectorySubjects', 'SpecificConnectedOrganizationSubjects', 'AllConfiguredConnectedOrganizationSubjects', 'AllExistingConnectedOrganizationSubjects', 'AllExistingDirectoryMemberUsers', 'AllExistingDirectorySubjects', 'AllExternalSubjects')]
    [System.String] $ScopeType
}

class MSFT_MicrosoftGraphcustomextensionhandler
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates which custom workflow extension will be executed at this stage.')]
    [System.String] $CustomExtensionId

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the stage of the access package assignment request workflow when the access package custom extension runs.')]
    [ValidateSet('assignmentRequestCreated', 'assignmentRequestApproved', 'assignmentRequestGranted', 'assignmentRequestRemoved', 'assignmentFourteenDaysBeforeExpiration', 'assignmentOneDayBeforeExpiration', 'unknownFutureValue')]
    [System.String] $Stage

    [DscProperty()]
    [System.ComponentModel.Description('Identifier of the stage.')]
    [System.String] $Id
}

class MSFT_MicrosoftGraphuserset
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the resource')]
    [ValidateSet('#microsoft.graph.singleUser', '#microsoft.graph.groupMembers', '#microsoft.graph.requestorManager', '#microsoft.graph.internalSponsors', '#microsoft.graph.externalSponsors', '#microsoft.graph.connectedOrganizationMembers')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('The id of the resource.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the resource is a backup fallback approver.')]
    [System.Nullable[System.Boolean]] $IsBackup

    [DscProperty()]
    [System.ComponentModel.Description('The hierarchical level of the manager with respect to the requestor. For example, the direct manager of a requestor would have a managerLevel of 1, while the manager of the requestor''s manager would have a managerLevel of 2. Default value for managerLevel is 1. Possible values for this property range from 1 to 2.')]
    [System.Nullable[System.UInt32]] $ManagerLevel
}

class MSFT_MicrosoftGraphaccessPackageLocalizedContent
{
    [DscProperty()]
    [System.ComponentModel.Description('The fallback string, which is used when a requested localization is not available. Required.')]
    [System.String] $DefaultText

    [DscProperty()]
    [System.ComponentModel.Description('Content represented in a format for a specific locale.')]
    [MSFT_MicrosoftGraphaccessPackageLocalizedText[]] $LocalizedTexts
}

class MSFT_MicrosoftGraphaccessPackageAnswerChoice
{
    [DscProperty()]
    [System.ComponentModel.Description('The actual value of the selected choice. This is typically a string value which is understandable by applications. Required.')]
    [System.String] $ActualValue

    [DscProperty()]
    [System.ComponentModel.Description('The localized display values shown to the requestor and approvers. Required.')]
    [MSFT_MicrosoftGraphaccessPackageLocalizedContent] $displayValue
}

class MSFT_MicrosoftGraphapprovalstage1
{
    [DscProperty()]
    [System.ComponentModel.Description('The number of days that a request can be pending a response before it is automatically denied.')]
    [System.Nullable[System.UInt32]] $ApprovalStageTimeOutInDays

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether approver information is visible to the requestor in approval processes within Microsoft Entra entitlement management and related governance scenarios.')]
    [ValidateSet('default', 'notVisible', 'visible', 'unknownFutureValue')]
    [System.String] $ApproverInformationVisibility

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the approver is required to provide a justification for approving a request.')]
    [System.Nullable[System.UInt32]] $EscalationTimeInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('If true, then one or more escalation approvers are configured in this approval stage.')]
    [System.Nullable[System.Boolean]] $IsApproverJustificationRequired

    [DscProperty()]
    [System.ComponentModel.Description('If escalation is required, the time a request can be pending a response from a primary approver.')]
    [System.Nullable[System.Boolean]] $IsEscalationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The users who will be asked to approve requests. A collection of singleUser, groupMembers, requestorManager, internalSponsors and externalSponsors. When creating or updating a policy, include at least one userSet in this collection.')]
    [MSFT_MicrosoftGraphuserset[]] $PrimaryApprovers

    [DscProperty()]
    [System.ComponentModel.Description('If escalation is enabled and the primary approvers do not respond before the escalation time, the escalationApprovers are the users who will be asked to approve requests. This can be a collection of singleUser, groupMembers, requestorManager, internalSponsors and externalSponsors. When creating or updating a policy, if there are no escalation approvers, or escalation approvers are not required for the stage, the value of this property should be an empty collection.')]
    [MSFT_MicrosoftGraphuserset[]] $EscalationApprovers
}

class MSFT_MicrosoftGraphaccessPackageLocalizedText
{
    [DscProperty()]
    [System.ComponentModel.Description('The text in the specific language. Required.')]
    [System.String] $Text

    [DscProperty()]
    [System.ComponentModel.Description('The ISO code for the intended language. Required.')]
    [System.String] $LanguageCode
}

class MSFT_MicrosoftGraphaccessPackageNotificationSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates if notifications are disabled. Default value is false.')]
    [System.Nullable[System.Boolean]] $IsAssignmentNotificationDisabled
}

class MSFT_MicrosoftGraphverifiableCredentialSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The verifiable credential types and their issuers that a requestor must present.')]
    [MSFT_MicrosoftGraphverifiableCredentialType[]] $CredentialTypes
}

class MSFT_MicrosoftGraphverifiableCredentialType
{
    [DscProperty()]
    [System.ComponentModel.Description('The name of the verifiable credential type.')]
    [System.String] $CredentialType

    [DscProperty()]
    [System.ComponentModel.Description('The issuers of the verifiable credential type, identified by their decentralized identifiers.')]
    [System.String[]] $Issuers
}
