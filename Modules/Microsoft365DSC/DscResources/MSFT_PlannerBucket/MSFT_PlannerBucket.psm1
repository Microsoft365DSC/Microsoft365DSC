using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class PlannerBucket : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name of the Planner Bucket.')]
    [System.String] $Name

    [DscProperty(Key)]
    [System.ComponentModel.Description('Id of the Plan to which the bucket is associated with.')]
    [System.String] $PlanId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Bucket, if known.')]
    [System.String] $Id

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

    [PlannerBucket] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [PlannerBucket]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Planner Bucket {$($this.Name)}"

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

            if (-not [System.String]::IsNullOrEmpty($this.Id))
            {
                [Array]$bucket = Get-MgPlannerPlanBucket -PlannerPlanId $this.PlanId | Where-Object -FilterScript { $_.Id -eq $this.Id }
            }
            else
            {
                [Array]$bucket = Get-MgPlannerPlanBucket -PlannerPlanId $this.PlanId | Where-Object -FilterScript { $_.Name -eq $this.Name }

                if ($bucket.Length -gt 1)
                {
                    throw ("Multiple Buckets with Name {$($this.Name)} were found for Plan with ID {$($this.PlanID)}." + `
                            ' Please use the Id property to identify the exact bucket.')
                }
            }

            if ($null -eq $bucket)
            {
                return $this.AsResult($nullReturn)
            }

            $results = @{
                Name                  = $this.Name
                PlanId                = $this.PlanId
                Id                    = $bucket[0].Id
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
        $Bucket = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of Planner Bucket {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentValues = $this.Get().ToHashtable()
        $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Planner Bucket {$($this.Name)} doesn't already exist. Creating it."
            New-MgPlannerBucket -Name $this.Name -PlanId $this.PlanId | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message ("Planner Bucket {$Bucket} already exists, but is not in the " + `
                    'Desired State. Updating it.')
            $SetParams.Remove('PlanId') | Out-Null
            Update-MgPlannerPlan -PlannerPlanId $currentValues.PlanId -BodyParameter $SetParams
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "This resource doesn't allow for removal of Planner Bucket."
            # TODO - Implement when available in the MSGraph PowerShell SDK
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
                    [Array]$plans = Get-MgGroupPlannerPlan -GroupId $group.Id -ErrorAction 'SilentlyContinue'

                    $j = 1
                    foreach ($plan in $plans)
                    {
                        Write-M365DSCHost -Message "        |---[$j/$($plans.Length)] $($plan.Title)"
                        $buckets = Get-MgPlannerPlanBucket -PlannerPlanId $plan.Id
                        $k = 1
                        foreach ($bucket in $buckets)
                        {
                            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                            {
                                $Global:M365DSCExportResourceInstancesCount++
                            }

                            Write-M365DSCHost -Message "            |---[$k/$($buckets.Length)] $($bucket.Name)" -DeferWrite
                            $params = @{
                                Name                  = $bucket.Name
                                PlanId                = $plan.Id
                                Id                    = $bucket.Id
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
                            $results = $this.GetForExport($params)
                            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                                -ConnectionMode $ConnectionMode `
                                -ModulePath $this.GetModulePath() `
                                -Results $Results `
                                -Credential $this.Credential
                            [void]$dscContent.Append($currentDSCBlock)

                            Save-M365DSCPartialExport -Content $currentDSCBlock `
                                -FileName $Global:PartialExportFileName
                            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                            $k++
                        }
                        $j++
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

    hidden [PlannerBucket] AsResult([System.Object] $Values)
    {
        if ($Values -is [PlannerBucket])
        {
            return $Values
        }

        $result = [PlannerBucket]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
