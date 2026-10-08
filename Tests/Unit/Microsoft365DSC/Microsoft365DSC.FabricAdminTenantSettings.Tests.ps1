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

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource $ResourceName -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "ServicePrincipalWithThumbprint"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    AADSSOForGateway                                                      = ([MSFT_FabricTenantSetting] @{
                        settingName              = 'AADSSOForGateway'
                        canSpecifySecurityGroups = $False
                        enabled                  = $True
                        tenantSettingGroup       = 'Integration settings'
                        title                    = 'Microsoft Entra single sign-on for data gateway'
                    });
                    AdminApisIncludeDetailedMetadata                                      = ([MSFT_FabricTenantSetting] @{
                            settingName              = 'AdminApisIncludeDetailedMetadata'
                            canSpecifySecurityGroups = $True
                            enabled                  = $True
                            tenantSettingGroup       = 'Admin API settings'
                            title                    = 'Enhance admin APIs responses with detailed metadata'
                            excludedSecurityGroups   = @('MyExcludedGroup')
                            enabledSecurityGroups    = @('Group1','Group2')
                    })
                    ApplicationId         = (New-GUID).ToString()
                    TenantId              = 'contoso.onmicrosoft.com'
                    CertificateThumbprint = (New-GUID).ToString()
                }

                Mock -CommandName Invoke-M365DSCFabricWebRequest -MockWith {
                    return @{
                        tenantSettings = @(
                            @{
                                settingName = 'AADSSOForGateway'
                                canSpecifySecurityGroups = $False
                                enabled                  = $True
                                tenantSettingGroup       = 'Integration settings'
                                title                    = 'Microsoft Entra single sign-on for data gateway'
                            },
                            @{
                                settingName = 'AdminApisIncludeDetailedMetadata'
                                tenantSettingGroup       = 'Admin API settings'
                                title                    = 'Enhance admin APIs responses with detailed metadata'
                                canSpecifySecurityGroups = $True
                                enabled                  = $True
                                excludedSecurityGroups   = @(
                                    @{
                                        Name = "MyExcludedGroup"
                                    }
                                )
                                enabledSecurityGroups    = @(
                                    @{
                                        Name = "Group1"
                                    },
                                    @{
                                        Name = "Group2"
                                    }
                                )
                            }
                        )
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'FabricAdminTenantSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    AADSSOForGateway                                                      = ([MSFT_FabricTenantSetting] @{
                        settingName              = 'AADSSOForGateway'
                        canSpecifySecurityGroups = $False
                        enabled                  = $True
                        tenantSettingGroup       = 'Integration settings'
                        title                    = 'Microsoft Entra single sign-on for data gateway'
                    });
                    AdminApisIncludeDetailedMetadata                                      = ([MSFT_FabricTenantSetting] @{
                            settingName              = 'AdminApisIncludeDetailedMetadata'
                            canSpecifySecurityGroups = $True
                            enabled                  = $True
                            tenantSettingGroup       = 'Admin API settings'
                            title                    = 'Enhance admin APIs responses with detailed metadata'
                            excludedSecurityGroups   = @('MyExcludedGroup')
                            enabledSecurityGroups    = @('Group1','Group4') # Drift
                    })
                    ApplicationId         = (New-GUID).ToString()
                    TenantId              = 'contoso.onmicrosoft.com'
                    CertificateThumbprint = (New-GUID).ToString()
                }

                Mock -CommandName Invoke-M365DSCFabricWebRequest -MockWith {
                    return @{
                        tenantSettings = @(
                            @{
                                settingName = 'AADSSOForGateway'
                                canSpecifySecurityGroups = $False
                                enabled                  = $True
                                tenantSettingGroup       = 'Integration settings'
                                title                    = 'Microsoft Entra single sign-on for data gateway'
                            },
                            @{
                                settingName = 'AdminApisIncludeDetailedMetadata'
                                tenantSettingGroup       = 'Admin API settings'
                                title                    = 'Enhance admin APIs responses with detailed metadata'
                                excludedSecurityGroups   = @(
                                    @{
                                        Name = "MyExcludedGroup"
                                    }
                                )
                                enabledSecurityGroups    = @(
                                    @{
                                        Name = "Group1"
                                    },
                                    @{
                                        Name = "Group2"
                                    }
                                )
                            }
                        )
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'FabricAdminTenantSettings' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    ApplicationId         = (New-GUID).ToString()
                    TenantId              = 'contoso.onmicrosoft.com'
                    CertificateThumbprint = (New-GUID).ToString()
                }

                Mock -CommandName Invoke-M365DSCFabricWebRequest -MockWith {
                    return @{
                        tenantSettings = @(
                            @{
                                settingName = 'AADSSOForGateway'
                                canSpecifySecurityGroups = $False
                                enabled                  = $True
                                tenantSettingGroup       = 'Integration settings'
                                title                    = 'Microsoft Entra single sign-on for data gateway'
                            },
                            @{
                                settingName = 'AdminApisIncludeDetailedMetadata'
                                tenantSettingGroup       = 'Admin API settings'
                                title                    = 'Enhance admin APIs responses with detailed metadata'
                                excludedSecurityGroups   = @(
                                    @{
                                        Name = "MyExcludedGroup"
                                    }
                                )
                                enabledSecurityGroups    = @(
                                    @{
                                        Name = "Group1"
                                    },
                                    @{
                                        Name = "Group4" # Drift
                                    }
                                )
                            }
                        )
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'FabricAdminTenantSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
