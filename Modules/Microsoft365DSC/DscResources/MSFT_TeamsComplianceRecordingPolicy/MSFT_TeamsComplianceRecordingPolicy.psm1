using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsComplianceRecordingPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Unique identifier of the application instance of a policy-based recording application to be retrieved.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('A list of application instances of policy-based recording applications to assign to this policy. The Id of each of these application instances must be the ObjectId of the application instance as obtained by the Get-CsOnlineApplicationInstance cmdlet.')]
    [MSFT_TeamsComplianceRecordingApplication[]] $ComplianceRecordingApplications

    [DscProperty()]
    [System.ComponentModel.Description('Enables administrators to provide explanatory text to accompany a Teams recording policy. For example, the Description might include information about the users the policy should be assigned to.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Setting this attribute to true disables recording audio notifications for 1:1 calls that are under compliance recording.')]
    [System.Nullable[System.Boolean]] $DisableComplianceRecordingAudioNotificationForCalls

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether this Teams recording policy is active or not.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('Setting this attribute to true enables compliance recording for calls that have been re-routed from a compliance recording-enabled user. Supported call scenarios include forward, transfer, delegation, call groups, and simultaneous ring.')]
    [System.Nullable[System.Boolean]] $RecordReroutedCalls

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is reserved for future use.')]
    [System.Nullable[System.Boolean]] $WarnUserOnRemoval

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin')]
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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter = '*'

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [TeamsComplianceRecordingPolicy] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsComplianceRecordingPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for TeamsComplianceRecordingPolicy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-CsTeamsComplianceRecordingPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $ComplexComplianceRecordingApplications = @()
            foreach ($application in $instance.ComplianceRecordingApplications)
            {
                $ComplexComplianceRecordingApplications += @{
                    Id                                    = $application.Id
                    ComplianceRecordingPairedApplications = Get-M365DSCArrayFromProperty -PropertyValue $application.ComplianceRecordingPairedApplications.Id -ElementType ([System.String])
                    RequiredBeforeMeetingJoin             = $application.RequiredBeforeMeetingJoin
                    RequiredBeforeCallEstablishment       = $application.RequiredBeforeCallEstablishment
                    RequiredDuringMeeting                 = $application.RequiredDuringMeeting
                    RequiredDuringCall                    = $application.RequiredDuringCall
                    ConcurrentInvitationCount             = $application.ConcurrentInvitationCount
                }
            }

            Write-Verbose -Message "Found an instance with Identity {$($this.Identity)}"
            $results = @{
                Identity                                            = $instance.Identity
                ComplianceRecordingApplications                     = $ComplexComplianceRecordingApplications
                Description                                         = $instance.Description
                DisableComplianceRecordingAudioNotificationForCalls = $instance.DisableComplianceRecordingAudioNotificationForCalls
                Enabled                                             = $instance.Enabled
                RecordReroutedCalls                                 = $instance.RecordReroutedCalls
                WarnUserOnRemoval                                   = $instance.WarnUserOnRemoval
                Ensure                                              = 'Present'
                Credential                                          = $this.Credential
                ApplicationId                                       = $this.ApplicationId
                TenantId                                            = $this.TenantId
                CertificateThumbprint                               = $this.CertificateThumbprint
                CertificatePath                                     = $this.CertificatePath
                CertificatePassword                                 = $this.CertificatePassword
                ManagedIdentity                                     = $this.ManagedIdentity
                AccessTokens                                        = $this.AccessTokens
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

        $policyParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $policyParameters.Remove('ComplianceRecordingApplications')
        $manageApplications = $this.GetBoundParameters().ContainsKey('ComplianceRecordingApplications')

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a Teams Compliance Recording Policy with Identity {$($this.Identity)}"
            New-CsTeamsComplianceRecordingPolicy @policyParameters -ErrorAction Stop

            if ($manageApplications)
            {
                $policy = Get-CsTeamsComplianceRecordingPolicy -Identity $this.Identity -ErrorAction Stop
                $this.SetComplianceRecordingApplications($policy.Identity, @())
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Teams Compliance Recording Policy with Identity {$($this.Identity)}"
            if ($policyParameters.Count -gt 1)
            {
                Set-CsTeamsComplianceRecordingPolicy @policyParameters -ErrorAction Stop
            }

            if ($manageApplications)
            {
                $this.SetComplianceRecordingApplications($currentInstance.Identity, $currentInstance.ComplianceRecordingApplications)
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Teams Compliance Recording Policy with Identity {$($this.Identity)}"
            Remove-CsTeamsComplianceRecordingPolicy -Identity $currentInstance.Identity
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
            [array]$getValue = Get-CsTeamsComplianceRecordingPolicy -Filter $this.Filter -ErrorAction Stop

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

                $displayedKey = $config.Identity
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.Identity
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)

                if ($null -ne $Results.ComplianceRecordingApplications)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'ComplianceRecordingApplications'
                            CimInstanceName = 'TeamsComplianceRecordingApplication'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ComplianceRecordingApplications `
                        -CIMInstanceName 'TeamsComplianceRecordingApplication' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ComplianceRecordingApplications = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ComplianceRecordingApplications') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ComplianceRecordingApplications')
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

    hidden [void] SetComplianceRecordingApplications([System.String] $PolicyIdentity, [System.Object[]] $CurrentApplications)
    {
        $desiredIds = Get-M365DSCArrayFromProperty -PropertyValue $this.ComplianceRecordingApplications.Id -ElementType ([System.String])
        $currentIds = Get-M365DSCArrayFromProperty -PropertyValue $CurrentApplications.Id -ElementType ([System.String])

        foreach ($currentId in $currentIds)
        {
            if ($currentId -notin $desiredIds)
            {
                Write-Verbose -Message "Removing compliance recording application {$currentId} from policy {$PolicyIdentity}"
                Remove-CsTeamsComplianceRecordingApplication -Identity "$PolicyIdentity/$currentId" -ErrorAction Stop
            }
        }

        foreach ($application in $this.ComplianceRecordingApplications)
        {
            $applicationParameters = @{
                Identity = "$PolicyIdentity/$($application.Id)"
            }
            foreach ($property in @('RequiredBeforeMeetingJoin', 'RequiredBeforeCallEstablishment', 'RequiredDuringMeeting', 'RequiredDuringCall'))
            {
                if ($null -ne $application.$property)
                {
                    $applicationParameters.Add($property, $application.$property)
                }
            }

            if (-not [System.String]::IsNullOrEmpty($application.ConcurrentInvitationCount))
            {
                $applicationParameters.Add('ConcurrentInvitationCount', [System.UInt32] $application.ConcurrentInvitationCount)
            }

            if ($null -ne $application.ComplianceRecordingPairedApplications)
            {
                $pairedApplications = @()
                foreach ($pairedApplicationId in $application.ComplianceRecordingPairedApplications)
                {
                    $pairedApplications += New-CsTeamsComplianceRecordingPairedApplication -Id $pairedApplicationId
                }
                $applicationParameters.Add('ComplianceRecordingPairedApplications', $pairedApplications)
            }

            if ($application.Id -notin $currentIds)
            {
                Write-Verbose -Message "Adding compliance recording application {$($application.Id)} to policy {$PolicyIdentity}"
                New-CsTeamsComplianceRecordingApplication @applicationParameters -ErrorAction Stop | Out-Null
            }
            elseif ($applicationParameters.Count -gt 1)
            {
                Write-Verbose -Message "Updating compliance recording application {$($application.Id)} of policy {$PolicyIdentity}"
                Set-CsTeamsComplianceRecordingApplication @applicationParameters -ErrorAction Stop
            }
        }
    }

    hidden [TeamsComplianceRecordingPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsComplianceRecordingPolicy])
        {
            return $Values
        }

        $result = [TeamsComplianceRecordingPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_TeamsComplianceRecordingApplication
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('A name that uniquely identifies the application instance of the policy-based recording application.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Determines the other policy-based recording applications to pair with this application to achieve application resiliency. Can only have one paired application.')]
    [System.String[]] $ComplianceRecordingPairedApplications

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the policy-based recording application must be in the meeting before the user is allowed to join the meeting.')]
    [System.Nullable[System.Boolean]] $RequiredBeforeMeetingJoin

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the policy-based recording application must be in the call before the call is allowed to establish.')]
    [System.Nullable[System.Boolean]] $RequiredBeforeCallEstablishment

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the policy-based recording application must be in the meeting while the user is in the meeting.')]
    [System.Nullable[System.Boolean]] $RequiredDuringMeeting

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the policy-based recording application must be in the call while the call is active.')]
    [System.Nullable[System.Boolean]] $RequiredDuringCall

    [DscProperty()]
    [System.ComponentModel.Description('Determines the number of invites to send out to the application instance of the policy-based recording application. Can be set to 1 or 2 only.')]
    [System.String] $ConcurrentInvitationCount
}
