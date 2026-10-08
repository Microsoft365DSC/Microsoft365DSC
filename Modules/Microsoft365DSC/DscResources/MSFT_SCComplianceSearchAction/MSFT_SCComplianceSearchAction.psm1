using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCComplianceSearchAction : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Action parameter specifies what type of action to define. Accepted values are Export, Retention and Purge.')]
    [ValidateSet('Export', 'Preview', 'Purge', 'Retention')]
    [System.String] $Action

    [DscProperty(Key)]
    [System.ComponentModel.Description('The SearchName parameter specifies the name of the existing content search to associate with the content search action. You can specify multiple content searches separated by commas.')]
    [System.String] $SearchName

    [DscProperty()]
    [System.ComponentModel.Description('The FileTypeExclusionsForUnindexedItems specifies the file types to exclude because they can''t be indexed. You can specify multiple values separated by commas.')]
    [System.String[]] $FileTypeExclusionsForUnindexedItems

    [DscProperty()]
    [System.ComponentModel.Description('The EnableDedupe parameter eliminates duplication of messages when you export content search results.')]
    [System.Nullable[System.Boolean]] $EnableDedupe

    [DscProperty()]
    [System.ComponentModel.Description('The IncludeCredential switch specifies whether to include the credential in the results.')]
    [System.Nullable[System.Boolean]] $IncludeCredential

    [DscProperty()]
    [System.ComponentModel.Description('The IncludeSharePointDocumentVersions parameter specifies whether to export previous versions of the document when you use the Export switch.')]
    [System.Nullable[System.Boolean]] $IncludeSharePointDocumentVersions

    [DscProperty()]
    [System.ComponentModel.Description('The PurgeType parameter specifies how to remove items when the action is Purge.')]
    [ValidateSet('SoftDelete', 'HardDelete')]
    [System.String] $PurgeType

    [DscProperty()]
    [System.ComponentModel.Description('The RetryOnError switch specifies whether to retry the action on any items that failed without re-running the entire action all over again.')]
    [System.Nullable[System.Boolean]] $RetryOnError

    [DscProperty()]
    [System.ComponentModel.Description('The ActionScope parameter specifies the items to include when the action is Export.')]
    [ValidateSet('IndexedItemsOnly', 'UnindexedItemsOnly', 'BothIndexedAndUnindexedItems')]
    [System.String] $ActionScope

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this action should exist or not.')]
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

    [SCComplianceSearchAction] Get()
    {
        $IncludeCreds = $null
        $ActionName = $null
        $enableDedupeValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCComplianceSearchAction]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SCComplianceSearchAction for $($this.SearchName) - $($this.Action)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Action -ne $this.Action)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $currentAction = Invoke-M365DSCCommand -ScriptBlock { $this.GetCurrentAction($this.SearchName, $this.Action) } -SuppressNotFoundError

                if ($null -eq $currentAction)
                {
                    Write-Verbose -Message "SCComplianceSearchAction $ActionName does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $currentAction = $this.ExportedInstance
            }

            if ($this.Action -eq 'Export' -or $this.Action -eq 'Retention')
            {
                $Scenario = $this.GetResultProperty($currentAction.Results, 'Scenario')
                $FileTypeExclusion = $this.GetResultProperty($currentAction.Results, 'File type exclusions for unindexed')
                $rawEnableDedupe = $this.GetResultProperty($currentAction.Results, 'Enable dedupe')
                if (-not [System.String]::IsNullOrEmpty($rawEnableDedupe))
                {
                    $enableDedupeValue = [System.Convert]::ToBoolean($rawEnableDedupe)
                }
                $IncludeCreds = $this.GetResultProperty($currentAction.Results, 'SAS token')
                $IncludeSP = $this.GetResultProperty($currentAction.Results, 'Include SharePoint versions')
                $ScopeValue = $this.GetResultProperty($currentAction.Results, 'Scope')

                $ActionName = $this.Action
                if ('RetentionReports' -eq $Scenario)
                {
                    $ActionName = 'Retention'
                }

                $result = @{
                    Action                              = $ActionName
                    SearchName                          = $currentAction.SearchName
                    FileTypeExclusionsForUnindexedItems = $FileTypeExclusion
                    EnableDedupe                        = $enableDedupeValue
                    IncludeSharePointDocumentVersions   = $IncludeSP
                    RetryOnError                        = $currentAction.Retry
                    ActionScope                         = $ScopeValue
                    Ensure                              = 'Present'
                    Credential                          = $this.Credential
                    ApplicationId                       = $this.ApplicationId
                    TenantId                            = $this.TenantId
                    CertificateThumbprint               = $this.CertificateThumbprint
                    CertificatePath                     = $this.CertificatePath
                    CertificatePassword                 = $this.CertificatePassword
                    ManagedIdentity                     = $this.ManagedIdentity
                    AccessTokens                        = $this.AccessTokens
                }
                if ($ActionName -eq 'Preview')
                {
                    $result.Remove('EnableDedupe') | Out-Null
                }
            }
            elseif ($this.Action -eq 'Purge')
            {
                $PurgeTP = $this.GetResultProperty($currentAction.Results, 'Purge Type')
                $result = @{
                    Action                = $currentAction.Action
                    SearchName            = $currentAction.SearchName
                    PurgeType             = $PurgeTP
                    RetryOnError          = $currentAction.Retry
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    Ensure                = 'Present'
                    AccessTokens          = $this.AccessTokens
                }
            }
            else
            {
                $result = @{
                    Action                = $currentAction.Action
                    SearchName            = $currentAction.SearchName
                    RetryOnError          = $currentAction.Retry
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    Ensure                = 'Present'
                    AccessTokens          = $this.AccessTokens
                }
            }

            if ('<Specify -IncludeCredential parameter to show the SAS token>' -eq $IncludeCreds -or 'Purge' -eq $this.Action)
            {
                $result.Add('IncludeCredential', $false)
            }
            elseif ('Purge' -ne $this.Action)
            {
                $result.Add('IncludeCredential', $true)
            }

            Write-Verbose "Found existing $($this.Action) SCComplianceSearchAction for Search $($this.SearchName)"

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
        $status = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of SCComplianceSearchAction for $($this.SearchName) - $($this.Action)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentAction = $this.Get().ToHashtable()

        # Calling the New-ComplianceSearchAction if the action already exists, updates it.
        if ('Present' -eq $this.Ensure)
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            if ($null -ne $this.ActionScope)
            {
                $CreationParams.Remove('ActionScope')
                $CreationParams.Add('Scope', $this.ActionScope)
            }

            switch ($this.Action)
            {
                'Export'
                {
                    $CreationParams.Add('Report', $true)
                }
                'Retention'
                {
                    $CreationParams.Add('RetentionReport', $true)
                }
                'Purge'
                {
                    $CreationParams.Add('Purge', $true)
                    $CreationParams.Remove('ActionScope') | Out-Null
                    $CreationParams.Remove('Scope') | Out-Null
                    $CreationParams.Add('Confirm', $false)
                }
                'Preview'
                {
                    $CreationParams.Add('Preview', $true)
                    $CreationParams.Remove('Scope') | Out-Null
                    $CreationParams.Add('Confirm', $false)
                    $CreationParams.Remove('EnableDedupe') | Out-Null
                }
            }

            $CreationParams.Remove('Action')

            Write-Verbose -Message 'Creating new Compliance Search Action calling the New-ComplianceSearchAction cmdlet'

            try
            {
                New-ComplianceSearchAction @CreationParams -ErrorAction Stop
            }
            catch
            {
                if ($_.Exception -like '*Please update the search results to get the most current estimate.*')
                {
                    try
                    {
                        Write-Verbose "Starting Compliance Search $($this.SearchName)"
                        Start-ComplianceSearch -Identity $this.SearchName

                        $loop = 1
                        do
                        {
                            $status = (Get-ComplianceSearch -Identity $this.SearchName).Status
                            Write-Verbose -Message "($loop) Waiting for 60 seconds for Compliance Search $($this.SearchName) to complete."
                            Start-Sleep -Seconds 60
                            $loop++
                        } while ($status -ne 'Completed' -and $loop -lt 10)
                        New-ComplianceSearchAction @CreationParams -ErrorAction Stop
                    }
                    catch
                    {
                        New-ComplianceSearchAction @CreationParams -ErrorAction Stop
                    }
                }
                else
                {
                    $this.LogError($_, 'Could not create a new SCComplianceSearchAction')
                    Write-Verbose -Message 'An error occured creating a new SCComplianceSearchAction'
                    throw $_
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentAction.Ensure -eq 'Present')
        {
            $currentAction = $this.GetCurrentAction($this.SearchName, $this.Action)

            # If the Rule exists and it shouldn't, simply remove it;
            Remove-ComplianceSearchAction -Identity $currentAction.Identity -Confirm:$false
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
            [array]$actions = Get-ComplianceSearchAction -ErrorAction Stop

            if ($actions.Count -gt 0)
            {
                Write-M365DSCHost -Message "`r`n    Tenant Wide Actions:" -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            foreach ($action in $actions)
            {
                Write-M365DSCHost -Message "        |---[$i/$($actions.Length)] $($action.Name)" -DeferWrite
                $Params = @{
                    Action     = $action.Action
                    SearchName = $action.SearchName
                }

                $Scenario = $this.GetResultProperty($action.Results, 'Scenario')

                if ('RetentionReports' -eq $Scenario)
                {
                    $Params.Action = 'Retention'
                }
                $this.ExportedInstance = $action
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
                $i++
            }

            [array]$cases = Get-ComplianceCase -ErrorAction Stop

            $j = 1
            foreach ($case in $cases)
            {
                Write-M365DSCHost -Message "    Case [$j/$($cases.Count)] $($Case.Name)"

                $actions = Get-ComplianceSearchAction -Case $Case.Name

                $i = 1
                foreach ($action in $actions)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "        |---[$i/$($actions.Length)] $($action.Name)" -DeferWrite

                    $Params = @{
                        Action     = $action.Action
                        SearchName = $action.SearchName
                    }

                    $Scenario = $this.GetResultProperty($action.Results, 'Scenario')

                    if ('RetentionReports' -eq $Scenario)
                    {
                        $Params.Action = 'Retention'
                    }
                    $Results = $this.Get().ToHashtable()
                    $rawResults = $Results.Clone()

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -RawResults $rawResults
                    [void]$dscContent.Append($currentDSCBlock)
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    $i++
                }
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

    hidden [System.Object] GetResultProperty([System.String] $ResultString, [System.String] $PropertyName)
    {
        $start = $ResultString.IndexOf($PropertyName) + $PropertyName.Length + 2
        if ($start -lt 0 -or $start -gt $ResultString.Length)
        {
            return $null
        }
        $end = $ResultString.IndexOf(';', $start)

        $result = $null
        if ($end -gt $start)
        {
            $result = $ResultString.SubString($start, $end - $start).Trim()

            if ('<null>' -eq $result)
            {
                $result = $null
            }
            elseif ('True' -eq $result)
            {
                $result = $true
            }
            elseif ('False' -eq $result)
            {
                $result = $false
            }
        }

        return $result
    }

    hidden [System.Object] GetCurrentAction([System.String] $SearchName, [System.String] $Action)
    {
        # For the sake of retrieving the current action, search by Action = Export;
        $scenario = $null
        $effectiveAction = $Action
        if ('Retention' -eq $Action)
        {
            $effectiveAction = 'Export'
            $scenario = 'RetentionReports'
        }
        elseif ('Export' -eq $Action)
        {
            $scenario = 'GenerateReports'
        }

        # Get the case associated with the Search Instance if any;
        $cases = Get-ComplianceCase
        $currentAction = $null

        foreach ($case in $cases)
        {
            $searches = Get-ComplianceSearch -Case $case.Name | Where-Object -FilterScript { $_.Name -eq $SearchName }

            if ($null -ne $searches)
            {
                $currentAction = Get-ComplianceSearchAction -Case $case.Name
                break
            }
        }

        if ($null -eq $currentAction)
        {
            $currentAction = Get-ComplianceSearchAction | Where-Object -FilterScript { $_.SearchName -eq $SearchName -and $_.Action -eq $effectiveAction }
        }

        if ('Purge' -ne $effectiveAction -and $null -ne $currentAction -and -not [System.String]::IsNullOrEmpty($scenario))
        {
            $currentAction = $currentAction | Where-Object -FilterScript { $_.Results -like "*Scenario: $($scenario)*" }
        }
        elseif ('Purge' -eq $effectiveAction)
        {
            $currentAction = $currentAction | Where-Object -FilterScript { $_.Action -eq 'Purge' }
        }
        elseif ('Preview' -eq $effectiveAction)
        {
            $currentAction = $currentAction | Where-Object -FilterScript { $_.Action -eq 'Preview' }
        }

        return $currentAction
    }

    hidden [SCComplianceSearchAction] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCComplianceSearchAction])
        {
            return $Values
        }

        $result = [SCComplianceSearchAction]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
