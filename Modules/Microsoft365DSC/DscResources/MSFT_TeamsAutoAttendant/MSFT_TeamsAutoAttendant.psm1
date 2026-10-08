using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsAutoAttendant : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The friendly name of the auto attendant.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The language used to read text-to-speech prompts, for example en-US. Required when the auto attendant is created.')]
    [System.String] $LanguageId

    [DscProperty()]
    [System.ComponentModel.Description('The voice used to read text-to-speech prompts, for example Female or Male.')]
    [System.String] $VoiceId

    [DscProperty()]
    [System.ComponentModel.Description('The time zone every schedule of the auto attendant is evaluated in, for example Pacific Standard Time. Required when the auto attendant is created.')]
    [System.String] $TimeZoneId

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether callers can answer the auto attendant by voice.')]
    [System.Nullable[System.Boolean]] $EnableVoiceResponse

    [DscProperty()]
    [System.ComponentModel.Description('The call flow executed when no other call flow is in effect, for example during business hours. Required when the auto attendant is created.')]
    [MSFT_TeamsAutoAttendantCallFlow] $DefaultCallFlow

    [DscProperty()]
    [System.ComponentModel.Description('The call flows referenced by the call handling associations.')]
    [MSFT_TeamsAutoAttendantCallFlow[]] $CallFlows

    [DscProperty()]
    [System.ComponentModel.Description('The associations that decide which call flow runs while a schedule is in effect.')]
    [MSFT_TeamsAutoAttendantCallHandlingAssociation[]] $CallHandlingAssociations

    [DscProperty()]
    [System.ComponentModel.Description('The operator callers are transferred to.')]
    [MSFT_TeamsAutoAttendantCallableEntity] $Operator

    [DscProperty()]
    [System.ComponentModel.Description('The ids of the groups whose members are reachable through directory search. When empty, every user of the organization is reachable.')]
    [System.String[]] $InclusionScopeGroupIds

    [DscProperty()]
    [System.ComponentModel.Description('The ids of the groups whose members are not reachable through directory search.')]
    [System.String[]] $ExclusionScopeGroupIds

    [DscProperty()]
    [System.ComponentModel.Description('The user principal names of the users authorized to make changes to the auto attendant. The users need a TeamsVoiceApplications policy.')]
    [System.String[]] $AuthorizedUsers

    [DscProperty()]
    [System.ComponentModel.Description('The user principal names of the authorized users hidden from the Teams client.')]
    [System.String[]] $HideAuthorizedUsers

    [DscProperty()]
    [System.ComponentModel.Description('The information appended to user names in dial by name search results to tell users with the same name apart.')]
    [ValidateSet('None', 'Office', 'Department')]
    [System.String] $UserNameExtension

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether Mainline Attendant is enabled. The auto attendant needs a resource account.')]
    [System.Nullable[System.Boolean]] $EnableMainlineAttendant

    [DscProperty()]
    [System.ComponentModel.Description('The voice used by Mainline Attendant.')]
    [ValidateSet('Alloy', 'Echo', 'Shimmer')]
    [System.String] $MainlineAttendantAgentVoiceId

    [DscProperty()]
    [System.ComponentModel.Description('The id of the auto recording template applied to the auto attendant. Requires Mainline Attendant to be enabled.')]
    [System.String] $AutoRecordingTemplateId

    [DscProperty()]
    [System.ComponentModel.Description('The id of the Mainline Attendant spam detection template assigned to the auto attendant.')]
    [System.String] $SpamDetectionTemplateId

    [DscProperty()]
    [System.ComponentModel.Description('The id of the shared voicemail triage settings template that turns on the automatic triage of shared voicemails.')]
    [System.String] $SharedVoicemailTriageSettingsTemplateId

    [DscProperty()]
    [System.ComponentModel.Description('The user principal names of the resource accounts associated with the auto attendant.')]
    [System.String[]] $ApplicationInstances

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the auto attendant should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Entra ID application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [TeamsAutoAttendant] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsAutoAttendant]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Teams Auto Attendant {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $autoAttendant = [TeamsAutoAttendant]::GetAutoAttendantInstance($this.Name)
            }
            else
            {
                $autoAttendant = $this.ExportedInstance
            }

            if ($null -eq $autoAttendant)
            {
                Write-Verbose -Message "No Teams Auto Attendant with Name {$($this.Name)} was found"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Teams Auto Attendant with Name {$($this.Name)}"

            $cache = $this.ResourceCache

            $callFlowsValue = @()
            foreach ($callFlow in $autoAttendant.CallFlows)
            {
                $callFlowsValue += [TeamsAutoAttendant]::GetCallFlowAsHashtable($cache, $callFlow)
            }

            $associationsValue = @()
            foreach ($association in $autoAttendant.CallHandlingAssociations)
            {
                $scheduleId = $association.ScheduleId
                $schedule = @($autoAttendant.Schedules) | Where-Object -FilterScript { $null -ne $_ -and $_.Id -eq $scheduleId } |
                    Select-Object -First 1
                if ($null -eq $schedule)
                {
                    $schedule = [TeamsAutoAttendant]::GetSchedules($cache) | Where-Object -FilterScript { $_.Id -eq $scheduleId } |
                        Select-Object -First 1
                }

                $scheduleName = $scheduleId
                if ($null -ne $schedule)
                {
                    $scheduleName = $schedule.Name
                }

                $callFlowId = $association.CallFlowId
                $associatedCallFlow = @($autoAttendant.CallFlows) | Where-Object -FilterScript { $null -ne $_ -and $_.Id -eq $callFlowId } |
                    Select-Object -First 1
                $callFlowName = $callFlowId
                if ($null -ne $associatedCallFlow)
                {
                    $callFlowName = $associatedCallFlow.Name
                }

                $associationsValue += @{
                    Type         = [System.String] $association.Type
                    ScheduleName = $scheduleName
                    CallFlowName = $callFlowName
                    Enabled      = [System.Boolean] $association.Enabled
                }
            }

            $inclusionScopeValue = @()
            $exclusionScopeValue = @()
            if ($null -ne $autoAttendant.DirectoryLookupScope)
            {
                $inclusionScopeValue = [TeamsAutoAttendant]::GetDialScopeGroupIds($autoAttendant.DirectoryLookupScope.InclusionScope)
                $exclusionScopeValue = [TeamsAutoAttendant]::GetDialScopeGroupIds($autoAttendant.DirectoryLookupScope.ExclusionScope)
            }

            $authorizedUsersValue = @()
            foreach ($userId in $autoAttendant.AuthorizedUsers)
            {
                $authorizedUsersValue += [TeamsAutoAttendant]::GetPrincipalName($cache, $userId.ToString())
            }

            $hideAuthorizedUsersValue = @()
            foreach ($userId in $autoAttendant.HideAuthorizedUsers)
            {
                $hideAuthorizedUsersValue += [TeamsAutoAttendant]::GetPrincipalName($cache, $userId.ToString())
            }

            $applicationInstancesValue = @()
            foreach ($accountId in $autoAttendant.ApplicationInstances)
            {
                $applicationInstancesValue += [TeamsAutoAttendant]::GetPrincipalName($cache, $accountId)
            }

            $result = @{
                Name                                    = $autoAttendant.Name
                LanguageId                              = $autoAttendant.LanguageId
                VoiceId                                 = $autoAttendant.VoiceId
                TimeZoneId                              = $autoAttendant.TimeZoneId
                EnableVoiceResponse                     = [System.Boolean] $autoAttendant.VoiceResponseEnabled
                CallFlows                               = [System.Array] $callFlowsValue
                CallHandlingAssociations                = [System.Array] $associationsValue
                InclusionScopeGroupIds                  = [System.String[]] $inclusionScopeValue
                ExclusionScopeGroupIds                  = [System.String[]] $exclusionScopeValue
                AuthorizedUsers                         = [System.String[]] $authorizedUsersValue
                HideAuthorizedUsers                     = [System.String[]] $hideAuthorizedUsersValue
                UserNameExtension                       = [System.String] $autoAttendant.UserNameExtension
                EnableMainlineAttendant                 = [System.Boolean] $autoAttendant.MainlineAttendantEnabled
                MainlineAttendantAgentVoiceId           = $autoAttendant.MainlineAttendantAgentVoiceId
                AutoRecordingTemplateId                 = $autoAttendant.AutoRecordingTemplateId
                SpamDetectionTemplateId                 = $autoAttendant.SpamDetectionTemplateId
                SharedVoicemailTriageSettingsTemplateId = $autoAttendant.SharedVoicemailTriageSettingsTemplateId
                ApplicationInstances                    = [System.String[]] $applicationInstancesValue
                Ensure                                  = 'Present'
                Credential                              = $this.Credential
                ApplicationId                           = $this.ApplicationId
                TenantId                                = $this.TenantId
                CertificateThumbprint                   = $this.CertificateThumbprint
                ManagedIdentity                         = $this.ManagedIdentity
                AccessTokens                            = $this.AccessTokens
            }

            if ($null -ne $autoAttendant.DefaultCallFlow)
            {
                $result.DefaultCallFlow = [TeamsAutoAttendant]::GetCallFlowAsHashtable($cache, $autoAttendant.DefaultCallFlow)
            }

            if ($null -ne $autoAttendant.Operator)
            {
                $result.Operator = [TeamsAutoAttendant]::GetCallableEntityAsHashtable($cache, $autoAttendant.Operator)
            }

            if ([System.String]::IsNullOrEmpty($result.MainlineAttendantAgentVoiceId) -or $result.MainlineAttendantAgentVoiceId -eq 'None')
            {
                $result.Remove('MainlineAttendantAgentVoiceId')
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

        Write-Verbose -Message "Setting configuration of Teams Auto Attendant {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            $currentInstance = $this.Get().ToHashtable()
            $boundParameters = $this.GetBoundParameters()
            $cache = $this.ResourceCache
            $autoAttendant = $null
            $currentApplicationInstances = @()

            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new Teams Auto Attendant {$($this.Name)}"

                foreach ($requiredProperty in @('LanguageId', 'TimeZoneId', 'DefaultCallFlow'))
                {
                    if ($null -eq $this.$requiredProperty)
                    {
                        throw "The property '$requiredProperty' is required to create the Teams Auto Attendant {$($this.Name)}."
                    }
                }

                $callFlowObjects = @()
                foreach ($callFlow in $this.CallFlows)
                {
                    $callFlowObjects += [TeamsAutoAttendant]::NewCallFlowObject($cache, $callFlow)
                }

                $createParameters = @{
                    Name            = $this.Name
                    LanguageId      = $this.LanguageId
                    TimeZoneId      = $this.TimeZoneId
                    DefaultCallFlow = [TeamsAutoAttendant]::NewCallFlowObject($cache, $this.DefaultCallFlow)
                }

                if ($callFlowObjects.Count -gt 0)
                {
                    $createParameters.CallFlows = $callFlowObjects
                }

                if ($this.CallHandlingAssociations.Count -gt 0)
                {
                    $createParameters.CallHandlingAssociations = [TeamsAutoAttendant]::NewCallHandlingAssociationObjects($cache, $this.CallHandlingAssociations, $callFlowObjects, $this.Name)
                }

                if (-not [System.String]::IsNullOrEmpty($this.VoiceId))
                {
                    $createParameters.VoiceId = $this.VoiceId
                }

                if ($null -ne $this.Operator)
                {
                    $createParameters.Operator = [TeamsAutoAttendant]::NewCallableEntityObject($cache, $this.Operator)
                }

                if ($this.InclusionScopeGroupIds.Count -gt 0)
                {
                    $createParameters.InclusionScope = New-CsAutoAttendantDialScope -GroupScope -GroupIds $this.InclusionScopeGroupIds
                }

                if ($this.ExclusionScopeGroupIds.Count -gt 0)
                {
                    $createParameters.ExclusionScope = New-CsAutoAttendantDialScope -GroupScope -GroupIds $this.ExclusionScopeGroupIds
                }

                if ($this.AuthorizedUsers.Count -gt 0)
                {
                    $createParameters.AuthorizedUsers = [System.Guid[]] [TeamsAutoAttendant]::GetPrincipalIds($cache, $this.AuthorizedUsers)
                }

                if ($this.HideAuthorizedUsers.Count -gt 0)
                {
                    $createParameters.HideAuthorizedUsers = [System.Guid[]] [TeamsAutoAttendant]::GetPrincipalIds($cache, $this.HideAuthorizedUsers)
                }

                foreach ($propertyName in @('MainlineAttendantAgentVoiceId', 'AutoRecordingTemplateId', 'SpamDetectionTemplateId', 'SharedVoicemailTriageSettingsTemplateId'))
                {
                    if (-not [System.String]::IsNullOrEmpty($this.$propertyName))
                    {
                        $createParameters.$propertyName = $this.$propertyName
                    }
                }

                if ($null -ne $this.EnableVoiceResponse)
                {
                    $createParameters.EnableVoiceResponse = [System.Boolean] $this.EnableVoiceResponse
                }

                if ($null -ne $this.EnableMainlineAttendant)
                {
                    $createParameters.EnableMainlineAttendant = [System.Boolean] $this.EnableMainlineAttendant
                }

                $autoAttendant = New-CsAutoAttendant @createParameters

                # New-CsAutoAttendant forwards UserNameExtension to its internal status lookup, which
                # rejects it after the auto attendant was already created.
                if (-not [System.String]::IsNullOrEmpty($this.UserNameExtension))
                {
                    $autoAttendant.UserNameExtension = $this.UserNameExtension
                    Set-CsAutoAttendant -Instance $autoAttendant | Out-Null
                }
            }
            elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating Teams Auto Attendant {$($this.Name)}"

                $autoAttendant = [TeamsAutoAttendant]::GetAutoAttendantInstance($this.Name)
                $currentApplicationInstances = @($autoAttendant.ApplicationInstances)

                foreach ($propertyName in @('LanguageId', 'VoiceId', 'TimeZoneId', 'UserNameExtension', 'MainlineAttendantAgentVoiceId', 'AutoRecordingTemplateId', 'SpamDetectionTemplateId', 'SharedVoicemailTriageSettingsTemplateId'))
                {
                    if ($boundParameters.ContainsKey($propertyName))
                    {
                        $autoAttendant.$propertyName = $this.$propertyName
                    }
                }

                if ($boundParameters.ContainsKey('EnableVoiceResponse'))
                {
                    $autoAttendant.VoiceResponseEnabled = [System.Boolean] $this.EnableVoiceResponse
                }

                if ($boundParameters.ContainsKey('EnableMainlineAttendant'))
                {
                    $autoAttendant.MainlineAttendantEnabled = [System.Boolean] $this.EnableMainlineAttendant
                }

                if ($boundParameters.ContainsKey('DefaultCallFlow'))
                {
                    $autoAttendant.DefaultCallFlow = [TeamsAutoAttendant]::NewCallFlowObject($cache, $this.DefaultCallFlow)
                }

                if ($boundParameters.ContainsKey('CallFlows'))
                {
                    $callFlowObjects = @()
                    foreach ($callFlow in $this.CallFlows)
                    {
                        $callFlowObjects += [TeamsAutoAttendant]::NewCallFlowObject($cache, $callFlow)
                    }
                    $autoAttendant.CallFlows = $callFlowObjects
                }

                if ($boundParameters.ContainsKey('CallFlows') -or $boundParameters.ContainsKey('CallHandlingAssociations'))
                {
                    $desiredAssociations = $currentInstance.CallHandlingAssociations
                    if ($boundParameters.ContainsKey('CallHandlingAssociations'))
                    {
                        $desiredAssociations = $this.CallHandlingAssociations
                    }

                    $autoAttendant.CallHandlingAssociations = [TeamsAutoAttendant]::NewCallHandlingAssociationObjects($cache, $desiredAssociations, @($autoAttendant.CallFlows), $this.Name)
                }

                if ($boundParameters.ContainsKey('Operator'))
                {
                    $autoAttendant.Operator = $null
                    if ($null -ne $this.Operator)
                    {
                        $autoAttendant.Operator = [TeamsAutoAttendant]::NewCallableEntityObject($cache, $this.Operator)
                    }
                }

                if ($boundParameters.ContainsKey('InclusionScopeGroupIds') -or $boundParameters.ContainsKey('ExclusionScopeGroupIds'))
                {
                    if ($null -eq $autoAttendant.DirectoryLookupScope)
                    {
                        $autoAttendant.DirectoryLookupScope = New-Object -TypeName 'Microsoft.Rtc.Management.Hosted.OAA.Models.DirectoryLookupScope'
                    }

                    if ($boundParameters.ContainsKey('InclusionScopeGroupIds'))
                    {
                        $autoAttendant.DirectoryLookupScope.InclusionScope = $null
                        if ($this.InclusionScopeGroupIds.Count -gt 0)
                        {
                            $autoAttendant.DirectoryLookupScope.InclusionScope = New-CsAutoAttendantDialScope -GroupScope -GroupIds $this.InclusionScopeGroupIds
                        }
                    }

                    if ($boundParameters.ContainsKey('ExclusionScopeGroupIds'))
                    {
                        $autoAttendant.DirectoryLookupScope.ExclusionScope = $null
                        if ($this.ExclusionScopeGroupIds.Count -gt 0)
                        {
                            $autoAttendant.DirectoryLookupScope.ExclusionScope = New-CsAutoAttendantDialScope -GroupScope -GroupIds $this.ExclusionScopeGroupIds
                        }
                    }
                }

                if ($boundParameters.ContainsKey('AuthorizedUsers'))
                {
                    $autoAttendant.AuthorizedUsers = [System.Guid[]] [TeamsAutoAttendant]::GetPrincipalIds($cache, $this.AuthorizedUsers)
                }

                if ($boundParameters.ContainsKey('HideAuthorizedUsers'))
                {
                    $autoAttendant.HideAuthorizedUsers = [System.Guid[]] [TeamsAutoAttendant]::GetPrincipalIds($cache, $this.HideAuthorizedUsers)
                }

                Set-CsAutoAttendant -Instance $autoAttendant | Out-Null
            }
            elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing Teams Auto Attendant {$($this.Name)}"

                $autoAttendant = [TeamsAutoAttendant]::GetAutoAttendantInstance($this.Name)
                $associatedIds = @($autoAttendant.ApplicationInstances | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
                if ($associatedIds.Count -gt 0)
                {
                    Write-Verbose -Message "Dissociating resource accounts {$($associatedIds -join ', ')} from Teams Auto Attendant {$($this.Name)}"
                    Remove-CsOnlineApplicationInstanceAssociation -Identities $associatedIds | Out-Null
                }
                Remove-CsAutoAttendant -Identity $autoAttendant.Identity | Out-Null
                return
            }

            if ($this.Ensure -eq 'Present' -and $boundParameters.ContainsKey('ApplicationInstances') -and $null -ne $autoAttendant)
            {
                $desiredIds = @([TeamsAutoAttendant]::GetPrincipalIds($cache, $this.ApplicationInstances))
                $currentIds = @($currentApplicationInstances | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
                $idsToAdd = @($desiredIds | Where-Object -FilterScript { $_ -notin $currentIds })
                $idsToRemove = @($currentIds | Where-Object -FilterScript { $_ -notin $desiredIds })

                if ($idsToAdd.Count -gt 0)
                {
                    Write-Verbose -Message "Associating resource accounts {$($idsToAdd -join ', ')} with Teams Auto Attendant {$($this.Name)}"
                    New-CsOnlineApplicationInstanceAssociation -Identities $idsToAdd `
                        -ConfigurationId $autoAttendant.Identity `
                        -ConfigurationType 'AutoAttendant' | Out-Null
                }

                if ($idsToRemove.Count -gt 0)
                {
                    Write-Verbose -Message "Dissociating resource accounts {$($idsToRemove -join ', ')} from Teams Auto Attendant {$($this.Name)}"
                    Remove-CsOnlineApplicationInstanceAssociation -Identities $idsToRemove | Out-Null
                }
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
            $getParameters = @{
                First       = 100
                ErrorAction = 'Stop'
            }
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $getParameters.NameFilter = $this.Filter
            }

            [array] $exportedInstances = @()
            $currentBatch = $null
            $offset = 0
            do
            {
                [array] $currentBatch = Get-CsAutoAttendant @getParameters -Skip $offset
                if ($null -ne $currentBatch)
                {
                    $exportedInstances += $currentBatch
                    $offset += $currentBatch.Count
                }
            } while ($currentBatch.Count -eq 100)

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            $complexProperties = [ordered]@{
                DefaultCallFlow          = 'TeamsAutoAttendantCallFlow'
                CallFlows                = 'TeamsAutoAttendantCallFlow'
                CallHandlingAssociations = 'TeamsAutoAttendantCallHandlingAssociation'
                Operator                 = 'TeamsAutoAttendantCallableEntity'
            }
            $complexMapping = @(
                @{ Name = 'Greetings'; CimInstanceName = 'TeamsAutoAttendantPrompt'; IsRequired = $false }
                @{ Name = 'Menu'; CimInstanceName = 'TeamsAutoAttendantMenu'; IsRequired = $false }
                @{ Name = 'Prompts'; CimInstanceName = 'TeamsAutoAttendantPrompt'; IsRequired = $false }
                @{ Name = 'MenuOptions'; CimInstanceName = 'TeamsAutoAttendantMenuOption'; IsRequired = $false }
                @{ Name = 'Prompt'; CimInstanceName = 'TeamsAutoAttendantPrompt'; IsRequired = $false }
                @{ Name = 'CallTarget'; CimInstanceName = 'TeamsAutoAttendantCallableEntity'; IsRequired = $false }
            )

            foreach ($exportedInstance in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($exportedInstance.Name)" -DeferWrite

                $Params = @{
                    Name                  = $exportedInstance.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $exportedInstance
                $Results = $this.GetForExport($Params)

                $noEscape = @()
                foreach ($propertyName in $complexProperties.Keys)
                {
                    if ($null -eq $Results.$propertyName)
                    {
                        continue
                    }

                    $cimInstanceName = $complexProperties[$propertyName]
                    $propertyMapping = @(@{ Name = $propertyName; CimInstanceName = $cimInstanceName; IsRequired = $false }) + $complexMapping
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.$propertyName `
                        -CIMInstanceName $cimInstanceName `
                        -ComplexTypeMapping $propertyMapping

                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.$propertyName = $complexTypeStringResult
                        $noEscape += $propertyName
                    }
                    else
                    {
                        $Results.Remove($propertyName) | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape $noEscape
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }

            return $dscContent.ToString()
        }
        catch
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX

            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden static [System.Object] GetAutoAttendantInstance([System.String] $AutoAttendantName)
    {
        $candidates = @(Get-CsAutoAttendant -NameFilter $AutoAttendantName -ErrorAction SilentlyContinue |
                Where-Object -FilterScript { $_.Name -eq $AutoAttendantName })

        if ($candidates.Count -gt 1)
        {
            Write-Warning -Message "Found $($candidates.Count) Teams Auto Attendants named {$AutoAttendantName}. Only the first one is managed."
        }

        if ($candidates.Count -eq 0)
        {
            return $null
        }

        return $candidates[0]
    }

    hidden static [System.String] GetPrincipalName([System.Collections.Hashtable] $Cache, [System.String] $ObjectId)
    {
        if (-not $Cache.ContainsKey('PrincipalNames'))
        {
            $Cache.PrincipalNames = @{}
        }

        if (-not $Cache.PrincipalNames.ContainsKey($ObjectId))
        {
            $principalName = $ObjectId
            $account = Get-CsOnlineUser -Identity $ObjectId -Properties UserPrincipalName -ErrorAction SilentlyContinue
            if ($null -eq $account)
            {
                Write-Warning -Message "Unable to resolve the account with object id {$ObjectId} referenced by a Teams Auto Attendant. Ensure the account exists and can be read by the account used for authentication."
            }
            else
            {
                $principalName = $account.UserPrincipalName
            }

            $Cache.PrincipalNames[$ObjectId] = $principalName
        }

        return $Cache.PrincipalNames[$ObjectId]
    }

    hidden static [System.String] GetPrincipalId([System.Collections.Hashtable] $Cache, [System.String] $PrincipalName)
    {
        $parsedId = [System.Guid]::Empty
        if ([System.Guid]::TryParse($PrincipalName, [ref] $parsedId))
        {
            return $PrincipalName
        }

        if (-not $Cache.ContainsKey('PrincipalIds'))
        {
            $Cache.PrincipalIds = @{}
        }

        if (-not $Cache.PrincipalIds.ContainsKey($PrincipalName))
        {
            $account = Get-CsOnlineUser -Identity $PrincipalName -Properties Identity -ErrorAction SilentlyContinue
            if ($null -eq $account)
            {
                Write-Warning -Message "Unable to resolve the account {$PrincipalName} referenced by a Teams Auto Attendant. Ensure the account exists and can be read by the account used for authentication."
                return $null
            }

            $Cache.PrincipalIds[$PrincipalName] = [System.String] $account.Identity
        }

        return $Cache.PrincipalIds[$PrincipalName]
    }

    hidden static [System.String[]] GetPrincipalIds([System.Collections.Hashtable] $Cache, [System.String[]] $PrincipalNames)
    {
        $result = @()
        foreach ($principalName in $PrincipalNames)
        {
            $principalId = [TeamsAutoAttendant]::GetPrincipalId($Cache, $principalName)
            if (-not [System.String]::IsNullOrEmpty($principalId))
            {
                $result += $principalId
            }
        }

        return [System.String[]] $result
    }

    hidden static [System.String[]] GetDialScopeGroupIds([System.Object] $DialScope)
    {
        if ($null -eq $DialScope -or $null -eq $DialScope.GroupScope)
        {
            return [System.String[]] @()
        }

        return [System.String[]] @($DialScope.GroupScope.GroupIds)
    }

    hidden static [System.Object[]] GetSchedules([System.Collections.Hashtable] $Cache)
    {
        if (-not $Cache.ContainsKey('Schedules'))
        {
            $Cache.Schedules = @(Get-CsOnlineSchedule -ErrorAction Stop)
        }

        return $Cache.Schedules
    }

    hidden static [System.Collections.Hashtable] GetPromptAsHashtable([System.Object] $Prompt)
    {
        $result = @{
            ActiveType = [System.String] $Prompt.ActiveType
        }

        if (-not [System.String]::IsNullOrEmpty($Prompt.TextToSpeechPrompt))
        {
            $result.TextToSpeechPrompt = $Prompt.TextToSpeechPrompt
        }

        if ($null -ne $Prompt.AudioFilePrompt)
        {
            $result.AudioFilePromptId = $Prompt.AudioFilePrompt.Id
            $result.AudioFilePromptFileName = $Prompt.AudioFilePrompt.FileName
        }

        return $result
    }

    hidden static [System.Collections.Hashtable] GetCallableEntityAsHashtable([System.Collections.Hashtable] $Cache, [System.Object] $CallableEntity)
    {
        $entityType = [System.String] $CallableEntity.Type
        $identity = $CallableEntity.Id
        if ($entityType -in @('User', 'ApplicationEndpoint'))
        {
            $identity = [TeamsAutoAttendant]::GetPrincipalName($Cache, $CallableEntity.Id)
        }

        $result = @{
            Identity = $identity
            Type     = $entityType
        }

        if ($null -ne $CallableEntity.EnableTranscription)
        {
            $result.EnableTranscription = [System.Boolean] $CallableEntity.EnableTranscription
        }

        if ($null -ne $CallableEntity.EnableSharedVoicemailSystemPromptSuppression)
        {
            $result.EnableSharedVoicemailSystemPromptSuppression = [System.Boolean] $CallableEntity.EnableSharedVoicemailSystemPromptSuppression
        }

        if ($CallableEntity.CallPriority -gt 0)
        {
            $result.CallPriority = [System.Int32] $CallableEntity.CallPriority
        }

        if (-not [System.String]::IsNullOrEmpty($CallableEntity.SharedVoicemailHistoryTemplateId))
        {
            $result.SharedVoicemailHistoryTemplateId = $CallableEntity.SharedVoicemailHistoryTemplateId
        }

        return $result
    }

    hidden static [System.Collections.Hashtable] GetCallFlowAsHashtable([System.Collections.Hashtable] $Cache, [System.Object] $CallFlow)
    {
        $greetings = @()
        foreach ($greeting in $CallFlow.Greetings)
        {
            $greetings += [TeamsAutoAttendant]::GetPromptAsHashtable($greeting)
        }

        $result = @{
            Name                   = $CallFlow.Name
            Greetings              = [System.Array] $greetings
            ForceListenMenuEnabled = [System.Boolean] $CallFlow.ForceListenMenuEnabled
        }

        if ($null -ne $CallFlow.RingResourceAccountDelegates)
        {
            $result.RingResourceAccountDelegates = [System.Boolean] $CallFlow.RingResourceAccountDelegates
        }

        if ($CallFlow.TimeoutThreshold -gt 0)
        {
            $result.TimeoutThreshold = [System.Int32] $CallFlow.TimeoutThreshold
        }

        foreach ($propertyName in @('TimeoutDisconnectPromptType', 'TimeoutDisconnectPromptCustomText', 'AiDisclaimerType', 'AiDisclaimerCustomText'))
        {
            if (-not [System.String]::IsNullOrEmpty($CallFlow.$propertyName))
            {
                $result.$propertyName = [System.String] $CallFlow.$propertyName
            }
        }

        if ($null -ne $CallFlow.Menu)
        {
            $prompts = @()
            foreach ($prompt in $CallFlow.Menu.Prompts)
            {
                $prompts += [TeamsAutoAttendant]::GetPromptAsHashtable($prompt)
            }

            $menuOptions = @()
            foreach ($menuOption in $CallFlow.Menu.MenuOptions)
            {
                $option = @{
                    Action       = [System.String] $menuOption.Action
                    DtmfResponse = [System.String] $menuOption.DtmfResponse
                }

                if ($menuOption.VoiceResponses.Count -gt 0)
                {
                    $option.VoiceResponses = [System.String[]] $menuOption.VoiceResponses
                }

                if ($null -ne $menuOption.CallTarget)
                {
                    $option.CallTarget = [TeamsAutoAttendant]::GetCallableEntityAsHashtable($Cache, $menuOption.CallTarget)
                }

                if ($null -ne $menuOption.Prompt)
                {
                    $option.Prompt = [TeamsAutoAttendant]::GetPromptAsHashtable($menuOption.Prompt)
                }

                foreach ($propertyName in @('Description', 'MainlineAttendantTarget', 'AgentTarget', 'AgentTargetTagTemplateId'))
                {
                    if (-not [System.String]::IsNullOrEmpty($menuOption.$propertyName))
                    {
                        $option.$propertyName = $menuOption.$propertyName
                    }
                }

                if ($null -ne $menuOption.AgentTargetType)
                {
                    $option.AgentTargetType = [System.String] $menuOption.AgentTargetType
                }

                $menuOptions += $option
            }

            $result.Menu = @{
                Name                  = $CallFlow.Menu.Name
                Prompts               = [System.Array] $prompts
                MenuOptions           = [System.Array] $menuOptions
                EnableDialByName      = [System.Boolean] $CallFlow.Menu.DialByNameEnabled
                DirectorySearchMethod = [System.String] $CallFlow.Menu.DirectorySearchMethod
            }
        }

        return $result
    }

    hidden static [System.Object] NewPromptObject([System.Object] $Prompt)
    {
        $activeType = $Prompt.ActiveType
        if ([System.String]::IsNullOrEmpty($activeType))
        {
            $activeType = 'TextToSpeech'
            if (-not [System.String]::IsNullOrEmpty($Prompt.AudioFilePromptId))
            {
                $activeType = 'AudioFile'
            }
        }

        $promptParameters = @{
            ActiveType = $activeType
        }

        if (-not [System.String]::IsNullOrEmpty($Prompt.TextToSpeechPrompt))
        {
            $promptParameters.TextToSpeechPrompt = $Prompt.TextToSpeechPrompt
        }

        if (-not [System.String]::IsNullOrEmpty($Prompt.AudioFilePromptId))
        {
            $audioFile = Get-CsOnlineAudioFile -Identity $Prompt.AudioFilePromptId -ApplicationId 'OrgAutoAttendant' -ErrorAction SilentlyContinue
            if ($null -eq $audioFile)
            {
                throw "The audio file {$($Prompt.AudioFilePromptId)} of a Teams Auto Attendant prompt does not exist. Upload it with Import-CsOnlineAudioFile and the application id OrgAutoAttendant."
            }

            $promptParameters.AudioFilePrompt = $audioFile
        }

        return New-CsAutoAttendantPrompt @promptParameters -ErrorAction Stop
    }

    hidden static [System.Object] NewCallableEntityObject([System.Collections.Hashtable] $Cache, [System.Object] $CallableEntity)
    {
        $identity = $CallableEntity.Identity
        if ($CallableEntity.Type -in @('User', 'ApplicationEndpoint'))
        {
            $identity = [TeamsAutoAttendant]::GetPrincipalId($Cache, $CallableEntity.Identity)
            if ([System.String]::IsNullOrEmpty($identity))
            {
                throw "The call target {$($CallableEntity.Identity)} of a Teams Auto Attendant could not be resolved to an account."
            }
        }

        $entityParameters = @{
            Identity = $identity
            Type     = $CallableEntity.Type
        }

        if ($null -ne $CallableEntity.EnableTranscription)
        {
            $entityParameters.EnableTranscription = [System.Boolean] $CallableEntity.EnableTranscription
        }

        if ($null -ne $CallableEntity.EnableSharedVoicemailSystemPromptSuppression)
        {
            $entityParameters.EnableSharedVoicemailSystemPromptSuppression = [System.Boolean] $CallableEntity.EnableSharedVoicemailSystemPromptSuppression
        }

        if ($null -ne $CallableEntity.CallPriority)
        {
            $entityParameters.CallPriority = [System.Int16] $CallableEntity.CallPriority
        }

        if (-not [System.String]::IsNullOrEmpty($CallableEntity.SharedVoicemailHistoryTemplateId))
        {
            $entityParameters.SharedVoicemailHistoryTemplateId = $CallableEntity.SharedVoicemailHistoryTemplateId
        }

        $entity = $null
        try
        {
            $entity = New-CsAutoAttendantCallableEntity @entityParameters -ErrorAction Stop
        }
        catch
        {
            throw "The call target {$($CallableEntity.Identity)} of type {$($CallableEntity.Type)} of a Teams Auto Attendant could not be created. Error: $($_.Exception.Message)"
        }

        if ($null -eq $entity)
        {
            throw "The call target {$($CallableEntity.Identity)} of type {$($CallableEntity.Type)} of a Teams Auto Attendant could not be created."
        }

        return $entity
    }

    hidden static [System.Object] NewCallFlowObject([System.Collections.Hashtable] $Cache, [System.Object] $CallFlow)
    {
        $menuParameters = @{
            Name = 'Default menu'
        }

        $menu = $CallFlow.Menu
        if ($null -ne $menu)
        {
            if (-not [System.String]::IsNullOrEmpty($menu.Name))
            {
                $menuParameters.Name = $menu.Name
            }

            $prompts = @()
            foreach ($prompt in $menu.Prompts)
            {
                $prompts += [TeamsAutoAttendant]::NewPromptObject($prompt)
            }
            if ($prompts.Count -gt 0)
            {
                $menuParameters.Prompts = $prompts
            }

            $menuOptions = @()
            foreach ($menuOption in $menu.MenuOptions)
            {
                $optionParameters = @{
                    Action       = $menuOption.Action
                    DtmfResponse = $menuOption.DtmfResponse
                }

                if ($menuOption.VoiceResponses.Count -gt 0)
                {
                    $optionParameters.VoiceResponses = [System.String[]] $menuOption.VoiceResponses
                }

                if ($null -ne $menuOption.CallTarget)
                {
                    $optionParameters.CallTarget = [TeamsAutoAttendant]::NewCallableEntityObject($Cache, $menuOption.CallTarget)
                }

                if ($null -ne $menuOption.Prompt)
                {
                    $optionParameters.Prompt = [TeamsAutoAttendant]::NewPromptObject($menuOption.Prompt)
                }

                foreach ($propertyName in @('Description', 'MainlineAttendantTarget', 'AgentTargetType', 'AgentTarget', 'AgentTargetTagTemplateId'))
                {
                    if (-not [System.String]::IsNullOrEmpty($menuOption.$propertyName))
                    {
                        $optionParameters.$propertyName = $menuOption.$propertyName
                    }
                }

                $menuOptions += New-CsAutoAttendantMenuOption @optionParameters
            }
            if ($menuOptions.Count -gt 0)
            {
                $menuParameters.MenuOptions = $menuOptions
            }

            if ($null -ne $menu.EnableDialByName)
            {
                $menuParameters.EnableDialByName = [System.Boolean] $menu.EnableDialByName
            }

            if (-not [System.String]::IsNullOrEmpty($menu.DirectorySearchMethod))
            {
                $menuParameters.DirectorySearchMethod = $menu.DirectorySearchMethod
            }
        }

        $callFlowParameters = @{
            Name = $CallFlow.Name
            Menu = New-CsAutoAttendantMenu @menuParameters
        }

        $greetings = @()
        foreach ($greeting in $CallFlow.Greetings)
        {
            $greetings += [TeamsAutoAttendant]::NewPromptObject($greeting)
        }
        if ($greetings.Count -gt 0)
        {
            $callFlowParameters.Greetings = $greetings
        }

        if ($null -ne $CallFlow.ForceListenMenuEnabled)
        {
            $callFlowParameters.ForceListenMenuEnabled = [System.Boolean] $CallFlow.ForceListenMenuEnabled
        }

        if ($null -ne $CallFlow.RingResourceAccountDelegates)
        {
            $callFlowParameters.RingResourceAccountDelegates = [System.Boolean] $CallFlow.RingResourceAccountDelegates
        }

        if ($null -ne $CallFlow.TimeoutThreshold)
        {
            $callFlowParameters.TimeoutThreshold = [System.Int32] $CallFlow.TimeoutThreshold
        }

        foreach ($propertyName in @('TimeoutDisconnectPromptType', 'TimeoutDisconnectPromptCustomText', 'AiDisclaimerType', 'AiDisclaimerCustomText'))
        {
            if (-not [System.String]::IsNullOrEmpty($CallFlow.$propertyName))
            {
                $callFlowParameters.$propertyName = $CallFlow.$propertyName
            }
        }

        return New-CsAutoAttendantCallFlow @callFlowParameters
    }

    hidden static [System.Object[]] NewCallHandlingAssociationObjects([System.Collections.Hashtable] $Cache, [System.Object[]] $Associations, [System.Object[]] $CallFlowObjects, [System.String] $AutoAttendantName)
    {
        $result = @()
        foreach ($association in $Associations)
        {
            $callFlowName = $association.CallFlowName
            $callFlowObject = @($CallFlowObjects) | Where-Object -FilterScript { $null -ne $_ -and $_.Name -eq $callFlowName } |
                Select-Object -First 1
            if ($null -eq $callFlowObject)
            {
                throw "The call flow {$callFlowName} referenced by a call handling association of the Teams Auto Attendant {$AutoAttendantName} is not part of its CallFlows."
            }

            $scheduleName = $association.ScheduleName
            $schedule = [TeamsAutoAttendant]::GetSchedules($Cache) | Where-Object -FilterScript { $_.Name -eq $scheduleName } |
                Select-Object -First 1
            if ($null -eq $schedule)
            {
                throw "The schedule {$scheduleName} referenced by the Teams Auto Attendant {$AutoAttendantName} does not exist."
            }

            $associationParameters = @{
                Type       = $association.Type
                ScheduleId = $schedule.Id
                CallFlowId = $callFlowObject.Id
            }

            if ($association.Enabled -eq $false)
            {
                $associationParameters.Disable = $true
            }

            $result += New-CsAutoAttendantCallHandlingAssociation @associationParameters
        }

        return $result
    }

    hidden [TeamsAutoAttendant] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsAutoAttendant])
        {
            return $Values
        }

        $result = [TeamsAutoAttendant]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_TeamsAutoAttendantCallFlow
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The name of the call flow. Call handling associations reference the call flow by this name.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The greetings played when the call flow starts.')]
    [MSFT_TeamsAutoAttendantPrompt[]] $Greetings

    [DscProperty()]
    [System.ComponentModel.Description('The menu of the call flow.')]
    [MSFT_TeamsAutoAttendantMenu] $Menu

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether callers have to listen to the whole menu before they can make a selection.')]
    [System.Nullable[System.Boolean]] $ForceListenMenuEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether calls ring the delegates of the resource account.')]
    [System.Nullable[System.Boolean]] $RingResourceAccountDelegates

    [DscProperty()]
    [System.ComponentModel.Description('The maximum length in seconds of a Mainline Attendant call before it is disconnected, from 15 to 2400. The service rounds the value to the nearest multiple of 15.')]
    [ValidateRange(15, 2400)]
    [System.Nullable[System.Int32]] $TimeoutThreshold

    [DscProperty()]
    [System.ComponentModel.Description('The type of the prompt played before a Mainline Attendant call is disconnected because it reached the timeout threshold.')]
    [ValidateSet('Default', 'Custom')]
    [System.String] $TimeoutDisconnectPromptType

    [DscProperty()]
    [System.ComponentModel.Description('The text read to callers before the call is disconnected when the timeout disconnect prompt type is Custom.')]
    [System.String] $TimeoutDisconnectPromptCustomText

    [DscProperty()]
    [System.ComponentModel.Description('The type of the artificial intelligence disclaimer played to callers at the start of a Mainline Attendant interaction.')]
    [ValidateSet('Default', 'Custom', 'None')]
    [System.String] $AiDisclaimerType

    [DscProperty()]
    [System.ComponentModel.Description('The artificial intelligence disclaimer read to callers when the disclaimer type is Custom.')]
    [System.String] $AiDisclaimerCustomText
}

