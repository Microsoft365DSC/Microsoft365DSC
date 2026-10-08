using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsTenantDialPlan : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter is a unique identifier that designates the name of the tenant dial plan. Identity is an alphanumeric string that cannot exceed 49 characters. Valid characters are alphabetic or numeric characters, hyphen (-) and dot (.). The value should not begin with a (.).')]
    [ValidateLength(1, 49)]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The Description parameter describes the tenant dial plan - what it''s for, what type of user it applies to and any other information that helps to identify the purpose of the tenant dial plan. Maximum characters: 512.')]
    [ValidateLength(1, 512)]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of normalization rules that are applied to this dial plan.')]
    [MSFT_TeamsVoiceNormalizationRule[]] $NormalizationRules

    [DscProperty()]
    [System.ComponentModel.Description('The SimpleName parameter is a display name for the tenant dial plan. This name must be unique among all tenant dial plans within the Skype for Business Server deployment.This string can be up to 49 characters long. Valid characters are alphabetic or numeric characters, hyphen (-), dot (.) and parentheses (()).')]
    [ValidateLength(1, 49)]
    [System.String] $SimpleName

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this dial plan should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin')]
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

    [TeamsTenantDialPlan] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsTenantDialPlan]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of Teams Tenant Dial Plan'

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $config = Get-CsTenantDialPlan -Identity $this.Identity -ErrorAction 'SilentlyContinue'
            }
            else
            {
                $config = $this.ExportedInstance
            }

            if ($null -eq $config)
            {
                Write-Verbose -Message "Could not find existing Dial Plan {$($this.Identity)}"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found existing Dial Plan {$($this.Identity)}"
            $rules = @()
            if ($config.NormalizationRules.Count -gt 0)
            {
                $rules = $this.GetNormalizationRules($config.NormalizationRules)
            }

            $result = @{
                Identity              = $this.Identity.Replace('Tag:', '')
                Description           = $config.Description
                NormalizationRules    = $rules
                SimpleName            = $config.SimpleName
                Credential            = $this.Credential
                Ensure                = 'Present'
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
        $plan = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message 'Setting configuration of Teams Guest Calling'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            Write-Verbose "Tenant Dial Plan {$($this.Identity)} doesn't exist but it should. Creating it."
            $createParameters = $boundParameters
            #region VoiceNormalizationRules
            $AllRules = @()
            # Ensure the VoiceNormalizationRules all exist
            foreach ($rule in $this.NormalizationRules)
            {
                # Need to create the rule
                Write-Verbose "Creating VoiceNormalizationRule {$($rule.Identity)}"
                $ruleObject = New-CsVoiceNormalizationRule -Identity "Global/$($rule.Identity.Replace('Tag:', ''))" `
                    -Description $rule.Description `
                    -Pattern $rule.Pattern `
                    -Translation $rule.Translation `
                    -InMemory

                $AllRules += $ruleObject
            }

            $createParameters.Remove('NormalizationRules') | Out-Null
            if ($AllRules.Count -gt 0)
            {
                $createParameters.NormalizationRules = @{ Add = $AllRules }
            }
            New-CsTenantDialPlan @createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Tenant Dial Plan {$($this.Identity)} already exists. Updating it."

            $updateParameters = $boundParameters
            $desiredRules = @()
            foreach ($rule in $this.NormalizationRules)
            {
                $desiredRule = @{
                    Identity            = $rule.Identity
                    Description         = $rule.Description
                    Pattern             = $rule.Pattern
                    IsExternalExtension = $rule.IsExternalExtension
                    Translation         = $rule.Translation
                }
                $desiredRules += $desiredRule
            }

            $updateParameters.Remove('NormalizationRules') | Out-Null
            Set-CsTenantDialPlan @updateParameters

            $differences = $this.GetVoiceNormalizationRulesDifference($CurrentValues.NormalizationRules, $desiredRules)
            foreach ($ruleToAdd in $differences.RulesToAdd)
            {
                Write-Verbose "Adding new VoiceNormalizationRule {$($ruleToAdd.Identity)}"
                $ruleObject = New-CsVoiceNormalizationRule -Identity "Global/$($ruleToAdd.Identity.Replace('Tag:', ''))" `
                    -Description $ruleToAdd.Description `
                    -Pattern $ruleToAdd.Pattern `
                    -Translation $ruleToAdd.Translation `
                    -InMemory
                Write-Verbose 'VoiceNormalizationRule created'
                Set-CsTenantDialPlan -Identity $this.Identity -NormalizationRules @{ Add = $ruleObject }
                Write-Verbose 'Updated the Tenant Dial Plan'
            }
            foreach ($ruleToRemove in $differences.RulesToRemove)
            {
                if ($null -eq $plan)
                {
                    $plan = Get-CsTenantDialPlan -Identity $this.Identity
                }
                $ruleObject = $plan.NormalizationRules | Where-Object -FilterScript { $_.Name -eq $ruleToRemove.Identity }

                if ($null -ne $ruleObject)
                {
                    Write-Verbose "Removing VoiceNormalizationRule {$($ruleToRemove.Identity)}"
                    Write-Verbose 'VoiceNormalizationRule created'
                    Set-CsTenantDialPlan -Identity $this.Identity -NormalizationRules @{ Remove = $ruleObject }
                    Write-Verbose 'Updated the Tenant Dial Plan'
                }
            }
            foreach ($ruleToUpdate in $differences.RulesToUpdate)
            {
                if ($null -eq $plan)
                {
                    $plan = Get-CsTenantDialPlan -Identity $this.Identity
                }
                $ruleObject = $plan.NormalizationRules | Where-Object -FilterScript { $_.Name -eq $ruleToUpdate.Identity }

                if ($null -ne $ruleObject)
                {
                    Write-Verbose "Updating VoiceNormalizationRule {$($ruleToUpdate.Identity)}"
                    Set-CsTenantDialPlan -Identity $this.Identity -NormalizationRules @{ Remove = $ruleObject }
                    $ruleObject = New-CsVoiceNormalizationRule -Identity "Global/$($ruleToUpdate.Identity.Replace('Tag:', ''))" `
                        -Description $ruleToUpdate.Description `
                        -Pattern $ruleToUpdate.Pattern `
                        -Translation $ruleToUpdate.Translation `
                        -InMemory
                    Write-Verbose 'VoiceNormalizationRule Updated'
                    Set-CsTenantDialPlan -Identity $this.Identity -NormalizationRules @{ Add = $ruleObject }
                    Write-Verbose 'Updated the Tenant Dial Plan'
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Tenant Dial Plan {$($this.Identity)} exists and shouldn't. Removing it."
            Remove-CsTenantDialPlan -Identity $this.Identity
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
            [array]$tenantDialPlans = Get-CsTenantDialPlan -Filter $this.Filter -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($plan in $tenantDialPlans)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($tenantDialPlans.Count)] $($plan.Identity)" -DeferWrite
                $params = @{
                    Identity              = $plan.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $plan
                $Results = $this.GetForExport($Params)

                if ($null -ne $Results.NormalizationRules)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'NormalizationRules'
                            CimInstanceName = 'TeamsVoiceNormalizationRule'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.NormalizationRules `
                        -CIMInstanceName 'TeamsVoiceNormalizationRule' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.NormalizationRules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('NormalizationRules') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('NormalizationRules')

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

    hidden [System.Collections.Hashtable] GetVoiceNormalizationRulesDifference([System.Object[]] $CurrentRules, [System.Object[]] $DesiredRules)
    {
        $differences = @{}
        $rulesToRemove = @()
        $rulesToAdd = @()
        $rulesToUpdate = @()
        foreach ($currentRule in $CurrentRules)
        {
            $equivalentDesiredRule = $DesiredRules | Where-Object -FilterScript { $_.Identity -eq $currentRule.Identity }

            # Case the current rule is not listed in the Desired rules, we need to remove it
            if ($null -eq $equivalentDesiredRule)
            {
                Write-Verbose "Adding Rule {$($currentRule.Identity)} to the RulesToRemove"
                $rulesToRemove += $currentRule
            }
            # Case the rule exists but is not in the desired state
            else
            {
                $differenceFound = $false
                foreach ($key in $currentRule.Keys)
                {
                    if (-not [System.String]::IsNullOrEmpty($equivalentDesiredRule.$key) -and $currentRule.$key -ne $equivalentDesiredRule.$key)
                    {
                        $differenceFound = $true
                    }
                }

                if ($differenceFound)
                {
                    Write-Verbose "Adding Rule {$($currentRule.Identity)} to the RulesToUpdate"
                    $rulesToUpdate += $equivalentDesiredRule
                }
            }
        }

        foreach ($desiredRule in $DesiredRules)
        {
            $equivalentCurrentRule = $CurrentRules | Where-Object -FilterScript { $_.Identity -eq $desiredRule.Identity }

            # Case the desired rule doesn't exist, we need to create it
            if ($null -eq $equivalentCurrentRule)
            {
                Write-Verbose "Adding Rule {$($desiredRule.Identity)} to the RulesToAdd"
                $rulesToAdd += $desiredRule
            }
        }
        $differences.Add('RulesToAdd', $rulesToAdd)
        $differences.Add('RulesToUpdate', $rulesToUpdate)
        $differences.Add('RulesToRemove', $rulesToRemove)
        return $differences
    }

    hidden [System.Object[]] GetNormalizationRules([System.Object] $Rules)
    {
        if ($null -eq $Rules)
        {
            return $null
        }

        $result = @()
        foreach ($rule in $Rules)
        {
            $ruleName = $rule.Name.Replace('Tag:', '')
            $currentRule = @{
                Identity            = $ruleName
                Priority            = $rule.Priority
                Description         = $rule.Description
                Pattern             = $rule.Pattern
                Translation         = $rule.Translation
                IsInternalExtension = $rule.IsInternalExtension
            }
            if ([System.String]::IsNullOrEmpty($rule.Priority))
            {
                $currentRule.Remove('Priority') | Out-Null
            }
            $result += $currentRule
        }

        return $result
    }

    hidden [TeamsTenantDialPlan] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsTenantDialPlan])
        {
            return $Values
        }

        $result = [TeamsTenantDialPlan]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_TeamsVoiceNormalizationRule
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('A unique identifier for the rule. The Identity specified must include the scope followed by a slash and then the name; for example: site:Redmond/Rule1, where site:Redmond is the scope and Rule1 is the name. The name portion will automatically be stored in the Name property. You cannot specify values for Identity and Name in the same command.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The order in which rules are applied. A phone number might match more than one rule. This parameter sets the order in which the rules are tested against the number.')]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('A friendly description of the normalization rule.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('A regular expression that the dialed number must match in order for this rule to be applied.')]
    [System.String] $Pattern

    [DscProperty()]
    [System.ComponentModel.Description('The regular expression pattern that will be applied to the number to convert it to E.164 format.')]
    [System.String] $Translation

    [DscProperty()]
    [System.ComponentModel.Description('If True, the result of applying this rule will be a number internal to the organization. If False, applying the rule results in an external number. This value is ignored if the value of the OptimizeDeviceDialing property of the associated dial plan is set to False.')]
    [System.Nullable[System.Boolean]] $IsInternalExtension
}
