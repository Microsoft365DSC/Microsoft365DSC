<#
.SYNOPSIS
    Creates a Microsoft365DSC error log entry and emits diagnostics.

.DESCRIPTION
    Builds a detailed error record, writes verbose output, logs to the M365DSC event log, emits telemetry, and appends error details to a session log file.

.PARAMETER Source
    Specifies the source name used for event and log entry context.

.PARAMETER Message
    Specifies the primary error message to record.

.PARAMETER Exception
    Specifies the exception object to include in diagnostics.

.PARAMETER Credential
    Specifies credential context used to derive tenant information when needed.

.PARAMETER TenantId
    Specifies the tenant identifier to include in log records.

.FUNCTIONALITY
    Internal
#>
function New-M365DSCLogEntry
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Source,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Message,

        [Parameter()]
        [System.Object]
        $Exception,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $TenantId
    )

    try
    {
        $tenantIdValue = ''
        if (-not [System.String]::IsNullOrEmpty($TenantId))
        {
            $tenantIdValue = $TenantId
        }
        elseif ($null -ne $Credential)
        {
            $tenantIdValue = $Credential.UserName.Split('@')[1]
        }

        #region Verbose message
        $outputMessage = $Message
        if ($PSBoundParameters.ContainsKey('Exception'))
        {
            $exceptionStackTrace = Resolve-M365DSCSourceLocation -InputObject $Exception.ScriptStackTrace
            $exceptionMessage = '{ ' + $Exception.Exception.Message + ' } \ ' + $exceptionStackTrace -replace '\n', ' \ '
            $outputMessage += ' ' + $exceptionMessage
        }
        Write-Verbose -Message $outputMessage
        #endregion

        #region Event Log logging
        $errorMessage = $Message
        if ($PSBoundParameters.ContainsKey('Exception'))
        {
            $errorMessage += "`n`n" + $exceptionMessage
        }

        if ($tenantIdValue -eq '')
        {
            Add-M365DSCEvent -Message $errorMessage `
                -EntryType 'Error' `
                -EventID 1 `
                -EventType 'Error' `
                -Source $Source
        }
        else
        {
            Add-M365DSCEvent -Message $errorMessage `
                -EntryType 'Error' `
                -EventID 1 `
                -EventType 'Error' `
                -Source $Source `
                -TenantId $tenantIdValue
        }
        #endregion

        #region Telemetry
        $driftedData = [System.Collections.Generic.Dictionary[[System.String], [System.Object]]]::new()
        $driftedData.Add('CustomMessage', $Message)
        $driftedData.Add('Source', $Source)

        if ($PSBoundParameters.ContainsKey('Exception'))
        {
            $driftedData.Add('Category', $Exception.CategoryInfo.Category.ToString())
            $driftedData.Add('Exception', $Exception.Exception.ToString())
            $driftedData.Add('StackTrace', $exceptionStackTrace)
        }

        if ($tenantIdValue -ne '')
        {
            $driftedData.Add('TenantId', $tenantIdValue)
        }
        Add-M365DSCTelemetryEvent -Type 'Error' -Data $driftedData
        #endregion

        #region Error log file

        # Obtain the ID of the current PowerShell session. While this may
        # not be unique, it will result in varying file names
        $SessionID = [System.Diagnostics.Process]::GetCurrentProcess().Id.ToString()

        # Generate the Error log file name based on the SessionID;
        $LogFileName = $SessionID + '-M365DSC-ErrorLog.log'

        # Build up the Error message to append to our log file;
        $LogContent = '[' + [System.DateTime]::Now.ToString('yyyy/MM/dd HH:mm:ss') + "]`r`n"
        if ($PSBoundParameters.ContainsKey('Exception'))
        {
            $LogContent += '{' + $Exception.CategoryInfo.Category.ToString() + "}`r`n"
            $LogContent += $Exception.Exception.ToString() + "`r`n"
        }
        $LogContent += "`"" + $Message + "`"`r`n"
        if ($PSBoundParameters.ContainsKey('Exception'))
        {
            $LogContent += $exceptionStackTrace + "`r`n"
        }
        if ($null -ne $Credential)
        {
            $LogContent += $Credential.UserName + "`r`n"
        }
        if ($tenantIdValue -ne '')
        {
            $LogContent += 'TenantId: ' + $tenantIdValue + "`r`n"
        }
        $LogContent += "`r`n`r`n"

        # Write the error content into the log file;
        $LogFileName = Join-Path -Path $env:TEMP -ChildPath $LogFileName
        $LogFileName = $LogFileName.Replace('\', '/')
        $LogContent | Out-File $LogFileName -Append
        Write-M365DSCHost -Message "Error Log created at {file://$LogFileName}" -ForegroundColor Red
        #endregion
    }
    catch
    {
        Write-Warning -Message "An error occured logging an exception: $_"
    }
}

<#
.SYNOPSIS
    Writes an entry to the Microsoft365DSC event log.

.DESCRIPTION
    Creates the event source when needed, truncates long payloads, optionally forwards notifications, and writes the event entry with the requested severity and metadata.

.PARAMETER Message
    Specifies the event message text.

.PARAMETER Source
    Specifies the event source name.

.PARAMETER EntryType
    Specifies the event entry type.

.PARAMETER EventID
    Specifies the numeric event identifier.

.PARAMETER EventType
    Specifies the notification event category used for endpoint forwarding.

.PARAMETER TenantId
    Specifies the tenant identifier appended to the event payload.

.FUNCTIONALITY
    Internal
#>
function Add-M365DSCEvent
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Message,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Source,

        [Parameter()]
        [ValidateSet('Error', 'Information', 'FailureAudit', 'SuccessAudit', 'Warning')]
        [System.String]
        $EntryType = 'Information',

        [Parameter()]
        [System.UInt32]
        $EventID = 1,

        [Parameter()]
        [System.String]
        [ValidateSet('Drift', 'Error', 'Warning', 'NonDrift', 'RuleEvaluation')]
        $EventType,

        [Parameter()]
        [System.String]
        $TenantId
    )
    $LogName = 'M365DSC'

    try
    {
        $sourceExists = $false
        $writeEntry = $true
        try
        {
            $sourceExists = [System.Diagnostics.EventLog]::SourceExists($Source)
        }
        catch [System.Security.SecurityException]
        {
            Write-Verbose -Message '[WARNING] Not all event logs could be searched. Source might exist in another event log.'
        }

        if ($sourceExists)
        {
            $sourceLogName = [System.Diagnostics.EventLog]::LogNameFromSourceName($Source, '.')
            if ($LogName -ne $sourceLogName)
            {
                Write-Verbose -Message "[ERROR] Specified source {$Source} already exists on log {$sourceLogName}"
                return
            }
        }
        else
        {
            try
            {
                [System.Diagnostics.EventLog]::CreateEventSource($Source, $LogName)
            }
            catch [System.Security.SecurityException]
            {
                Write-Verbose -Message "[WARNING] The event source {$Source} could not be created in the event log {$LogName}. Creating an event source requires administrator rights."
                $writeEntry = $false
            }
        }

        # Limit the size of the message. The event log accepts at most 31,839 characters.
        $maxMessageLength = 31839
        $outputMessage = $Message
        if ($PSBoundParameters.ContainsKey('TenantId'))
        {
            $outputMessage += "`n`nTenantId: " + $TenantId
        }

        if ($outputMessage.Length -gt $maxMessageLength)
        {
            $outputMessage = $outputMessage.Substring(0, $maxMessageLength)
        }

        if (-not [System.String]::IsNullOrEmpty($EventType))
        {
            Send-M365DSCNotificationEndPointMessage -EventDetails $outputMessage `
                -EventType $EventType
        }

        if ($writeEntry)
        {
            try
            {
                [System.Diagnostics.EventLog]::WriteEntry($Source, $outputMessage, $EntryType, $EventID)
            }
            catch
            {
                Write-Verbose -Message $_
            }
        }
    }
    catch
    {
        Write-Verbose -Message $_

        $MessageText = "Could not write to event log Source {$Source} EntryType {$EntryType} Message {$Message}"
        # Check call stack to prevent indefinite loop between New-M365DSCLogEntry and this function
        if ((Get-PSCallStack)[1].FunctionName -ne 'New-M365DSCLogEntry' -and `
                -not $_.ToString().Contains('EventLog access is not supported on this platform.'))
        {
            New-M365DSCLogEntry -Exception $_ -Message $MessageText `
                -Source '[M365DSCLogEngine]' `
                -TenantId $TenantId
        }
        else
        {
            Write-Verbose -Message $MessageText
        }
    }
}

