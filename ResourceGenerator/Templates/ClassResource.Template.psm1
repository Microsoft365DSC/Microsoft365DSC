using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class <ResourceName> : M365DSCResourceBase
{
<PropertyBlock>
<#IF ExportOnlyPropertyBlock#>

<ExportOnlyPropertyBlock>
<#ENDIF ExportOnlyPropertyBlock#>

    [<ResourceName>] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [<ResourceName>]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of <ResourceDescription> {$($this.<PrimaryKey>)}"

        try
        {
            $null = $this.Connect('<Workload>')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
<#IF HasEnsure#>
            $nullResult.Ensure = 'Absent'
<#ENDIF HasEnsure#>

            if (-not $this.ExportedInstance -or $this.ExportedInstance.<PrimaryKey> -ne $this.<PrimaryKey>)
            {
<GetInstanceBlock>
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "No <ResourceDescription> with <PrimaryKey> {$($this.<PrimaryKey>)} was found"
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found <ResourceDescription> with <PrimaryKey> {$($this.<PrimaryKey>)}"

<#IF ComplexConversionBlock#>
<ComplexConversionBlock>

<#ENDIF ComplexConversionBlock#>
            $result = @{
<HashtableMappingBlock>
            }
<AssignmentsGetBlock>

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

        Write-Verbose -Message "Setting configuration of <ResourceDescription> {$($this.<PrimaryKey>)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            $null = $this.Connect('<Workload>')

            $currentInstance = $this.Get().ToHashtable()

<SetPreambleBlock>

<#IF HasEnsure#>
            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new <ResourceDescription> {$($this.<PrimaryKey>)}"

<NewInvocationBlock>
            }
            elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating <ResourceDescription> {$($this.<PrimaryKey>)}"

<UpdateInvocationBlock>
            }
            elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing <ResourceDescription> {$($this.<PrimaryKey>)}"

<RemoveInvocationBlock>
            }
<#ELSE#>
            Write-Verbose -Message "Updating <ResourceDescription> {$($this.<PrimaryKey>)}"

<UpdateInvocationBlock>
<#ENDIF HasEnsure#>
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
<#IF CompareParametersBlock#>

<CompareParametersBlock>
<#ENDIF CompareParametersBlock#>

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('<Workload>')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
<ExportGetAllBlock>

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

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($exportedInstance.<ExportedInstanceLabel>)" -DeferWrite

                $Params = @{
<ExportParameterBlock>
                }

                $this.ExportedInstance = $exportedInstance
                $Results = $this.GetForExport($Params)

<ExportComplexToStringBlock>
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential<NoEscapeArgument>
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

    hidden [<ResourceName>] AsResult([System.Object] $Values)
    {
        if ($Values -is [<ResourceName>])
        {
            return $Values
        }

        $result = [<ResourceName>]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
<#IF CimInstanceClassBlock#>

<CimInstanceClassBlock>
<#ENDIF CimInstanceClassBlock#>
