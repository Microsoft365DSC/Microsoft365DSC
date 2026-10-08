using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADVerifiedIdAuthorityContract : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Id of the Verified ID Authority Contract.')]
    [System.String] $id

    [DscProperty(Key)]
    [System.ComponentModel.Description('URL of the linked domain of the authority.')]
    [System.String] $linkedDomainUrl

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Verified ID Authority.')]
    [System.String] $authorityId

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the Verified ID Authority Contract.')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('Display settings of the Authority Contract.')]
    [MSFT_AADVerifiedIdAuthorityContractDisplayModel[]] $displays

    [DscProperty()]
    [System.ComponentModel.Description('Rules settings of the Authority Contract.')]
    [MSFT_AADVerifiedIdAuthorityContractRulesModel] $rules

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
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

    [AADVerifiedIdAuthorityContract] Get()
    {
        $authority = $null
        $contracts = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADVerifiedIdAuthorityContract]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the AAD Verified Id Authority Contract with Name {$($this.Name)} for Authority with Linked Domain Url {$($this.linkedDomainUrl)}"

        try
        {
            $null = $this.Connect('AdminAPI')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'
            if ($null -ne $this.ResourceCache['exportedInstances'] -and $this.ResourceCache['ExportMode'])
            {
                $contracts = $this.ResourceCache['exportedInstances']
            }
            else
            {
                $uri = 'https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities'
                $response = $this.InvokeVerifiedIdWebRequest($uri, 'GET')
                $authorities = $response.value
                if ($null -eq $authorities)
                {
                    return $this.AsResult($nullResult)
                }
                $authority = $this.GetVerifiedIdAuthorityObject(($authorities | Where-Object -FilterScript { $_.didModel.linkedDomainUrls[0] -eq $this.linkedDomainUrl }))

                if ($null -eq $authority)
                {
                    return $this.AsResult($nullResult)
                }

                $uri = "https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities/$($authority.Id)/contracts"
                $response = $this.InvokeVerifiedIdWebRequest($uri, 'GET')
                $contracts = $response.value
            }
            if ($null -eq $contracts)
            {
                return $this.AsResult($nullResult)
            }

            $contract = $this.GetVerifiedIdAuthorityContractObject(($contracts | Where-Object -FilterScript { $_.name -eq $this.name }))
            if ($null -eq $contract)
            {
                return $this.AsResult($nullResult)
            }

            $results = @{
                id                    = $contract.id
                name                  = $contract.name
                linkedDomainUrl       = $this.linkedDomainUrl
                authorityId           = $authority.Id
                displays              = $contract.displays
                rules                 = $contract.rules
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                ApplicationSecret     = $this.ApplicationSecret
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
        $authority = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('AdminAPI')

        $currentInstance = $this.Get().ToHashtable()

        Write-Verbose -Message "Retrieved current instance: $($currentInstance.Name) with Id $($currentInstance.Id)"

        $rulesHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.rules
        $displaysHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.displays
        if ($null -ne $rulesHashmap.attestations.idTokens)
        {
            foreach ($idToken in $rulesHashmap.attestations.idTokens)
            {
                if ($null -ne $idToken.scopeValue)
                {
                    $idToken.Add('scope', $idToken.scopeValue)
                    $idToken.Remove('scopeValue') | Out-Null
                }
            }
        }

        $body = @{
            name     = $this.Name
            rules    = $rulesHashmap
            displays = @($displaysHashmap)
        }
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $uri = 'https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities'
            $response = $this.InvokeVerifiedIdWebRequest($uri, 'GET')
            $authorities = $response.value
            $authority = $this.GetVerifiedIdAuthorityObject(($authorities | Where-Object -FilterScript { $_.didModel.linkedDomainUrls[0] -eq $this.linkedDomainUrl }))

            Write-Verbose -Message "Creating an VerifiedId Authority Contract with Name {$($this.name)} for Authority Id $($authority.Id)"

            $uri = "https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities/$($authority.Id)/contracts"
            $null = $this.InvokeVerifiedIdWebRequest($uri, 'POST', $body)
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating an VerifiedId Authority Contract with Name {$($this.name)} for Authority Id $($currentInstance.authorityId)"
            $uri = "https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities/$($currentInstance.authorityId)/contracts/$($currentInstance.id)"
            $body.Remove('name') | Out-Null
            $null = $this.InvokeVerifiedIdWebRequest($uri, 'PATCH', $body)
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Warning -Message 'Removal of Contracts is not supported'
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

        $ConnectionMode = $this.Connect('AdminAPI')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $dscContent = [System.Text.StringBuilder]::new()
        $i = 1
        Write-M365DSCHost -Message "`r`n" -DeferWrite
        try
        {
            $this.ResourceCache['ExportMode'] = $true
            $uri = 'https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities'
            $response = $this.InvokeVerifiedIdWebRequest($uri, 'GET')
            [array] $authorities = $response.value
            [array] $this.ResourceCache['exportedInstances'] = $()

            foreach ($authority in $authorities)
            {
                $uri = "https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities/$($authority.Id)/contracts"
                $response = $this.InvokeVerifiedIdWebRequest($uri, 'GET')
                $contracts = $response.value

                foreach ($contract in $contracts)
                {
                    $this.ResourceCache['exportedInstances'] += $contract

                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($this.ResourceCache['exportedInstances'].Count)] $($contract.name)" -DeferWrite
                    $Params = @{
                        linkedDomainUrl       = $authority.didModel.linkedDomainUrls[0]
                        name                  = $contract.name
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

                    $Results = $this.GetForExport($Params)
                    if ($Results.Ensure -eq 'Present')
                    {

                        if ($null -ne $Results.displays)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'displays'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractDisplayModel'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'logo'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractDisplayCredentialLogo'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'card'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractDisplayCard'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'consent'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractDisplayConsent'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'claims'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractDisplayClaims'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.displays `
                                -CIMInstanceName 'AADVerifiedIdAuthorityContractDisplayModel' `
                                -ComplexTypeMapping $complexMapping

                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.displays = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('displays') | Out-Null
                            }
                        }

                        if ($null -ne $Results.rules)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'rules'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractRulesModel'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'attestations'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractAttestations'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'vc'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractVcType'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'customStatusEndpoint'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractCustomStatusEndpoint'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'idTokenHints'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractAttestationValues'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'idTokens'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractAttestationValues'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'presentations'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractAttestationValues'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'selfIssued'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractAttestationValues'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'accessTokens'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractAttestationValues'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'mapping'
                                    CimInstanceName = 'AADVerifiedIdAuthorityContractClaimMapping'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.rules`
                                -CIMInstanceName 'AADVerifiedIdAuthorityContractRulesModel' `
                                -ComplexTypeMapping $complexMapping

                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.rules = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('rules') | Out-Null
                            }
                        }

                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential `
                            -NoEscape @('displays', 'rules')

                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName
                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                        $i++
                    }
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

    hidden [System.Collections.Hashtable] GetVerifiedIdAuthorityContractObject([System.Object] $Contract)
    {
        if ($null -eq $Contract)
        {
            return $null
        }

        Write-Verbose -Message "Retrieving values for contract {$($Contract.name)}"
        $values = @{
            id   = $Contract.id
            name = $Contract.name
        }
        if ($null -ne $Contract.displays)
        {
            $displayValues = @()
            foreach ($display in $Contract.displays)
            {
                $claims = @()
                foreach ($claim in $display.claims)
                {
                    $claims += @{
                        claim = $claim.claim
                        label = $claim.label
                        type  = $claim.type
                    }
                }
                $displayValues += @{
                    locale  = $display.locale
                    card    = @{
                        title           = $display.card.title
                        issuedBy        = $display.card.issuedBy
                        backgroundColor = $display.card.backgroundColor
                        textColor       = $display.card.textColor
                        logo            = @{
                            uri         = $display.card.logo.uri
                            description = $display.card.logo.description
                        }
                        description     = $display.card.description
                    }
                    consent = @{
                        title        = $display.consent.title
                        instructions = $display.consent.instructions
                    }
                    claims  = $claims
                }
            }

            $values.Add('displays', $displayValues)
        }

        if ($null -ne $Contract.rules)
        {
            $ruleValues = @{}
            $attestations = @{}
            if ($null -ne $Contract.rules.attestations.idTokenHints)
            {
                $idTokenHints = @()
                foreach ($idTokenHint in $Contract.rules.attestations.idTokenHints)
                {
                    $mapping = @()
                    foreach ($map in $idTokenHint.mapping)
                    {
                        $mapping += @{
                            outputClaim = $map.outputClaim
                            inputClaim  = $map.inputClaim
                            required    = $map.required
                            indexed     = $map.indexed
                            type        = $map.type
                        }
                    }
                    $idTokenHints += @{
                        required       = $idTokenHint.required
                        mapping        = $mapping
                        trustedIssuers = $idTokenHint.trustedIssuers
                    }
                }
                $attestations.Add('idTokenHints', $idTokenHints)
            }

            if ($null -ne $Contract.rules.attestations.idTokens)
            {
                $idTokens = @()
                foreach ($idToken in $Contract.rules.attestations.idTokens)
                {
                    $mapping = @()
                    foreach ($map in $idToken.mapping)
                    {
                        $mapping += @{
                            outputClaim = $map.outputClaim
                            inputClaim  = $map.inputClaim
                            required    = $map.required
                            indexed     = $map.indexed
                            type        = $map.type
                        }
                    }
                    $idTokens += @{
                        required      = $idToken.required
                        mapping       = $mapping
                        configuration = $idToken.configuration
                        clientId      = $idToken.clientId
                        redirectUri   = $idToken.redirectUri
                        scopeValue    = $idToken.scope
                    }
                }
                $attestations.Add('idTokens', $idTokens)
            }

            if ($null -ne $Contract.rules.attestations.presentations)
            {
                $presentations = @()
                foreach ($presentation in $Contract.rules.attestations.presentations)
                {
                    $mapping = @()
                    foreach ($map in $presentation.mapping)
                    {
                        $mapping += @{
                            outputClaim = $map.outputClaim
                            inputClaim  = $map.inputClaim
                            required    = $map.required
                            indexed     = $map.indexed
                            type        = $map.type
                        }
                    }
                    $presentations += @{
                        required       = $presentation.required
                        mapping        = $mapping
                        trustedIssuers = $presentation.trustedIssuers
                        credentialType = $presentation.credentialType
                    }
                }
                $attestations.Add('presentations', $presentations)
            }

            if ($null -ne $Contract.rules.attestations.selfIssued)
            {
                $mySelfIssueds = @()
                foreach ($mySelfIssued in $Contract.rules.attestations.selfIssued)
                {
                    $mapping = @()
                    foreach ($map in $mySelfIssued.mapping)
                    {
                        $mapping += @{
                            outputClaim = $map.outputClaim
                            inputClaim  = $map.inputClaim
                            required    = $map.required
                            indexed     = $map.indexed
                            type        = $map.type
                        }
                    }
                    $mySelfIssueds += @{
                        required = $mySelfIssued.required
                        mapping  = $mapping
                    }
                }
                $attestations.Add('selfIssued', $mySelfIssueds)
            }

            if ($null -ne $Contract.rules.attestations.accessTokens)
            {
                $accessTokenValues = @()
                foreach ($accessToken in $Contract.rules.attestations.accessTokens)
                {
                    $mapping = @()
                    foreach ($map in $accessToken.mapping)
                    {
                        $mapping += @{
                            outputClaim = $map.outputClaim
                            inputClaim  = $map.inputClaim
                            required    = $map.required
                            indexed     = $map.indexed
                            type        = $map.type
                        }
                    }
                    $accessTokenValues += @{
                        required = $accessToken.required
                        mapping  = $mapping
                    }
                }
                $attestations.Add('accessTokens', $accessTokenValues)
            }

            $ruleValues.Add('attestations', $attestations)
            $ruleValues.Add('vc', @{
                    type = $Contract.rules.vc.type
                })
            $ruleValues.Add('validityInterval', $Contract.rules.validityInterval)

            $values.Add('rules', $ruleValues)
        }

        return $values
    }

    hidden [System.Collections.Hashtable] GetVerifiedIdAuthorityObject([System.Object] $Authority)
    {
        if ($null -eq $Authority)
        {
            return $null
        }

        Write-Verbose -Message "Retrieving values for authority {$($Authority.didModel.linkedDomainUrls[0])}"
        $did = ($Authority.didModel.did -split ':')[1]
        $values = @{
            Id              = $Authority.Id
            Name            = $Authority.Name
            LinkedDomainUrl = $Authority.didModel.linkedDomainUrls[0]
            DidMethod       = $did
        }
        if ($null -ne $Authority.KeyVaultMetadata)
        {
            $KeyVaultMetadata = @{
                SubscriptionId = $Authority.KeyVaultMetadata.SubscriptionId
                ResourceGroup  = $Authority.KeyVaultMetadata.ResourceGroup
                ResourceName   = $Authority.KeyVaultMetadata.ResourceName
                ResourceUrl    = $Authority.KeyVaultMetadata.ResourceUrl
            }

            $values.Add('KeyVaultMetadata', $KeyVaultMetadata)
        }
        return $values
    }

    hidden [System.Object] InvokeVerifiedIdWebRequest([System.String] $Uri, [System.String] $Method)
    {
        return $this.InvokeVerifiedIdWebRequest($Uri, $Method, $null)
    }

    hidden [System.Object] InvokeVerifiedIdWebRequest([System.String] $Uri, [System.String] $Method, [System.Collections.Hashtable] $Body)
    {
        $headers = @{
            Authorization  = (Get-MSCloudLoginConnectionProfile -Workload AdminAPI).AccessToken
            'Content-Type' = 'application/json'
        }

        $response = $null
        if ($Method -eq 'PATCH' -or $Method -eq 'POST')
        {
            $BodyJson = $Body | ConvertTo-Json -Depth 10
            $response = Invoke-WebRequest -Method $Method -Uri $Uri -Headers $headers -Body $BodyJson -UseBasicParsing
        }
        else
        {
            $response = Invoke-WebRequest -Method $Method -Uri $Uri -Headers $headers -UseBasicParsing
        }

        if ($Method -eq 'DELETE')
        {
            return $null
        }
        $result = ConvertFrom-Json $response.Content
        return $result
    }

    hidden [AADVerifiedIdAuthorityContract] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADVerifiedIdAuthorityContract])
        {
            return $Values
        }

        $result = [AADVerifiedIdAuthorityContract]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADVerifiedIdAuthorityContractDisplayModel
{
    [DscProperty()]
    [System.ComponentModel.Description('The locale of this display.')]
    [System.String] $locale

    [DscProperty()]
    [System.ComponentModel.Description('The display properties of the verifiable credential.')]
    [MSFT_AADVerifiedIdAuthorityContractDisplayCard] $card

    [DscProperty()]
    [System.ComponentModel.Description('Supplemental data when the verifiable credential is issued.')]
    [MSFT_AADVerifiedIdAuthorityContractDisplayConsent] $consent

    [DscProperty()]
    [System.ComponentModel.Description('Labels for the claims included in the verifiable credential.')]
    [MSFT_AADVerifiedIdAuthorityContractDisplayClaims[]] $claims
}

class MSFT_AADVerifiedIdAuthorityContractRulesModel
{
    [DscProperty()]
    [System.ComponentModel.Description('Describing supported inputs for the rules.')]
    [MSFT_AADVerifiedIdAuthorityContractAttestations] $attestations

    [DscProperty()]
    [System.ComponentModel.Description('This value shows the lifespan of the credential.')]
    [System.Nullable[System.UInt32]] $validityInterval

    [DscProperty()]
    [System.ComponentModel.Description('Types for this contract.')]
    [MSFT_AADVerifiedIdAuthorityContractVcType] $vc

    [DscProperty()]
    [System.ComponentModel.Description('Status endpoint to include in the verifiable credential for this contract.')]
    [MSFT_AADVerifiedIdAuthorityContractCustomStatusEndpoint] $customStatusEndpoint
}

class MSFT_AADVerifiedIdAuthorityContractDisplayCard
{
    [DscProperty()]
    [System.ComponentModel.Description('Title of the credential.')]
    [System.String] $title

    [DscProperty()]
    [System.ComponentModel.Description('The name of the issuer of the credential.')]
    [System.String] $issuedBy

    [DscProperty()]
    [System.ComponentModel.Description('Background color of the credential in hex, for example, #FFAABB.')]
    [System.String] $backgroundColor

    [DscProperty()]
    [System.ComponentModel.Description('Text color of the credential in hex, for example, #FFAABB.')]
    [System.String] $textColor

    [DscProperty()]
    [System.ComponentModel.Description('Supplemental text displayed alongside each credential.')]
    [System.String] $description

    [DscProperty()]
    [System.ComponentModel.Description('The logo to use for the credential.')]
    [MSFT_AADVerifiedIdAuthorityContractDisplayCredentialLogo] $logo
}

class MSFT_AADVerifiedIdAuthorityContractDisplayConsent
{
    [DscProperty()]
    [System.ComponentModel.Description('Title of the consent.')]
    [System.String] $title

    [DscProperty()]
    [System.ComponentModel.Description('Supplemental text to use when displaying consent.')]
    [System.String] $instructions
}

class MSFT_AADVerifiedIdAuthorityContractDisplayClaims
{
    [DscProperty()]
    [System.ComponentModel.Description('The label of the claim in display.')]
    [System.String] $label

    [DscProperty()]
    [System.ComponentModel.Description('The name of the claim to which the label applies.')]
    [System.String] $claim

    [DscProperty()]
    [System.ComponentModel.Description('The type of the claim.')]
    [System.String] $type

    [DscProperty()]
    [System.ComponentModel.Description('The description of the claim.')]
    [System.String] $description
}

class MSFT_AADVerifiedIdAuthorityContractAttestations
{
    [DscProperty()]
    [System.ComponentModel.Description('Id token hints attestations.')]
    [MSFT_AADVerifiedIdAuthorityContractAttestationValues[]] $idTokenHints

    [DscProperty()]
    [System.ComponentModel.Description('Id token attestations.')]
    [MSFT_AADVerifiedIdAuthorityContractAttestationValues[]] $idTokens

    [DscProperty()]
    [System.ComponentModel.Description('Presentations attestations.')]
    [MSFT_AADVerifiedIdAuthorityContractAttestationValues[]] $presentations

    [DscProperty()]
    [System.ComponentModel.Description('Self Issued attestations.')]
    [MSFT_AADVerifiedIdAuthorityContractAttestationValues[]] $selfIssued

    [DscProperty()]
    [System.ComponentModel.Description('Access Token attestations.')]
    [MSFT_AADVerifiedIdAuthorityContractAttestationValues[]] $accessTokens
}

class MSFT_AADVerifiedIdAuthorityContractVcType
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the vc.')]
    [System.String[]] $type
}

class MSFT_AADVerifiedIdAuthorityContractCustomStatusEndpoint
{
    [DscProperty()]
    [System.ComponentModel.Description('The URL of the custom status endpoint.')]
    [System.String] $url

    [DscProperty()]
    [System.ComponentModel.Description('The type of the endpoint.')]
    [System.String] $type
}

class MSFT_AADVerifiedIdAuthorityContractDisplayCredentialLogo
{
    [DscProperty()]
    [System.ComponentModel.Description('URI of the logo. If this is a URL, it must be reachable over the public internet anonymously.')]
    [System.String] $uri

    [DscProperty()]
    [System.ComponentModel.Description('Description of the logo.')]
    [System.String] $description
}

class MSFT_AADVerifiedIdAuthorityContractAttestationValues
{
    [DscProperty()]
    [System.ComponentModel.Description('Rules to map input claims into output claims in the verifiable credential.')]
    [MSFT_AADVerifiedIdAuthorityContractClaimMapping[]] $mapping

    [DscProperty()]
    [System.ComponentModel.Description('Indicating whether this attestation is required or not.')]
    [System.Nullable[System.Boolean]] $required

    [DscProperty()]
    [System.ComponentModel.Description('A list of DIDs allowed to issue the verifiable credential for this contract.')]
    [System.String[]] $trustedIssuers

    [DscProperty()]
    [System.ComponentModel.Description('Required credential type of the input.')]
    [System.String] $credentialType

    [DscProperty()]
    [System.ComponentModel.Description('Location of the identity provider''s configuration document.')]
    [System.String] $configuration

    [DscProperty()]
    [System.ComponentModel.Description('Client ID to use when obtaining the ID token.')]
    [System.String] $clientId

    [DscProperty()]
    [System.ComponentModel.Description('Redirect URI to use when obtaining the ID token. MUST BE vcclient://openid/')]
    [System.String] $redirectUri

    [DscProperty()]
    [System.ComponentModel.Description('Space delimited list of scopes to use when obtaining the ID token.')]
    [System.String] $scopeValue
}

class MSFT_AADVerifiedIdAuthorityContractClaimMapping
{
    [DscProperty()]
    [System.ComponentModel.Description('The name of the claim to use from the input.')]
    [System.String] $inputClaim

    [DscProperty()]
    [System.ComponentModel.Description('The name of the claim in the verifiable credential.')]
    [System.String] $outputClaim

    [DscProperty()]
    [System.ComponentModel.Description('Indicating whether the value of this claim is used for searching.')]
    [System.Nullable[System.Boolean]] $indexed

    [DscProperty()]
    [System.ComponentModel.Description('Indicating whether this mapping is required or not.')]
    [System.Nullable[System.Boolean]] $required

    [DscProperty()]
    [System.ComponentModel.Description('Type of claim.')]
    [System.String] $type
}