<#
.SYNOPSIS
    Exports Microsoft365DSC diagnostic artifacts into a zip archive.

.DESCRIPTION
    Collects DSC verbose logs, M365DSC event log entries, PowerShell and OS details, and LCM information.
    Optionally anonymizes selected values before packaging the output.

.PARAMETER ExportFilePath
    Specifies the destination zip file path.

.PARAMETER NumberOfDays
    Specifies how many days of logs should be included.

.PARAMETER Anonymize
    Indicates that sensitive values should be anonymized in exported artifacts.

.PARAMETER Server
    Specifies the server value to replace during anonymization.

.PARAMETER Domain
    Specifies the domain value to replace during anonymization.

.PARAMETER Url
    Specifies the URL value to replace during anonymization.

.EXAMPLE
    Export-M365DSCDiagnosticData -ExportFilePath C:\Temp\DSCLogsExport.zip -NumberOfDays 3

.EXAMPLE
    Export-M365DSCDiagnosticData -ExportFilePath C:\Temp\DSCLogsExport.zip -Anonymize -Server spfe -Domain contoso.com -Url sharepoint.contoso.com

.FUNCTIONALITY
    Public
#>
function Export-M365DSCDiagnosticData
{
    [CmdletBinding(DefaultParametersetName = 'None')]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $ExportFilePath,

        [Parameter()]
        [System.UInt32]
        $NumberOfDays = 7,

        [Parameter(ParameterSetName = 'Anon')]
        [Switch]
        $Anonymize,

        [Parameter(ParameterSetName = 'Anon', Mandatory = $true)]
        [System.String]
        $Server,

        [Parameter(ParameterSetName = 'Anon', Mandatory = $true)]
        [System.String]
        $Domain,

        [Parameter(ParameterSetName = 'Anon', Mandatory = $true)]
        [System.String]
        $Url
    )
    Write-Host 'Exporting logging information' -ForegroundColor Yellow

    if ($IsWindows -and -not (Test-M365DSCCurrentUserIsAdministrator))
    {
        throw 'You need to run this cmdlet with Administrator privileges!'
    }

    $afterDate = (Get-Date).AddDays(($NumberOfDays * -1))

    # Create Temp folder
    $guid = [Guid]::NewGuid()
    $tempPath = Join-Path -Path $env:TEMP -ChildPath $guid
    $null = New-Item -Path $tempPath -ItemType 'Directory'

    try
    {
        # Copy DSC Verbose Logs
        Write-Host '  * Copying DSC Verbose Logs' -ForegroundColor Gray
        $logPath = Join-Path -Path $tempPath -ChildPath 'DSCLogs'
        $null = New-Item -Path $logPath -ItemType 'Directory'

        $sourceLogPath = Join-Path -Path $env:windir -ChildPath 'System32/Configuration/ConfigurationStatus'
        $items = Get-ChildItem -Path "$sourceLogPath/*.json" | Where-Object -Property LastWriteTime -GT $afterDate
        if ($null -ne $items)
        {
            Copy-Item -Path $items.FullName -Destination $logPath -ErrorAction 'SilentlyContinue'
        }

        $anonymizeText = {
            param
            (
                [System.String]
                $Text
            )

            $Text -replace [System.Text.RegularExpressions.Regex]::Escape($Url), 'fqdn.com' `
                -replace [System.Text.RegularExpressions.Regex]::Escape($Domain), '[DOMAIN]' `
                -replace [System.Text.RegularExpressions.Regex]::Escape($Server), '[SERVER]'
        }

        if ($Anonymize)
        {
            Write-Host '    * Anonymizing DSC Verbose Logs' -ForegroundColor Gray
            foreach ($file in (Get-ChildItem -Path $logPath))
            {
                $content = Get-Content -Path $file.FullName -Raw -Encoding Unicode
                $content = & $anonymizeText $content
                Set-Content -Path $file.FullName -Value $content -Encoding Unicode
            }
        }

        # Export M365DSC event log
        Write-Host '  * Exporting DSC Event Log' -ForegroundColor Gray
        $evtExportLog = Join-Path -Path $tempPath -ChildPath 'M365DSC.csv'

        try
        {
            Get-WinEvent -FilterHashtable @{ LogName = 'M365DSC'; StartTime = $afterDate } -ErrorAction SilentlyContinue | Export-Csv $evtExportLog -NoTypeInformation
        }
        catch
        {
            $txtExportLog = Join-Path -Path $tempPath -ChildPath 'M365DSC.txt'
            Add-Content -Value 'M365DSC event log does not exist!' -Path $txtExportLog
        }

        if ($Anonymize -and (Test-Path -Path $evtExportLog))
        {
            Write-Host '    * Anonymizing DSC Event Log' -ForegroundColor Gray
            try
            {
                $newLog = Import-Csv $evtExportLog
                foreach ($entry in $newLog)
                {
                    $entry.MachineName = '[SERVER]'
                    $entry.UserId = '[USER]'
                    $entry.Message = & $anonymizeText $entry.Message
                }

                $newLog | Export-Csv -Path $evtExportLog -NoTypeInformation
            }
            catch
            {
                # The raw event log must not be packaged when anonymization fails.
                Remove-Item -Path $evtExportLog -Force -ErrorAction SilentlyContinue
                Write-Warning -Message "The M365DSC event log could not be anonymized and is not included: $_"
            }
        }

        # PowerShell Version
        Write-Host '  * Exporting PowerShell Version info' -ForegroundColor Gray
        $psInfoFile = Join-Path -Path $tempPath -ChildPath 'PSInfo.txt'
        $PSVersionTable | Out-File -FilePath $psInfoFile

        # OS Version
        Write-Host '  * Exporting OS Version info' -ForegroundColor Gray
        $computerInfoFile = Join-Path -Path $tempPath -ChildPath 'OSInfo.txt'

        Get-ComputerInfo -Property @(
            'OsName',
            'OsOperatingSystemSKU',
            'OSArchitecture',
            'WindowsVersion',
            'WindowsBuildLabEx',
            'OsLanguage',
            'OsMuiLanguages') | Out-File -FilePath $computerInfoFile

        # LCM settings
        Write-Host '  * Exporting LCM Configuration info' -ForegroundColor Gray
        $lcmInfoFile = Join-Path -Path $tempPath -ChildPath 'LCMInfo.txt'
        Get-DscLocalConfigurationManager | Out-File -FilePath $lcmInfoFile

        # Creating export package
        Write-Host '  * Creating Zip file with all collected information' -ForegroundColor Gray
        Compress-Archive -Path $tempPath -DestinationPath $ExportFilePath -Force
    }
    finally
    {
        # Cleaning up temporary data
        Write-Host '  * Removing temporary data' -ForegroundColor Gray
        Remove-Item -LiteralPath $tempPath -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
    }

    Write-Host ('Completed with export. Information exported to {0}' -f $ExportFilePath) -ForegroundColor Yellow
}

