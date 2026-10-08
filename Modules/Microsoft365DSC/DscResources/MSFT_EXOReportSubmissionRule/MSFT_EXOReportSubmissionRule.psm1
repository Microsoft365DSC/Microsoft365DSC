using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOReportSubmissionRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The Identity parameter specifies the report submission rule that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The Comments parameter specifies informative comments for the rule, such as what the rule is used for or how it has changed over time.')]
    [System.String] $Comments

    [DscProperty()]
    [System.ComponentModel.Description('The SentTo parameter specifies the email address of the reporting mailbox in Exchange Online where user reported messages are sent.')]
    [System.String[]] $SentTo

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this report submission rule should exist.')]
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

    [EXOReportSubmissionRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOReportSubmissionRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of ReportSubmissionRule'

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'
                $nullReturn.IsSingleInstance = 'Yes'

                $ReportSubmissionRule = Get-ReportSubmissionRule -ErrorAction SilentlyContinue
                if ($null -eq $ReportSubmissionRule)
                {
                    Write-Verbose -Message 'ReportSubmissionRule does not exist.'
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $ReportSubmissionRule = $this.ExportedInstance
            }

            Write-Verbose -Message "Found ReportSubmissionRule with Identity {$($this.Identity)}"

            $result = @{
                IsSingleInstance      = 'Yes'
                Identity              = $ReportSubmissionRule.Identity
                Comments              = $ReportSubmissionRule.Comments
                SentTo                = $ReportSubmissionRule.SentTo
                Credential            = $this.Credential
                Ensure                = 'Present'
                ApplicationId         = $this.ApplicationId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                TenantId              = $this.TenantId
                AccessTokens          = $this.AccessTokens
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')
        Write-Verbose -Message 'Setting configuration of ReportSubmissionRule'

        $currentReportSubmissionRule = $this.Get().ToHashtable()

        $ReportSubmissionRuleParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $ReportSubmissionRuleParams.Remove('IsSingleInstance') | Out-Null

        if ($this.Ensure -eq 'Present' -and $currentReportSubmissionRule.Ensure -eq 'Absent')
        {
            Write-Verbose -Message 'Creating ReportSubmissionRule'

            $ReportSubmissionRuleParams.Add('Name', $this.Identity) | Out-Null
            $ReportSubmissionRuleParams.Remove('Identity') | Out-Null
            # There is only one ReportSubmissionPolicy, so we can hardcode the identity.
            $ReportSubmissionRuleParams.Add('ReportSubmissionPolicy', 'DefaultReportSubmissionPolicy') | Out-Null

            New-ReportSubmissionRule @ReportSubmissionRuleParams
        }
        elseif ($this.Ensure -eq 'Present' -and $currentReportSubmissionRule.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Setting ReportSubmissionRule with values: $(Convert-M365DscHashtableToString -Hashtable $ReportSubmissionRuleParams)"
            Set-ReportSubmissionRule @ReportSubmissionRuleParams -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentReportSubmissionRule.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Removing ReportSubmissionRule'
            Remove-ReportSubmissionRule -Identity $this.Identity -Confirm:$false
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $ReportSubmissionRule = Get-ReportSubmissionRule -ErrorAction Stop
            if ($ReportSubmissionRule.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                return ''
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()

            Write-M365DSCHost -Message '    |---Export ReportSubmissionRule' -DeferWrite

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $Params = @{
                Identity              = $ReportSubmissionRule.Identity
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                CertificatePath       = $this.CertificatePath
                IsSingleInstance      = 'Yes'
                AccessTokens          = $this.AccessTokens
            }
            $this.ExportedInstance = $ReportSubmissionRule
            $Results = $this.GetForExport($Params)
            $keysToRemove = @()
            foreach ($key in $Results.Keys)
            {
                if ([System.String]::IsNullOrEmpty($Results.$key))
                {
                    $keysToRemove += $key
                }
            }
            foreach ($key in $keysToRemove)
            {
                $Results.Remove($key) | Out-Null
            }
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $Results `
                -Credential $this.Credential
            [void]$dscContent.Append($currentDSCBlock)
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOReportSubmissionRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOReportSubmissionRule])
        {
            return $Values
        }

        $result = [EXOReportSubmissionRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
