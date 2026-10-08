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
    -DscResource 'SCDLPCompliancePolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Import-PSSession -MockWith {
            }

            Mock -CommandName New-PSSession -MockWith {
            }

            Mock -CommandName Remove-DLPCompliancePolicy -MockWith {
            }

            Mock -CommandName New-DLPCompliancePolicy -MockWith {
                return @{

                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Policy doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure             = 'Present'
                    Credential         = $Credential
                    Priority           = 1
                    SharePointLocation = 'https://contoso.sharepoint.com/sites/demo'
                    Name               = 'TestPolicy'
                }

                Mock -CommandName Get-DLPCompliancePolicy -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPCompliancePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCDLPCompliancePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'

                Mock -CommandName Get-DLPCompliancePolicy -MockWith {
                    return @{
                        Name = 'TestPolicy'
                        Mode = 'PendingDeletion'
                    }
                }
                ((New-M365DSCResourceInstance -ResourceName 'SCDLPCompliancePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPCompliancePolicy' -Property $testParams).Set()
            }
        }

        Context -Name 'Policy already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure             = 'Present'
                    Credential         = $Credential
                    Priority           = 1
                    Mode               = 'Enable'
                    SharePointLocation = @('https://contoso.sharepoint.com/sites/demo')
                    Name               = 'TestPolicy'
                }

                Mock -CommandName Get-DLPCompliancePolicy -MockWith {
                    return @{
                        Name               = 'TestPolicy'
                        Priority           = 1
                        Mode               = 'Enable'
                        SharePointLocation = @(
                            @{
                                Name = 'https://contoso.sharepoint.com/sites/demo'
                            }
                        )
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPCompliancePolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should recreate from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPCompliancePolicy' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCDLPCompliancePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Policy should not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure             = 'Absent'
                    Credential         = $Credential
                    SharePointLocation = 'https://contoso.sharepoint.com/sites/demo'
                    Name               = 'TestPolicy'
                }

                Mock -CommandName Get-DLPCompliancePolicy -MockWith {
                    return @{
                        Name = 'TestPolicy'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPCompliancePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should delete from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPCompliancePolicy' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCDLPCompliancePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Policy Exists but Needs to Update Settings' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                    SharePointLocation          = @('https://contoso.sharepoint.com/sites/demo', 'https://northwind.com')
                    SharePointLocationException = @('https://contoso.sharepoint.com/sites/ex', 'https://northwind.com/ex')
                    OneDriveLocation            = @('https://contoso.sharepoint.com/sites/demo', 'https://northwind.com')
                    ExchangeLocation            = @('https://owa.contoso.com')
                    OneDriveLocationException   = @('https://tailspin.com/sites/', 'https://tailspin.com/od')
                    TeamsLocation               = @('john.smith@contoso.com', 'jane.doe@contoso.com')
                    TeamsLocationException      = @('https://contoso.sharepoint.com/sites/ex', 'https://northwind.com/ex')
                    Name                        = 'TestPolicy'
                }

                Mock -CommandName Get-DLPCompliancePolicy -MockWith {
                    return @{
                        Name                        = 'TestPolicy'
                        ExchangeLocation            = @('https://owa.tailspin.com')
                        SharePointLocation          = @(
                            @{
                                Name = 'https://contoso.sharepoint.com/sites/demo'
                            },
                            @{
                                Name = 'https://tailspin.com'
                            }
                        )
                        SharePointLocationException = @('https://contoso.sharepoint.com/od', 'https://northwind.com/ex')
                        OneDriveLocation            = @(
                            @{
                                Name = 'https://contoso.sharepoint.com/sites/demo'
                            },
                            @{
                                Name = 'https://tailspin.com'
                            }
                        )
                        OneDriveLocationException   = @('https://tailspin.com/sites/', 'https://tailspin.com')
                        TeamsLocation               = @(
                            @{
                                Name = 'john.smith@contoso.com'
                            },
                            @{
                                Name = 'bob.houle@contoso.com'
                            }
                        )
                        TeamsLocationException      = @('https://tailspin.com/sites/', 'https://tailspin.com')
                    }
                }
            }

            It 'Should update location from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPCompliancePolicy' -Property $testParams).Set()
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-DLPCompliancePolicy -MockWith {
                    return @{
                        Name                        = 'TestPolicy'
                        ExchangeLocation            = @('https://owa.tailspin.com')
                        SharePointLocation          = @(
                            @{
                                Name = 'https://contoso.sharepoint.com/sites/demo'
                            },
                            @{
                                Name = 'https://tailspin.com'
                            }
                        )
                        SharePointLocationException = @('https://contoso.sharepoint.com/od', 'https://northwind.com/ex')
                        OneDriveLocation            = @(
                            @{
                                Name = 'https://contoso.sharepoint.com/sites/demo'
                            },
                            @{
                                Name = 'https://tailspin.com'
                            }
                        )
                        OneDriveLocationException   = @('https://tailspin.com/sites/', 'https://tailspin.com')
                        TeamsLocation               = @(
                            @{
                                Name = 'john.smith@contoso.com'
                            },
                            @{
                                Name = 'bob.houle@contoso.com'
                            }
                        )
                        TeamsLocationException      = @('https://tailspin.com/sites/', 'https://tailspin.com')
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCDLPCompliancePolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
