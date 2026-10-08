using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceAndAppManagementAssignmentFilter : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('DisplayName of the Assignment Filter.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Key of the Assignment Filter.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Assignment Filter.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Indicates filter is applied to either ''devices'' or ''apps'' management type. Default is ''devices''.')]
    [ValidateSet('apps', 'devices')]
    [System.String] $AssignmentFilterManagementType

    [DscProperty()]
    [System.ComponentModel.Description('Platform type of the devices on which the Assignment Filter will be applicable.')]
    [ValidateSet('android', 'androidForWork', 'iOS', 'macOS', 'windowsPhone81', 'windows81AndLater', 'windows10AndLater', 'androidWorkProfile', 'unknown', 'androidAOSP', 'androidMobileApplicationManagement', 'iOSMobileApplicationManagement', 'unknownFutureValue', 'windowsMobileApplicationManagement')]
    [System.String] $Platform

    [DscProperty()]
    [System.ComponentModel.Description('Indicates role scope tags assigned for the assignment filter.')]
    [System.String[]] $RoleScopeTags

    [DscProperty()]
    [System.ComponentModel.Description('Rule definition of the Assignment Filter.')]
    [System.String] $Rule

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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

    [IntuneDeviceAndAppManagementAssignmentFilter] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceAndAppManagementAssignmentFilter]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device and App Management Assignment Filter with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = @{
                    DisplayName = $this.DisplayName
                    Ensure      = 'Absent'
                }

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message "Checking if filter exists with identity {$($this.Id)}."
                    $assignmentFilter = Get-MgBetaDeviceManagementAssignmentFilter -DeviceAndAppManagementAssignmentFilterId $this.Id -ErrorAction 'SilentlyContinue'
                }

                if ($null -eq $assignmentFilter)
                {
                    Write-Verbose -Message "No assignment filter with Id {$($this.Id)} was found."

                    Write-Verbose -Message "Checking if filter exists with DisplayName {$($this.DisplayName)}."
                    [array]$assignmentFilter = Get-MgBetaDeviceManagementAssignmentFilter -All | Where-Object -FilterScript { $_.DisplayName -eq $this.DisplayName }
                    if ($assignmentFilter.Count -gt 1)
                    {
                        throw "More than one Assignment Filter with name {$($this.DisplayName)} was found. Please provide the Id parameter."
                    }
                    elseif ($assignmentFilter.Count -eq 0)
                    {
                        Write-Verbose -Message "No assignment filter with name {$($this.DisplayName)} was found."
                        return $this.AsResult($nullResult)
                    }
                }
            }
            else
            {
                $assignmentFilter = $this.ExportedInstance
            }

            Write-Verbose -Message "Found assignment filter {$($assignmentFilter.displayName)}"

            $returnHashtable = @{}
            $returnHashtable.Add('Id', $assignmentFilter.Id)
            $returnHashtable.Add('DisplayName', $assignmentFilter.DisplayName)
            $returnHashtable.Add('Description', $assignmentFilter.Description)
            $returnHashtable.Add('AssignmentFilterManagementType', $assignmentFilter.AssignmentFilterManagementType)
            $returnHashtable.Add('Platform', $assignmentFilter.Platform)
            $returnHashtable.Add('RoleScopeTags', $assignmentFilter.RoleScopeTags)
            $returnHashtable.Add('Rule', $assignmentFilter.Rule)
            $returnHashtable.Add('Ensure', 'Present')
            $returnHashtable.Add('Credential', $this.Credential)
            $returnHashtable.Add('ApplicationId', $this.ApplicationId)
            $returnHashtable.Add('TenantId', $this.TenantId)
            $returnHashtable.Add('ApplicationSecret', $this.ApplicationSecret)
            $returnHashtable.Add('CertificateThumbprint', $this.CertificateThumbprint)
            $returnHashtable.Add('ManagedIdentity', $this.ManagedIdentity)
            $returnHashtable.Add('AccessTokens', $this.AccessTokens)

            return $this.AsResult($returnHashtable)
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

        Write-Verbose -Message "Setting the Intune Device and App Management Assignment Filter {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentPolicy = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new assignment filter {$($this.DisplayName)}"

            New-MgBetaDeviceManagementAssignmentFilter `
                -DisplayName $this.DisplayName `
                -Description $this.Description `
                -Platform $this.Platform `
                -RoleScopeTags $this.RoleScopeTags `
                -Rule $this.Rule `
                -AssignmentFilterManagementType $this.AssignmentFilterManagementType | Out-Null

        }
        elseif ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing assignment filter {$($this.DisplayName)}"

            if ($currentPolicy.AssignmentFilterManagementType -ne $this.AssignmentFilterManagementType)
            {
                throw 'Cannot change the AssignmentFilterManagementType of an existing IntuneDeviceAndAppManagementAssignmentFilter. Remove and recreate the filter if you want to change the filter type.'
            }

            Update-MgBetaDeviceManagementAssignmentFilter `
                -DeviceAndAppManagementAssignmentFilterId $currentPolicy.Id `
                -DisplayName $this.DisplayName `
                -Description $this.Description `
                -RoleScopeTags $this.RoleScopeTags `
                -Rule $this.Rule `
                -AssignmentFilterManagementType $this.AssignmentFilterManagementType | Out-Null

        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing assignment filter {$($this.DisplayName)}"
            Remove-MgBetaDeviceManagementAssignmentFilter -DeviceAndAppManagementAssignmentFilterId $currentPolicy.Id | Out-Null
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $policies = $null
        $complexFunctions = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $dscContent = [System.Text.StringBuilder]::new()
        $i = 1

        try
        {
            $mergedFilter = $this.Filter
            if (-not [string]::IsNullOrEmpty($this.Filter))
            {
                Write-Warning -Message 'Microsoft Graph filter is only supported for the platform on this resource. Other filters are only supported using startswith, endswith and contains and done by best-effort.'
                $complexFunctions = Get-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
                $mergedFilter = Remove-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
            }
            [array]$assignmentFilters = Get-MgBetaDeviceManagementAssignmentFilter -All -Filter $mergedFilter -ErrorAction Stop
            $assignmentFilters = Find-GraphDataUsingComplexFunctions -ComplexFunctions $complexFunctions -Policies $assignmentFilters

            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($assignmentFilter in $assignmentFilters)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($assignmentFilters.Count)] $($assignmentFilter.displayName)" -DeferWrite

                $params = @{
                    DisplayName           = $assignmentFilter.DisplayName
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

                $this.ExportedInstance = $assignmentFilter
                $Results = $this.GetForExport($Params)

                if ($Results.Ensure -eq 'Present')
                {
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
            }
            return $dscContent.ToString()
        }
        catch
        {
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                    $_.Exception -like '*Request not applicable to target tenant*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    hidden [IntuneDeviceAndAppManagementAssignmentFilter] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceAndAppManagementAssignmentFilter])
        {
            return $Values
        }

        $result = [IntuneDeviceAndAppManagementAssignmentFilter]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
