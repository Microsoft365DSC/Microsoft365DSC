using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsApplicationInstance : M365DSCResourceBase
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The display name of the resource instance.')]
    [System.String] $DisplayName

    [DscProperty(Key)]
    [System.ComponentModel.Description('The user principal name associated with the resource instance.')]
    [System.String] $UserPrincipalName

    [DscProperty()]
    [System.ComponentModel.Description('The type of resource account. Values can be: AutoAttendant or CallQueue.')]
    [ValidateSet('AutoAttendant', 'CallQueue')]
    [System.String] $ResourceAccountType

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [TeamsApplicationInstance] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsApplicationInstance]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for TeamsApplicationInstance $($this.DisplayName)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-CsOnlineApplicationInstance -Identity $this.UserPrincipalName -ErrorAction SilentlyContinue
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $ResourceAccountTypeValue = $null
            if (-not [System.String]::IsNullOrEmpty($instance.ApplicationId))
            {
                if ($instance.ApplicationId -eq 'ce933385-9390-45d1-9512-c8d228074e07')
                {
                    $ResourceAccountTypeValue = 'AutoAttendant'
                }
                elseif ($instance.ApplicationId -eq '11cd3e2e-fccb-42ad-ad00-878b93575e07')
                {
                    $ResourceAccountTypeValue = 'CallQueue'
                }
            }

            $results = @{
                DisplayName           = $instance.DisplayName
                UserPrincipalName     = $instance.UserPrincipalName
                ResourceAccountType   = $ResourceAccountTypeValue
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

        Write-Verbose -Message "Setting configuration for TeamsApplicationInstance $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        $currentInstance = $this.Get().ToHashtable()

        $params = @{
            DisplayName       = $this.DisplayName
            UserPrincipalName = $this.UserPrincipalName
        }

        if (-not [System.String]::IsNullOrEmpty($this.ResourceAccountType))
        {
            Write-Verbose -Message 'ResourceAccountType specified. Retrieving associated ApplicationId'
            if ($this.ResourceAccountType -eq 'AutoAttendant')
            {
                $params.Add('ApplicationId', 'ce933385-9390-45d1-9512-c8d228074e07')
            }
            elseif ($this.ResourceAccountType -eq 'CallQueue')
            {
                $params.Add('ApplicationId', '11cd3e2e-fccb-42ad-ad00-878b93575e07')
            }
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            New-CsOnlineApplicationInstance @params -ErrorAction SilentlyContinue
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating application instance {$($this.DisplayName)}"

            if ($ConnectionMode -ne 'Credentials')
            {
                throw 'Updating an existing instance of TeamsApplicationInstance requires delegated credentials. Set-CsOnlineApplicationInstance does not support application-based authentication.'
            }

            $updateParameters = @{
                Identity    = $this.UserPrincipalName
                DisplayName = $this.DisplayName
            }
            if ($params.ContainsKey('ApplicationId'))
            {
                $updateParameters.Add('ApplicationId', $params.ApplicationId)
            }
            Set-CsOnlineApplicationInstance @updateParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            throw 'Resource instances of type {TeamsApplicationInstance} cannot be removed.'
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
            [array]$exportedInstances = Get-CsOnlineApplicationInstance -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.DisplayName
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DisplayName           = $config.DisplayName
                    UserPrincipalName     = $config.UserPrincipalName
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
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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

    hidden [TeamsApplicationInstance] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsApplicationInstance])
        {
            return $Values
        }

        $result = [TeamsApplicationInstance]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