<#
.SYNOPSIS
    Parses the stored notification endpoint registrations.

.DESCRIPTION
    Splits the 'Url|EventType;Url|EventType;' value stored in the machine environment
    variable into objects. Entries without exactly one '|' separator are skipped.

.PARAMETER Value
    Specifies the raw registration value.

.FUNCTIONALITY
    Private

.OUTPUTS
    System.Management.Automation.PSCustomObject[]
#>
function ConvertFrom-M365DSCNotificationEndpointRegistration
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject[]])]
    param
    (
        [Parameter()]
        [System.String]
        $Value
    )

    $result = @()
    if ([System.String]::IsNullOrEmpty($Value))
    {
        return ,$result
    }

    foreach ($entry in $Value.Split(';', [System.StringSplitOptions]::RemoveEmptyEntries))
    {
        $parts = $entry.Split('|')
        if ($parts.Count -ne 2)
        {
            continue
        }

        $result += [PSCustomObject]@{
            Url       = $parts[0]
            EventType = $parts[1]
        }
    }
    return ,$result
}

<#
.SYNOPSIS
    Converts notification endpoint registrations back into the stored value.

.PARAMETER Registration
    Specifies the registrations, as returned by ConvertFrom-M365DSCNotificationEndpointRegistration.

.FUNCTIONALITY
    Private

