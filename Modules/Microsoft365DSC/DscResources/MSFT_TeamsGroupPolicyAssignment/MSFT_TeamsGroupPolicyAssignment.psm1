using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsGroupPolicyAssignment : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Group Displayname of the group the policies are assigned to')]
    [System.String] $GroupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('GroupId, alternatively to Group Displayname')]
    [System.String] $GroupId

    [DscProperty(Key)]
    [System.ComponentModel.Description('Teams PolicyType. The type of the policy to be assigned. Possible values:')]
    [ValidateSet('ApplicationAccessPolicy', 'CallingLineIdentity', 'OnlineAudioConferencingRoutingPolicy', 'OnlineVoicemailPolicy', 'OnlineVoiceRoutingPolicy', 'TeamsAudioConferencingPolicy', 'TeamsCallHoldPolicy', 'TeamsCallParkPolicy', 'TeamsChannelsPolicy', 'TeamsComplianceRecordingPolicy', 'TeamsCortanaPolicy', 'TeamsEmergencyCallingPolicy', 'TeamsEnhancedEncryptionPolicy', 'TeamsFeedbackPolicy', 'TeamsFilesPolicy', 'TeamsIPPhonePolicy', 'TeamsMediaLoggingPolicy', 'TeamsMeetingBroadcastPolicy', 'TeamsMeetingPolicy', 'TeamsMessagingPolicy', 'TeamsMobilityPolicy', 'TeamsRoomVideoTeleConferencingPolicy', 'TeamsShiftsPolicy', 'TeamsUpdateManagementPolicy', 'TeamsVdiPolicy', 'TeamsVideoInteropServicePolicy', 'TenantDialPlan', 'ExternalAccessPolicy', 'TeamsAppSetupPolicy', 'TeamsCallingPolicy', 'TeamsEventsPolicy', 'TeamsMeetingBrandingPolicy', 'TeamsMeetingTemplatePermissionPolicy', 'TeamsVerticalPackagePolicy')]
    [System.String] $PolicyType

    [DscProperty()]
    [System.ComponentModel.Description('Teams PolicyName. The name of the policy to be assigned.')]
    [System.String] $PolicyName

    [DscProperty()]
    [System.ComponentModel.Description('Teams Priority. The rank of the policy assignment, relative to other group policy assignments for the same policy type')]
    [System.String] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the group policy assignment exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin')]
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

    [TeamsGroupPolicyAssignment] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsGroupPolicyAssignment]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Teams Group Policy Assignment for Group: $($this.GroupDisplayName)"

        try
        {
            $null = $this.Connect('MicrosoftTeams')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullReturn = $this.GetBoundParameters()
            $nullReturn.Ensure = 'Absent'

            Write-Verbose -Message "Getting Group with Id {$($this.GroupId)}"
            if ($this.GroupId -match '\b[A-Fa-f0-9]{8}(?:-[A-Fa-f0-9]{4}){3}-[A-Fa-f0-9]{12}\b' -and $this.GroupId -ne '00000000-0000-0000-0000-000000000000')
            {
                $Group = Find-CsGroup -SearchQuery $this.GroupId -ExactMatchOnly $true -ErrorAction Stop
            }
            else
            {
                $Group = $null
            }
            if ($null -eq $Group)
            {
                Write-Verbose -Message "Could not find Group with Id {$($this.GroupId)}, searching with DisplayName {$($this.GroupDisplayName)}"
                $Group = Find-CsGroup -SearchQuery $this.GroupDisplayName -ExactMatchOnly $true -ErrorAction Stop

                if ($null -eq $Group)
                {
                    Write-Verbose -Message "Could not find Group with DisplayName {$($this.GroupDisplayName)}"
                    return $this.AsResult($nullReturn)
                }

                if ($Group -and $Group.Count -gt 1)
                {
                    Write-Verbose -Message "Found $($Group.Count) groups with DisplayName {$($this.GroupDisplayName)}"
                    $Group = $Group | Where-Object -FilterScript { $_.DisplayName -eq $this.GroupDisplayName }
                    if ($Group -and $Group.Count -gt 1)
                    {
                        Write-Verbose -Message "Still found $($Group.Count) groups with DisplayName {$($this.GroupDisplayName)}"
                        return $this.AsResult($nullReturn)
                    }
                }
            }

            Write-Verbose -Message "Getting GroupPolicyAssignment with PolicyType {$($this.PolicyType)} for Group {$($Group.DisplayName)}"
            $AllGroupPolicyAssignment = Get-CsGroupPolicyAssignment -ErrorAction Stop
            $GroupPolicyAssignment = $AllGroupPolicyAssignment | Where-Object { $_.GroupId -eq $Group.Id -and $_.PolicyType -eq $this.PolicyType }
            if ($null -eq $GroupPolicyAssignment)
            {
                Write-Verbose -Message "GroupPolicyAssignment not found for Group {$($this.GroupDisplayName)}"
                $nullReturn.GroupId = $Group.Id
                return $this.AsResult($nullReturn)
            }

            $priorityValue = $null
            if ($null -ne $GroupPolicyAssignment.Priority)
            {
                $priorityValue = $GroupPolicyAssignment.Priority.ToString()
            }

            $Message = "Found GroupPolicyAssignment with PolicyType {$($GroupPolicyAssignment.PolicyType)}, " + `
                "PolicyName {$($GroupPolicyAssignment.PolicyName)} and Priority {$($GroupPolicyAssignment.Priority)} for Group {$($Group.Displayname)}"
            Write-Verbose -Message $Message
            return $this.AsResult(@{
                GroupId               = $Group.Id
                GroupDisplayName      = $Group.DisplayName
                PolicyType            = $GroupPolicyAssignment.PolicyType
                PolicyName            = $GroupPolicyAssignment.PolicyName
                Priority              = $priorityValue
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            })
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

        $CurrentValues = $this.Get().ToHashtable()

        try
        {
            if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Adding GroupPolicyAssignment for $($this.GroupDisplayName)"
                $parameters = @{
                    GroupId    = $CurrentValues.GroupId
                    PolicyType = $this.PolicyType
                    PolicyName = $this.PolicyName
                }

                if (-not [System.String]::IsNullOrEmpty($this.Priority))
                {
                    $parameters.Add('Rank', $this.Priority)
                }
                New-CsGroupPolicyAssignment @parameters `
                    -ErrorAction Stop
            }
            elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
            {
                #Set-CsGroupPolicyAssignment not implemented jet / use remove-add as described in docs
                Write-Verbose -Message "Remove GroupPolicyAssignment for $($this.GroupDisplayName)"
                Remove-CsGroupPolicyAssignment -GroupId $CurrentValues.GroupId -PolicyType $CurrentValues.PolicyType
                Write-Verbose -Message "Adding GroupPolicyAssignment for $($this.GroupDisplayName)"
                New-CsGroupPolicyAssignment -GroupId $CurrentValues.GroupId `
                    -PolicyType $this.PolicyType `
                    -PolicyName $this.PolicyName `
                    -Rank $this.Priority `
                    -ErrorAction Stop
            }
            elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Remove GroupPolicyAssignment for $($this.GroupDisplayName)"
                Remove-CsGroupPolicyAssignment -GroupId $CurrentValues.GroupId -PolicyType $CurrentValues.PolicyType
            }
        }
        catch
        {
            Write-Verbose -Message "Error: $($_.Exception.Message)"
            $this.LogError($_, "Error while setting GroupPolicyAssignment for $($this.GroupDisplayName)")
            throw $_
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

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$instances = Get-CsGroupPolicyAssignment
            if ($instances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $j = 1
            foreach ($item in $instances)
            {
                [array]$Group = Find-CsGroup -SearchQuery $item.GroupId -ExactMatchOnly $true
                if ($null -eq $Group -or $null -eq $Group.DisplayName)
                {
                    $Message = "Group with Id {$($item.GroupId)} could not be found, skipping assignment"
                    Write-M365DSCHost -Message $Message
                    $this.LogError($_, "Error during Export: $Message")

                    continue
                }

                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$j/$($instances.Length)] GroupPolicyAssignment {$($Group.DisplayName)-$($item.PolicyType)}" -DeferWrite
                $Params = @{
                    GroupDisplayName      = $Group.DisplayName
                    GroupId               = $item.GroupId
                    PolicyType            = $item.PolicyType
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -RawResults $rawResults
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite

                $j++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('GroupId')
        }
    }

    hidden [TeamsGroupPolicyAssignment] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsGroupPolicyAssignment])
        {
            return $Values
        }

        $result = [TeamsGroupPolicyAssignment]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
