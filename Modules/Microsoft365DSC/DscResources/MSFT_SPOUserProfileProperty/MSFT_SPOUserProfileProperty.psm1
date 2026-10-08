using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOUserProfileProperty : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Username of the user to configure the profile properties for. E.g. John.Smith@contoso.com')]
    [System.String] $UserName

    [DscProperty()]
    [System.ComponentModel.Description('Array of MSFT_SPOUserProfilePropertyInstance representing the profile properties to set.')]
    [MSFT_SPOUserProfilePropertyInstance[]] $Properties

    [DscProperty()]
    [System.ComponentModel.Description('This resource cannot be removed and the value must be set to ''Ensure''.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

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

    [SPOUserProfileProperty] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOUserProfileProperty]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting SPO Profile Properties for user {$($this.UserName)}"

        try
        {
            if (-not $this.ResourceCache['ExportMode'])
            {
                $null = $this.Connect('PNP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')
            }

            $nullReturn = @{
                UserName = $this.UserName
                Ensure   = 'Absent'
            }

            $currentProperties = Get-PnPUserProfileProperty -Account $this.UserName -ErrorAction SilentlyContinue

            if ($null -eq $currentProperties.AccountName)
            {
                return $this.AsResult($nullReturn)
            }

            # Remove generic properties
            $currentProperties.Remove('AccountName') | Out-Null
            $currentProperties.Remove('DirectReports') | Out-Null
            $currentProperties.Remove('DisplayName') | Out-Null
            $currentProperties.Remove('Email') | Out-Null
            $currentProperties.Remove('DirectReports') | Out-Null
            $currentProperties.Remove('ExtendedManagers') | Out-Null
            $currentProperties.Remove('ExtendedReports') | Out-Null
            $currentProperties.Remove('IsFollowed') | Out-Null
            $currentProperties.Remove('LatestPost') | Out-Null
            $currentProperties.Remove('Peers') | Out-Null
            $currentProperties.Remove('PersonalSiteHostUrl') | Out-Null
            $currentProperties.Remove('PersonalUrl') | Out-Null
            $currentProperties.Remove('PictureUrl') | Out-Null
            $currentProperties.Remove('UserUrl') | Out-Null

            $propertiesValue = @()
            foreach ($key in $currentProperties.Keys)
            {
                $convertedProperty = [ordered]@{
                    Key   = $Key
                    Value = $currentProperties[$Key]
                }
                $propertiesValue += $convertedProperty
            }

            $result = @{
                UserName              = $this.UserName
                Properties            = $propertiesValue
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                Ensure                = 'Present'
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

        Write-Verbose -Message "Setting Profile Properties for user {$($this.UserName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentProperties = $this.Get().ToHashtable()

        foreach ($property in $this.Properties)
        {
            if ($currentProperties.Properties[$property.Key] -ne $property.Value)
            {
                Write-Verbose "Setting Profile Property {$($property.Key)} as {$($property.Value)}"
                try
                {
                    Set-PnPUserProfileProperty -Account $this.UserName -PropertyName $property.Key -Value $property.Value -ErrorAction Stop
                }
                catch
                {
                    Write-Warning "Cannot update property {$($property.Key)}. This value of that key cannot be modified."
                }
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

        try
        {
            $ConnectionMode = $this.Connect('PNP')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Export')
            #endregion

            # Get all instances;
            $instances = Get-PnPUser | Where-Object -FilterScript { $_.PrincipalType -eq 'User' -and '' -ne $_.Email }
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            $i = 1
            $this.ResourceCache['ExportMode'] = $true
            foreach ($instance in $Instances)
            {
                Write-M365DSCHost -Message "    |---[$i/$($Instances.Count)] $($instance.Email)" -DeferWrite
                $Params = @{
                    UserName              = $instance.Email
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    Credential            = $this.Credential
                    AccessTokens          = $this.AccessTokens
                }

                $Results = $this.GetForExport($Params)
                if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
                {
                    if ($Results.Properties)
                    {
                        if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                        {
                            $Global:M365DSCExportResourceInstancesCount++
                        }

                        if ($null -ne $Results.Properties)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'Properties'
                                    CimInstanceName = 'MSFT_SPOUserProfilePropertyInstance'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.Properties `
                                -CIMInstanceName 'MSFT_SPOUserProfilePropertyInstance' `
                                -ComplexTypeMapping $complexMapping

                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.Properties = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('Properties') | Out-Null
                            }
                        }

                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential `
                            -NoEscape @('Properties')
                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName
                    }

                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                }

                $i++
            }

            $organization = ''
            $principal = '' # Principal represents the "NetBios" name of the tenant (e.g. the M365DSC part of M365DSC.onmicrosoft.com)
            $organization = Get-M365DSCOrganization -Credential $this.Credential -TenantId $this.Tenantid
            if ($organization.IndexOf('.') -gt 0)
            {
                $principal = $organization.Split('.')[0]
            }
            $dscContent = $dscContent.ToString()
            if ($dscContent.ToLower().Contains($organization.ToLower()) -or `
                    $dscContent.ToLower().Contains($principal.ToLower()))
            {
                $dscContent = $dscContent -ireplace [regex]::Escape('https://' + $principal + '.sharepoint.com/'), "https://`$(`$OrganizationName.Split('.')[0]).sharepoint.com/"
                $dscContent = $dscContent -ireplace [regex]::Escape('@' + $organization), "@`$(`$OrganizationName)"
            }

            return $dscContent
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [SPOUserProfileProperty] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOUserProfileProperty])
        {
            return $Values
        }

        $result = [SPOUserProfileProperty]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_SPOUserProfilePropertyInstance
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the User Profile Property.')]
    [System.String] $Key

    [DscProperty()]
    [System.ComponentModel.Description('Value of the User Profile Property.')]
    [System.String] $Value
}