.OUTPUTS
    System.String
#>
function ConvertTo-M365DSCNotificationEndpointRegistration
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.Object[]]
        $Registration
    )

    $value = ''
    foreach ($entry in $Registration)
    {
        $value += "$($entry.Url)|$($entry.EventType);"
    }
    return $value
}

<#
.SYNOPSIS
    Registers a notification endpoint for M365DSC events.

.DESCRIPTION
    Adds a URL and event type pair to the machine-level endpoint registration list.
    The function validates duplicates before persisting the new registration.

.PARAMETER Url
    Specifies the notification endpoint URL.

.PARAMETER EventType
    Specifies the event type that should trigger notifications.

.FUNCTIONALITY
    Public
#>
function New-M365DSCNotificationEndpointRegistration
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('Drift', 'Error', 'Warning', 'NonDrift', 'RuleEvaluation')]
        $EventType
    )

    # Get current notification endpoint registrations from registry and parse them into an object.
    $CurrentNotificationEndpoints = ([System.Environment]::GetEnvironmentVariable('M365DSCNotificationEndPointRegistrations', `
                [System.EnvironmentVariableTarget]::Machine))
    $CurrentNotificationEndpointsAsObject = ConvertFrom-M365DSCNotificationEndpointRegistration -Value $CurrentNotificationEndpoints

    # Check to see if a notification endpoint registration with the same url and for the same event type already exists or not
    $sanitizedUrl = $Url.Replace('|', '').Replace(';', '')
    $existingInstance = $CurrentNotificationEndpointsAsObject | Where-Object -FilterScript { $_.Url -eq $sanitizedUrl -and $_.EventType -eq $EventType }
    if ($null -ne $existingInstance)
    {
        throw "An existing endpoint notification registration on {$url} for {$EventType} already exists."
    }

    # If no exisiting instances, add the current one to the registry entry
    $CurrentNotificationEndpoints += "$sanitizedUrl|$EventType;"
    [System.Environment]::SetEnvironmentVariable('M365DSCNotificationEndPointRegistrations', $CurrentNotificationEndpoints, `
            [System.EnvironmentVariableTarget]::Machine)
}

