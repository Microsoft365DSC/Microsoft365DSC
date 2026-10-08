using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsOnlineSchedule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The unique friendly name of the schedule.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The type of the schedule. A weekly recurrent schedule defines business or after hours, a fixed schedule defines holidays. The type cannot change once the schedule exists. Required when the schedule is created.')]
    [ValidateSet('WeeklyRecurrence', 'Fixed')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('The time ranges of a weekly recurrent schedule on Mondays.')]
    [MSFT_TeamsOnlineScheduleTimeRange[]] $MondayHours

    [DscProperty()]
    [System.ComponentModel.Description('The time ranges of a weekly recurrent schedule on Tuesdays.')]
    [MSFT_TeamsOnlineScheduleTimeRange[]] $TuesdayHours

    [DscProperty()]
    [System.ComponentModel.Description('The time ranges of a weekly recurrent schedule on Wednesdays.')]
    [MSFT_TeamsOnlineScheduleTimeRange[]] $WednesdayHours

    [DscProperty()]
    [System.ComponentModel.Description('The time ranges of a weekly recurrent schedule on Thursdays.')]
    [MSFT_TeamsOnlineScheduleTimeRange[]] $ThursdayHours

    [DscProperty()]
    [System.ComponentModel.Description('The time ranges of a weekly recurrent schedule on Fridays.')]
    [MSFT_TeamsOnlineScheduleTimeRange[]] $FridayHours

    [DscProperty()]
    [System.ComponentModel.Description('The time ranges of a weekly recurrent schedule on Saturdays.')]
    [MSFT_TeamsOnlineScheduleTimeRange[]] $SaturdayHours

    [DscProperty()]
    [System.ComponentModel.Description('The time ranges of a weekly recurrent schedule on Sundays.')]
    [MSFT_TeamsOnlineScheduleTimeRange[]] $SundayHours

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether a weekly recurrent schedule is in effect outside of its time ranges instead of inside them.')]
    [System.Nullable[System.Boolean]] $Complement

    [DscProperty()]
    [System.ComponentModel.Description('The date time ranges of a fixed schedule.')]
    [MSFT_TeamsOnlineScheduleDateTimeRange[]] $DateTimeRanges

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the schedule should exist.')]
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

    [TeamsOnlineSchedule] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsOnlineSchedule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Teams Online Schedule {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $schedule = [TeamsOnlineSchedule]::GetScheduleInstance($this.Name)
            }
            else
            {
                $schedule = $this.ExportedInstance
            }

            if ($null -eq $schedule)
            {
                Write-Verbose -Message "No Teams Online Schedule with Name {$($this.Name)} was found"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Teams Online Schedule with Name {$($this.Name)}"

            $result = @{
                Name                  = $schedule.Name
                Type                  = [System.String] $schedule.Type
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }

            if ($null -ne $schedule.WeeklyRecurrentSchedule)
            {
                foreach ($day in [TeamsOnlineSchedule]::GetDayPropertyNames())
                {
                    $ranges = @()
                    foreach ($range in $schedule.WeeklyRecurrentSchedule.$day)
                    {
                        $ranges += @{
                            Start = [TeamsOnlineSchedule]::ConvertToTimeString($range.Start)
                            End   = [TeamsOnlineSchedule]::ConvertToTimeString($range.End)
                        }
                    }
                    $result.$day = [System.Array] $ranges
                }

                $result.Complement = [System.Boolean] $schedule.WeeklyRecurrentSchedule.ComplementEnabled
            }

            if ($null -ne $schedule.FixedSchedule)
            {
                $ranges = @()
                foreach ($range in $schedule.FixedSchedule.DateTimeRanges)
                {
                    $ranges += @{
                        Start = [TeamsOnlineSchedule]::ConvertToDateTimeString($range.Start)
                        End   = [TeamsOnlineSchedule]::ConvertToDateTimeString($range.End)
                    }
                }
                $result.DateTimeRanges = [System.Array] $ranges
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

        Write-Verbose -Message "Setting configuration of Teams Online Schedule {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            $currentInstance = $this.Get().ToHashtable()
            $boundParameters = $this.GetBoundParameters()

            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new Teams Online Schedule {$($this.Name)}"

                $createParameters = @{
                    Name = $this.Name
                }

                if ($this.Type -eq 'Fixed')
                {
                    $createParameters.FixedSchedule = $true
                    if ($this.DateTimeRanges.Count -gt 0)
                    {
                        $createParameters.DateTimeRanges = [TeamsOnlineSchedule]::NewDateTimeRangeObjects($this.DateTimeRanges)
                    }
                }
                elseif ($this.Type -eq 'WeeklyRecurrence')
                {
                    $createParameters.WeeklyRecurrentSchedule = $true
                    foreach ($day in [TeamsOnlineSchedule]::GetDayPropertyNames())
                    {
                        if ($this.$day.Count -gt 0)
                        {
                            $createParameters.$day = [TeamsOnlineSchedule]::NewTimeRangeObjects($this.$day)
                        }
                    }

                    if ($this.Complement -eq $true)
                    {
                        $createParameters.Complement = $true
                    }
                }
                else
                {
                    throw "The property 'Type' is required to create the Teams Online Schedule {$($this.Name)}."
                }

                New-CsOnlineSchedule @createParameters | Out-Null
            }
            elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating Teams Online Schedule {$($this.Name)}"

                if ($boundParameters.ContainsKey('Type') -and $this.Type -ne $currentInstance.Type)
                {
                    throw "The type of the Teams Online Schedule {$($this.Name)} cannot change from {$($currentInstance.Type)} to {$($this.Type)}. Remove the schedule and create it again."
                }

                $schedule = [TeamsOnlineSchedule]::GetScheduleInstance($this.Name)

                if ($null -eq $schedule.FixedSchedule -and $this.DateTimeRanges.Count -gt 0)
                {
                    throw "The Teams Online Schedule {$($this.Name)} is a weekly recurrent schedule and cannot hold DateTimeRanges."
                }

                if ($null -eq $schedule.WeeklyRecurrentSchedule)
                {
                    foreach ($day in [TeamsOnlineSchedule]::GetDayPropertyNames())
                    {
                        if ($this.$day.Count -gt 0)
                        {
                            throw "The Teams Online Schedule {$($this.Name)} is a fixed schedule and cannot hold $day."
                        }
                    }
                }

                if ($null -ne $schedule.WeeklyRecurrentSchedule)
                {
                    foreach ($day in [TeamsOnlineSchedule]::GetDayPropertyNames())
                    {
                        if ($boundParameters.ContainsKey($day))
                        {
                            $schedule.WeeklyRecurrentSchedule.$day = [TeamsOnlineSchedule]::NewTimeRangeObjects($this.$day)
                        }
                    }

                    if ($boundParameters.ContainsKey('Complement'))
                    {
                        $schedule.WeeklyRecurrentSchedule.ComplementEnabled = [System.Boolean] $this.Complement
                    }
                }

                if ($null -ne $schedule.FixedSchedule -and $boundParameters.ContainsKey('DateTimeRanges'))
                {
                    $schedule.FixedSchedule.DateTimeRanges = [TeamsOnlineSchedule]::NewDateTimeRangeObjects($this.DateTimeRanges)
                }

                Set-CsOnlineSchedule -Instance $schedule | Out-Null
            }
            elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing Teams Online Schedule {$($this.Name)}"

                $schedule = [TeamsOnlineSchedule]::GetScheduleInstance($this.Name)
                Remove-CsOnlineSchedule -Id $schedule.Id | Out-Null
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
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)

                foreach ($day in [TeamsOnlineSchedule]::GetDayPropertyNames())
                {
                    foreach ($range in $DesiredValues.$day)
                    {
                        $range.Start = [TeamsOnlineSchedule]::ConvertToTimeString($range.Start)
                        $range.End = [TeamsOnlineSchedule]::ConvertToTimeString($range.End)
                    }
                }

                foreach ($range in $DesiredValues.DateTimeRanges)
                {
                    $range.Start = [TeamsOnlineSchedule]::ConvertToDateTimeString($range.Start)
                    $range.End = [TeamsOnlineSchedule]::ConvertToDateTimeString($range.End)
                }

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
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
            [array] $exportedInstances = Get-CsOnlineSchedule `
                -ErrorAction Stop

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

            $complexProperties = @{ DateTimeRanges = 'TeamsOnlineScheduleDateTimeRange' }
            foreach ($day in [TeamsOnlineSchedule]::GetDayPropertyNames())
            {
                $complexProperties.$day = 'TeamsOnlineScheduleTimeRange'
            }

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

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.$propertyName `
                        -CIMInstanceName $complexProperties[$propertyName]

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

    hidden static [System.String[]] GetDayPropertyNames()
    {
        return @('MondayHours', 'TuesdayHours', 'WednesdayHours', 'ThursdayHours', 'FridayHours', 'SaturdayHours', 'SundayHours')
    }

    hidden static [System.Object] GetScheduleInstance([System.String] $ScheduleName)
    {
        $candidates = @(Get-CsOnlineSchedule -ErrorAction Stop | Where-Object -FilterScript { $_.Name -eq $ScheduleName })

        if ($candidates.Count -gt 1)
        {
            Write-Warning -Message "Found $($candidates.Count) Teams Online Schedules named {$ScheduleName}. Only the first one is managed."
        }

        if ($candidates.Count -eq 0)
        {
            return $null
        }

        return $candidates[0]
    }

    hidden static [System.String] ConvertToTimeString([System.Object] $Value)
    {
        if ($null -eq $Value)
        {
            return $null
        }

        $timeSpan = [System.TimeSpan]::Zero
        if ($Value -is [System.TimeSpan])
        {
            $timeSpan = $Value
        }
        elseif (-not [System.TimeSpan]::TryParse([System.String] $Value, [System.Globalization.CultureInfo]::InvariantCulture, [ref] $timeSpan))
        {
            return [System.String] $Value
        }

        if ($timeSpan.Days -ge 1)
        {
            return '1.00:00'
        }

        return $timeSpan.ToString('hh\:mm')
    }

    hidden static [System.String] ConvertToDateTimeString([System.Object] $Value)
    {
        if ($null -eq $Value)
        {
            return $null
        }

        $dateTime = [System.DateTime]::MinValue
        if ($Value -is [System.DateTime])
        {
            $dateTime = $Value
        }
        elseif (-not [System.DateTime]::TryParseExact([System.String] $Value, [System.String[]] @('d/M/yyyy H:mm', 'd/M/yyyy'),
                [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref] $dateTime))
        {
            return [System.String] $Value
        }

        return $dateTime.ToString('d/M/yyyy H:mm', [System.Globalization.CultureInfo]::InvariantCulture)
    }

    hidden static [System.Object[]] NewTimeRangeObjects([System.Object[]] $Ranges)
    {
        $result = @()
        foreach ($range in $Ranges)
        {
            $result += New-CsOnlineTimeRange -Start $range.Start -End $range.End
        }

        return $result
    }

    hidden static [System.Object[]] NewDateTimeRangeObjects([System.Object[]] $Ranges)
    {
        $result = @()
        foreach ($range in $Ranges)
        {
            $rangeParameters = @{
                Start = $range.Start
            }

            if (-not [System.String]::IsNullOrEmpty($range.End))
            {
                $rangeParameters.End = $range.End
            }

            $result += New-CsOnlineDateTimeRange @rangeParameters
        }

        return $result
    }

    hidden [TeamsOnlineSchedule] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsOnlineSchedule])
        {
            return $Values
        }

        $result = [TeamsOnlineSchedule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_TeamsOnlineScheduleTimeRange
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The start of the time range in the format HH:mm, for example 09:00.')]
    [System.String] $Start

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The end of the time range in the format HH:mm, for example 17:00. Use 1.00:00 for the end of the day.')]
    [System.String] $End
}

class MSFT_TeamsOnlineScheduleDateTimeRange
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The start of the date time range in the format d/M/yyyy H:mm, for example 24/12/2026 0:00.')]
    [System.String] $Start

    [DscProperty()]
    [System.ComponentModel.Description('The end of the date time range in the format d/M/yyyy H:mm, for example 26/12/2026 0:00.')]
    [System.String] $End
}
