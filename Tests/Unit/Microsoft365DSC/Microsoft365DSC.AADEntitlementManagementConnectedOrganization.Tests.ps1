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
    -DscResource 'AADEntitlementManagementConnectedOrganization' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Update-MgBetaEntitlementManagementConnectedOrganization -MockWith {
            }

            Mock -CommandName New-MgBetaEntitlementManagementConnectedOrganization -MockWith {
                return @{
                    Id = '12345678-1234-1234-1234-123456789012'
                }
            }

            Mock -CommandName Remove-MgBetaEntitlementManagementConnectedOrganization -MockWith {
            }

            Mock -CommandName New-MgBetaEntitlementManagementConnectedOrganizationExternalSponsorByRef -MockWith {
            }

            Mock -CommandName New-MgBetaEntitlementManagementConnectedOrganizationInternalSponsorByRef -MockWith {
            }

            Mock -CommandName Remove-MgBetaEntitlementManagementConnectedOrganizationExternalSponsorDirectoryObjectByRef -MockWith {
            }

            Mock -CommandName Remove-MgBetaEntitlementManagementConnectedOrganizationInternalSponsorDirectoryObjectByRef -MockWith {
            }

            Mock -CommandName Get-MgBetaEntitlementManagementConnectedOrganizationExternalSponsor -MockWith {
                return @(
                    @{
                        Id = '12345678-1234-1234-1234-123456789012'
                        '@odata.type' = '#microsoft.graph.user'
                        userPrincipalName = 'John.smith@contoso.com'
                    }
                )
            }
            Mock -CommandName Get-MgBetaEntitlementManagementConnectedOrganizationInternalSponsor -MockWith {
                return @(
                    @{
                        Id = '12345678-1234-1234-1234-123456789012'
                        '@odata.type' = '#microsoft.graph.user'
                        userPrincipalName = 'John.smith@contoso.com'
                    }
                )
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }
            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                return @{}
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgUser -ParameterFilter { $UserId -eq '12345678-1234-1234-1234-123456789012' -or $UserId -eq 'John.smith@contoso.com' } -MockWith {
                return @{
                    Id = '12345678-1234-1234-1234-123456789012'
                    UserPrincipalName = 'John.smith@contoso.com'
                }
            }

            Mock -CommandName Get-MgUser -ParameterFilter { $UserId -eq '12345678-1234-1234-1234-12345678903' -or $UserId -eq 'John.Snow@contoso.com' } -MockWith {
                return @{
                    Id = '12345678-1234-1234-1234-12345678903'
                    UserPrincipalName = 'John.Snow@contoso.com'
                }
            }

            Mock -CommandName Get-MgUser -ParameterFilter { $UserId -eq '12345678-1234-1234-1234-234567890123' -or $UserId -eq 'John.Doe@contoso.com' } -MockWith {
                return @{
                    Id = '12345678-1234-1234-1234-234567890123'
                    UserPrincipalName = 'John.Doe@contoso.com'
                }
            }

            Mock -CommandName Get-MgBetaDirectoryObject -ParameterFilter { $DirectoryObjectId -eq '12345678-1234-1234-1234-234567890123' } -MockWith {
                return @{
                    Id                   = '12345678-1234-1234-1234-234567890123'
                    '@odata.type' = '#microsoft.graph.user'
                }
            }

            Mock -CommandName Get-MgBetaDirectoryObject -ParameterFilter { $DirectoryObjectId -eq '12345678-1234-1234-1234-123456789012' } -MockWith {
                return @{
                    Id                   = '12345678-1234-1234-1234-123456789012'
                    '@odata.type' = '#microsoft.graph.user'
                }
            }

            Mock -CommandName Get-MgBetaDirectoryObject -ParameterFilter { $DirectoryObjectId -eq '12345678-1234-1234-1234-12345678903' } -MockWith {
                return @{
                    Id                   = '12345678-1234-1234-1234-12345678903'
                    '@odata.type' = '#microsoft.graph.user'
                }
            }

            Mock -CommandName Get-MgBetaEntitlementManagementConnectedOrganization -MockWith {
                return @{
                    Description     = 'ConnectedOrganization_Description'
                    DisplayName     = 'ConnectedOrganization_DisplayName'
                    Id              = 'ConnectedOrganization_Id'
                    IdentitySources = @(
                        @{
                            '@odata.type' = '#microsoft.graph.azureActiveDirectoryTenant'
                            tenantId      = 'IdentitySource_TenantId'
                            displayName   = 'IdentitySource_DisplayName'
                        }
                    )
                    State           = 'configured'
                }
            }
        }
        # Test contexts
        Context -Name 'The AADEntitlementManagementConnectedOrganization should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description      = 'ConnectedOrganization_Description'
                    DisplayName      = 'ConnectedOrganization_DisplayName'
                    ExternalSponsors = @('John.smith@contoso.com')
                    Id               = 'ConnectedOrganization_Id'
                    IdentitySources  = @(
                        ([MSFT_AADEntitlementManagementConnectedOrganizationIdentitySource] @{
                            ExternalTenantId = 'IdentitySource_TenantId'
                            odataType        = '#microsoft.graph.azureActiveDirectoryTenant'
                            displayName      = 'IdentitySource_DisplayName'
                        })
                    )
                    InternalSponsors = @('John.smith@contoso.com')
                    State            = 'configured'
                    Ensure           = 'Present'
                    Credential       = $Credential
                }

                Mock -CommandName Get-MgBetaEntitlementManagementConnectedOrganization -MockWith {
                    return $null
                }
                Mock -CommandName Get-MgBetaEntitlementManagementConnectedOrganizationExternalSponsor -MockWith {
                    return @()
                }
                Mock -CommandName Get-MgBetaEntitlementManagementConnectedOrganizationInternalSponsor -MockWith {
                    return @()
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementConnectedOrganization' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementConnectedOrganization' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementConnectedOrganization' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaEntitlementManagementConnectedOrganization -Exactly 1
                Should -Invoke -CommandName New-MgBetaEntitlementManagementConnectedOrganizationExternalSponsorByRef -Exactly 1
                Should -Invoke -CommandName New-MgBetaEntitlementManagementConnectedOrganizationInternalSponsorByRef -Exactly 1
            }
        }

        Context -Name 'The AADEntitlementManagementConnectedOrganization exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description      = 'ConnectedOrganization_Description'
                    DisplayName      = 'ConnectedOrganization_DisplayName'
                    ExternalSponsors = @('John.smith@contoso.com')
                    Id               = 'ConnectedOrganization_Id'
                    IdentitySources  = @(
                        ([MSFT_AADEntitlementManagementConnectedOrganizationIdentitySource] @{
                            ExternalTenantId = 'IdentitySource_TenantId'
                            odataType        = '#microsoft.graph.azureActiveDirectoryTenant'
                            displayName      = 'IdentitySource_DisplayName'
                        })
                    )
                    InternalSponsors = @('John.smith@contoso.com')
                    State            = 'configured'
                    Ensure           = 'Absent'
                    Credential       = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementConnectedOrganization' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementConnectedOrganization' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementConnectedOrganization' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaEntitlementManagementConnectedOrganization -Exactly 1
            }
        }
        Context -Name 'The AADEntitlementManagementConnectedOrganization Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description      = 'ConnectedOrganization_Description'
                    DisplayName      = 'ConnectedOrganization_DisplayName'
                    ExternalSponsors = @('John.Smith@contoso.com')
                    Id               = '12345678-1234-1234-1234-123456789012'
                    IdentitySources  = @(
                        ([MSFT_AADEntitlementManagementConnectedOrganizationIdentitySource] @{
                            ExternalTenantId = 'IdentitySource_TenantId'
                            odataType        = '#microsoft.graph.azureActiveDirectoryTenant'
                            displayName      = 'IdentitySource_DisplayName'
                        })
                    )
                    InternalSponsors = @('John.Smith@contoso.com')
                    State            = 'configured'
                    Ensure           = 'Present'
                    Credential       = $Credential
                }
            }
            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementConnectedOrganization' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The AADEntitlementManagementConnectedOrganization exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description      = 'ConnectedOrganization_Description'
                    DisplayName      = 'ConnectedOrganization_DisplayName'
                    ExternalSponsors = @('John.Smith@contoso.com', "John.Snow@contoso.com") # Drift
                    Id               = '12345678-1234-1234-1234-123456789012'
                    IdentitySources  = @(
                        ([MSFT_AADEntitlementManagementConnectedOrganizationIdentitySource] @{
                            ExternalTenantId = 'IdentitySource_TenantId'
                            odataType        = '#microsoft.graph.azureActiveDirectoryTenant'
                            displayName      = 'IdentitySource_DisplayName'
                        })
                    )
                    InternalSponsors = @('John.Smith@contoso.com')
                    State            = 'configured'
                    Ensure           = 'Present'
                    Credential       = $Credential
                }

                Mock -CommandName Get-MgBetaEntitlementManagementConnectedOrganizationExternalSponsor -MockWith {
                    return @(
                        @{
                            Id = '12345678-1234-1234-1234-123456789012'
                            '@odata.type' = '#microsoft.graph.user'
                            userPrincipalName = 'John.Smith@contoso.com'
                        },
                        @{
                            Id = '12345678-1234-1234-1234-234567890123' #Drift
                            '@odata.type' = '#microsoft.graph.user'
                            userPrincipalName = 'John.doe@contoso.com'
                        }
                    )
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementConnectedOrganization' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementConnectedOrganization' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementConnectedOrganization' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaEntitlementManagementConnectedOrganization -Exactly 1
                Should -Invoke -CommandName Remove-MgBetaEntitlementManagementConnectedOrganizationExternalSponsorDirectoryObjectByRef -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADEntitlementManagementConnectedOrganization' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