<#
.SYNOPSIS
    Removes a notification endpoint registration.

.DESCRIPTION
    Removes a URL and event type pair from the machine-level endpoint registration list.
    The function throws when the registration does not exist.

.PARAMETER Url
    Specifies the notification endpoint URL.

.PARAMETER EventType
    Specifies the registered event type to remove.

.FUNCTIONALITY
    Public
#>
function Remove-M365DSCNotificationEndpointRegistration
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('Drift', 'Error', 'Warning', 'NonDrift', 'RuleEvaluation')]
        $EventType
    )

    # Get current notification endpoint registrations from registry and parse them into an object.
    $CurrentNotificationEndpoints = ([System.Environment]::GetEnvironmentVariable('M365DSCNotificationEndPointRegistrations', `
                [System.EnvironmentVariableTarget]::Machine))
    $CurrentNotificationEndpointsAsObject = ConvertFrom-M365DSCNotificationEndpointRegistration -Value $CurrentNotificationEndpoints

    # Check to see if a notification endpoint registration with the same url and for the same event type already exists or not
    $sanitizedUrl = $Url.Replace('|', '').Replace(';', '')
    $existingInstance = $CurrentNotificationEndpointsAsObject | Where-Object -FilterScript { $_.Url -eq $sanitizedUrl -and $_.EventType -eq $EventType }
    if ($null -eq $existingInstance)
    {
        throw "No existing endpoint notification registration on {$url} for {$EventType} were found."
    }

    $remaining = $CurrentNotificationEndpointsAsObject | Where-Object -FilterScript { -not ($_.Url -eq $sanitizedUrl -and $_.EventType -eq $EventType) }
    $CurrentNotificationEndpoints = ConvertTo-M365DSCNotificationEndpointRegistration -Registration $remaining

    # If we found an exisiting instance, remove it from registry entry's value.
    [System.Environment]::SetEnvironmentVariable('M365DSCNotificationEndPointRegistrations', $CurrentNotificationEndpoints, `
            [System.EnvironmentVariableTarget]::Machine)
}

