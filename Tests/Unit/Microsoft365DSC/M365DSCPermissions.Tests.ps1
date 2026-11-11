BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global

    $Script:GraphAppId = '00000003-0000-0000-c000-000000000000'
    $Script:ExchangeAppId = '00000002-0000-0ff1-ce00-000000000000'
    $Script:GroupReadWriteId = '62a82d76-70ea-41e2-9197-370581804d09'
    $Script:UserReadId = 'df021288-bdef-4463-88db-98f22de89214'
    $Script:ManageAsAppId = 'dc50a0fb-09a3-484d-be87-e023b12c6440'
}

Describe 'Get-M365DSCCompiledPermissionList' {
    BeforeEach {
        Mock -ModuleName M365DSCPermissions -CommandName Write-Progress
        Mock -ModuleName M365DSCPermissions -CommandName Get-M365DSCResourceSetting -MockWith {
            $graphPermissions = [PSCustomObject]@{
                application = [PSCustomObject]@{
                    read   = @([PSCustomObject]@{ name = 'Organization.Read.All' }, [PSCustomObject]@{ name = 'Group.Read.All' })
                    update = @([PSCustomObject]@{ name = 'Group.ReadWrite.All' })
                }
                delegated   = [PSCustomObject]@{
                    read   = @([PSCustomObject]@{ name = 'group.read.all' })
                    update = @([PSCustomObject]@{ name = 'NotSupported' })
                }
            }
            [PSCustomObject]@{
                roles       = $null
                permissions = [PSCustomObject]@{ graph = $graphPermissions }
            }
        }
    }

    It 'adds each permission once, ignoring case and the seeded Organization.Read.All entry' {
        $result = Get-M365DSCCompiledPermissionList -ResourceNameList @('ResourceA', 'ResourceB')

        $applicationRead = @($result.Read | Where-Object -FilterScript { $_.Permission.Type -eq 'Application' })
        $applicationRead.Permission.Name | Should -Be @('Organization.Read.All', 'Group.Read.All')
        @($result.Read | Where-Object -FilterScript { $_.Permission.Type -eq 'Delegated' }).Count | Should -Be 1
        @($result.Update | Where-Object -FilterScript { $_.Permission.Name -eq 'Group.ReadWrite.All' }).Count | Should -Be 1
    }

    It 'keeps a separate permission list per resource with GroupByResourceName' {
        $result = Get-M365DSCCompiledPermissionList -ResourceNameList @('ResourceA', 'ResourceB') -GroupByResourceName

        foreach ($resourceName in @('ResourceA', 'ResourceB'))
        {
            $result[$resourceName].Read.Count | Should -Be 3
            $result[$resourceName].Update.Count | Should -Be 2
        }
    }
}

Describe 'Update-M365DSCAzureAdApplication' {
    BeforeEach {
        $Script:WrittenMessages = @()
        Mock -ModuleName M365DSCPermissions -CommandName Write-Host -MockWith { $Script:WrittenMessages += "$Object" }
        Mock -ModuleName M365DSCPermissions -CommandName Confirm-M365DSCDependencies
        Mock -ModuleName M365DSCPermissions -CommandName New-M365DSCConnection -MockWith { 'Credentials' }
        Mock -ModuleName M365DSCPermissions -CommandName Update-MgApplication
        Mock -ModuleName M365DSCPermissions -CommandName Add-MgBetaApplicationPassword
        Mock -ModuleName M365DSCPermissions -CommandName Get-MgApplication -MockWith {
            [PSCustomObject]@{
                Id                     = 'app-object-id'
                AppId                  = 'app-client-id'
                AppRoles               = @()
                PasswordCredentials    = @([PSCustomObject]@{ KeyId = 'secret-1' })
                RequiredResourceAccess = @(
                    [PSCustomObject]@{
                        ResourceAppId  = $Script:GraphAppId
                        ResourceAccess = @(
                            [PSCustomObject]@{ Id = $Script:GroupReadWriteId; Type = 'Role' }
                            [PSCustomObject]@{ Id = $Script:UserReadId; Type = 'Role' }
                        )
                    }
                )
            }
        }
        Mock -ModuleName M365DSCPermissions -CommandName Get-M365DSCApiServicePrincipal -MockWith {
            switch ($ApiName)
            {
                'Graph'
                {
                    [PSCustomObject]@{
                        AppId    = $Script:GraphAppId
                        AppRoles = @([PSCustomObject]@{ Value = 'Group.ReadWrite.All'; Id = $Script:GroupReadWriteId })
                    }
                }
                'Exchange'
                {
                    [PSCustomObject]@{
                        AppId    = $Script:ExchangeAppId
                        AppRoles = @([PSCustomObject]@{ Value = 'Exchange.ManageAsApp'; Id = $Script:ManageAsAppId })
                    }
                }
            }
        }
    }

    It 'does not send an empty resource entry or a PATCH for an unknown permission' {
        Update-M365DSCAzureAdApplication -ApplicationName 'Microsoft365DSC' -Type Secret -Permissions @(
            @{ Api = 'Exchange'; PermissionName = 'Exchange.ManagAsApp' }
        )

        Should -Invoke -ModuleName M365DSCPermissions -CommandName Update-MgApplication -Exactly -Times 0
        ($Script:WrittenMessages -join "`n") | Should -BeLike "*API 'Exchange' has no application permission 'Exchange.ManagAsApp'*"
        ($Script:WrittenMessages -join "`n") | Should -BeLike '*application permissions are left unchanged*'
    }

    It 'keeps already requested permissions in the PATCH and reports the dropped ones' {
        Update-M365DSCAzureAdApplication -ApplicationName 'Microsoft365DSC' -Type Secret -Permissions @(
            @{ Api = 'Graph'; PermissionName = 'Group.ReadWrite.All' }
            @{ Api = 'Graph'; PermissionName = 'Group.ReadWrite.All' }
            @{ Api = 'Exchange'; PermissionName = 'Exchange.ManageAsApp' }
            @{ Api = 'Exchange'; PermissionName = 'Typo.Permission' }
        )

        Should -Invoke -ModuleName M365DSCPermissions -CommandName Update-MgApplication -Exactly -Times 1 -ParameterFilter {
            $access = $BodyParameter.requiredResourceAccess
            $graph = $access | Where-Object -FilterScript { $_.resourceAppId -eq $Script:GraphAppId }
            $exchange = $access | Where-Object -FilterScript { $_.resourceAppId -eq $Script:ExchangeAppId }
            $access.Count -eq 2 -and
            @($graph.resourceAccess).Count -eq 1 -and $graph.resourceAccess[0].id -eq $Script:GroupReadWriteId -and
            @($exchange.resourceAccess).Count -eq 1 -and $exchange.resourceAccess[0].id -eq $Script:ManageAsAppId
        }
        $messages = $Script:WrittenMessages -join "`n"
        $messages | Should -BeLike "*Permission 'Graph\Group.ReadWrite.All' already added to the application!*"
        $messages | Should -BeLike "*Permission '$($Script:UserReadId)' (Role) of API '$($Script:GraphAppId)' is not specified and will be removed*"
        $messages | Should -Not -BeLike "*Permission '$($Script:GroupReadWriteId)' (Role)*will be removed*"
    }
}

