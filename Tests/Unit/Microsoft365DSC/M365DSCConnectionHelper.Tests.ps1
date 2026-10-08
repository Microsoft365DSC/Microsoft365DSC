BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader

    $Script:AllAuthenticationMethods = @(
        'ApplicationWithSecret'
        'CertificateThumbprint'
        'CertificatePath'
        'Credentials'
        'CredentialsWithTenantId'
        'CredentialsWithApplicationId'
        'ManagedIdentity'
        'AccessTokens'
    )

    $Script:TestResources = @('GraphThing', 'ExoThing', 'SPOThing', 'MinimalThing')

    $Script:PropertyMap = @{
        GraphThing    = [System.String[]] @('Id', 'Credential', 'ApplicationId', 'TenantId', 'ApplicationSecret', 'CertificateThumbprint', 'CertificatePassword', 'CertificatePath', 'ManagedIdentity', 'AccessTokens')
        MSFT_ExoThing = [System.String[]] @('Id', 'Credential', 'ApplicationId', 'TenantId', 'CertificateThumbprint', 'ManagedIdentity', 'AccessTokens')
        SPOThing      = [System.String[]] @('Id', 'Credential', 'ApplicationId', 'TenantId', 'AccessTokens')
        MinimalThing  = @('Id', 'AccessTokens')
        NotSelected   = [System.String[]] @('Id', 'ApplicationId', 'TenantId', 'CertificateThumbprint')
    }

    function Get-TestAuthenticationMethod
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [System.String]
            $ResourceName,

            [Parameter()]
            [System.String[]]
            $AuthenticationMethod = $Script:AllAuthenticationMethods
        )

        $components = [Microsoft365DSC.Connection.ConnectionHelper]::GetComponentsWithMostSecureAuthenticationType(
            [System.Collections.IDictionary] $Script:PropertyMap,
            $AuthenticationMethod,
            $Script:TestResources
        )

        return ($components | Where-Object -FilterScript { $_.Resource -eq $ResourceName }).AuthMethod
    }
}

Describe 'ConnectionHelper.GetComponentsWithMostSecureAuthenticationType' {
    It 'Prefers the certificate thumbprint over every other method' {
        Get-TestAuthenticationMethod -ResourceName 'GraphThing' | Should -Be 'CertificateThumbprint'
    }

    It 'Falls back to the application secret when no certificate method is requested' {
        Get-TestAuthenticationMethod -ResourceName 'GraphThing' `
            -AuthenticationMethod @('ApplicationWithSecret', 'Credentials') | Should -Be 'ApplicationSecret'
    }

    It 'Skips the application secret for a resource that does not declare one' {
        Get-TestAuthenticationMethod -ResourceName 'ExoThing' `
            -AuthenticationMethod @('ApplicationWithSecret', 'Credentials') | Should -Be 'Credentials'
    }

    It 'Excludes SPO resources from CredentialsWithTenantId' {
        Get-TestAuthenticationMethod -ResourceName 'SPOThing' `
            -AuthenticationMethod @('CredentialsWithTenantId', 'Credentials') | Should -Be 'Credentials'
    }

    It 'Returns CredentialsWithTenantId for a resource without an SPO, OD or PP prefix' {
        Get-TestAuthenticationMethod -ResourceName 'ExoThing' `
            -AuthenticationMethod @('CredentialsWithTenantId', 'Credentials') | Should -Be 'CredentialsWithTenantId'
    }

    It 'Returns the access tokens when the resource declares nothing else' {
        Get-TestAuthenticationMethod -ResourceName 'MinimalThing' | Should -Be 'AccessTokens'
    }

    It 'Accepts object[] values and strips the MSFT_ prefix' {
        $components = [Microsoft365DSC.Connection.ConnectionHelper]::GetComponentsWithMostSecureAuthenticationType([System.Collections.IDictionary] $Script:PropertyMap, $Script:AllAuthenticationMethods, @('MinimalThing', 'ExoThing'))
        ($components | Where-Object -FilterScript { $_.Resource -eq 'MinimalThing' }).AuthMethod | Should -Be 'AccessTokens'
        ($components | Where-Object -FilterScript { $_.Resource -eq 'ExoThing' }).AuthMethod | Should -Be 'CertificateThumbprint'
    }

    It 'Ignores resources that were not requested' {
        $components = [Microsoft365DSC.Connection.ConnectionHelper]::GetComponentsWithMostSecureAuthenticationType([System.Collections.IDictionary] $Script:PropertyMap, $Script:AllAuthenticationMethods, $Script:TestResources)
        $components.Count | Should -Be $Script:TestResources.Count
        $components.Resource | Should -Not -Contain 'NotSelected'
    }

    It 'Omits a resource that supports none of the requested methods' {
        $components = [Microsoft365DSC.Connection.ConnectionHelper]::GetComponentsWithMostSecureAuthenticationType([System.Collections.IDictionary] $Script:PropertyMap, @('ManagedIdentity'), $Script:TestResources)
        $components.Resource | Should -Not -Contain 'MinimalThing'
        $components.Resource | Should -Contain 'GraphThing'
    }

    It 'Throws for an empty map' {
        {
            [Microsoft365DSC.Connection.ConnectionHelper]::GetComponentsWithMostSecureAuthenticationType([System.Collections.IDictionary] @{}, $Script:AllAuthenticationMethods, $Script:TestResources)
        } | Should -Throw -ExceptionType ([System.Management.Automation.MethodInvocationException])
    }
}

