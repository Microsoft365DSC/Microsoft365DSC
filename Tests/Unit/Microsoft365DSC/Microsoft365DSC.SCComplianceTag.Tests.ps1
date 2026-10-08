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
    -DscResource 'SCComplianceTag' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Import-PSSession -MockWith {
            }

            Mock -CommandName New-PSSession -MockWith {
            }

            Mock -CommandName Remove-ComplianceTag -MockWith {
                return @{

                }
            }

            Mock -CommandName New-ComplianceTag -MockWith {
                return @{

                }
            }

            Mock -CommandName Set-ComplianceTag -MockWith {
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
        Context -Name "Rule doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name              = 'TestRule'
                    Comment           = 'This is a test Rule'
                    RetentionAction   = 'Keep'
                    RetentionDuration = '1025'
                    FilePlanProperty  = ([MSFT_SCFilePlanProperty] @{
                            FilePlanPropertyDepartment = 'Legal'
                        })
                    Credential        = $Credential
                    RetentionType     = 'ModificationAgeInDays'
                    Ensure            = 'Present'
                }

                Mock -CommandName Get-ComplianceTag -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceTag' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCComplianceTag' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceTag' -Property $testParams).Set()
            }
        }

        Context -Name 'Rule already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name              = 'TestRule'
                    Comment           = 'This is a test Rule'
                    RetentionAction   = 'Keep'
                    RetentionDuration = '1025'
                    FilePlanProperty  = ([MSFT_SCFilePlanProperty] @{
                            FilePlanPropertyDepartment  = 'DemoDept'
                            FilePlanPropertyCitation    = 'DemoCit'
                            FilePlanPropertyReferenceId = 'DemoRef'
                            FilePlanPropertyAuthority   = 'DemoAuth'
                            FilePlanPropertyCategory    = 'DemoCat'
                            FilePlanPropertySubcategory = 'DemoSub'
                        })
                    Credential        = $Credential
                    RetentionType     = 'ModificationAgeInDays'
                    Ensure            = 'Present'
                }

                Mock -CommandName Get-ComplianceTag -MockWith {
                    return @{
                        Name              = 'TestRule'
                        Comment           = 'This is a test Rule'
                        RetentionAction   = 'Keep'
                        RetentionDuration = '1025'
                        FilePlanMetadata  = '{"Settings":[
                            {"Key":"FilePlanPropertyDepartment","Value":"DemoDept"},
                            {"Key":"FilePlanPropertyCitation","Value":"DemoCit"},
                            {"Key":"FilePlanPropertyReferenceId","Value":"DemoRef"},
                            {"Key":"FilePlanPropertyAuthority","Value":"DemoAuth"},
                            {"Key":"FilePlanPropertyCategory","Value":"DemoCat"},
                            {"Key":"FilePlanPropertySubcategory","Value":"DemoSub"}]}'
                        RetentionType     = 'ModificationAgeInDays'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceTag' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should update from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceTag' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCComplianceTag' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Rule should not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure            = 'Absent'
                    Name              = 'TestRule'
                    Comment           = 'This is a test Rule'
                    RetentionAction   = 'Keep'
                    FilePlanProperty  = ([MSFT_SCFilePlanProperty] @{
                            FilePlanPropertyDepartment = 'Legal'
                        })
                    RetentionDuration = '1025'
                    Credential        = $Credential
                    RetentionType     = 'ModificationAgeInDays'
                }

                Mock -CommandName Get-ComplianceTag -MockWith {
                    return @{
                        Name              = 'TestRule'
                        Comment           = 'This is a test Rule'
                        RetentionAction   = 'Keep'
                        RetentionDuration = '1025'
                        FilePlanMetadata  = '{"Settings":[
                            {"Key":"FilePlanPropertyDepartment","Value":"DemoDept"},
                            {"Key":"FilePlanPropertyCitation","Value":"DemoCit"},
                            {"Key":"FilePlanPropertyReferenceId","Value":"DemoRef"},
                            {"Key":"FilePlanPropertyAuthority","Value":"DemoAuth"},
                            {"Key":"FilePlanPropertyCategory","Value":"DemoCat"},
                            {"Key":"FilePlanPropertySubcategory","Value":"DemoSub"}]}'
                        RetentionType     = 'ModificationAgeInDays'
                    }
                }
            }

            It 'Should return False from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceTag' -Property $testParams).Test() | Should -Be $False
            }

            It 'Should delete from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCComplianceTag' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-ComplianceTag -Exactly 1
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCComplianceTag' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-ComplianceTag -MockWith {
                    return @{
                        Name              = 'TestRule'
                        Comment           = 'This is a test Rule'
                        RetentionAction   = 'Keep'
                        RetentionDuration = '1025'
                        FilePlanMetadata  = '{"Settings":[
                            {"Key":"FilePlanPropertyDepartment","Value":"DemoDept"},
                            {"Key":"FilePlanPropertyCitation","Value":"DemoCit"},
                            {"Key":"FilePlanPropertyReferenceId","Value":"DemoRef"},
                            {"Key":"FilePlanPropertyAuthority","Value":"DemoAuth"},
                            {"Key":"FilePlanPropertyCategory","Value":"DemoCat"},
                            {"Key":"FilePlanPropertySubcategory","Value":"DemoSub"}]}'
                        RetentionType     = 'ModificationAgeInDays'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCComplianceTag' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
