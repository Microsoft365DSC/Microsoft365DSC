using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class PlannerPlan : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Title of the Planner Plan.')]
    [System.String] $Title

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of Id of the Azure Active Directory Group who owns the plan')]
    [System.String] $OwnerGroup

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Plan exists, absent ensures it is removed')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the account to authenticate with.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

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
    [System.String] $Filter

    [PlannerPlan] Get()
    {
        $OwnerGroupValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [PlannerPlan]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Planner Plan {$($this.Title)}"

        try
        {
            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $null = $this.Connect('MicrosoftGraph')

            $nullReturn = $this.GetBoundParameters()
            $nullReturn.Ensure = 'Absent'

            $UsedID = $false
            $AllGroups = Get-MgGroup -GroupId $this.OwnerGroup -ErrorAction 'SilentlyContinue'
            if ($null -eq $AllGroups)
            {
                Write-Verbose -Message "Could not get Azure AD Group {$($this.OwnerGroup)} by ID. `
                Trying by Name."
                [Array]$AllGroups = Get-MgGroup -Filter "displayName eq '$($this.OwnerGroup -replace "'", "''")'"
            }
            else
            {
                Write-Verbose -Message "Found group {$($this.OwnerGroup)} by ID"
                $UsedID = $true
            }

            if ($null -eq $AllGroups)
            {
                Write-Verbose -Message "No Azure AD Group found for {$($this.OwnerGroup)}"
            }
            elseif ($AllGroups.Length -gt 1)
            {
                Write-Verbose -Message "Multiple Groups with name {$($this.OwnerGroup)} found."
            }

            $plan = $null
            foreach ($group in $AllGroups)
            {
                try
                {
                    Write-Verbose -Message "Scanning Group {$($group.DisplayName)} for plan {$($this.Title)}"
                    $plan = Get-MgGroupPlannerPlan -GroupId $group.Id | Where-Object -FilterScript { $_.Title -eq $this.Title }
                    if ($null -ne $plan)
                    {
                        Write-Verbose -Message 'Found Plan.'
                        if ($UsedID)
                        {
                            $OwnerGroupValue = $group.Id
                        }
                        else
                        {
                            $OwnerGroupValue = $group.DisplayName
                        }
                        break
                    }
                }
                catch
                {
                    $this.LogError($_, 'Error retrieving data:')
                }
            }

            if ($null -eq $plan)
            {
                Write-Verbose -Message 'Plan not found, returning Ensure = Absent'
                return $this.AsResult($nullReturn)
            }
            else
            {
                Write-Verbose -Message 'Plan found, returning Ensure = Present'
                $results = @{
                    Title                 = $this.Title
                    OwnerGroup            = $OwnerGroupValue
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
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

        Write-Verbose -Message "Setting configuration of Planner Plan {$($this.Title)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftGraph')

        $currentValues = $this.Get().ToHashtable()
        $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $ownerGroupId = $null
        if ($this.Ensure -eq 'Present')
        {
            [Array]$AllGroups = Get-MgGroup -GroupId $this.OwnerGroup -ErrorAction 'SilentlyContinue'
            if ($null -eq $AllGroups)
            {
                [Array]$AllGroups = Get-MgGroup -Filter "displayName eq '$($this.OwnerGroup -replace "'", "''")'"
            }

            if ($null -eq $AllGroups)
            {
                throw "Could not find the Azure AD Group {$($this.OwnerGroup)} that owns the Planner Plan {$($this.Title)}."
            }

            $ownerGroupId = $AllGroups[0].Id
        }

        if ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Planner Plan {$($this.Title)} doesn't already exist. Creating it."
            New-MgPlannerPlan -Owner $ownerGroupId -Title $this.Title | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Planner Plan {$($this.Title)} already exists, but is not in the `
            Desired State. Updating it."
            $plan = Get-MgGroupPlannerPlan -GroupId $ownerGroupId | Where-Object -FilterScript { $_.Title -eq $this.Title }
            $SetParams.Add('Owner', $ownerGroupId)
            $SetParams.Remove('OwnerGroup') | Out-Null
            Update-MgPlannerPlan -PlannerPlanId $plan.Id -BodyParameter $SetParams
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "This resource doesn't allow for removal of Planner plans."
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        try
        {
            [array]$groups = Get-MgGroup -All -ErrorAction Stop -Filter $this.filter

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($group in $groups)
            {
                Write-M365DSCHost -Message "    [$i/$($groups.Length)] $($group.DisplayName) - {$($group.Id)}"
                try
                {
                    [Array]$plans = Get-MgGroupPlannerPlan -GroupId $group.Id `
                        -All `
                        -ErrorAction 'SilentlyContinue'

                    $j = 1
                    foreach ($plan in $plans)
                    {
                        if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                        {
                            $Global:M365DSCExportResourceInstancesCount++
                        }

                        $params = @{
                            Title                 = $plan.Title
                            OwnerGroup            = $group.Id
                            Credential            = $this.Credential
                            ApplicationId         = $this.ApplicationId
                            TenantId              = $this.TenantId
                            ApplicationSecret     = $this.ApplicationSecret
                            CertificateThumbprint = $this.CertificateThumbprint
                            CertificatePath       = $this.CertificatePath
                            CertificatePassword   = $this.CertificatePassword
                            ManagedIdentity       = $this.ManagedIdentity
                            AccessTokens          = $this.AccessTokens
                        }

                        Write-M365DSCHost -Message "        [$j/$($plans.Length)] $($plan.Title)"
                        $results = $this.GetForExport($params)
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
                        $j++
                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    }
                    $i++
                }
                catch
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

                    $this.LogError($_, 'Error during Export:')
                }
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [PlannerPlan] AsResult([System.Object] $Values)
    {
        if ($Values -is [PlannerPlan])
        {
            return $Values
        }

        $result = [PlannerPlan]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