Describe 'Get-M365DSCComponentsWithMostSecureAuthenticationType' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCConnection.psm1" -Force -Global
        function global:Initialize-M365DSCSchemaCache
        {
            [CmdletBinding()]
            param ()
        }

        $Script:FixtureSchema = @(
            @{
                ClassName  = 'MSFT_GraphThing'
                Parameters = @(
                    @{ Name = 'Id'; CIMType = 'String'; Option = 'Key' }
                    @{ Name = 'ApplicationId'; CIMType = 'String'; Option = 'Write' }
                    @{ Name = 'TenantId'; CIMType = 'String'; Option = 'Write' }
                    @{ Name = 'CertificateThumbprint'; CIMType = 'String'; Option = 'Write' }
                    @{ Name = 'Credential'; CIMType = 'PSCredential'; Option = 'Write' }
                )
            }
            @{
                ClassName  = 'MSFT_MinimalThing'
                Parameters = @(
                    @{ Name = 'Id'; CIMType = 'String'; Option = 'Key' }
                    @{ Name = 'AccessTokens'; CIMType = 'StringArray'; Option = 'Write' }
                )
            }
            @{
                ClassName  = 'MSFT_GraphThingItem'
                Parameters = @(
                    @{ Name = 'Key'; CIMType = 'String'; Option = 'Required' }
                )
            }
        )
        [Microsoft365DSC.Cache.CacheManager]::LoadSchema([System.Collections.Generic.List[object]] @($Script:FixtureSchema))
    }

    AfterAll {
        [Microsoft365DSC.Cache.CacheManager]::ClearSchema()
        Remove-Item -Path 'Function:\global:Initialize-M365DSCSchemaCache' -ErrorAction SilentlyContinue
        Remove-Module -Name M365DSCConnection -Force -ErrorAction SilentlyContinue
    }

    It 'Builds the property map for requested resources only' {
        $map = Get-M365DSCResourcePropertyNameMap -Resources @('GraphThing', 'MinimalThing', 'Unknown')
        $map.Count | Should -Be 2
        $map['GraphThing'] | Should -Contain 'CertificateThumbprint'
        $map.ContainsKey('GraphThingItem') | Should -BeFalse
    }

    It 'Maps every exported resource when none is requested' {
        Mock -ModuleName M365DSCConnection -CommandName Get-M365DSCExportedResourceName -MockWith { return [System.String[]] @('GraphThing', 'MinimalThing') }
        $map = Get-M365DSCResourcePropertyNameMap
        $map.Count | Should -Be 2
        $map.ContainsKey('GraphThingItem') | Should -BeFalse
    }

    It 'Evaluates every exported resource and authentication method when no argument is supplied' {
        Mock -ModuleName M365DSCConnection -CommandName Get-M365DSCExportedResourceName -MockWith { return [System.String[]] @('GraphThing', 'MinimalThing') }
        $components = @(Get-M365DSCComponentsWithMostSecureAuthenticationType)
        $components.Count | Should -Be 2
        ($components | Where-Object -FilterScript { $_.Resource -eq 'GraphThing' }).AuthMethod | Should -Be 'CertificateThumbprint'
        ($components | Where-Object -FilterScript { $_.Resource -eq 'MinimalThing' }).AuthMethod | Should -Be 'AccessTokens'
    }

    It 'Resolves the requested resources from the loaded schema' {
        $components = @(Get-M365DSCComponentsWithMostSecureAuthenticationType -AuthenticationMethod $Script:AllAuthenticationMethods -Resources @('GraphThing', 'MinimalThing'))
        $components.Count | Should -Be 2
        ($components | Where-Object -FilterScript { $_.Resource -eq 'GraphThing' }).AuthMethod | Should -Be 'CertificateThumbprint'
        ($components | Where-Object -FilterScript { $_.Resource -eq 'MinimalThing' }).AuthMethod | Should -Be 'AccessTokens'
    }

    It 'Throws when the schema contains none of the requested resources' {
        { Get-M365DSCComponentsWithMostSecureAuthenticationType -AuthenticationMethod $Script:AllAuthenticationMethods -Resources @('Unknown') } |
            Should -Throw -ExpectedMessage '*schema cache does not contain*'
    }

    It 'Propagates a failure to load the schema cache' {
        Mock -ModuleName M365DSCConnection -CommandName Initialize-M365DSCSchemaCache -MockWith { throw 'missing' }
        { Get-M365DSCComponentsWithMostSecureAuthenticationType -AuthenticationMethod $Script:AllAuthenticationMethods -Resources @('GraphThing') } |
            Should -Throw -ExpectedMessage '*missing*'
    }
}
