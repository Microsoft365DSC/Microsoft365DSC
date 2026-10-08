using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOTheme : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the theme, which appears in the theme picker UI and is also used by administrators and developers to refer to the theme in PowerShell cmdlets or calls to the SharePoint REST API.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('This value should be false for light themes and true for dark themes; it controls whether SharePoint uses dark or light theme colors to render text on colored backgrounds.')]
    [System.Nullable[System.Boolean]] $IsInverted

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the color scheme which composes your theme.')]
    [MSFT_SPOThemePaletteProperty[]] $Palette

    [DscProperty()]
    [System.ComponentModel.Description('Only accepted value is ''Present''.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the account to authenticate with.')]
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

    [SPOTheme] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOTheme]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for SPO Theme $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('PNP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Getting theme $($this.Name)"
                $theme = Get-PnPTenantTheme -ErrorAction SilentlyContinue | Where-Object -FilterScript { $_.Name -eq $this.Name }
            }
            else
            {
                $theme = $this.ExportedInstance
            }

            if ($null -eq $theme)
            {
                Write-Verbose -Message "The specified theme doesn't exist."
                return $this.AsResult($nullReturn)
            }
            $convertedPalette = $this.ConvertExistingThemePaletteToArray([System.Collections.Hashtable]$theme.Palette)

            return $this.AsResult(@{
                Name                  = $theme.Name
                IsInverted            = $theme.IsInverted
                Palette               = $convertedPalette
                Credential            = $this.Credential
                Ensure                = 'Present'
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
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
        $existingTheme = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration for SPO Theme $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentPalette = $this.Get().ToHashtable()
        if ($this.Ensure -eq 'Present')
        {
            Write-Verbose 'Converting Received Palette Values into Hashtable'
            $convertedPalettes = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.Palette
            $hashPalette = @{}
            foreach ($convertedPalette in $convertedPalettes)
            {
                $hashPalette.Add($convertedPalette.Property, $convertedPalette.Value)
            }
            $AddParameters = @{
                Identity   = $this.Name
                IsInverted = $this.IsInverted
                Palette    = $hashPalette
            }

            try
            {
                $existingTheme = Get-PnPTenantTheme -Name $this.Name -ErrorAction SilentlyContinue
            }
            catch
            {
                Write-Verbose -Message "Theme $($this.Name) does not yet exist."
            }

            if ($null -eq $existingTheme)
            {
                Write-Verbose -Message "Theme {$($this.Name)} doesn't already exist. Creating it."
                Add-PnPTenantTheme @AddParameters
            }
            else
            {
                Write-Verbose -Message "Theme {$($this.Name)} already exists. Updating it"
                Add-PnPTenantTheme @AddParameters -Overwrite
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentPalette.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing theme $($this.Name)"
            try
            {
                Remove-PnPTenantTheme -Identity $this.Name
            }
            catch
            {
                $Message = "The SPOTheme $($this.Name) does not exist and for that cannot be removed."
                $this.LogError($_, $Message)
                throw
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

            [array]$themes = Get-PnPTenantTheme -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

            if ($themes.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($theme in $themes)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($themes.Length)] $($theme.Name)" -DeferWrite
                $Params = @{
                    Name                  = $theme.Name
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

                $this.ExportedInstance = $theme
                $Results = $this.GetForExport($Params)
                if ($null -ne $Results.Palette)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Palette `
                        -CIMInstanceName 'MSFT_SPOThemePaletteProperty' `
                        -IsArray

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Palette = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Palette') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Palette')
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

    hidden [System.Object[]] ConvertExistingThemePaletteToArray([System.Collections.Hashtable] $Palette)
    {
        $themes = @()
        foreach ($entry in $Palette.GetEnumerator())
        {
            $themes += [ordered]@{
                Property = $entry.Key
                Value    = $entry.Value
            }
        }
        return $themes
    }

    hidden [SPOTheme] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOTheme])
        {
            return $Values
        }

        $result = [SPOTheme]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_SPOThemePaletteProperty
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the property.')]
    [System.String] $Property

    [DscProperty()]
    [System.ComponentModel.Description('Color value in Hexadecimal.')]
    [System.String] $Value
}
