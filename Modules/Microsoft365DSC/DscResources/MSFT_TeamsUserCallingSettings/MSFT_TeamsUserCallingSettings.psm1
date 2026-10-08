using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsUserCallingSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity of the user to set call forwarding, simultaneous ringing and call group settings for. Can be specified using the ObjectId or the SIP address.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The group notification override that will be set on the specified user. The supported values are Ring, Mute and Banner.')]
    [ValidateSet('Ring', 'Mute', 'Banner')]
    [System.String] $GroupNotificationOverride

    [DscProperty()]
    [System.ComponentModel.Description('The order in which to call members of the Call Group. The supported values are Simultaneous and InOrder.')]
    [System.String] $CallGroupOrder

    [DscProperty()]
    [System.ComponentModel.Description('The members of the Call Group. You need to always specify the full set of members as the parameter value. What you set here will overwrite the current call group membership.')]
    [System.String[]] $CallGroupTargets

    [DscProperty()]
    [System.ComponentModel.Description('This parameter controls whether forwarding for unasnwered calls is enabled or not.')]
    [System.Nullable[System.Boolean]] $IsUnansweredEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The time the call will ring the user before it is forwarded to the unanswered target. The supported format is hh:mm:ss and the delay range needs to be between 10 and 60 seconds in 10 seconds increments, i.e. 00:00:10, 00:00:20, 00:00:30, 00:00:40, 00:00:50 and 00:01:00. The default value is 20 seconds.')]
    [System.String] $UnansweredDelay

    [DscProperty()]
    [System.ComponentModel.Description('The unanswered target. Supported type of values are ObjectId, SIP address and phone number. For phone numbers we support the following types of formats: E.164 (+12065551234 or +1206555000;ext=1234) or non-E.164 like 1234.')]
    [System.String] $UnansweredTarget

    [DscProperty()]
    [System.ComponentModel.Description('The unanswered target type. Supported values are Voicemail, SingleTarget, MyDelegates and Group.')]
    [ValidateSet('Group', 'MyDelegates', 'SingleTarget', 'Voicemail')]
    [System.String] $UnansweredTargetType

    [DscProperty()]
    [System.ComponentModel.Description('This parameter controls whether forwarding is enabled or not.')]
    [System.Nullable[System.Boolean]] $IsForwardingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The type of forwarding to set. Supported values are Immediate and Simultaneous')]
    [ValidateSet('Immediate', 'Simultaneous')]
    [System.String] $ForwardingType

    [DscProperty()]
    [System.ComponentModel.Description('The forwarding target type. Supported values are Voicemail, SingleTarget, MyDelegates and Group. Voicemail is only supported for Immediate forwarding.')]
    [ValidateSet('Group', 'MyDelegates', 'SingleTarget', 'Voicemail')]
    [System.String] $ForwardingTargetType

    [DscProperty()]
    [System.ComponentModel.Description('The forwarding target. Supported types of values are ObjectId''s, SIP addresses and phone numbers. For phone numbers we support the following types of formats: E.164 (+12065551234 or +1206555000;ext=1234) or non-E.164 like 1234.')]
    [System.String] $ForwardingTarget

    [DscProperty()]
    [System.ComponentModel.Description('The busy on busy setting for the specified user. It controls what happens to a new incoming call when the user is already in a call or in a conference. Supported values are PlayBusySignal, RedirectAsUnansweredCall and RingUser. The setting applies when the Teams calling policy of the user has BusyOnBusyEnabledType set to UserOverride.')]
    [ValidateSet('PlayBusySignal', 'RedirectAsUnansweredCall', 'RingUser')]
    [System.String] $BusyOnBusyOption

    [DscProperty()]
    [System.ComponentModel.Description('The maximum number of concurrent calls for the specified user.')]
    [System.Nullable[System.Int32]] $MaximumConcurrentCalls

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Global Admin.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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

    [TeamsUserCallingSettings] Get()
    {
        ${$Identity} = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsUserCallingSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Teams Calling Policy $($this.Identity)"

        try
        {
            if (-not $this.ResourceCache['exportMode'])
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')
            }

            $nullReturn = $this.GetBoundParameters()
            $nullReturn.Ensure = 'Absent'

            $instance = Get-CsUserCallingSettings -Identity $this.Identity -ErrorAction 'SilentlyContinue'

            if ($null -eq $instance)
            {
                Write-Verbose -Message "Could not find Teams User Calling Settings for ${$Identity}"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Teams User Calling Settings for {$($this.Identity)}"
            return $this.AsResult(@{
                Identity                  = $this.Identity
                GroupNotificationOverride = $instance.GroupNotificationOverride
                CallGroupOrder            = $instance.CallGroupOrder
                CallGroupTargets          = [TeamsUserCallingSettings]::RemoveSipPrefix($instance.CallGroupTargets)
                IsUnansweredEnabled       = $instance.IsUnansweredEnabled
                UnansweredDelay           = $instance.UnansweredDelay
                UnansweredTarget          = [TeamsUserCallingSettings]::RemoveSipPrefix($instance.UnansweredTarget)
                UnansweredTargetType      = $instance.UnansweredTargetType
                IsForwardingEnabled       = $instance.IsForwardingEnabled
                ForwardingType            = $instance.ForwardingType
                ForwardingTargetType      = $instance.ForwardingTargetType
                ForwardingTarget          = [TeamsUserCallingSettings]::RemoveSipPrefix($instance.ForwardingTarget)
                BusyOnBusyOption          = $instance.BusyOnBusyOption
                MaximumConcurrentCalls    = $instance.MaximumConcurrentCalls
                Ensure                    = 'Present'
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                TenantId                  = $this.TenantId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                AccessTokens              = $this.AccessTokens
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

        Write-Verbose -Message 'Setting Teams User Calling Settings'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()
        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        if ($CurrentValues.Ensure -eq 'Absent')
        {
            $CurrentValues = @{}
        }

        foreach ($name in @('CallGroupTargets', 'UnansweredTarget', 'ForwardingTarget'))
        {
            if ($SetParameters.ContainsKey($name))
            {
                $SetParameters[$name] = [TeamsUserCallingSettings]::RemoveSipPrefix($SetParameters[$name])
            }
        }

        $parameterSets = [ordered]@{
            CallGroupNotification  = @('GroupNotificationOverride')
            Unanswered             = @('IsUnansweredEnabled', 'UnansweredDelay', 'UnansweredTargetType', 'UnansweredTarget')
            Forwarding             = @('IsForwardingEnabled', 'ForwardingType', 'ForwardingTargetType', 'ForwardingTarget')
            BusyOnBusy             = @('BusyOnBusyOption')
            MaximumConcurrentCalls = @('MaximumConcurrentCalls')
        }

        $callGroupPosition = 0
        if ($SetParameters.ContainsKey('CallGroupTargets') -and @($SetParameters.CallGroupTargets).Count -eq 0)
        {
            $callGroupPosition = 3
        }
        $parameterSets.Insert($callGroupPosition, 'CallGroup', @('CallGroupOrder', 'CallGroupTargets'))
        $optionalParameters = @('UnansweredTargetType', 'UnansweredTarget', 'ForwardingTarget')

        try
        {
            foreach ($parameterSet in $parameterSets.GetEnumerator())
            {
                $configured = [System.Collections.Generic.List[System.String]]::new()
                $isDrifted = $false
                foreach ($name in $parameterSet.Value)
                {
                    if ($SetParameters.ContainsKey($name))
                    {
                        $configured.Add($name)
                        $isDrifted = $isDrifted -or ((@($SetParameters[$name]) -join ';') -ne (@($CurrentValues[$name]) -join ';'))
                    }
                }

                if (-not $isDrifted)
                {
                    continue
                }

                $toggle = $parameterSet.Value[0]
                $parameters = @{
                    Identity = $this.Identity
                }
                if ($toggle -like 'Is*Enabled' -and ($false -eq $SetParameters[$toggle] -or ($configured.Count -eq 1 -and $configured[0] -eq $toggle)))
                {
                    $parameters[$toggle] = $SetParameters[$toggle]
                }
                else
                {
                    foreach ($name in $parameterSet.Value)
                    {
                        $value = $CurrentValues[$name]
                        if ($SetParameters.ContainsKey($name))
                        {
                            $value = $SetParameters[$name]
                        }

                        if ($null -ne $value)
                        {
                            $parameters[$name] = $value
                        }
                        elseif ($optionalParameters -notcontains $name)
                        {
                            throw "Could not update the $($parameterSet.Key) calling settings of Teams user {$($this.Identity)} because $name is neither configured nor set on the user."
                        }
                    }
                }

                Write-Verbose -Message "Updating the $($parameterSet.Key) calling settings of Teams user {$($this.Identity)}"
                Set-CsUserCallingSettings @parameters
            }
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                foreach ($name in @('CallGroupTargets', 'UnansweredTarget', 'ForwardingTarget'))
                {
                    if ($DesiredValues.ContainsKey($name))
                    {
                        $DesiredValues[$name] = [TeamsUserCallingSettings]::RemoveSipPrefix($DesiredValues[$name])
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden static [System.Object] RemoveSipPrefix([System.Object] $Value)
    {
        if ($null -eq $Value)
        {
            return $null
        }

        if ($Value -is [System.String])
        {
            return $Value -replace '^sip:', ''
        }

        return [System.String[]] @($Value | ForEach-Object -Process { "$_" -replace '^sip:', '' })
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $allUsers = Get-MgUser -All -Property 'UserPrincipalName'
            $i = 1
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            $dscContent = [System.Text.StringBuilder]::new()
            $this.ResourceCache['exportMode'] = $true
            foreach ($user in $allUsers)
            {
                Write-M365DSCHost -Message "    |---[$i/$($allUsers.Length)] $($user.UserPrincipalName)" -DeferWrite
                $params = @{
                    Identity              = $user.UserPrincipalName
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
                $Results = $this.GetForExport($Params)
                if ($Results.Ensure -eq 'Present')
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                }
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [TeamsUserCallingSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsUserCallingSettings])
        {
            return $Values
        }

        $result = [TeamsUserCallingSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
