using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCCaseHoldPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the case hold policy.')]
    [System.String] $Name

    [DscProperty(Key)]
    [System.ComponentModel.Description('The Case parameter specifies the eDiscovery case that you want to associate with the case hold policy.')]
    [System.String] $Case

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The Enabled parameter specifies whether the policy is enabled or disabled.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeLocation parameter specifies the mailboxes to include in the policy.')]
    [System.String[]] $ExchangeLocation

    [DscProperty()]
    [System.ComponentModel.Description('The PublicFolderLocation parameter specifies that you want to include all public folders in the case hold policy. You use the value All for this parameter.')]
    [System.String[]] $PublicFolderLocation

    [DscProperty()]
    [System.ComponentModel.Description('The SharePointLocation parameter specifies the SharePoint Online and OneDrive for Business sites to include. You identify a site by its URL value.')]
    [System.String[]] $SharePointLocation

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

    [SCCaseHoldPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCCaseHoldPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SCCaseHoldPolicy for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'
                $CaseObject = Invoke-M365DSCCommand -ScriptBlock { Get-ComplianceCase -Identity $this.Case -ErrorAction Stop } -SuppressNotFoundError
                if ($null -eq $CaseObject)
                {
                    Write-Verbose -Message "Compliance case $($this.Case) does not exist."
                    return $this.AsResult($nullReturn)
                }

                $PolicyObject = Invoke-M365DSCCommand -ScriptBlock { Get-CaseHoldPolicy -Case $this.Case -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $PolicyObject -or "$($PolicyObject.Mode)" -eq 'PendingDeletion')
                {
                    Write-Verbose -Message "SCCaseHoldPolicy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $PolicyObject = $this.ExportedInstance
            }

            Write-Verbose "Found existing SCCaseHoldPolicy $($this.Name)"

            $result = @{
                Ensure                = 'Present'
                Name                  = $PolicyObject.Name
                Case                  = $this.Case
                Enabled               = $PolicyObject.Enabled
                Comment               = $PolicyObject.Comment
                ExchangeLocation      = $PolicyObject.ExchangeLocation.Name
                PublicFolderLocation  = $PolicyObject.PublicFolderLocation.Name
                SharePointLocation    = $PolicyObject.SharePointLocation.Name
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

        Write-Verbose -Message "Setting configuration of SCCaseHoldPolicy for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentPolicy = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Absent')
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            try
            {
                New-CaseHoldPolicy @CreationParams -ErrorAction Stop
            }
            catch
            {
                [SCCaseHoldPolicy]::ThrowUnlessDeploymentFailure($_)
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $CreationParams.Remove('Name')
            $CreationParams.Remove('Case')

            $policy = Get-CaseHoldPolicy -Identity $this.Name -Case $this.Case
            $CreationParams.Add('Identity', $policy.Name)

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
            if ($null -ne $CurrentPolicy.PublicFolderLocation -or `
                    $null -ne $this.PublicFolderLocation)
            {
                $ToBeRemoved = $CurrentPolicy.PublicFolderLocation | `
                        Where-Object { $this.PublicFolderLocation -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    $CreationParams.Add('RemovePublicFolderLocation', $ToBeRemoved)
                }

                $ToBeAdded = $this.PublicFolderLocation | `
                        Where-Object { $CurrentPolicy.PublicFolderLocation -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    $CreationParams.Add('AddPublicFolderLocation', $ToBeAdded)
                }
                $CreationParams.Remove('PublicFolderLocation')
            }

            Write-Verbose "Updating Policy with values: $(Convert-M365DscHashtableToString -Hashtable $CreationParams)"
            try
            {
                Set-CaseHoldPolicy @CreationParams -ErrorAction Stop
            }
            catch
            {
                [SCCaseHoldPolicy]::ThrowUnlessDeploymentFailure($_)
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            # If the Policy exists and it shouldn't, simply remove it;
            $policy = Get-CaseHoldPolicy -Identity $this.Name -Case $this.Case
            try
            {
                Remove-CaseHoldPolicy -Identity $policy.Name -Confirm:$false -ErrorAction Stop
            }
            catch
            {
                [SCCaseHoldPolicy]::ThrowUnlessDeploymentFailure($_)
            }

            foreach ($rule in @(Get-CaseHoldRule -Policy $policy.Name -ErrorAction SilentlyContinue))
            {
                Remove-CaseHoldRule -Identity $rule.Name -ForceDeletion -Confirm:$false
            }
            try
            {
                Remove-CaseHoldPolicy -Identity $policy.Name -ForceDeletion -Confirm:$false -ErrorAction Stop
            }
            catch
            {
                [SCCaseHoldPolicy]::ThrowUnlessDeploymentFailure($_)
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
            [array]$cases = Get-ComplianceCase -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($cases.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($case in $cases)
            {
                Write-M365DSCHost -Message "    |---[$i/$($Cases.Count)] Scanning Policies in Case {$($case.Name)}"
                [array]$policies = Get-CaseHoldPolicy -Case $case.Name

                $j = 1
                foreach ($policy in $policies)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "        |---[$j/$($policies.Count)] $($policy.Name)" -DeferWrite

                    $this.ExportedInstance = $policy
                    $Results = $this.GetForExport(@{ Name = $policy.Name; Case = $case.Name })
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

    hidden [SCCaseHoldPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCCaseHoldPolicy])
        {
            return $Values
        }

        $result = [SCCaseHoldPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
