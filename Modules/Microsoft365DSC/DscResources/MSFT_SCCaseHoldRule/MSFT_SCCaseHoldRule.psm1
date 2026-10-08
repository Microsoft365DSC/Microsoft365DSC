using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCCaseHoldRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies a unique name for the case hold rule.')]
    [System.String] $Name

    [DscProperty(Key)]
    [System.ComponentModel.Description('The Policy parameter specifies the case hold policy that contains the rule. You can use any value that uniquely identifies the policy.')]
    [System.String] $Policy

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The ContentMatchQuery parameter specifies a content search filter. Use this parameter to create a query-based hold so only the content that matches the specified search query is placed on hold. This parameter uses a text search string or a query that''s formatted by using the Keyword Query Language (KQL).')]
    [System.String] $ContentMatchQuery

    [DscProperty()]
    [System.ComponentModel.Description('The Disabled parameter specifies whether the case hold rule is enabled or disabled.')]
    [System.Nullable[System.Boolean]] $Disabled

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the rule exists, absent ensures it is removed')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin Account')]
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

    [SCCaseHoldRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCCaseHoldRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SCCaseHoldRule for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                Confirm-M365DSCDependencies

                $null = $this.Connect('SecurityComplianceCenter')

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'
                $Rules = Invoke-M365DSCCommand -ScriptBlock { Get-CaseHoldRule -Policy $this.Policy -ErrorAction Stop } -SuppressNotFoundError
                $Rule = $Rules | Where-Object -FilterScript { $_.Name -eq $this.Name -and "$($_.Mode)" -ne 'PendingDeletion' }

                if ($null -eq $Rule)
                {
                    Write-Verbose -Message "SCCaseHoldRule $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $Rule = $this.ExportedInstance
            }

            Write-Verbose "Found existing SCCaseHoldRule $($this.Name)"

            $result = @{
                Name                  = $Rule.Name
                Policy                = $this.Policy
                Comment               = $Rule.Comment
                Disabled              = $Rule.Disabled
                ContentMatchQuery     = $Rule.ContentMatchQuery
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

        Write-Verbose -Message "Setting configuration of SCCaseHoldRule for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentRule = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentRule.Ensure -eq 'Absent')
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            Write-Verbose "Creating new Case Hold Rule $($this.Name) calling the New-CaseHoldRule cmdlet."
            try
            {
                New-CaseHoldRule @CreationParams -ErrorAction Stop
            }
            catch
            {
                [SCCaseHoldRule]::ThrowUnlessDeploymentFailure($_)
            }
        }
        # Compliance Case exists and it should. Update it.
        elseif ($this.Ensure -eq 'Present' -and $CurrentRule.Ensure -eq 'Present')
        {
            $UpdateParams = @{
                Identity          = $this.Name
                Comment           = $this.Comment
                Disabled          = $this.Disabled
                ContentMatchQuery = $this.ContentMatchQuery
            }
            Write-Verbose "Updating Case Hold Rule $($this.Name) by calling the Set-CaseHoldRule cmdlet."
            try
            {
                Set-CaseHoldRule @UpdateParams -ErrorAction Stop
            }
            catch
            {
                [SCCaseHoldRule]::ThrowUnlessDeploymentFailure($_)
            }
        }
        # Compliance Case exists but it shouldn't. Remove it.
        elseif ($this.Ensure -eq 'Absent' -and $CurrentRule.Ensure -eq 'Present')
        {
            try
            {
                Remove-CaseHoldRule -Identity $this.Name -Confirm:$false -ErrorAction Stop
            }
            catch
            {
                [SCCaseHoldRule]::ThrowUnlessDeploymentFailure($_)
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
            [array]$Rules = Get-CaseHoldRule -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($Rules.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($Rule in $Rules)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($Rules.Count)] $($Rule.Name)" -DeferWrite
                try
                {
                    $policyObject = Get-CaseHoldPolicy -Identity $Rule.Policy -ErrorAction Stop

                    $this.ExportedInstance = $Rule
                    $Results = $this.GetForExport(@{ Name = $Rule.Name; Policy = $policyObject.Name })
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
                }
                catch
                {
                    Write-Verbose -Message "You are not authorized to access Case Hold Policy {$($Rule.Policy)}"
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

    hidden static [void] ThrowUnlessDeploymentFailure([System.Management.Automation.ErrorRecord] $ErrorRecord)
    {
        if ($ErrorRecord.Exception.Message -notlike '*failed to be deployed*')
        {
            throw $ErrorRecord
        }
        Write-Warning -Message ($ErrorRecord.Exception.Message -split "`r?`n")[0]
    }

    hidden [SCCaseHoldRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCCaseHoldRule])
        {
            return $Values
        }

        $result = [SCCaseHoldRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
