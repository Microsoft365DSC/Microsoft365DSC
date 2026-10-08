using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOPartnerApplication : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies a new name for the partner application.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The ApplicationIdentifier parameter specifies a unique application identifier for the partner application that uses an authorization server.')]
    [System.String] $ApplicationIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('The AcceptSecurityIdentifierInformation parameter specifies whether Exchange should accept security identifiers (SIDs) from another trusted Active Directory forest for the partner application.')]
    [System.Nullable[System.Boolean]] $AcceptSecurityIdentifierInformation

    [DscProperty()]
    [System.ComponentModel.Description('The AccountType parameter specifies the type of Microsoft account that''s required for the partner application.')]
    [ValidateSet('OrganizationalAccount', 'ConsumerAccount')]
    [System.String] $AccountType

    [DscProperty()]
    [System.ComponentModel.Description('The Enabled parameter specifies whether the partner application is enabled.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The LinkedAccount parameter specifies a linked Active Directory user account for the application.')]
    [System.String] $LinkedAccount

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Partner Application should exist or not.')]
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

    [EXOPartnerApplication] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOPartnerApplication]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Partner Application configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $PartnerApplication = Get-PartnerApplication -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $PartnerApplication)
                {
                    Write-Verbose -Message "Partner Application $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $PartnerApplication = $this.ExportedInstance
            }

            Write-Verbose -Message "Partner Application with Name $($PartnerApplication.Name) found"

            $result = @{
                Name                                = $PartnerApplication.Name
                ApplicationIdentifier               = $PartnerApplication.ApplicationIdentifier
                AcceptSecurityIdentifierInformation = $PartnerApplication.AcceptSecurityIdentifierInformation
                AccountType                         = $PartnerApplication.AccountType
                Enabled                             = $PartnerApplication.Enabled
                LinkedAccount                       = $PartnerApplication.LinkedAccount
                Ensure                              = 'Present'
                Credential                          = $this.Credential
                ApplicationId                       = $this.ApplicationId
                CertificateThumbprint               = $this.CertificateThumbprint
                CertificatePath                     = $this.CertificatePath
                CertificatePassword                 = $this.CertificatePassword
                ManagedIdentity                     = $this.ManagedIdentity
                TenantId                            = $this.TenantId
                AccessTokens                        = $this.AccessTokens
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

        Write-Verbose -Message "Setting Partner Application configuration for $($this.Name)"

        $currentPartnerApplicationConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewPartnerApplicationParams = @{
            Name                                = $this.Name
            ApplicationIdentifier               = $this.ApplicationIdentifier
            AcceptSecurityIdentifierInformation = $this.AcceptSecurityIdentifierInformation
            Enabled                             = $this.Enabled
            Confirm                             = $false
        }

        $SetPartnerApplicationParams = @{
            Identity                            = $this.Name
            Name                                = $this.Name
            ApplicationIdentifier               = $this.ApplicationIdentifier
            AcceptSecurityIdentifierInformation = $this.AcceptSecurityIdentifierInformation
            Enabled                             = $this.Enabled
            Confirm                             = $false
        }

        if (-not [System.String]::IsNullOrEmpty($this.AccountType))
        {
            $NewPartnerApplicationParams.Add('AccountType', $this.AccountType)
            $SetPartnerApplicationParams.Add('AccountType', $this.AccountType)
        }

        if (-not [System.String]::IsNullOrEmpty($this.LinkedAccount))
        {
            $NewPartnerApplicationParams.Add('LinkedAccount', $this.LinkedAccount)
            $SetPartnerApplicationParams.Add('LinkedAccount', $this.LinkedAccount)
        }

        # CASE: Partner Application doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentPartnerApplicationConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Partner Application '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Partner Application
            New-PartnerApplication @NewPartnerApplicationParams

        }
        # CASE: Partner Application exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentPartnerApplicationConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Partner Application '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-PartnerApplication -Identity $this.Name -Confirm:$false
        }
        # CASE: Partner Application exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentPartnerApplicationConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Partner Application '$($this.Name)' already exists, but needs updating."
            if ($this.ApplicationIdentifier -eq $currentPartnerApplicationConfig.ApplicationIdentifier)
            {
                $SetPartnerApplicationParams.Remove('ApplicationIdentifier') | Out-Null
            }
            Write-Verbose -Message "Setting Partner Application $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $SetPartnerApplicationParams)"
            Set-PartnerApplication @SetPartnerApplicationParams
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
            [array]$AllPartnerApplications = Get-PartnerApplication -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            if ($AllPartnerApplications.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($PartnerApplication in $AllPartnerApplications)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllPartnerApplications.Length)] $($PartnerApplication.Name)" -DeferWrite

                $Params = @{
                    Name                  = $PartnerApplication.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $PartnerApplication
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

    hidden [EXOPartnerApplication] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOPartnerApplication])
        {
            return $Values
        }

        $result = [EXOPartnerApplication]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