<#
.SYNOPSIS
    Retrieves notification endpoint registrations.

.DESCRIPTION
    Returns all or filtered endpoint registrations from the machine-level registration value based on URL and event type filters.

.PARAMETER Url
    Specifies an optional URL filter.

.PARAMETER EventType
    Specifies an optional event type filter.

.FUNCTIONALITY
    Public
#>
function Get-M365DSCNotificationEndpointRegistration
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Url,

        [Parameter()]
        [System.String]
        [ValidateSet('Drift', 'Error', 'Warning', 'NonDrift', 'RuleEvaluation')]
        $EventType
    )

    # Get current notification endpoint registrations from registry and parse them into an object.
    $CurrentNotificationEndpoints = ([System.Environment]::GetEnvironmentVariable('M365DSCNotificationEndPointRegistrations', `
                [System.EnvironmentVariableTarget]::Machine))
    if ($null -ne $CurrentNotificationEndpoints)
    {
        $CurrentNotificationEndpointsAsObject = ConvertFrom-M365DSCNotificationEndpointRegistration -Value $CurrentNotificationEndpoints

        # If both Url and EventType are null, return all endpoints
        if ([System.String]::IsNullOrEmpty($Url) -and [System.String]::IsNullOrEmpty($EventType))
        {
            return $CurrentNotificationEndpointsAsObject
        }
        elseif ([System.String]::IsNullOrEmpty($EventType) -and -not[System.String]::IsNullOrEmpty($Url))
        {
            # If Url is specified but EventType is null, return all endpoints on the given Url, no matter the EventType.
            return $CurrentNotificationEndpointsAsObject | Where-Object -Property Url -EQ $Url
        }
        elseif (-not [System.String]::IsNullOrEmpty($EventType) -and [System.String]::IsNullOrEmpty($Url))
        {
            # If EventType is specified but $Url is null, return all endpoints matching the specified EventType.
            return $CurrentNotificationEndpointsAsObject | Where-Object -Property EventType -EQ $EventType
        }
        elseif (-not [System.String]::IsNullOrEmpty($EventType) -and -not [System.String]::IsNullOrEmpty($Url))
        {
            # If both Url and EventType are specified, return endpoints that match both.
            return $CurrentNotificationEndpointsAsObject | Where-Object -FilterScript { $_.EventType -eq $EventType -and $_.Url -eq $Url }
        }
    }
    return $null
}

<#
.Description
This function receives an event, will loop through all registered notification endpoints
and will send a message to them if they have a registration on the given EventType of
the message.

.Functionality
Private
#>
function Send-M365DSCNotificationEndPointMessage
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $EventDetails,

        [Parameter()]
        [System.String]
        [ValidateSet('Drift', 'Error', 'Warning', 'NonDrift', 'RuleEvaluation')]
        $EventType
    )

    # Get all notification endpoints that are registered for the given EventType
    [Array]$endpointsToContact = Get-M365DSCNotificationEndpointRegistration -EventType $EventType

    $messageBody = @{
        Details   = $EventDetails
        EventType = $EventType
    }

    $Parameters = @{
        Method                   = 'POST'
        Uri                      = ''
        Body                     = ($messageBody | ConvertTo-Json)
        Headers                  = $null
        ContentType              = 'application/json'
        ConnectionTimeoutSeconds = 10
        OperationTimeoutSeconds  = 30
    }

    foreach ($endpoint in $endpointsToContact)
    {
        try
        {
            $domain = $endpoint.Url.Replace('https://', '').Replace('http://', '').Split('/')[0].Split('.')[0]
            $bearerTokenValue = Get-Variable -Name ('M365DSCNotificationEndpointBearer' + $domain) -Scope Global -ValueOnly -ErrorAction SilentlyContinue

            if (-not [System.String]::IsNullOrEmpty($bearerTokenValue))
            {
                $Parameters.Headers = @{'Authorization' = "Bearer $bearerTokenValue" }
            }
            else
            {
                $Parameters.Headers = $null
            }
            $Parameters.Uri = $endpoint.Url
            Invoke-RestMethod @Parameters | Out-Null
        }
        catch
        {
            Write-Verbose -Message "Could not send notification to {$($endpoint.Url)}: $_"
        }
    }
}

<#
.SYNOPSIS
    Configures M365DSC event logging options.

.DESCRIPTION
    Updates machine-scoped logging behavior for drift reporting.

.PARAMETER IncludeNonDrifted
    Specifies whether non-drifted resources should also be logged.

.FUNCTIONALITY
    Public
#>
function Set-M365DSCLoggingOption
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Boolean]
        $IncludeNonDrifted
    )

    if ($PSBoundParameters.ContainsKey('IncludeNonDrifted'))
    {
        [System.Environment]::SetEnvironmentVariable('M365DSCEventLogIncludeNonDrifted', $IncludeNonDrifted, `
                [System.EnvironmentVariableTarget]::Machine)
    }
}