class MSFT_TeamsAutoAttendantMenu
{
    [DscProperty()]
    [System.ComponentModel.Description('The name of the menu.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The prompts played when the menu is read to callers.')]
    [MSFT_TeamsAutoAttendantPrompt[]] $Prompts

    [DscProperty()]
    [System.ComponentModel.Description('The options callers can choose from.')]
    [MSFT_TeamsAutoAttendantMenuOption[]] $MenuOptions

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether callers can search the directory.')]
    [System.Nullable[System.Boolean]] $EnableDialByName

    [DscProperty()]
    [System.ComponentModel.Description('The method used to search the directory.')]
    [ValidateSet('None', 'ByName', 'ByExtension')]
    [System.String] $DirectorySearchMethod
}

class MSFT_TeamsAutoAttendantMenuOption
{
    [DscProperty()]
    [System.ComponentModel.Description('The action taken when the option is selected.')]
    [ValidateSet('TransferCallToOperator', 'DisconnectCall', 'TransferCallToTarget', 'Announcement', 'MainlineAttendantFlow', 'AgentsAndQueues')]
    [System.String] $Action

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The key callers press to select the option.')]
    [ValidateSet('Tone0', 'Tone1', 'Tone2', 'Tone3', 'Tone4', 'Tone5', 'Tone6', 'Tone7', 'Tone8', 'Tone9', 'ToneStar', 'TonePound', 'Automatic')]
    [System.String] $DtmfResponse

