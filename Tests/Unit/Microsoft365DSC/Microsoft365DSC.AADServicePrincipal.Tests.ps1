[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
    -ChildPath '..\..\Unit' `
    -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Microsoft365.psm1' `
        -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Generic.psm1' `
        -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\UnitTestHelper.psm1' `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource 'AADServicePrincipal' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaServicePrincipal -MockWith {
            }

            Mock -CommandName Remove-MgBetaServicePrincipal -MockWith {
            }

            Mock -CommandName New-MgBetaServicePrincipal -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-MgApplication -MockWith {
                return @{
                    AppId = "b4f08c68-7276-4cb8-b9ae-e75fca5ff834"
                    DisplayName = "App1"
                }
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                return @()
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The service principal should exist but it does not' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppId                     = 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834'
                    DisplayName               = 'App1'
                    AlternativeNames          = 'AlternativeName1', 'AlternativeName2'
                    AccountEnabled            = $true
                    AppRoleAssignmentRequired = $false
                    ErrorUrl                  = ''
                    Homepage                  = 'https://app1.contoso.com'
                    LoginUrl                  = 'https://app1.contoso.com/login'
                    LogoutUrl                 = 'https://app1.contoso.com/logout'
                    PreferredTokenSigningKeyThumbprint = 'B7E3A19C5D428F06A1C93E7B2054D8F6C3A1E97B'
                    PublisherName             = 'Contoso'
                    ReplyURLs                 = 'https://app1.contoso.com'
                    SamlMetadataURL           = ''
                    ServicePrincipalNames     = 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834', 'https://app1.contoso.com'
                    ServicePrincipalType      = 'Application'
                    Tags                      = '{WindowsAzureActiveDirectoryIntegratedApp}'
                    Description               = 'Submit, review and approve expense reports from any device.'
                    NotificationEmailAddresses = 'certificatealerts@contoso.com'
                    SamlSingleSignOnSettings  = [MSFT_MicrosoftGraphsamlSingleSignOnSettings] @{
                        RelayState = '/expenses/dashboard'
                    }
                    TokenEncryptionKeyId      = 'a7f3c9d1-6e42-4b58-90ac-5d2e1b874f36'
                    PasswordCredentials       = @(
                        [MSFT_MicrosoftGraphpasswordCredential] @{
                            KeyId = 'keyid'
                            EndDateTime = '2025-03-15T19:50:29.0310000+00:00'
                            Hint = 'VsO'
                            DisplayName = 'Super Secret'
                            StartDateTime = '2024-09-16T19:50:29.0310000+00:00'
                        }
                    )
                    KeyCredentials = @(
                        [MSFT_MicrosoftGraphkeyCredential] @{
                            Usage = 'Verify'
                            StartDateTime = '2024-09-25T09:13:11.0000000+00:00'
                            Type = 'AsymmetricX509Cert'
                            KeyId = 'Key ID'
                            EndDateTime = '2025-09-25T09:33:11.0000000+00:00'
                            DisplayName = 'anexas_test_2'
                        }
                    )
                    Ensure                    = 'Present'
                    Credential                = $Credscredential
                }

                Mock -CommandName Get-MgBetaServicePrincipal -MockWith {
                    return $null
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaServicePrincipal' -Exactly 1
            }
            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should create the application from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaServicePrincipal' -Exactly 1
            }
        }

        Context -Name 'The application exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppId                     = 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834'
                    DisplayName               = 'App1'
                    AlternativeNames          = 'AlternativeName1', 'AlternativeName2'
                    AccountEnabled            = $true
                    AppRoleAssignmentRequired = $false
                    ErrorUrl                  = ''
                    Homepage                  = 'https://app1.contoso.com'
                    LoginUrl                  = 'https://app1.contoso.com/login'
                    LogoutUrl                 = 'https://app1.contoso.com/logout'
                    PreferredTokenSigningKeyThumbprint = 'B7E3A19C5D428F06A1C93E7B2054D8F6C3A1E97B'
                    PublisherName             = 'Contoso'
                    ReplyURLs                 = 'https://app1.contoso.com'
                    SamlMetadataURL           = ''
                    ServicePrincipalNames     = 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834', 'https://app1.contoso.com'
                    ServicePrincipalType      = 'Application'
                    Tags                      = '{WindowsAzureActiveDirectoryIntegratedApp}'
                    Description               = 'Submit, review and approve expense reports from any device.'
                    NotificationEmailAddresses = 'certificatealerts@contoso.com'
                    SamlSingleSignOnSettings  = [MSFT_MicrosoftGraphsamlSingleSignOnSettings] @{
                        RelayState = '/expenses/dashboard'
                    }
                    TokenEncryptionKeyId      = 'a7f3c9d1-6e42-4b58-90ac-5d2e1b874f36'
                    PasswordCredentials       = @(
                        [MSFT_MicrosoftGraphpasswordCredential] @{
                            KeyId = 'keyid'
                            EndDateTime = '2025-03-15T19:50:29.0310000+00:00'
                            Hint = 'VsO'
                            DisplayName = 'Super Secret'
                            StartDateTime = '2024-09-16T19:50:29.0310000+00:00'
                        }
                    )
                    KeyCredentials            = @(
                        [MSFT_MicrosoftGraphkeyCredential] @{
                            Usage = 'Verify'
                            StartDateTime = '2024-09-25T09:13:11.0000000+00:00'
                            Type = 'AsymmetricX509Cert'
                            KeyId = 'Key ID'
                            EndDateTime = '2025-09-25T09:33:11.0000000+00:00'
                            DisplayName = 'anexas_test_2'
                        }
                    )
                    Ensure                    = 'Absent'
                    Credential                = $Credscredential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaServicePrincipal -MockWith {
                    $AADSP = New-Object PSCustomObject
                    $AADSP | Add-Member -MemberType NoteProperty -Name AppId -Value 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Id -Value '5dcb2237-c61b-4258-9c85-eae2aaeba9d6'
                    $AADSP | Add-Member -MemberType NoteProperty -Name DisplayName -Value 'App1'
                    $AADSP | Add-Member -MemberType NoteProperty -Name AlternativeNames -Value 'AlternativeName1', 'AlternativeName2'
                    $AADSP | Add-Member -MemberType NoteProperty -Name AccountEnabled -Value $true
                    $AADSP | Add-Member -MemberType NoteProperty -Name AppRoleAssignmentRequired -Value $false
                    $AADSP | Add-Member -MemberType NoteProperty -Name ErrorUrl -Value ''
                    $AADSP | Add-Member -MemberType NoteProperty -Name Homepage -Value 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name LoginUrl -Value 'https://app1.contoso.com/login'
                    $AADSP | Add-Member -MemberType NoteProperty -Name LogoutUrl -Value 'https://app1.contoso.com/logout'
                    $AADSP | Add-Member -MemberType NoteProperty -Name PreferredTokenSigningKeyThumbprint -Value 'B7E3A19C5D428F06A1C93E7B2054D8F6C3A1E97B'
                    $AADSP | Add-Member -MemberType NoteProperty -Name PublisherName -Value 'Contoso'
                    $AADSP | Add-Member -MemberType NoteProperty -Name ReplyURLs -Value 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name SamlMetadataURL -Value ''
                    $AADSP | Add-Member -MemberType NoteProperty -Name ServicePrincipalNames -Value 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834', 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name ServicePrincipalType -Value 'Application'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Tags -Value '{WindowsAzureActiveDirectoryIntegratedApp}'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Description -Value 'Submit, review and approve expense reports from any device.'
                    $AADSP | Add-Member -MemberType NoteProperty -Name NotificationEmailAddresses -Value 'certificatealerts@contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name SamlSingleSignOnSettings -Value @{
                        relayState = '/expenses/dashboard'
                    }
                    $AADSP | Add-Member -MemberType NoteProperty -Name TokenEncryptionKeyId -Value 'a7f3c9d1-6e42-4b58-90ac-5d2e1b874f36'
                    $AADSP | Add-Member -MemberType NoteProperty -Name KeyCredentials -Value @{
                        Usage = 'Verify'
                        StartDateTime = '2024-09-25T09:13:11.0000000+00:00'
                        Type = 'AsymmetricX509Cert'
                        KeyId = 'Key ID'
                        EndDateTime = '2025-09-25T09:33:11.0000000+00:00'
                        DisplayName = 'anexas_test_2'
                    }
                    $AADSP | Add-Member -MemberType NoteProperty -Name PasswordCredentials -Value @{
                        KeyId = 'keyid'
                        EndDateTime = '2025-03-15T19:50:29.0310000+00:00'
                        Hint = 'VsO'
                        DisplayName = 'Super Secret'
                        StartDateTime = '2024-09-16T19:50:29.0310000+00:00'
                    }
                    return $AADSP
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaServicePrincipal' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the app from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaServicePrincipal' -Exactly 1
            }
        }
        Context -Name 'The app exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppId                     = 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834'
                    DisplayName               = 'App1'
                    AlternativeNames          = 'AlternativeName1', 'AlternativeName2'
                    AccountEnabled            = $true
                    AppRoleAssignmentRequired = $false
                    ErrorUrl                  = ''
                    Homepage                  = 'https://app1.contoso.com'
                    LoginUrl                  = 'https://app1.contoso.com/login'
                    LogoutUrl                 = 'https://app1.contoso.com/logout'
                    PreferredTokenSigningKeyThumbprint = 'B7E3A19C5D428F06A1C93E7B2054D8F6C3A1E97B'
                    PublisherName             = 'Contoso'
                    ReplyURLs                 = 'https://app1.contoso.com'
                    SamlMetadataURL           = ''
                    ServicePrincipalNames     = 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834', 'https://app1.contoso.com'
                    ServicePrincipalType      = 'Application'
                    Tags                      = '{WindowsAzureActiveDirectoryIntegratedApp}'
                    Description               = 'Submit, review and approve expense reports from any device.'
                    NotificationEmailAddresses = 'certificatealerts@contoso.com'
                    SamlSingleSignOnSettings  = [MSFT_MicrosoftGraphsamlSingleSignOnSettings] @{
                        RelayState = '/expenses/dashboard'
                    }
                    TokenEncryptionKeyId      = 'a7f3c9d1-6e42-4b58-90ac-5d2e1b874f36'
                    PasswordCredentials       = @(
                        [MSFT_MicrosoftGraphpasswordCredential] @{
                            KeyId = 'keyid'
                            EndDateTime = '2025-03-15T19:50:29.0310000+00:00'
                            Hint = 'VsO'
                            DisplayName = 'Super Secret'
                            StartDateTime = '2024-09-16T19:50:29.0310000+00:00'
                        }
                    )
                    KeyCredentials            = @(
                        [MSFT_MicrosoftGraphkeyCredential] @{
                            Usage = 'Verify'
                            StartDateTime = '2024-09-25T09:13:11.0000000+00:00'
                            Type = 'AsymmetricX509Cert'
                            KeyId = 'Key ID'
                            EndDateTime = '2025-09-25T09:33:11.0000000+00:00'
                            DisplayName = 'anexas_test_2'
                        }
                    )
                    Ensure                    = 'Present'
                    Credential                = $Credscredential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaServicePrincipal -MockWith {
                    $AADSP = New-Object PSCustomObject
                    $AADSP | Add-Member -MemberType NoteProperty -Name AppId -Value 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834'
                    $AADSP | Add-Member -MemberType NoteProperty -Name AppDisplayName -Value 'App1'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Id -Value '5dcb2237-c61b-4258-9c85-eae2aaeba9d6'
                    $AADSP | Add-Member -MemberType NoteProperty -Name DisplayName -Value 'App1'
                    $AADSP | Add-Member -MemberType NoteProperty -Name AlternativeNames -Value 'AlternativeName1', 'AlternativeName2'
                    $AADSP | Add-Member -MemberType NoteProperty -Name AccountEnabled -Value $true
                    $AADSP | Add-Member -MemberType NoteProperty -Name AppRoleAssignmentRequired -Value $false
                    $AADSP | Add-Member -MemberType NoteProperty -Name ErrorUrl -Value ''
                    $AADSP | Add-Member -MemberType NoteProperty -Name Homepage -Value 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name LoginUrl -Value 'https://app1.contoso.com/login'
                    $AADSP | Add-Member -MemberType NoteProperty -Name LogoutUrl -Value 'https://app1.contoso.com/logout'
                    $AADSP | Add-Member -MemberType NoteProperty -Name PreferredTokenSigningKeyThumbprint -Value 'B7E3A19C5D428F06A1C93E7B2054D8F6C3A1E97B'
                    $AADSP | Add-Member -MemberType NoteProperty -Name PublisherName -Value 'Contoso'
                    $AADSP | Add-Member -MemberType NoteProperty -Name ReplyURLs -Value 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name SamlMetadataURL -Value ''
                    $AADSP | Add-Member -MemberType NoteProperty -Name ServicePrincipalNames -Value 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834', 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name ServicePrincipalType -Value 'Application'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Tags -Value '{WindowsAzureActiveDirectoryIntegratedApp}'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Description -Value 'Submit, review and approve expense reports from any device.'
                    $AADSP | Add-Member -MemberType NoteProperty -Name NotificationEmailAddresses -Value 'certificatealerts@contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name SamlSingleSignOnSettings -Value @{
                        relayState = '/expenses/dashboard'
                    }
                    $AADSP | Add-Member -MemberType NoteProperty -Name TokenEncryptionKeyId -Value 'a7f3c9d1-6e42-4b58-90ac-5d2e1b874f36'
                    $AADSP | Add-Member -MemberType NoteProperty -Name KeyCredentials -Value @{
                        Usage = 'Verify'
                        StartDateTime = '2024-09-25T09:13:11.0000000+00:00'
                        Type = 'AsymmetricX509Cert'
                        KeyId = 'Key ID'
                        EndDateTime = '2025-09-25T09:33:11.0000000+00:00'
                        DisplayName = 'anexas_test_2'
                    }
                    $AADSP | Add-Member -MemberType NoteProperty -Name PasswordCredentials -Value @{
                        KeyId = 'keyid'
                        EndDateTime = '2025-03-15T19:50:29.0310000+00:00'
                        Hint = 'VsO'
                        DisplayName = 'Super Secret'
                        StartDateTime = '2024-09-16T19:50:29.0310000+00:00'
                    }
                    return $AADSP
                }
            }

            It 'Should return Values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaServicePrincipal' -Exactly 1
            }

            It 'Should return true from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppId                     = 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834'
                    DisplayName               = 'App1'
                    AlternativeNames          = 'AlternativeName1', 'AlternativeName2', 'AlternativeName3' #drift
                    AccountEnabled            = $true
                    AppRoleAssignmentRequired = $false
                    ErrorUrl                  = ''
                    Homepage                  = 'https://app1.contoso.com'
                    LoginUrl                  = 'https://app1.contoso.com/login'
                    LogoutUrl                 = 'https://app1.contoso.com/logout'
                    PreferredTokenSigningKeyThumbprint = 'B7E3A19C5D428F06A1C93E7B2054D8F6C3A1E97B'
                    PublisherName             = 'Contoso'
                    ReplyURLs                 = 'https://app1.contoso.com'
                    SamlMetadataURL           = ''
                    ServicePrincipalNames     = 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834', 'https://app1.contoso.com'
                    ServicePrincipalType      = 'Application'
                    Tags                      = '{WindowsAzureActiveDirectoryIntegratedApp}'
                    Description               = 'Submit, review and approve expense reports from any device.'
                    NotificationEmailAddresses = 'certificatealerts@contoso.com'
                    SamlSingleSignOnSettings  = [MSFT_MicrosoftGraphsamlSingleSignOnSettings] @{
                        RelayState = '/expenses/dashboard'
                    }
                    TokenEncryptionKeyId      = 'a7f3c9d1-6e42-4b58-90ac-5d2e1b874f36'
                    PasswordCredentials       = @()
                    KeyCredentials            = @()
                    Ensure                    = 'Present'
                    Credential                = $Credscredential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaServicePrincipal -MockWith {
                    $AADSP = New-Object PSCustomObject
                    $AADSP | Add-Member -MemberType NoteProperty -Name AppId -Value 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Id -Value '5dcb2237-c61b-4258-9c85-eae2aaeba9d6'
                    $AADSP | Add-Member -MemberType NoteProperty -Name AlternativeNames -Value 'AlternativeName1', 'AlternativeName2'
                    $AADSP | Add-Member -MemberType NoteProperty -Name AccountEnabled -Value $true
                    $AADSP | Add-Member -MemberType NoteProperty -Name AppRoleAssignmentRequired -Value $false
                    $AADSP | Add-Member -MemberType NoteProperty -Name ErrorUrl -Value ''
                    $AADSP | Add-Member -MemberType NoteProperty -Name Homepage -Value 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name LoginUrl -Value 'https://app1.contoso.com/login'
                    $AADSP | Add-Member -MemberType NoteProperty -Name LogoutUrl -Value 'https://app1.contoso.com/logout'
                    $AADSP | Add-Member -MemberType NoteProperty -Name PreferredTokenSigningKeyThumbprint -Value 'B7E3A19C5D428F06A1C93E7B2054D8F6C3A1E97B'
                    $AADSP | Add-Member -MemberType NoteProperty -Name PublisherName -Value 'Contoso'
                    $AADSP | Add-Member -MemberType NoteProperty -Name ReplyURLs -Value 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name SamlMetadataURL -Value ''
                    $AADSP | Add-Member -MemberType NoteProperty -Name ServicePrincipalNames -Value 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834', 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name ServicePrincipalType -Value 'Application'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Tags -Value '{WindowsAzureActiveDirectoryIntegratedApp}'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Description -Value 'Submit, review and approve expense reports from any device.'
                    $AADSP | Add-Member -MemberType NoteProperty -Name NotificationEmailAddresses -Value 'certificatealerts@contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name SamlSingleSignOnSettings -Value @{
                        relayState = '/expenses/dashboard'
                    }
                    $AADSP | Add-Member -MemberType NoteProperty -Name TokenEncryptionKeyId -Value 'a7f3c9d1-6e42-4b58-90ac-5d2e1b874f36'
                    $AADSP | Add-Member -MemberType NoteProperty -Name KeyCredentials -Value @{
                        Usage = 'Verify'
                        StartDateTime = '2024-09-25T09:13:11.0000000+00:00'
                        Type = 'AsymmetricX509Cert'
                        KeyId = 'Key ID'
                        EndDateTime = '2025-09-25T09:33:11.0000000+00:00'
                        DisplayName = 'anexas_test_2'
                    }
                    $AADSP | Add-Member -MemberType NoteProperty -Name PasswordCredentials -Value @{
                        KeyId = 'keyid'
                        EndDateTime = '2025-03-15T19:50:29.0310000+00:00'
                        Hint = 'VsO'
                        DisplayName = 'Super Secret'
                        StartDateTime = '2024-09-16T19:50:29.0310000+00:00'
                    }
                    return $AADSP
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaServicePrincipal' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaServicePrincipal' -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaServicePrincipal -MockWith {
                    $AADSP = New-Object PSCustomObject
                    $AADSP | Add-Member -MemberType NoteProperty -Name AppId -Value 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Id -Value '5dcb2237-c61b-4258-9c85-eae2aaeba9d6'
                    $AADSP | Add-Member -MemberType NoteProperty -Name DisplayName -Value 'App1'
                    $AADSP | Add-Member -MemberType NoteProperty -Name AlternativeNames -Value 'AlternativeName1', 'AlternativeName2'
                    $AADSP | Add-Member -MemberType NoteProperty -Name AccountEnabled -Value $true
                    $AADSP | Add-Member -MemberType NoteProperty -Name AppRoleAssignmentRequired -Value $false
                    $AADSP | Add-Member -MemberType NoteProperty -Name ErrorUrl -Value ''
                    $AADSP | Add-Member -MemberType NoteProperty -Name Homepage -Value 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name LoginUrl -Value 'https://app1.contoso.com/login'
                    $AADSP | Add-Member -MemberType NoteProperty -Name LogoutUrl -Value 'https://app1.contoso.com/logout'
                    $AADSP | Add-Member -MemberType NoteProperty -Name PreferredTokenSigningKeyThumbprint -Value 'B7E3A19C5D428F06A1C93E7B2054D8F6C3A1E97B'
                    $AADSP | Add-Member -MemberType NoteProperty -Name PublisherName -Value 'Contoso'
                    $AADSP | Add-Member -MemberType NoteProperty -Name ReplyURLs -Value 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name SamlMetadataURL -Value ''
                    $AADSP | Add-Member -MemberType NoteProperty -Name ServicePrincipalNames -Value 'b4f08c68-7276-4cb8-b9ae-e75fca5ff834', 'https://app1.contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name ServicePrincipalType -Value 'Application'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Tags -Value '{WindowsAzureActiveDirectoryIntegratedApp}'
                    $AADSP | Add-Member -MemberType NoteProperty -Name Description -Value 'Submit, review and approve expense reports from any device.'
                    $AADSP | Add-Member -MemberType NoteProperty -Name NotificationEmailAddresses -Value 'certificatealerts@contoso.com'
                    $AADSP | Add-Member -MemberType NoteProperty -Name SamlSingleSignOnSettings -Value @{
                        relayState = '/expenses/dashboard'
                    }
                    $AADSP | Add-Member -MemberType NoteProperty -Name TokenEncryptionKeyId -Value 'a7f3c9d1-6e42-4b58-90ac-5d2e1b874f36'
                    $AADSP | Add-Member -MemberType NoteProperty -Name KeyCredentials -Value @{
                        Usage = 'Verify'
                        StartDateTime = '2024-09-25T09:13:11.0000000+00:00'
                        Type = 'AsymmetricX509Cert'
                        KeyId = 'Key ID'
                        EndDateTime = '2025-09-25T09:33:11.0000000+00:00'
                        DisplayName = 'anexas_test_2'
                    }
                    $AADSP | Add-Member -MemberType NoteProperty -Name PasswordCredentials -Value @{
                        KeyId = 'keyid'
                        EndDateTime = '2025-03-15T19:50:29.0310000+00:00'
                        Hint = 'VsO'
                        DisplayName = 'Super Secret'
                        StartDateTime = '2024-09-16T19:50:29.0310000+00:00'
                    }
                    return $AADSP
                }
            }

            It 'Should reverse engineer resource from the export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADServicePrincipal' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Should convert a claims policy that carries @odata.type discriminators' {
                Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                    return @(
                        @{
                            id     = '5dcb2237-c61b-4258-9c85-eae2aaeba9d6|ClaimsPolicy'
                            status = 200
                            body   = @{
                                '@odata.context'       = 'https://graph.microsoft.com/beta/$metadata#servicePrincipals'
                                'id'                   = '5dcb2237-c61b-4258-9c85-eae2aaeba9d6'
                                'includeBasicClaimSet' = $true
                                'groupFilter'          = @{
                                    '@odata.type' = '#microsoft.graph.groupClaimFilter'
                                    'type'        = 'prefix'
                                    'matchOn'     = 'samAccountName'
                                    'value'       = 'DSC'
                                }
                                'claims'               = @(
                                    @{
                                        '@odata.type'    = '#microsoft.graph.customClaim'
                                        'name'           = 'employeeid'
                                        'tokenFormat'    = @('saml')
                                        'configurations' = @(
                                            @{
                                                'attribute' = @{
                                                    '@odata.type' = '#microsoft.graph.sourcedAttribute'
                                                    'id'          = 'employeeid'
                                                }
                                            }
                                        )
                                    }
                                )
                            }
                        }
                    )
                }

                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADServicePrincipal' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                $result | Should -Match 'employeeid'
                $result | Should -Match 'groupClaimFilter'
            }
        }

        Context -Name 'AppRoleAssignedTo AppRoleId resolution' -Fixture {
            It 'Should return the matching app role id' {
                $appRoles = @(
                    @{
                        DisplayName = 'Group'
                        Id          = '5dcb2237-c61b-4258-9c85-eae2aaeba9d6'
                    }
                )

                (New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal').GetAppRoleId($appRoles, 'Group') | Should -Be '5dcb2237-c61b-4258-9c85-eae2aaeba9d6'
            }

            It 'Should return the default access app role id when no role matches the principal type' {
                $appRoles = @(
                    @{
                        DisplayName = 'Read.All'
                        Id          = '5dcb2237-c61b-4258-9c85-eae2aaeba9d6'
                    }
                )

                (New-M365DSCResourceInstance -ResourceName 'AADServicePrincipal').GetAppRoleId($appRoles, 'Group') | Should -Be '00000000-0000-0000-0000-000000000000'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