<#
.SYNOPSIS
    Returns current M365DSC event logging options.

.DESCRIPTION
    Reads machine-scoped logging options and returns them as a hashtable.

.FUNCTIONALITY
    Public

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCLoggingOption
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param()

    $rawValue = [System.Environment]::GetEnvironmentVariable('M365DSCEventLogIncludeNonDrifted', [System.EnvironmentVariableTarget]::Machine)
    $includeNonDrifted = $false
    $null = [System.Boolean]::TryParse($rawValue, [ref] $includeNonDrifted)

    return @{
        IncludeNonDrifted = $includeNonDrifted
    }
}

<#
.SYNOPSIS
    Returns the source map of the generated class files.

.DESCRIPTION
    Reads Classes/SourceMap.json written by Utilities/Build-Microsoft365DSC.ps1 once per session.
    Keys are generated file names, values the blocks with StartLine, EndLine, Source and SourceLine.

.FUNCTIONALITY
    Private

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCSourceMap
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param()

    if ($null -eq $Script:M365DSCSourceMap)
    {
        $map = @{}
        $mapPath = Join-Path -Path $PSScriptRoot -ChildPath '../Classes/SourceMap.json'
        if (Test-Path -Path $mapPath)
        {
            $content = Get-Content -Path $mapPath -Raw | ConvertFrom-Json
            foreach ($property in $content.PSObject.Properties)
            {
                $map[$property.Name] = @($property.Value)
            }
        }
        $Script:M365DSCSourceMap = $map
    }

    return $Script:M365DSCSourceMap
}

<#
.SYNOPSIS
    Maps a line of a generated class file to its resource source file.

.DESCRIPTION
    Returns the source path and line for a line of Classes/Part<NN>.psm1 or Classes/_Shared.psm1,
    or $null when the line is not part of a mapped block. The path is absolute when the source file
    exists, otherwise relative to the module root.

.PARAMETER Path
    Path or file name of the generated file.

.PARAMETER Line
    Line number in the generated file.

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.Management.Automation.PSObject
#>
function Get-M365DSCSourceLocation
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $Line
    )

    $blocks = (Get-M365DSCSourceMap)[[System.IO.Path]::GetFileName($Path)]
    foreach ($block in $blocks)
    {
        if ($Line -ge $block.StartLine -and $Line -le $block.EndLine)
        {
            $sourcePath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath $block.Source
            if (-not (Test-Path -Path $sourcePath))
            {
                $sourcePath = $block.Source
            }

            return [PSCustomObject]@{
                Path = $sourcePath
                Line = $block.SourceLine + $Line - $block.StartLine
            }
        }
    }

    return $null
}

<#
.SYNOPSIS
    Adds the resource source location to every generated class file location in a text.