    [DscProperty()]
    [System.ComponentModel.Description('The phrases callers say to select the option when voice response is enabled.')]
    [System.String[]] $VoiceResponses

    [DscProperty()]
    [System.ComponentModel.Description('The target calls are transferred to when the action is TransferCallToTarget.')]
    [MSFT_TeamsAutoAttendantCallableEntity] $CallTarget

    [DscProperty()]
    [System.ComponentModel.Description('The prompt played when the action is Announcement.')]
    [MSFT_TeamsAutoAttendantPrompt] $Prompt

    [DscProperty()]
    [System.ComponentModel.Description('The description of the option.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The Mainline Attendant flow the option runs.')]
    [System.String] $MainlineAttendantTarget

    [DscProperty()]
    [System.ComponentModel.Description('The type of the agent target.')]
    [ValidateSet('Ivr', 'CoPilot')]
    [System.String] $AgentTargetType

    [DscProperty()]
    [System.ComponentModel.Description('The agent target of the option.')]
    [System.String] $AgentTarget

    [DscProperty()]
    [System.ComponentModel.Description('The id of the tag template of the agent target.')]
    [System.String] $AgentTargetTagTemplateId
}

class MSFT_TeamsAutoAttendantPrompt
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the prompt that is played.')]
    [ValidateSet('None', 'TextToSpeech', 'AudioFile')]
    [System.String] $ActiveType

    [DscProperty()]
    [System.ComponentModel.Description('The text read to callers.')]
    [System.String] $TextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The id of an audio file already uploaded for auto attendants.')]
    [System.String] $AudioFilePromptId

    [DscProperty()]
    [System.ComponentModel.Description('The file name of the audio file.')]
    [System.String] $AudioFilePromptFileName
}

