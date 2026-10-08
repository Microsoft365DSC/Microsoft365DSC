using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMessageClassification : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the OME Configuration policy that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The ClassificationID parameter specifies the classification ID (GUID) of an existing message classification that you want to import and use in your Exchange organization.')]
    [System.String] $ClassificationID

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayName parameter specifies the title of the message classification that''s displayed in Outlook and selected by users.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayPrecedence parameter specifies the relative precedence of the message classification to other message classifications that may be applied to a specified message.')]
    [ValidateSet('Highest', 'Higher', 'High', 'MediumHigh', 'Medium', 'MediumLow', 'Low', 'Lower', 'Lowest')]
    [System.String] $DisplayPrecedence

    [DscProperty()]
    [System.ComponentModel.Description('The Name parameter specifies the unique name for the message classification.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The PermissionMenuVisible parameter specifies whether the values that you entered for the DisplayName and RecipientDescription parameters are displayed in Outlook as the user composes a message. ')]
    [System.Nullable[System.Boolean]] $PermissionMenuVisible

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientDescription parameter specifies the detailed text that''s shown to Outlook recipient when they receive a message that has the message classification applied.')]
    [System.String] $RecipientDescription

    [DscProperty()]
    [System.ComponentModel.Description('The RetainClassificationEnabled parameter specifies whether the message classification should persist with the message if the message is forwarded or replied to.')]
    [System.Nullable[System.Boolean]] $RetainClassificationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SenderDescription parameter specifies the detailed text that''s shown to Outlook senders when they select a message classification to apply to a message before they send the message. ')]
    [System.String] $SenderDescription

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this Outbound connector should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
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

    [EXOMessageClassification] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMessageClassification]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Message Classification Configuration for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $MessageClassification = Get-MessageClassification -Identity $this.Identity -ErrorAction SilentlyContinue

                if ($null -eq $MessageClassification)
                {
                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        Write-Verbose -Message "Couldn't retrieve Message Classification policy by Id {$($this.Identity)}. Trying by DisplayName."
                        $MessageClassification = Get-MessageClassification -Identity $this.DisplayName -ErrorAction SilentlyContinue
                    }
                    if ($null -eq $MessageClassification)
                    {
                        return $this.AsResult($nullReturn)
                    }
                }
            }
            else
            {
                $MessageClassification = $this.ExportedInstance
            }

            $result = @{
                Identity                    = $this.Identity
                ClassificationID            = $MessageClassification.ClassificationID
                DisplayName                 = $MessageClassification.DisplayName
                DisplayPrecedence           = $MessageClassification.DisplayPrecedence
                Name                        = $MessageClassification.Name
                PermissionMenuVisible       = $MessageClassification.PermissionMenuVisible
                RecipientDescription        = $MessageClassification.RecipientDescription
                RetainClassificationEnabled = $MessageClassification.RetainClassificationEnabled
                SenderDescription           = $MessageClassification.SenderDescription
                Credential                  = $this.Credential
                Ensure                      = 'Present'
                ApplicationId               = $this.ApplicationId
                CertificateThumbprint       = $this.CertificateThumbprint
                CertificatePath             = $this.CertificatePath
                CertificatePassword         = $this.CertificatePassword
                ManagedIdentity             = $this.ManagedIdentity
                TenantId                    = $this.TenantId
                AccessTokens                = $this.AccessTokens
            }

            Write-Verbose -Message "Found Message Classification policy $($this.Identity)"
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

        $null = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        Write-Verbose -Message "Setting configuration of Message Classification for $($this.Identity)"

        $MessageClassification = Get-MessageClassification -Identity $this.Identity -ErrorAction SilentlyContinue
        $messageClassificationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $null -eq $MessageClassification)
        {
            $messageClassificationParams.Remove('Identity') | Out-Null
            Write-Verbose -Message "Creating Message Classification policy  $($this.Identity)."
            New-MessageClassification @messageClassificationParams
        }
        elseif ($this.Ensure -eq 'Present' -and $null -ne $MessageClassification)
        {
            Write-Verbose -Message "Setting Message Classification policy $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $messageClassificationParams)"
            Set-MessageClassification @messageClassificationParams -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Absent' -and $null -ne $MessageClassification)
        {
            Write-Verbose -Message "Removing Message Classification policy $($this.Identity)"
            Remove-MessageClassification -Identity $this.Identity -Confirm:$false
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        #Ensure the proper dependencies are installed in the current environment.
        Confirm-M365DSCDependencies

        #region Telemetry
        $this.AddTelemetry('Export')

        #endregion
        try
        {

            [Array]$MessageClassifications = Get-MessageClassification -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            if ($MessageClassifications.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($MessageClassification in $MessageClassifications)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($MessageClassifications.Length)] $($MessageClassification.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $MessageClassification.Identity
                    DisplayName           = $MessageClassification.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $MessageClassification
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

    hidden [EXOMessageClassification] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMessageClassification])
        {
            return $Values
        }

        $result = [EXOMessageClassification]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
