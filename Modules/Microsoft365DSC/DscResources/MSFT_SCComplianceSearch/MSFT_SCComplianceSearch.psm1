using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCComplianceSearch : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the complaiance tag.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Compliance Case (eDiscovery) that this Search is associated with')]
    [System.String] $Case

    [DscProperty()]
    [System.ComponentModel.Description('The AllowNotFoundExchangeLocationsEnabled parameter specifies whether to include mailboxes other than regular user mailboxes in the compliance search.')]
    [System.Nullable[System.Boolean]] $AllowNotFoundExchangeLocationsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ContentMatchQuery parameter specifies a content search filter. This parameter uses a text search string or a query that''s formatted by using the Keyword Query Language (KQL).')]
    [System.String] $ContentMatchQuery

    [DscProperty()]
    [System.ComponentModel.Description('The Description parameter specifies an optional description for the compliance search. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeLocation parameter specifies the mailboxes to include.')]
    [System.String[]] $ExchangeLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the mailboxes to exclude when you use the value All for the ExchangeLocation parameter.')]
    [System.String[]] $ExchangeLocationExclusion

    [DscProperty()]
    [System.ComponentModel.Description('The HoldNames parameter specifies that the content locations that have been placed on hold in the specified eDiscovery case will be searched. You use the value All for this parameter. You also need to specify the name of an eDiscovery case by using the Case parameter.')]
    [System.String[]] $HoldNames

    [DscProperty()]
    [System.ComponentModel.Description('The IncludeUserAppContent parameter specifies that you want to search the cloud-based storage location for users who don''t have a regular Office 365 user account in your organization. These types of users include users without an Exchange Online license who use Office applications, Office 365 guest users, and on-premises users whose identity is synchronized with your Office 365 organization.')]
    [System.Nullable[System.Boolean]] $IncludeUserAppContent

    [DscProperty()]
    [System.ComponentModel.Description('The Language parameter specifies the language for the compliance search. Valid input for this parameter is a supported culture code value from the Microsoft .NET Framework CultureInfo class. For example, da-DK for Danish or ja-JP for Japanese.')]
    [System.String] $Language

    [DscProperty()]
    [System.ComponentModel.Description('The PublicFolderLocation parameter specifies that you want to include all public folders in the search. You use the value All for this parameter.')]
    [System.String[]] $PublicFolderLocation

    [DscProperty()]
    [System.ComponentModel.Description('The SharePointLocation parameter specifies the SharePoint Online sites to include. You identify the site by its URL value, or you can use the value All to include all sites.')]
    [System.String[]] $SharePointLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the SharePoint Online sites to exclude when you use the value All for the SharePointLocation parameter. You identify the site by its URL value.')]
    [System.String[]] $SharePointLocationExclusion

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this search should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin Account')]
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

    [SCComplianceSearch] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCComplianceSearch]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SCComplianceSearch for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                if ($null -eq $this.Case)
                {
                    $Search = Invoke-M365DSCCommand -ScriptBlock { Get-ComplianceSearch -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError
                }
                else
                {
                    $Search = Invoke-M365DSCCommand -ScriptBlock { Get-ComplianceSearch -Identity $this.Name -Case $this.Case -ErrorAction Stop } -SuppressNotFoundError
                }

                if ($null -eq $Search)
                {
                    Write-Verbose -Message "SCComplianceSearch $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $Search = $this.ExportedInstance
            }

            Write-Verbose "Found existing SCComplianceSearch $($this.Name)"

            $result = @{
                Name                                  = $this.Name
                Case                                  = $this.Case
                AllowNotFoundExchangeLocationsEnabled = $Search.AllowNotFoundExchangeLocationsEnabled
                ContentMatchQuery                     = $Search.ContentMatchQuery
                Description                           = $Search.Description
                ExchangeLocation                      = $Search.ExchangeLocation
                ExchangeLocationExclusion             = $Search.ExchangeLocationExclusion
                HoldNames                             = $Search.HoldNames
                IncludeUserAppContent                 = $Search.IncludeUserAppContent
                Language                              = $Search.Language.Name
                PublicFolderLocation                  = $Search.PublicFolderLocation
                SharePointLocation                    = $Search.SharePointLocation
                SharePointLocationExclusion           = $Search.SharePointLocationExclusion
                Ensure                                = 'Present'
                Credential                            = $this.Credential
                ApplicationId                         = $this.ApplicationId
                TenantId                              = $this.TenantId
                CertificateThumbprint                 = $this.CertificateThumbprint
                CertificatePath                       = $this.CertificatePath
                CertificatePassword                   = $this.CertificatePassword
                ManagedIdentity                       = $this.ManagedIdentity
                AccessTokens                          = $this.AccessTokens
            }

            $nullParams = @()
            foreach ($parameter in $result.Keys)
            {
                if ($null -eq $result.$parameter)
                {
                    $nullParams += $parameter
                }
            }

            foreach ($paramToRemove in $nullParams)
            {
                $result.Remove($paramToRemove)
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

        Write-Verbose -Message "Setting configuration of SCComplianceSearch for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentSearch = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentSearch.Ensure -eq 'Absent')
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            Write-Verbose "Creating new Compliance Search $($this.Name) calling the New-ComplianceSearch cmdlet."
            New-ComplianceSearch @CreationParams
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentSearch.Ensure -eq 'Present')
        {
            $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            # Remove unused parameters for Set-ComplianceSearch cmdlet
            $SetParams.Remove('Name')
            $SetParams.Remove('Case')

            Set-ComplianceSearch @SetParams -Identity $this.Name
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentSearch.Ensure -eq 'Present')
        {
            # If the Search exists and it shouldn't, simply remove it;
            Remove-ComplianceSearch -Identity $this.Name -Confirm:$false
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$searches = Get-ComplianceSearch -ErrorAction Stop

            if ($searches.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n    * Searches not assigned to an eDiscovery Case`r`n" -DeferWrite
            }
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            foreach ($search in $searches)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "        |---[$i/$($searches.Name.Count)] $($search.Name)" -DeferWrite

                $this.ExportedInstance = $search
                $Results = $this.GetForExport(@{ Name = $search.Name })
                $rawResults = $Results.Clone()
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -RawResults $rawResults
                [void]$dscContent.Append($currentDSCBlock)
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }

            $cases = Get-ComplianceCase
            $j = 1

            foreach ($case in $cases)
            {
                $searches = Get-ComplianceSearch -Case $case.Name

                Write-M365DSCHost -Message "`r`n    * [$j/$($cases.Length)] Searches assigned to case $($case.Name)`r`n" -DeferWrite
                $i = 1
                foreach ($search in $searches)
                {
                    $Params = @{
                        Name                  = $search.Name
                        Case                  = $case.Name
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePath       = $this.CertificatePath
                        CertificatePassword   = $this.CertificatePassword
                        AccessTokens          = $this.AccessTokens
                    }
                    Write-M365DSCHost -Message "        |---[$i/$($searches.Name.Count)] $($search.Name)" -DeferWrite
                    $Results = $this.GetForExport($Params)
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
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    $i++
                }
                $j++
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('IncludeUserAppContent')
        }
    }

    hidden [SCComplianceSearch] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCComplianceSearch])
        {
            return $Values
        }

        $result = [SCComplianceSearch]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
