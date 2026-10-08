using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCDLPCompliancePolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the DLP policy. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The EndpointDLPLocation parameter specifies the user accounts to include in the DLP policy for Endpoint DLP when they are logged on to an onboarded device. You identify the account by name or email address. You can use the value All to include all user accounts.')]
    [System.String[]] $EndpointDlpLocation

    [DscProperty()]
    [System.ComponentModel.Description('The EndpointDlpLocationException parameter specifies the user accounts to exclude from Endpoint DLP when you use the value All for the EndpointDlpLocation parameter. You identify the account by name or email address.')]
    [System.String[]] $EndpointDlpLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The OnPremisesScannerDlpLocation parameter specifies the on-premises file shares and SharePoint document libraries and folders to include in the DLP policy. You can use the value All to include all on-premises file shares and SharePoint document libraries and folders.')]
    [System.String[]] $OnPremisesScannerDlpLocation

    [DscProperty()]
    [System.ComponentModel.Description('The OnPremisesScannerDlpLocationException parameter specifies the on-premises file shares and SharePoint document libraries and folders to exclude from the DLP policy if you use the value All for the OnPremisesScannerDlpLocation parameter.')]
    [System.String[]] $OnPremisesScannerDlpLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The PowerBIDlpLocation parameter specifies the Power BI workspace IDs to include in the DLP policy. Only workspaces hosted in Premium Gen2 capacities are permitted. You can use the value All to include all supported workspaces.')]
    [System.String[]] $PowerBIDlpLocation

    [DscProperty()]
    [System.ComponentModel.Description('The PowerBIDlpLocationException parameter specifies the Power BI workspace IDs to exclude from the DLP policy when you use the value All for the PowerBIDlpLocation parameter. Only workspaces hosted in Premium Gen2 capacities are permitted.')]
    [System.String[]] $PowerBIDlpLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The ThirdPartyAppDlpLocation parameter specifies the non-Microsoft cloud apps to include in the DLP policy. You can use the value All to include all connected apps.')]
    [System.String[]] $ThirdPartyAppDlpLocation

    [DscProperty()]
    [System.ComponentModel.Description('The ThirdPartyAppDlpLocationException parameter specifies the non-Microsoft cloud apps to exclude from the DLP policy when you use the value All for the ThirdPartyAppDlpLocation parameter.')]
    [System.String[]] $ThirdPartyAppDlpLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeLocation parameter specifies Exchange Online mailboxes to include in the DLP policy. You can only use the value All for this parameter to include all mailboxes.')]
    [System.String[]] $ExchangeLocation

    [DscProperty()]
    [System.ComponentModel.Description('Exchange members to include.')]
    [System.String[]] $ExchangeSenderMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('Exchange members to exclude.')]
    [System.String[]] $ExchangeSenderMemberOfException

    [DscProperty()]
    [System.ComponentModel.Description('The Mode parameter specifies the action and notification level of the DLP policy. Valid values are: Enable, TestWithNotifications, TestWithoutNotifications, Disable and PendingDeletion.')]
    [ValidateSet('Enable', 'TestWithNotifications', 'TestWithoutNotifications', 'Disable', 'PendingDeletion')]
    [System.String] $Mode

    [DscProperty()]
    [System.ComponentModel.Description('The OneDriveLocation parameter specifies the OneDrive for Business sites to include. You identify the site by its URL value, or you can use the value All to include all sites.')]
    [System.String[]] $OneDriveLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the OneDrive for Business sites to exclude when you use the value All for the OneDriveLocation parameter. You identify the site by its URL value.')]
    [System.String[]] $OneDriveLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The OneDriveSharedBy parameter specifies the users to include in the DLP policy (the sites of the OneDrive user accounts are included in the policy). You identify the users by UPN.')]
    [System.String[]] $OneDriveSharedBy

    [DscProperty()]
    [System.ComponentModel.Description('The OneDriveSharedByMemberOf parameter specifies the distribution groups or mail-enabled security groups to include in the DLP policy (the OneDrive sites of group members are included in the policy). You identify the groups by email address.')]
    [System.String[]] $OneDriveSharedByMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfOneDriveSharedBy parameter specifies the users to exclude from the DLP policy (the sites of the OneDrive user accounts are included in the policy). You identify the users by UPN.')]
    [System.String[]] $ExceptIfOneDriveSharedBy

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfOneDriveSharedByMemberOf parameter specifies the distribution groups or mail-enabled security groups to exclude from the DLP policy (the OneDrive sites of group members are excluded from the policy). You identify the groups by email address.')]
    [System.String[]] $ExceptIfOneDriveSharedByMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('Priority for the Policy.')]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('The SharePointLocation parameter specifies the SharePoint Online sites to include. You identify the site by its URL value, or you can use the value All to include all sites.')]
    [System.String[]] $SharePointLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the SharePoint Online sites to exclude when you use the value All for the SharePointLocation parameter. You identify the site by its URL value.')]
    [System.String[]] $SharePointLocationException

    [DscProperty()]
    [System.ComponentModel.Description('Teams locations to include')]
    [System.String[]] $TeamsLocation

    [DscProperty()]
    [System.ComponentModel.Description('Teams locations to exclude.')]
    [System.String[]] $TeamsLocationException

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

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

    [SCDLPCompliancePolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCDLPCompliancePolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of DLPCompliancePolicy for {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Retrieving DLPCompliancePolicy {$($this.Name)}"
                $PolicyObject = Invoke-M365DSCCommand -ScriptBlock { Get-DlpCompliancePolicy -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $PolicyObject -or $PolicyObject.Mode -eq 'PendingDeletion')
                {
                    Write-Verbose -Message "DLPCompliancePolicy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $PolicyObject = $this.ExportedInstance
            }

            Write-Verbose "Found existing DLPCompliancePolicy $($this.Name)"

            $ExchangeSenderMemberOfValue = @()
            if ($null -ne $PolicyObject.ExchangeSenderMemberOf)
            {
                foreach ($member in $PolicyObject.ExchangeSenderMemberOf)
                {
                    $ExchangeSenderMemberOfValue += (ConvertFrom-Json $member).PrimarySmtpAddress
                }
            }

            $ExchangeSenderMemberOfExceptionValue = @()
            if ($null -ne $PolicyObject.ExchangeSenderMemberOfException)
            {
                foreach ($member in $PolicyObject.ExchangeSenderMemberOfException)
                {
                    $ExchangeSenderMemberOfExceptionValue += (ConvertFrom-Json $member).PrimarySmtpAddress
                }
            }

            $oneDriveSharedByValue = @()
            if ($null -ne $PolicyObject.OneDriveSharedBy)
            {
                foreach ($member in $PolicyObject.OneDriveSharedBy)
                {
                    $oneDriveSharedByValue += (ConvertFrom-Json $member).PrimarySmtpAddress
                }
            }

            $oneDriveSharedByMemberOfValue = @()
            if ($null -ne $PolicyObject.OneDriveSharedByMemberOf)
            {
                foreach ($member in $PolicyObject.OneDriveSharedByMemberOf)
                {
                    $oneDriveSharedByMemberOfValue += (ConvertFrom-Json $member).DisplayName
                }
            }

            $exceptIfOneDriveSharedByValue = @()
            if ($null -ne $PolicyObject.ExceptIfOneDriveSharedBy)
            {
                foreach ($member in $PolicyObject.ExceptIfOneDriveSharedBy)
                {
                    $exceptIfOneDriveSharedByValue += (ConvertFrom-Json $member).PrimarySmtpAddress
                }
            }

            $exceptIfOneDriveSharedByMemberOfValue = @()
            if ($null -ne $PolicyObject.ExceptIfOneDriveSharedByMemberOf)
            {
                foreach ($member in $PolicyObject.ExceptIfOneDriveSharedByMemberOf)
                {
                    $exceptIfOneDriveSharedByMemberOfValue += (ConvertFrom-Json $member).DisplayName
                }
            }

            $result = @{
                Ensure                                = 'Present'
                Name                                  = $PolicyObject.Name
                Comment                               = $PolicyObject.Comment
                EndpointDlpLocation                   = Get-M365DSCArrayFromProperty -PropertyValue $PolicyObject.EndpointDlpLocation.Name -ElementType ([System.String])
                EndpointDlpLocationException          = $PolicyObject.EndpointDlpLocationException
                ExchangeLocation                      = Get-M365DSCArrayFromProperty -PropertyValue $PolicyObject.ExchangeLocation.Name -ElementType ([System.String])
                ExchangeSenderMemberOf                = $ExchangeSenderMemberOfValue
                ExchangeSenderMemberOfException       = $ExchangeSenderMemberOfExceptionValue
                Mode                                  = $PolicyObject.Mode
                OneDriveLocation                      = Get-M365DSCArrayFromProperty -PropertyValue $PolicyObject.OneDriveLocation.Name -ElementType ([System.String])
                OneDriveLocationException             = $PolicyObject.OneDriveLocationException
                OneDriveSharedBy                      = $oneDriveSharedByValue
                OneDriveSharedByMemberOf              = $oneDriveSharedByMemberOfValue
                ExceptIfOneDriveSharedBy              = $exceptIfOneDriveSharedByValue
                ExceptIfOneDriveSharedByMemberOf      = $exceptIfOneDriveSharedByMemberOfValue
                OnPremisesScannerDlpLocation          = Get-M365DSCArrayFromProperty -PropertyValue $PolicyObject.OnPremisesScannerDlpLocation.Name -ElementType ([System.String])
                OnPremisesScannerDlpLocationException = $PolicyObject.OnPremisesScannerDlpLocationException
                PowerBIDlpLocation                    = Get-M365DSCArrayFromProperty -PropertyValue $PolicyObject.PowerBIDlpLocation.Name -ElementType ([System.String])
                PowerBIDlpLocationException           = $PolicyObject.PowerBIDlpLocationException
                Priority                              = $PolicyObject.Priority
                SharePointLocation                    = Get-M365DSCArrayFromProperty -PropertyValue $PolicyObject.SharePointLocation.Name -ElementType ([System.String])
                SharePointLocationException           = $PolicyObject.SharePointLocationException
                TeamsLocation                         = Get-M365DSCArrayFromProperty -PropertyValue $PolicyObject.TeamsLocation.Name -ElementType ([System.String])
                TeamsLocationException                = $PolicyObject.TeamsLocationException
                ThirdPartyAppDlpLocation              = Get-M365DSCArrayFromProperty -PropertyValue $PolicyObject.ThirdPartyAppDlpLocation.Name -ElementType ([System.String])
                ThirdPartyAppDlpLocationException     = $PolicyObject.ThirdPartyAppDlpLocationException
                Credential                            = $this.Credential
                ApplicationId                         = $this.ApplicationId
                TenantId                              = $this.TenantId
                CertificateThumbprint                 = $this.CertificateThumbprint
                CertificatePath                       = $this.CertificatePath
                CertificatePassword                   = $this.CertificatePassword
                ManagedIdentity                       = $this.ManagedIdentity
                AccessTokens                          = $this.AccessTokens
            }

            return $this.AsResult($result)
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

        Write-Verbose -Message "Setting configuration of DLPCompliancePolicy for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentPolicy = $this.Get().ToHashtable()

        $null = $this.Connect('MicrosoftGraph')

        $boundParameters = $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('OneDriveSharedByMemberOf') -and $this.OneDriveSharedByMemberOf.Count -gt 0)
        {
            $groupIds = @()
            foreach ($group in $this.OneDriveSharedByMemberOf)
            {
                $groupObject = Get-MgGroup -Filter "displayName eq '$group'" -Property Id -ErrorAction Stop
                if ($null -ne $groupObject)
                {
                    $groupIds += $groupObject.Id
                }
                else
                {
                    throw "Failed to find group with display name '$group' to add to OneDriveSharedByMemberOf. Ensure the group exists and the display name is correct."
                }
            }
            $boundParameters.Remove('OneDriveSharedByMemberOf') | Out-Null
            $boundParameters.Add('OneDriveSharedByMemberOf', $groupIds)
        }

        if ($boundParameters.ContainsKey('ExceptIfOneDriveSharedByMemberOf') -and $this.ExceptIfOneDriveSharedByMemberOf.Count -gt 0)
        {
            $exceptGroupIds = @()
            foreach ($group in $this.ExceptIfOneDriveSharedByMemberOf)
            {
                $groupObject = Get-MgGroup -Filter "displayName eq '$group'" -Property Id -ErrorAction Stop
                if ($null -ne $groupObject)
                {
                    $exceptGroupIds += $groupObject.Id
                }
                else
                {
                    throw "Failed to find group with display name '$group' to add to ExceptIfOneDriveSharedByMemberOf. Ensure the group exists and the display name is correct."
                }
            }
            $boundParameters.Remove('ExceptIfOneDriveSharedByMemberOf') | Out-Null
            $boundParameters.Add('ExceptIfOneDriveSharedByMemberOf', $exceptGroupIds)
        }

        if ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Absent')
        {
            $createParameters = $boundParameters
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $createParameters
            New-DLPCompliancePolicy @CreationParams
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            $updateParameters = $boundParameters
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $updateParameters
            $CreationParams.Remove('Name') | Out-Null
            $CreationParams.Add('Identity', $this.Name) | Out-Null

            # SharePoint Location is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.SharePointLocation -or `
                    $null -ne $this.SharePointLocation)
            {
                $ToBeRemoved = $CurrentPolicy.SharePointLocation | `
                        Where-Object { $this.SharePointLocation -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveSharePointLocation', $ToBeRemoved)
                }

                $ToBeAdded = $this.SharePointLocation | `
                        Where-Object { $CurrentPolicy.SharePointLocation -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddSharePointLocation', $ToBeAdded)
                }

                $CreationParams.Remove('SharePointLocation')
            }

            # Exchange Location is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.ExchangeLocation -or `
                    $null -ne $this.ExchangeLocation)
            {
                $ToBeRemoved = $CurrentPolicy.ExchangeLocation | `
                        Where-Object { $this.ExchangeLocation -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveExchangeLocation', $ToBeRemoved)
                }

                $ToBeAdded = $this.ExchangeLocation | `
                        Where-Object { $CurrentPolicy.ExchangeLocation -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddExchangeLocation', $ToBeAdded)
                }

                $CreationParams.Remove('ExchangeLocation')
            }

            # OneDrive Location is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.OneDriveLocation -or `
                    $null -ne $this.OneDriveLocation)
            {
                $ToBeRemoved = $CurrentPolicy.OneDriveLocation | `
                        Where-Object { $this.OneDriveLocation -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveOneDriveLocation', $ToBeRemoved)
                }

                $ToBeAdded = $this.OneDriveLocation | `
                        Where-Object { $CurrentPolicy.OneDriveLocation -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddOneDriveLocation', $ToBeAdded)
                }
                $CreationParams.Remove('OneDriveLocation')
            }

            # Endpoint Location is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.EndpointDlpLocation -or `
                    $null -ne $this.EndpointDlpLocation)
            {
                $ToBeRemoved = $CurrentPolicy.EndpointDlpLocation | `
                        Where-Object { $this.EndpointDlpLocation -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveEndpointDlpLocation', $ToBeRemoved)
                }

                $ToBeAdded = $this.EndpointDlpLocation | `
                        Where-Object { $CurrentPolicy.EndpointDlpLocation -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddEndpointDlpLocation', $ToBeAdded)
                }

                $CreationParams.Remove('EndpointDlpLocation')
            }

            # On-Prem Location is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.OnPremisesScannerDlpLocation -or `
                    $null -ne $this.OnPremisesScannerDlpLocation)
            {
                $ToBeRemoved = $CurrentPolicy.OnPremisesScannerDlpLocation | `
                        Where-Object { $this.OnPremisesScannerDlpLocation -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveOnPremisesScannerDlpLocation', $ToBeRemoved)
                }

                $ToBeAdded = $this.OnPremisesScannerDlpLocation | `
                        Where-Object { $CurrentPolicy.OnPremisesScannerDlpLocation -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddOnPremisesScannerDlpLocation', $ToBeAdded)
                }

                $CreationParams.Remove('OnPremisesScannerDlpLocation')
            }

            # PowerBI Location is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.PowerBIDlpLocation -or `
                    $null -ne $this.PowerBIDlpLocation)
            {
                $ToBeRemoved = $CurrentPolicy.PowerBIDlpLocation | `
                        Where-Object { $this.PowerBIDlpLocation -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemovePowerBIDlpLocation', $ToBeRemoved)
                }

                $ToBeAdded = $this.PowerBIDlpLocation | `
                        Where-Object { $CurrentPolicy.PowerBIDlpLocation -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddPowerBIDlpLocation', $ToBeAdded)
                }

                $CreationParams.Remove('PowerBIDlpLocation')
            }

            # Teams Location is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.TeamsLocation -or `
                    $null -ne $this.TeamsLocation)
            {
                $ToBeRemoved = $CurrentPolicy.TeamsLocation | `
                        Where-Object { $this.TeamsLocation -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveTeamsLocation', $ToBeRemoved)
                }

                $ToBeAdded = $this.TeamsLocation | `
                        Where-Object { $CurrentPolicy.TeamsLocation -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddTeamsLocation', $ToBeAdded)
                }
                $CreationParams.Remove('TeamsLocation')
            }

            # 3rd party Location is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.ThirdPartyAppDlpLocation -or `
                    $null -ne $this.ThirdPartyAppDlpLocation)
            {
                $ToBeRemoved = $CurrentPolicy.ThirdPartyAppDlpLocation | `
                        Where-Object { $this.ThirdPartyAppDlpLocation -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveThirdPartyAppDlpLocation', $ToBeRemoved)
                }

                $ToBeAdded = $this.ThirdPartyAppDlpLocation | `
                        Where-Object { $CurrentPolicy.ThirdPartyAppDlpLocation -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddThirdPartyAppDlpLocation', $ToBeAdded)
                }

                $CreationParams.Remove('ThirdPartyAppDlpLocation')
            }

            # OneDrive Location Exception is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.OneDriveLocationException -or `
                    $null -ne $this.OneDriveLocationException)
            {
                $ToBeRemoved = $CurrentPolicy.OneDriveLocationException | `
                        Where-Object { $this.OneDriveLocationException -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveOneDriveLocationException', $ToBeRemoved)
                }

                $ToBeAdded = $this.OneDriveLocationException | `
                        Where-Object { $CurrentPolicy.OneDriveLocationException -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddOneDriveLocationException', $ToBeAdded)
                }
                $CreationParams.Remove('OneDriveLocationException')
            }

            # SharePoint Location Exception is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.SharePointLocationException -or `
                    $null -ne $this.SharePointLocationException)
            {
                $ToBeRemoved = $CurrentPolicy.SharePointLocationException | `
                        Where-Object { $this.SharePointLocationException -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveSharePointLocationException', $ToBeRemoved)
                }

                $ToBeAdded = $this.SharePointLocationException | `
                        Where-Object { $CurrentPolicy.SharePointLocationException -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddSharePointLocationException', $ToBeAdded)
                }
                $CreationParams.Remove('SharePointLocationException')
            }

            # Teams Location Exception is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.TeamsLocationException -or `
                    $null -ne $this.TeamsLocationException)
            {
                $ToBeRemoved = $CurrentPolicy.TeamsLocationException | `
                        Where-Object { $this.TeamsLocationException -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveTeamsLocationException', $ToBeRemoved)
                }

                $ToBeAdded = $this.TeamsLocationException | `
                        Where-Object { $CurrentPolicy.TeamsLocationException -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddTeamsLocationException', $ToBeAdded)
                }
                $CreationParams.Remove('TeamsLocationException')
            }

            # Endpoint Location Exception is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.EndpointDlpLocationException -or `
                    $null -ne $this.EndpointDlpLocationException)
            {
                $ToBeRemoved = $CurrentPolicy.EndpointDlpLocationException | `
                        Where-Object { $this.EndpointDlpLocationException -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveEndpointDlpLocationException', $ToBeRemoved)
                }

                $ToBeAdded = $this.EndpointDlpLocationException | `
                        Where-Object { $CurrentPolicy.EndpointDlpLocationException -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddEndpointDlpLocationException', $ToBeAdded)
                }
                $CreationParams.Remove('EndpointDlpLocationException')
            }

            # On-Prem Location Exception is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.OnPremisesScannerDlpLocationException -or `
                    $null -ne $this.OnPremisesScannerDlpLocationException)
            {
                $ToBeRemoved = $CurrentPolicy.OnPremisesScannerDlpLocationException | `
                        Where-Object { $this.OnPremisesScannerDlpLocationException -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveOnPremisesScannerDlpLocationException', $ToBeRemoved)
                }

                $ToBeAdded = $this.OnPremisesScannerDlpLocationException | `
                        Where-Object { $CurrentPolicy.OnPremisesScannerDlpLocationException -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddOnPremisesScannerDlpLocationException', $ToBeAdded)
                }
                $CreationParams.Remove('OnPremisesScannerDlpLocationException')
            }

            # PowerBI Location Exception is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.PowerBIDlpLocationException -or `
                    $null -ne $this.PowerBIDlpLocationException)
            {
                $ToBeRemoved = $CurrentPolicy.PowerBIDlpLocationException | `
                        Where-Object { $this.PowerBIDlpLocationException -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemovePowerBIDlpLocationException', $ToBeRemoved)
                }

                $ToBeAdded = $this.PowerBIDlpLocationException | `
                        Where-Object { $CurrentPolicy.PowerBIDlpLocationException -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddPowerBIDlpLocationException', $ToBeAdded)
                }
                $CreationParams.Remove('PowerBIDlpLocationException')
            }

            # 3rd party Location Exception is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.ThirdPartyAppDlpLocationException -or `
                    $null -ne $this.ThirdPartyAppDlpLocationException)
            {
                $ToBeRemoved = $CurrentPolicy.ThirdPartyAppDlpLocationException | `
                        Where-Object { $this.ThirdPartyAppDlpLocationException -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemoveThirdPartyAppDlpLocationException', $ToBeRemoved)
                }

                $ToBeAdded = $this.ThirdPartyAppDlpLocationException | `
                        Where-Object { $CurrentPolicy.ThirdPartyAppDlpLocationException -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddThirdPartyAppDlpLocationException', $ToBeAdded)
                }
                $CreationParams.Remove('ThirdPartyAppDlpLocationException')
            }

            Write-Verbose "Updating Policy with values: $(Convert-M365DscHashtableToString -Hashtable $CreationParams)"
            Set-DLPCompliancePolicy @CreationParams
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            # If the Policy exists and it shouldn't, simply remove it;
            try
            {
                $policy = Get-DlpCompliancePolicy -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $policy)
                {
                    Write-Verbose -Message "Policy $($this.Name) was not found."
                }
                elseif ("$($policy.Mode)" -ne 'PendingDeletion')
                {
                    Remove-DLPCompliancePolicy -Identity $this.Name -Confirm:$false
                }
                else
                {
                    Write-Verbose -Message "Policy $($this.Name) is already in the process of being deleted."
                }
            }
            catch
            {
                $this.LogError($_, "Error removing the DLP compliance policy $($this.Name)")

                throw
            }
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $policies = Get-DLPCompliancePolicy -ErrorAction Stop | Where-Object -FilterScript { $_.Mode -ne 'PendingDeletion' }

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Name)" -DeferWrite
                $this.ExportedInstance = $policy
                $Results = $this.GetForExport(@{ Name = $policy.Name })
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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

    hidden [SCDLPCompliancePolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCDLPCompliancePolicy])
        {
            return $Values
        }

        $result = [SCDLPCompliancePolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
