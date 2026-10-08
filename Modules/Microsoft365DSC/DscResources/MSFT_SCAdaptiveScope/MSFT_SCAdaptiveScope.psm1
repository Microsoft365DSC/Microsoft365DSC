using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCAdaptiveScope : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the adaptive scope.')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of location the adaptive scope targets. It cannot be changed after the scope is created.')]
    [ValidateSet('User', 'Group', 'Site')]
    [System.String] $LocationType

    [DscProperty()]
    [System.ComponentModel.Description('The filter conditions of the adaptive scope as a JSON string with a Conjunction and a list of Conditions. A condition either has a Name, an Operator and a Value or is a nested group with its own Conjunction and Conditions. Cannot be combined with RawQuery.')]
    [System.String] $FilterConditions

    [DscProperty()]
    [System.ComponentModel.Description('The advanced query of the adaptive scope. Cannot be combined with FilterConditions.')]
    [System.String] $RawQuery

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the RawQuery of a Site scope uses the Keyword Query Language. It cannot be changed after the scope is created.')]
    [System.Nullable[System.Boolean]] $UseKql

    [DscProperty()]
    [System.ComponentModel.Description('The display name or id of the administrative unit the adaptive scope is restricted to.')]
    [System.String] $AdministrativeUnit

    [DscProperty()]
    [System.ComponentModel.Description('The comment of the adaptive scope.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The states of the users or groups the adaptive scope includes. Only supported by User and Group scopes.')]
    [ValidateSet('Active', 'Inactive', 'SoftDeleted')]
    [System.String[]] $EnabledStates

    [DscProperty()]
    [System.ComponentModel.Description('The states of the OneDrive, group and channel sites the adaptive scope includes. Only supported by Site scopes.')]
    [ValidateSet('OneDrive_Active', 'OneDrive_Inactive', 'OneDrive_SoftDeleted', 'GroupSite_Active', 'GroupSite_Inactive', 'GroupSite_SoftDeleted', 'ChannelSite_Active', 'ChannelSite_SoftDeleted')]
    [System.String[]] $LinkedRecipientEnabledStates

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the adaptive scope should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin')]
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
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [SCAdaptiveScope] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCAdaptiveScope]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SC Adaptive Scope {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $scopeName = $this.Name
                $instance = Invoke-M365DSCCommand -ScriptBlock { Get-AdaptiveScope -Identity $scopeName -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $instance -or $instance.Mode -eq 'PendingDeletion')
                {
                    Write-Verbose -Message "No SC Adaptive Scope with Name {$($this.Name)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "Found SC Adaptive Scope with Name {$($this.Name)}"

            $filterConditionsValue = $null
            if (-not [System.String]::IsNullOrEmpty($instance.FilterConditions))
            {
                $filterConditionsValue = $instance.FilterConditions
                if (-not [System.String]::IsNullOrEmpty($this.FilterConditions) -and
                    [SCAdaptiveScope]::ConvertToCanonicalJson($this.FilterConditions) -eq [SCAdaptiveScope]::ConvertToCanonicalJson($filterConditionsValue))
                {
                    $filterConditionsValue = $this.FilterConditions
                }
            }

            $administrativeUnitValue = $null
            if ($null -ne $instance.AdministrativeUnit -and $instance.AdministrativeUnit -ne [System.Guid]::Empty)
            {
                $administrativeUnitValue = $instance.AdministrativeUnit.ToString()
                if ($this.AdministrativeUnit -ne $administrativeUnitValue)
                {
                    $null = $this.Connect('MicrosoftGraph')
                    $unit = Get-MgDirectoryAdministrativeUnit -AdministrativeUnitId $administrativeUnitValue -ErrorAction SilentlyContinue
                    if ($null -ne $unit)
                    {
                        $administrativeUnitValue = $unit.DisplayName
                    }
                }
            }

            $commentValue = $null
            if (-not [System.String]::IsNullOrEmpty($instance.Comment))
            {
                $commentValue = $instance.Comment
            }

            $rawQueryValue = $null
            if (-not [System.String]::IsNullOrEmpty($instance.RawQuery))
            {
                $rawQueryValue = $instance.RawQuery
            }

            $result = @{
                Name                         = $instance.Name
                LocationType                 = [System.String] $instance.LocationType
                FilterConditions             = $filterConditionsValue
                RawQuery                     = $rawQueryValue
                UseKql                       = $instance.UseKql
                AdministrativeUnit           = $administrativeUnitValue
                Comment                      = $commentValue
                EnabledStates                = [System.String[]] $instance.EnabledStates
                LinkedRecipientEnabledStates = [System.String[]] $instance.LinkedRecipientEnabledStates
                Ensure                       = 'Present'
                Credential                   = $this.Credential
                ApplicationId                = $this.ApplicationId
                TenantId                     = $this.TenantId
                CertificateThumbprint        = $this.CertificateThumbprint
                CertificatePassword          = $this.CertificatePassword
                CertificatePath              = $this.CertificatePath
                AccessTokens                 = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of SC Adaptive Scope {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            $null = $this.Connect('SecurityComplianceCenter')

            $currentInstance = $this.Get().ToHashtable()

            $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            if ($this.Ensure -eq 'Present')
            {
                if (-not [System.String]::IsNullOrEmpty($this.FilterConditions) -and -not [System.String]::IsNullOrEmpty($this.RawQuery))
                {
                    throw "SC Adaptive Scope {$($this.Name)} cannot specify both FilterConditions and RawQuery."
                }

                if (-not [System.String]::IsNullOrEmpty($this.AdministrativeUnit) -and
                    -not [System.Guid]::TryParse($this.AdministrativeUnit, [ref][System.Guid]::Empty))
                {
                    $null = $this.Connect('MicrosoftGraph')
                    $units = @(Get-MgDirectoryAdministrativeUnit -Filter "displayName eq '$($this.AdministrativeUnit -replace "'", "''")'" -ErrorAction Stop)
                    if ($units.Count -ne 1)
                    {
                        throw "Found $($units.Count) administrative units with display name {$($this.AdministrativeUnit)} for SC Adaptive Scope {$($this.Name)}. Specify the id of the administrative unit instead."
                    }

                    $boundParameters.AdministrativeUnit = $units[0].Id
                }
            }

            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new SC Adaptive Scope {$($this.Name)}"

                New-AdaptiveScope @boundParameters -ErrorAction Stop | Out-Null
            }
            elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating SC Adaptive Scope {$($this.Name)}"

                if ($this.LocationType -ne $currentInstance.LocationType)
                {
                    throw "The LocationType of SC Adaptive Scope {$($this.Name)} cannot be changed from {$($currentInstance.LocationType)} to {$($this.LocationType)}. Remove the adaptive scope and create it again instead."
                }

                if ($boundParameters.ContainsKey('UseKql') -and $this.UseKql -ne $currentInstance.UseKql)
                {
                    throw "The UseKql value of SC Adaptive Scope {$($this.Name)} cannot be changed. Remove the adaptive scope and create it again instead."
                }

                $updateParameters = $boundParameters
                $updateParameters.Remove('Name') | Out-Null
                $updateParameters.Remove('LocationType') | Out-Null
                $updateParameters.Remove('UseKql') | Out-Null
                $updateParameters.Identity = $this.Name

                Set-AdaptiveScope @updateParameters -ErrorAction Stop | Out-Null
            }
            elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing SC Adaptive Scope {$($this.Name)}"

                Remove-AdaptiveScope -Identity $this.Name -Confirm:$false -ErrorAction Stop | Out-Null
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $exportedInstances = @(Get-AdaptiveScope -ErrorAction Stop | Where-Object -FilterScript {
                    -not $_.IsImplicitAdaptiveScope -and $_.Mode -ne 'PendingDeletion'
                })

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

            foreach ($exportedInstance in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($exportedInstance.Name)" -DeferWrite

                $Params = @{
                    Name                  = $exportedInstance.Name
                    LocationType          = [System.String] $exportedInstance.LocationType
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $exportedInstance
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
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX

            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    # Returns the JSON with the properties of every object sorted by name, or the input when it is not valid JSON.
    hidden static [System.String] ConvertToCanonicalJson([System.String] $Json)
    {
        try
        {
            $node = ConvertFrom-Json -InputObject $Json -ErrorAction Stop
        }
        catch
        {
            return $Json
        }

        return ConvertTo-Json -InputObject ([SCAdaptiveScope]::SortJsonNode($node)) -Depth 20 -Compress
    }

    hidden static [System.Object] SortJsonNode([System.Object] $Node)
    {
        if ($null -eq $Node)
        {
            return $null
        }

        if ($Node.GetType() -eq [System.Management.Automation.PSCustomObject])
        {
            $sorted = [ordered]@{}
            foreach ($property in ($Node.PSObject.Properties | Sort-Object -Property Name))
            {
                $sorted[$property.Name] = [SCAdaptiveScope]::SortJsonNode($property.Value)
            }

            return $sorted
        }

        if ($Node -is [System.Array])
        {
            return [System.Object[]] @($Node | ForEach-Object -Process { [SCAdaptiveScope]::SortJsonNode($_) })
        }

        return $Node
    }

    hidden [SCAdaptiveScope] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCAdaptiveScope])
        {
            return $Values
        }

        $result = [SCAdaptiveScope]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
