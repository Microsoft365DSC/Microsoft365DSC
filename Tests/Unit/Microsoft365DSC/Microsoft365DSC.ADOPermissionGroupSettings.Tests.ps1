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

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Invoke-M365DSCAzureDevOPSWebRequest -ParameterFilter { $Uri -like "*groups*" } -MockWith {
                return @{
                    value = @(
                        @{
                            principalName = "[O365DSC-DEV]\My Test Group"
                            Descriptor    = "vssgp.Uy0xLTktMTU1MTM3NDI0NS0yNzEyNzI0MzgtMzkwMDMyNjIxNC0yMTgxNjI3NzQwLTkxMDg0NDI0NC0xLTgyODcyNzAzNC0yOTkzNjA0MTcxLTI5MjUwMjk4ODgtNTY0MDg1OTcy";
                        }
                    )
                }
            }

            Mock -CommandName Invoke-M365DSCAzureDevOPSWebRequest -ParameterFilter { $Uri -like "*identities*" } -MockWith {
                return @{
                    value = @{
                        id = "FakeStringValue"
                        subjectDescriptor = "vssgp.Uy0xLTktMTU1MTM3NDI0NS0yNzEyNzI0MzgtMzkwMDMyNjIxNC0yMTgxNjI3NzQwLTkxMDg0NDI0NC0xLTgyODcyNzAzNC0yOTkzNjA0MTcxLTI5MjUwMjk4ODgtNTY0MDg1OTcy"
                        descriptor = "Microsoft.TeamFoundation.Identity;S-1-9-1234567890-3479028130-1841756239-2951999137-3860724248-0-0-0-0-3"
                    }
                }
            }

            Mock -CommandName Invoke-M365DSCAzureDevOPSWebRequest -ParameterFilter { $Uri -like "*securitynamespaces*" } -MockWith {
                return @{
                    value = @{
                        namespaceId = "5a27515b-ccd7-42c9-84f1-54c998f03866"
                        name = "Analytics"
                        displayName = "Analytics"
                        actions = @(
                            @{
                                bit = 2
                                name = "Administer"
                                displayName = "Edit identity information"
                                namespaceId = "5a27515b-ccd7-42c9-84f1-54c998f03866"
                            }
                            @{
                                bit = 8
                                name = "ExecuteUnrestrictedQuery"
                                displayName = "Execute query without any restrictions on the query form"
                                namespaceId = "5a27515b-ccd7-42c9-84f1-54c998f03866"
                            }
                        )
                    }
                }
            }

            Mock -CommandName Invoke-M365DSCAzureDevOPSWebRequest -ParameterFilter { $Uri -like "*accesscontrollists*" } -MockWith {
                return @{
                    value = @(
                        @{
                            acesDictionary = @{
                                "Microsoft.TeamFoundation.Identity;S-1-9-1234567890-3479028130-1841756239-2951999137-3860724248-0-0-0-0-3" = @{
                                    descriptor = "Microsoft.TeamFoundation.Identity;S-1-9-1234567890-3479028130-1841756239-2951999137-3860724248-0-0-0-0-3"
                                    Allow = 2
                                    Deny  = 0
                                }
                            }
                            token = "f6492b10-7ae8-4641-8208-ff5c364a6154\dbe6034e-8fbe-4d6e-a7f3-07a7e70816c9"
                        }
                    )
                }
            }

            Mock -CommandName Invoke-M365DSCAzureDevOPSWebRequest -ParameterFilter { $Uri -like "*profiles/me*" } -MockWith {
                return @{
                    id = "FakeStringValue"
                    displayName = "My Test Group"
                }
            }

            Mock -CommandName Invoke-M365DSCAzureDevOPSWebRequest -ParameterFilter { $Uri -like "*&memberId=FakeStringValue*" } -MockWith {
                return @{
                    value = @(
                        @{
                            accountName = "[O365DSC-DEV]\My Test Group"
                        }
                    )
                }
            }

            Mock -CommandName Invoke-M365DSCAzureDevOPSWebRequest -MockWith {
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
                    AllowPermissions     = @(
                        ([MSFT_ADOPermission] @{
                            NamespaceId = '5a27515b-ccd7-42c9-84f1-54c998f03866'
                            DisplayName = 'Edit identity information'
                            Bit         = 2
                            Token       = 'f6492b10-7ae8-4641-8208-ff5c364a6154\dbe6034e-8fbe-4d6e-a7f3-07a7e70816c9'
                        })
                    );
                    Credential           = $Credential;
                    DenyPermissions      = @();
                    Descriptor           = "vssgp.Uy0xLTktMTU1MTM3NDI0NS0yNzEyNzI0MzgtMzkwMDMyNjIxNC0yMTgxNjI3NzQwLTkxMDg0NDI0NC0xLTgyODcyNzAzNC0yOTkzNjA0MTcxLTI5MjUwMjk4ODgtNTY0MDg1OTcy";
                    GroupName            = "[O365DSC-DEV]\My Test Group";
                    OrganizationName     = "O365DSC-DEV";
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'ADOPermissionGroupSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowPermissions     = @(
                        ([MSFT_ADOPermission] @{
                            NamespaceId = '5a27515b-ccd7-42c9-84f1-54c998f03866'
                            DisplayName = 'Edit identity information'
                            Bit         = 8 # Drift
                            Token       = 'f6492b10-7ae8-4641-8208-ff5c364a6154\dbe6034e-8fbe-4d6e-a7f3-07a7e70816c9'
                        })
                    );
                    Credential           = $Credential;
                    DenyPermissions      = @();
                    Descriptor           = "vssgp.Uy0xLTktMTU1MTM3NDI0NS0yNzEyNzI0MzgtMzkwMDMyNjIxNC0yMTgxNjI3NzQwLTkxMDg0NDI0NC0xLTgyODcyNzAzNC0yOTkzNjA0MTcxLTI5MjUwMjk4ODgtNTY0MDg1OTcy";
                    GroupName            = "[O365DSC-DEV]\My Test Group";
                    OrganizationName     = "O365DSC-DEV";
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'ADOPermissionGroupSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'ADOPermissionGroupSettings' -Property $testParams).Set()
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'ADOPermissionGroupSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
