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
    -DscResource 'AADEntitlementManagementAccessPackageCatalogResource' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-MgBetaEntitlementManagementAccessPackageResourceRequest -MockWith {
            }

            Mock -CommandName Get-MgBetaEntitlementManagementAccessPackageCatalog -MockWith {
                return @{
                    id          = 'f34c2d92-9e9d-4703-ba9b-955b6ac8dcb3'
                    displayName = 'MyCatalog'
                }
            }

            Mock -CommandName Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResource -MockWith {
                return @{
                    AddedBy             = 'myAdmin'
                    AddedOn             = '25/10/2022 18:47:28'
                    CatalogId           = 'f34c2d92-9e9d-4703-ba9b-955b6ac8dcb3'
                    Description         = 'https://001q1.sharepoint.com/'
                    DisplayName         = 'Communication site'
                    Id                  = '6a636d76-5025-44d4-9a80-78618f00c16d'
                    IsPendingOnboarding = $False
                    ManagedIdentity     = $False
                    OriginId            = 'https://001q1.sharepoint.com/'
                    OriginSystem        = 'SharePointOnline'
                    ResourceType        = 'SharePoint Online Site'
                    Url                 = 'https://001q1.sharepoint.com/'
                }
            }

            Mock -CommandName Get-MgBetaEntitlementManagementAccessPackageCatalog -MockWith {
                return @(
                    @{
                        Id = 'f34c2d92-9e9d-4703-ba9b-955b6ac8dcb3'
                        displayName = 'MyCatalog'
                    }
                )
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The AADEntitlementManagementAccessPackageCatalogResource should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AddedBy             = 'myAdmin'
                    AddedOn             = '25/10/2022 18:47:28'
                    CatalogId           = 'MyCatalog'
                    Description         = 'https://001q1.sharepoint.com/'
                    DisplayName         = 'Communication site'
                    Id                  = '6a636d76-5025-44d4-9a80-78618f00c16d'
                    IsPendingOnboarding = $False
                    ManagedIdentity     = $False
                    OriginId            = 'https://001q1.sharepoint.com/'
                    OriginSystem        = 'SharePointOnline'
                    ResourceType        = 'SharePoint Online Site'
                    Url                 = 'https://001q1.sharepoint.com/'
                    Ensure              = 'Present'
                    Credential          = $Credential
                }

                Mock -CommandName Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResource -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaEntitlementManagementAccessPackageResourceRequest -Exactly 1
            }
        }

        Context -Name 'The AADEntitlementManagementAccessPackageCatalogResource exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Communication site'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.CatalogId | Should -Be 'MyCatalog'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaEntitlementManagementAccessPackageResourceRequest -Exactly 1 -ParameterFilter {
                    $BodyParameter.requestType -eq 'AdminRemove' -and
                    $BodyParameter.catalogId -eq 'f34c2d92-9e9d-4703-ba9b-955b6ac8dcb3' -and
                    $BodyParameter.accessPackageResource.id -eq '6a636d76-5025-44d4-9a80-78618f00c16d'
                }
            }
        }

        Context -Name 'The AADEntitlementManagementAccessPackageCatalogResource Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AddedBy             = 'myAdmin'
                    AddedOn             = '25/10/2022 18:47:28'
                    CatalogId           = 'MyCatalog'
                    Description         = 'https://001q1.sharepoint.com/'
                    DisplayName         = 'Communication site'
                    Ensure              = 'Present'
                    Id                  = '6a636d76-5025-44d4-9a80-78618f00c16d'
                    IsPendingOnboarding = $False
                    ManagedIdentity     = $False
                    OriginId            = 'https://001q1.sharepoint.com/'
                    OriginSystem        = 'SharePointOnline'
                    ResourceType        = 'SharePoint Online Site'
                    Url                 = 'https://001q1.sharepoint.com/'
                    Credential          = $Credential
                }
            }

            It 'Should return the catalog display name from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Get().ToHashtable()).CatalogId | Should -Be 'MyCatalog'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The AADEntitlementManagementAccessPackageCatalogResource is referenced by catalog id and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AddedBy             = 'myAdmin'
                    AddedOn             = '25/10/2022 18:47:28'
                    CatalogId           = 'f34c2d92-9e9d-4703-ba9b-955b6ac8dcb3'
                    Description         = 'https://001q1.sharepoint.com/'
                    DisplayName         = 'Communication site'
                    Ensure              = 'Present'
                    Id                  = '6a636d76-5025-44d4-9a80-78618f00c16d'
                    IsPendingOnboarding = $false
                    ManagedIdentity     = $false
                    OriginId            = 'https://001q1.sharepoint.com/'
                    OriginSystem        = 'SharePointOnline'
                    ResourceType        = 'SharePoint Online Site'
                    Url                 = 'https://001q1.sharepoint.com/'
                    Credential          = $Credential
                }
            }

            It 'Should return the catalog id from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Get().ToHashtable()).CatalogId | Should -Be 'f34c2d92-9e9d-4703-ba9b-955b6ac8dcb3'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The AADEntitlementManagementAccessPackageCatalogResource is identified by object id and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AddedBy             = 'myAdmin'
                    AddedOn             = '25/10/2022 18:47:28'
                    CatalogId           = 'MyCatalog'
                    Description         = 'Marketing Team'
                    DisplayName         = 'Marketing Team'
                    Ensure              = 'Present'
                    Id                  = '6a636d76-5025-44d4-9a80-78618f00c16d'
                    IsPendingOnboarding = $false
                    ManagedIdentity     = $false
                    OriginId            = '9ba7bd2f-8d0f-4c3a-96f5-9e5eab7b7a1d'
                    OriginSystem        = 'AadGroup'
                    ResourceType        = 'Security group'
                    Url                 = 'https://myaccess.microsoft.com/'
                    Credential          = $Credential
                }

                Mock -CommandName Get-M365DSCAccessPackageResourceOriginDisplayName -MockWith {
                    if ($OriginId -eq '9ba7bd2f-8d0f-4c3a-96f5-9e5eab7b7a1d' -and $OriginSystem -eq 'AadGroup')
                    {
                        return 'Marketing Team'
                    }

                    return $OriginId
                }

                Mock -CommandName Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResource -MockWith {
                    return @{
                        AddedBy             = 'myAdmin'
                        AddedOn             = '25/10/2022 18:47:28'
                        CatalogId           = 'f34c2d92-9e9d-4703-ba9b-955b6ac8dcb3'
                        Description         = 'Marketing Team'
                        DisplayName         = 'Marketing Team'
                        Id                  = '6a636d76-5025-44d4-9a80-78618f00c16d'
                        IsPendingOnboarding = $false
                        ManagedIdentity     = $false
                        OriginId            = '9ba7bd2f-8d0f-4c3a-96f5-9e5eab7b7a1d'
                        OriginSystem        = 'AadGroup'
                        ResourceType        = 'Security group'
                        Url                 = 'https://myaccess.microsoft.com/'
                    }
                }
            }

            It 'Should return the group display name from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Get().ToHashtable()).OriginId | Should -Be 'Marketing Team'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The AADEntitlementManagementAccessPackageCatalogResource exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AddedBy             = 'myAdmin'
                    AddedOn             = '25/10/2022 18:47:28'
                    CatalogId           = 'MyCatalog'
                    Description         = 'https://001q2.sharepoint.com/' # Drift
                    DisplayName         = 'Communication site'
                    Ensure              = 'Present'
                    Id                  = '6a636d76-5025-44d4-9a80-78618f00c16d'
                    IsPendingOnboarding = $False
                    ManagedIdentity     = $False
                    OriginId            = 'https://001q2.sharepoint.com/' # Drift
                    OriginSystem        = 'SharePointOnline'
                    ResourceType        = 'SharePoint Online Site'
                    Url                 = 'https://001q2.sharepoint.com/' # Drift
                    Credential          = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaEntitlementManagementAccessPackageResourceRequest -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADEntitlementManagementAccessPackageCatalogResource' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