.DESCRIPTION
    Finds locations in Classes/Part<NN>.psm1 and Classes/_Shared.psm1, in both the stack trace
    form 'Part03.psm1: line 120' and the position form 'Part03.psm1:120', and appends the mapped
    source location as ' [<path>:<line>]'. An ErrorRecord is resolved from its ScriptStackTrace and
    PositionMessage.

.PARAMETER InputObject
    Text, such as a stack trace, or an ErrorRecord.

.FUNCTIONALITY
    Public

.OUTPUTS
    System.String
#>
function Resolve-M365DSCSourceLocation
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [System.Object]
        $InputObject
    )

    process
    {
        $text = $InputObject
        if ($InputObject -is [System.Management.Automation.ErrorRecord])
        {
            $text = $InputObject.ScriptStackTrace + [System.Environment]::NewLine + $InputObject.InvocationInfo.PositionMessage
        }

        if ([System.String]::IsNullOrEmpty($text))
        {
            return $text
        }

        $evaluator = [System.Text.RegularExpressions.MatchEvaluator] {
            param ($Match)

            $location = Get-M365DSCSourceLocation -Path $Match.Groups['file'].Value -Line $Match.Groups['line'].Value
            if ($null -eq $location)
            {
                return $Match.Value
            }

            return "$($Match.Value) [$($location.Path):$($location.Line)]"
        }

        return [System.Text.RegularExpressions.Regex]::Replace($text, '(?<file>(?:Part\d{2}|_Shared)\.psm1)(?:: line |:)(?<line>\d+)', $evaluator)
    }
}

<#
.SYNOPSIS
    Sets a breakpoint on a line of a resource source file.

.DESCRIPTION
    Maps the source line to the generated class file that the module runs and sets a line
    breakpoint there with Set-PSBreakpoint.

.PARAMETER Path
    Source file path, file name or resource name, for example AADAgreement, MSFT_AADAgreement or
    M365DSCResourceBase.psm1.

.PARAMETER Line
    Line numbers in the source file.

.FUNCTIONALITY
    Public

.OUTPUTS
    System.Management.Automation.LineBreakpoint
#>
function Set-M365DSCSourceBreakpoint
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.LineBreakpoint])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.Int32[]]
        $Line
    )

    $fileName = [System.IO.Path]::GetFileName($Path)
    if (-not $fileName.EndsWith('.psm1', [System.StringComparison]::OrdinalIgnoreCase))
    {
        $fileName += '.psm1'
    }
    $candidates = @($fileName, "MSFT_$fileName")

    $classRoot = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Classes'
    $map = Get-M365DSCSourceMap

    foreach ($sourceLine in $Line)
    {
        $target = $null
        foreach ($generatedFile in $map.Keys)
        {
            foreach ($block in $map[$generatedFile])
            {
                $lastSourceLine = $block.SourceLine + $block.EndLine - $block.StartLine
                if ([System.IO.Path]::GetFileName($block.Source) -in $candidates -and
                    $sourceLine -ge $block.SourceLine -and $sourceLine -le $lastSourceLine)
                {
                    $target = @{
                        Script = Join-Path -Path $classRoot -ChildPath $generatedFile
                        Line   = $block.StartLine + $sourceLine - $block.SourceLine
                    }
                    break
                }
            }

            if ($null -ne $target)
            {
                break
            }
        }

        if ($null -eq $target)
        {
            throw "Line $sourceLine of '$Path' is not part of a generated class file. Run Utilities/Build-Microsoft365DSC.ps1."
        }

        Set-PSBreakpoint -Script $target.Script -Line $target.Line
    }
}

Export-ModuleMember -Function @(
    'Add-M365DSCEvent',
    'Export-M365DSCDiagnosticData',
    'Get-M365DSCLoggingOption',
    'Get-M365DSCSourceLocation',
    'New-M365DSCLogEntry',
    'Get-M365DSCNotificationEndpointRegistration',
    'New-M365DSCNotificationEndpointRegistration',
    'Remove-M365DSCNotificationEndpointRegistration',
    'Resolve-M365DSCSourceLocation',
    'Set-M365DSCLoggingOption',
    'Set-M365DSCSourceBreakpoint'
)
