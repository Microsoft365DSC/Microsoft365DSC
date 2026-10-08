using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsTemplatesPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the Teams Templates Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Teams Templates Policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The list of Teams templates to hide.')]
    [System.String[]] $HiddenTemplates

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin.')]
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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter = '*'

    [TeamsTemplatesPolicy] Get()
    {
        ${$Identity} = $null
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsTemplatesPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Teams Calling Policy {$($this.Identity)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $policy = Get-CsTeamsTemplatePermissionPolicy -Identity $this.Identity -ErrorAction 'SilentlyContinue'
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "Could not find Teams Templates Policy ${$Identity}"
                return $this.AsResult($nullReturn)
            }
            Write-Verbose -Message "Found Teams Templates Policy {$($this.Identity)}"
            $allTemplates = Get-CsTeamTemplateList -ErrorAction 'Stop'

            $hiddenTemplatesNames = @()
            if ($null -ne $policy.HiddenTemplates)
            {
                foreach ($hiddenTemplate in $policy.HiddenTemplates.Id)
                {
                    $currentTemplate = $allTemplates | Where-Object -FilterScript { $_.Id -eq $hiddenTemplate }
                    if ($null -ne $currentTemplate)
                    {
                        $hiddenTemplatesNames += $currentTemplate.Name
                    }
                }
            }

            return $this.AsResult(@{
                Identity              = $this.Identity
                Description           = $policy.Description
                HiddenTemplates       = $hiddenTemplatesNames
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

        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $hideTemplatesValues = @()
        if ($null -ne $this.HiddenTemplates)
        {
            $allTemplates = Get-CsTeamTemplateList
            foreach ($hiddenTemplate in $this.HiddenTemplates)
            {
                $template = $allTemplates | Where-Object -FilterScript { $_.Name -eq $hiddenTemplate }
                $hideTemplatesValues += New-CsTeamsHiddenTemplate -Id $template.Id
            }
            $SetParameters.HiddenTemplates = $hideTemplatesValues
        }
        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new Teams Template Policy {$($this.Identity)} with parameters:"
            Write-Verbose -Message $(Convert-M365DscHashtableToString -Hashtable $SetParameters)
            New-CsTeamsTemplatePermissionPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating settings for Teams Templates Policy {$($this.Identity)} with parameters:"
            Write-Verbose -Message $(Convert-M365DscHashtableToString -Hashtable $SetParameters)
            Set-CsTeamsTemplatePermissionPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing Teams Templates Policy {$($this.Identity)}"
            Remove-CsTeamsTemplatePermissionPolicy -Identity $this.Identity -Confirm:$false
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
            $i = 1
            [array]$policies = Get-CsTeamsTemplatePermissionPolicy -Filter $this.Filter -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Length)] $($policy.Identity)" -DeferWrite
                $params = @{
                    Identity              = $policy.Identity
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

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [TeamsTemplatesPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsTemplatesPolicy])
        {
            return $Values
        }

        $result = [TeamsTemplatesPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