class MSFT_TeamsAutoAttendantCallableEntity
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The target. A user principal name for the types User and ApplicationEndpoint, a tel URI for ExternalPstn and an object id otherwise.')]
    [System.String] $Identity

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the target.')]
    [ValidateSet('User', 'OrganizationalAutoAttendant', 'HuntGroup', 'ApplicationEndpoint', 'ExternalPstn', 'SharedVoicemail', 'ConfigurationEndpoint', 'Voicemail')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether voicemail left for a shared voicemail target is transcribed.')]
    [System.Nullable[System.Boolean]] $EnableTranscription

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the system prompt of a shared voicemail target is suppressed.')]
    [System.Nullable[System.Boolean]] $EnableSharedVoicemailSystemPromptSuppression

    [DscProperty()]
    [System.ComponentModel.Description('The priority of calls transferred to the target, from 1 (highest) to 5 (lowest).')]
    [ValidateRange(1, 5)]
    [System.Nullable[System.Int32]] $CallPriority

    [DscProperty()]
    [System.ComponentModel.Description('The id of the shared call history template that collects the history of the voicemails left for a shared voicemail target in the Queues app.')]
    [System.String] $SharedVoicemailHistoryTemplateId
}

class MSFT_TeamsAutoAttendantCallHandlingAssociation
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the association.')]
    [ValidateSet('AfterHours', 'Holiday')]
    [System.String] $Type

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The name of the schedule that activates the call flow. Manage the schedule with the TeamsOnlineSchedule resource.')]
    [System.String] $ScheduleName

    [DscProperty()]
    [System.ComponentModel.Description('The name of the call flow that runs while the schedule is in effect. It references an entry of CallFlows.')]
    [System.String] $CallFlowName

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the association is enabled.')]
    [System.Nullable[System.Boolean]] $Enabled
}