Describe 'Test-M365DSCKeyCredentialMatch' {
    BeforeAll {
        $rsa = [System.Security.Cryptography.RSA]::Create(2048)
        $request = [System.Security.Cryptography.X509Certificates.CertificateRequest]::new(
            'CN=Microsoft365DSC',
            $rsa,
            [System.Security.Cryptography.HashAlgorithmName]::SHA256,
            [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
        )
        $Script:Certificate = $request.CreateSelfSigned([System.DateTimeOffset]::UtcNow.AddDays(-1), [System.DateTimeOffset]::UtcNow.AddDays(30))
        $Script:CertificateHash = $Script:Certificate.GetCertHash()
    }

    AfterAll {
        $Script:Certificate.Dispose()
    }

    It 'matches a customKeyIdentifier returned as <Name>' -ForEach @(
        @{ Name = 'byte array'; Kind = 'Bytes' }
        @{ Name = 'base64 string'; Kind = 'Base64' }
        @{ Name = 'hex thumbprint'; Kind = 'Hex' }
    ) {
        $identifier = switch ($Kind)
        {
            'Bytes' { , $Script:CertificateHash }
            'Base64' { [System.Convert]::ToBase64String($Script:CertificateHash) }
            'Hex' { $Script:Certificate.Thumbprint }
        }
        $keyCredential = [PSCustomObject]@{
            CustomKeyIdentifier = $identifier
            DisplayName         = 'Custom name set in the portal'
            EndDateTime         = [System.DateTime]::MinValue
        }

        InModuleScope -ModuleName M365DSCPermissions -Parameters @{ KeyCredential = $keyCredential; Certificate = $Script:Certificate } {
            Test-M365DSCKeyCredentialMatch -KeyCredential $KeyCredential -Certificate $Certificate
        } | Should -BeTrue
    }

    It 'does not match another certificate' {
        $keyCredential = [PSCustomObject]@{
            CustomKeyIdentifier = [System.Convert]::ToBase64String([System.Byte[]]::new(20))
            DisplayName         = 'CN=Other'
            EndDateTime         = [System.DateTime]::MinValue
        }

        InModuleScope -ModuleName M365DSCPermissions -Parameters @{ KeyCredential = $keyCredential; Certificate = $Script:Certificate } {
            Test-M365DSCKeyCredentialMatch -KeyCredential $KeyCredential -Certificate $Certificate
        } | Should -BeFalse
    }

    It 'falls back to DisplayName and EndDateTime without customKeyIdentifier' {
        $keyCredential = [PSCustomObject]@{
            CustomKeyIdentifier = $null
            DisplayName         = $Script:Certificate.Subject
            EndDateTime         = $Script:Certificate.NotAfter.ToUniversalTime()
        }

        InModuleScope -ModuleName M365DSCPermissions -Parameters @{ KeyCredential = $keyCredential; Certificate = $Script:Certificate } {
            Test-M365DSCKeyCredentialMatch -KeyCredential $KeyCredential -Certificate $Certificate
        } | Should -BeTrue
    }
}
