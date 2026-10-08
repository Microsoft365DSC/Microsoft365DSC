using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXORetentionPolicyTag : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the name of the tag.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The Description parameter specifies a comment for the tag.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The AgeLimitForRetention parameter specifies the age at which retention is enforced on an item. The age limit corresponds to the number of days from the date the item was delivered, or the date an item was created if it wasn''t delivered. If this parameter isn''t present and the RetentionEnabled parameter is set to $true, an error is returned.')]
    [System.Nullable[System.UInt32]] $AgeLimitForRetention

    [DscProperty()]
    [System.ComponentModel.Description('The MessageClass parameter specifies the message type to which the tag applies. If not specified, the default value is set to *.')]
    [System.String] $MessageClass

    [DscProperty()]
    [System.ComponentModel.Description('The MustDisplayCommentEnabled parameter specifies whether the comment can be hidden. The default value is $true.')]
    [System.Nullable[System.Boolean]] $MustDisplayCommentEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The RetentionAction parameter specifies the action for the retention policy.')]
    [System.String] $RetentionAction

    [DscProperty()]
    [System.ComponentModel.Description('The RetentionEnabled parameter specifies whether the tag is enabled. When set to $false, the tag is disabled, and no retention action is taken on messages that have the tag applied.')]
    [System.Nullable[System.Boolean]] $RetentionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The Type parameter specifies the type of retention tag being created.')]
    [System.String] $Type

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

    [EXORetentionPolicyTag] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXORetentionPolicyTag]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Retention Policy Tag with Identity {$($this.Identity)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-RetentionPolicyTag -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Retention Policy Tag {$($this.Identity)} not found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "Found existing instance of retention policy tag {$($this.Identity)}"

            $results = @{
                Identity                  = $instance.Identity
                Comment                   = $instance.Comment
                MessageClass              = $instance.MessageClass
                MustDisplayCommentEnabled = $instance.MustDisplayCommentEnabled
                RetentionAction           = $instance.RetentionAction
                RetentionEnabled          = $instance.RetentionEnabled
                Type                      = $instance.Type
                Ensure                    = 'Present'
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                TenantId                  = $this.TenantId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                AccessTokens              = $this.AccessTokens
            }
            if (-not [System.String]::IsNullOrEmpty($instance.AgeLimitForRetention))
            {
                $results.Add('AgeLimitForRetention', [UInt32]::Parse($instance.AgeLimitForRetention.Split('.')[0]))
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

        Write-Verbose -Message "Setting configuration for Retention Policy Tag with Identity {$($this.Identity)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new retention policy tag {$($this.Identity)}"
            $setParameters.Add('Name', $this.Identity)
            $setParameters.Remove('Identity') | Out-Null
            New-RetentionPolicyTag @SetParameters
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating retention policy tag {$($this.Identity)}"
            $setParameters.Remove('Type') | Out-Null
            Set-RetentionPolicyTag @SetParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing retention policy tag {$($this.Identity)}"
            Remove-RetentionPolicyTag -Identity $this.Identity
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $retentionPolicyTags = Get-RetentionPolicyTag -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($retentionPolicyTags.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $retentionPolicyTags)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Identity
                Write-M365DSCHost -Message "    |---[$i/$($retentionPolicyTags.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.Identity
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

    hidden [EXORetentionPolicyTag] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXORetentionPolicyTag])
        {
            return $Values
        }

        $result = [EXORetentionPolicyTag]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
