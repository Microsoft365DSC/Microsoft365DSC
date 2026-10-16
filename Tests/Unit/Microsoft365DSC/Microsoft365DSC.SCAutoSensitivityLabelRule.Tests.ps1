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
    -DscResource 'SCAutoSensitivityLabelRule' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Remove-AutoSensitivityLabelRule -MockWith {
            }

            Mock -CommandName New-AutoSensitivityLabelRule -MockWith {
                return @{

                }
            }

            Mock -CommandName Set-AutoSensitivityLabelRule -MockWith {
                return @{

                }
            }

            Mock -CommandName Get-AutoSensitivityLabelPolicy -MockWith {
                return @{
                    ApplySensitivityLabel = 'TopSecret'
                    Comment               = 'Test'
                    ExchangeLocation      = @('All')
                    Mode                  = 'Enable'
                    Name                  = 'TestPolicy'
                    Priority              = 0
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Rule doesn't already exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Comment                             = 'Detects when 1 to 9 credit card numbers are contained in Exchange items'
                    Credential                          = $Credential
                    Disabled                            = $False
                    DocumentIsPasswordProtected         = $False
                    DocumentIsUnsupported               = $False
                    Ensure                              = 'Present'
                    ExceptIfDocumentIsPasswordProtected = $False
                    ExceptIfDocumentIsUnsupported       = $False
                    ExceptIfHeaderMatchesPatterns       = [MSFT_SCHeaderPattern] @{ Name = 'X-Contoso-Approval'; Value = 'Approved' }
                    ExceptIfProcessingLimitExceeded     = $False
                    HeaderMatchesPatterns               = [MSFT_SCHeaderPattern] @{ Name = 'X-Contoso-Classification'; Value = 'Restricted|Payment-Data' }
                    Name                                = 'TestRule'
                    Policy                              = 'TestPolicy'
                    ProcessingLimitExceeded             = $False
                    ReportSeverityLevel                 = 'Low'
                    Workload                            = 'Exchange'
                    ContentContainsSensitiveInformation = ([MSFT_SCDLPContainsSensitiveInformation] @{
                            SensitiveInformation = @([MSFT_SCDLPSensitiveInformation] @{
                                    name           = 'ABA Routing Number'
                                    id             = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'
                                    maxconfidence  = '100'
                                    minconfidence  = '75'
                                    classifiertype = 'Content'
                                    mincount       = '1'
                                    maxcount       = '-1'
                                })
                        })
                }

                Mock -CommandName Get-AutoSensitivityLabelRule -MockWith {
                    return @{
                        Name = 'TestRule'
                        Mode = 'PendingDeletion'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-AutoSensitivityLabelRule -Exactly 1 -ParameterFilter {
                    $HeaderMatchesPatterns['X-Contoso-Classification'] -eq 'Restricted|Payment-Data' -and
                    $ExceptIfHeaderMatchesPatterns['X-Contoso-Approval'] -eq 'Approved'
                }
            }
        }

        Context -Name 'Rule already exists and is in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AnyOfRecipientAddressMatchesPatterns = '^[a-z]+\.[a-z]+@contoso\.com'
                    Comment                              = 'Detects when 1 to 9 credit card numbers are contained in Exchange items'
                    Credential                           = $Credential
                    Disabled                             = $False
                    DocumentIsPasswordProtected          = $False
                    DocumentIsUnsupported                = $False
                    Ensure                               = 'Present'
                    ExceptIfDocumentIsPasswordProtected  = $False
                    ExceptIfDocumentIsUnsupported        = $False
                    ExceptIfHeaderMatchesPatterns        = [MSFT_SCHeaderPattern] @{ Name = 'X-Contoso-Approval'; Value = 'Approved' }
                    ExceptIfProcessingLimitExceeded      = $False
                    HeaderMatchesPatterns                = [MSFT_SCHeaderPattern] @{ Name = 'X-Contoso-Classification'; Value = 'Restricted|Payment-Data' }
                    Name                                 = 'TestRule'
                    Policy                               = 'TestPolicy'
                    ProcessingLimitExceeded              = $False
                    ReportSeverityLevel                  = 'Low'
                    Workload                             = 'Exchange'
                    ContentContainsSensitiveInformation  = ([MSFT_SCDLPContainsSensitiveInformation] @{
                            SensitiveInformation = @([MSFT_SCDLPSensitiveInformation] @{
                                    name           = 'ABA Routing Number'
                                    id             = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'
                                    maxconfidence  = '100'
                                    minconfidence  = '75'
                                    classifiertype = 'Content'
                                    mincount       = '1'
                                    maxcount       = '-1'
                                })
                        })
                }

                Mock -CommandName Get-AutoSensitivityLabelRule -MockWith {
                    return @{
                        AnyOfRecipientAddressMatchesPatterns = [System.Collections.ArrayList] @('^[a-z]+\.[a-z]+@contoso\.com')
                        Comment                              = 'Detects when 1 to 9 credit card numbers are contained in Exchange items'
                        Disabled                             = $False
                        DocumentIsPasswordProtected          = $False
                        DocumentIsUnsupported                = $False
                        ExceptIfDocumentIsPasswordProtected  = $False
                        ExceptIfDocumentIsUnsupported        = $False
                        ExceptIfHeaderMatchesPatterns        = @{ 'X-Contoso-Approval' = 'Approved' }
                        ExceptIfProcessingLimitExceeded      = $False
                        HeaderMatchesPatterns                = @{ 'X-Contoso-Classification' = 'Restricted|Payment-Data' }
                        Name                                 = 'TestRule'
                        ParentPolicyName                     = 'TestPolicy'
                        ProcessingLimitExceeded              = $False
                        ReportSeverityLevel                  = 'Low'
                        Workload                             = 'Exchange'
                        ContentContainsSensitiveInformation  = @(@{maxconfidence = '100'; id = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'; minconfidence = '75'; rulePackId = '00000000-0000-0000-0000-000000000000'; classifiertype = 'Content'; name = 'ABA Routing Number'; mincount = '1'; maxcount = '-1'; })
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should create from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Rule already exists and is NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Comment                             = 'Detects when 1 to 9 credit card numbers are contained in Exchange items'
                    Credential                          = $Credential
                    Disabled                            = $False
                    DocumentIsPasswordProtected         = $False
                    DocumentIsUnsupported               = $False
                    Ensure                              = 'Present'
                    ExceptIfDocumentIsPasswordProtected = $False
                    ExceptIfDocumentIsUnsupported       = $False
                    ExceptIfProcessingLimitExceeded     = $False
                    Name                                = 'TestRule'
                    Policy                              = 'TestPolicy'
                    ProcessingLimitExceeded             = $False
                    ReportSeverityLevel                 = 'Low'
                    Workload                            = 'Exchange'
                    ContentContainsSensitiveInformation = ([MSFT_SCDLPContainsSensitiveInformation] @{
                            SensitiveInformation = @([MSFT_SCDLPSensitiveInformation] @{
                                    name           = 'ABA Routing Number'
                                    id             = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'
                                    maxconfidence  = '100'
                                    minconfidence  = '75'
                                    classifiertype = 'Content'
                                    mincount       = '1'
                                    maxcount       = '-1'
                                })
                        })
                }

                Mock -CommandName Get-AutoSensitivityLabelRule -MockWith {
                    return @{
                        Comment                             = 'Detects when 1 to 9 credit card numbers are contained in Exchange items'
                        Disabled                            = $False
                        DocumentIsPasswordProtected         = $False
                        DocumentIsUnsupported               = $False
                        ExceptIfDocumentIsPasswordProtected = $True; # Drift
                        ExceptIfDocumentIsUnsupported       = $False
                        ExceptIfProcessingLimitExceeded     = $False
                        Name                                = 'TestRule'
                        ParentPolicyName                    = 'TestPolicy'
                        ProcessingLimitExceeded             = $False
                        ReportSeverityLevel                 = 'Low'
                        Workload                            = 'Exchange'
                        ContentContainsSensitiveInformation = @(@{maxconfidence = '100'; id = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'; minconfidence = '75'; rulePackId = '00000000-0000-0000-0000-000000000000'; classifiertype = 'Content'; name = 'ABA Routing Number'; mincount = '1'; maxcount = '-1'; })
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Set()
                Should -Invoke -CommandName Set-AutoSensitivityLabelRule -Exactly 1
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Rule should not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    Comment                             = 'Detects when 1 to 9 credit card numbers are contained in Exchange items'
                    Credential                          = $Credential
                    Disabled                            = $False
                    DocumentIsPasswordProtected         = $False
                    DocumentIsUnsupported               = $False
                    Ensure                              = 'Absent'
                    ExceptIfDocumentIsPasswordProtected = $False
                    ExceptIfDocumentIsUnsupported       = $False
                    ExceptIfProcessingLimitExceeded     = $False
                    Name                                = 'TestRule'
                    Policy                              = 'TestPolicy'
                    ProcessingLimitExceeded             = $False
                    ReportSeverityLevel                 = 'Low'
                    Workload                            = 'Exchange'
                    ContentContainsSensitiveInformation = ([MSFT_SCDLPContainsSensitiveInformation] @{
                            SensitiveInformation = @([MSFT_SCDLPSensitiveInformation] @{
                                    name           = 'ABA Routing Number'
                                    id             = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'
                                    maxconfidence  = '100'
                                    minconfidence  = '75'
                                    classifiertype = 'Content'
                                    mincount       = '1'
                                    maxcount       = '-1'
                                })
                        })
                }

                Mock -CommandName Get-AutoSensitivityLabelRule -MockWith {
                    return @{
                        Comment                             = 'Detects when 1 to 9 credit card numbers are contained in Exchange items'
                        Disabled                            = $False
                        DocumentIsPasswordProtected         = $False
                        DocumentIsUnsupported               = $False
                        ExceptIfDocumentIsPasswordProtected = $False
                        ExceptIfDocumentIsUnsupported       = $False
                        ExceptIfProcessingLimitExceeded     = $False
                        Name                                = 'TestRule'
                        ParentPolicyName                    = 'TestPolicy'
                        ProcessingLimitExceeded             = $False
                        ReportSeverityLevel                 = 'Low'
                        Workload                            = 'Exchange'
                        ContentContainsSensitiveInformation = @(@{maxconfidence = '100'; id = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'; minconfidence = '75'; rulePackId = '00000000-0000-0000-0000-000000000000'; classifiertype = 'Content'; name = 'ABA Routing Number'; mincount = '1'; maxcount = '-1'; })
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should delete from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-AutoSensitivityLabelRule -Exactly 1
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Sensitive information comparison' -Fixture {
            BeforeAll {
                $compareRules = (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelRule' -Property @{
                        Name       = 'TestRule'
                        Policy     = 'TestPolicy'
                        Workload   = 'Exchange'
                        Credential = $Credential
                    }).GetCompareParameters().CompareRules

                function Invoke-ContentCompare
                {
                    param($Desired, $Current)

                    & $Global:DscHelper.InvokeCompareRules -CompareRules $compareRules -DesiredValues @{ ContentContainsSensitiveInformation = $Desired } -CurrentValues @{ ContentContainsSensitiveInformation = $Current }
                }
            }

            It 'Should treat a null operator and an empty operator as equal' {
                $result = Invoke-ContentCompare -Desired @{ operator = ''; groups = @() } -Current @{ operator = $null; groups = @() }
                $result.ValuesToCheck.ContainsKey('ContentContainsSensitiveInformation') | Should -BeFalse
                $result.Messages | Should -BeNullOrEmpty
            }

            It 'Should match a sensitive information type and a label with escaped single quotes in the name' {
                $desired = @{ operator = 'Or'; groups = @(@{ name = 'Group1'; SensitiveInformation = @(@{ name = "Driver''s License"; id = 'id-1' }); labels = @(@{ name = "Driver''s License"; id = 'id-1'; type = 'Sensitivity' }) }) }
                $current = @{ operator = 'Or'; groups = @(@{ name = 'Group1'; SensitiveInformation = @(@{ name = "Driver's License"; id = 'id-1' }); labels = @(@{ name = "Driver's License"; id = 'id-1'; type = 'Sensitivity' }) }) }
                (Invoke-ContentCompare -Desired $desired -Current $current).Messages | Should -BeNullOrEmpty
            }

            It 'Should report drift when a group is missing on the current side' {
                $result = Invoke-ContentCompare -Desired @{ operator = 'Or'; groups = @(@{ name = 'Group1'; operator = 'And'; SensitiveInformation = @(@{ name = 'ABA Routing Number' }) }) } -Current @{ operator = 'Or'; groups = @() }
                $result.Desired.ContentContainsSensitiveInformation | Should -Be 'SIT-Drift-Desired'
                $result.Messages | Should -BeLike '*An action on {Group1} Sensitive Information Type is missing.'
            }

            It 'Should report drift when maxcount is present on one side only' {
                $withMaxCount = @{ SensitiveInformation = @(@{ name = 'ABA Routing Number'; maxcount = '9' }) }
                $withoutMaxCount = @{ SensitiveInformation = @(@{ name = 'ABA Routing Number' }) }
                (Invoke-ContentCompare -Desired $withMaxCount -Current $withoutMaxCount).Desired.ContentContainsSensitiveInformation | Should -Be 'SIT-Drift-Desired'
                (Invoke-ContentCompare -Desired $withoutMaxCount -Current $withMaxCount).Desired.ContentContainsSensitiveInformation | Should -Be 'SIT-Drift-Desired'
            }

            It 'Should log the current value as current and the desired value as expected, once' {
                $result = Invoke-ContentCompare -Desired @{ SensitiveInformation = @(@{ name = 'ABA Routing Number'; mincount = '1' }) } -Current @{ SensitiveInformation = @(@{ name = 'ABA Routing Number'; mincount = '5' }) }
                $result.Messages.Count | Should -Be 1
                $result.Messages[0] | Should -BeLike '*Current value is {5} and is expected to be {1}.'
            }

            It 'Should log the current operator as current and the desired operator as expected' {
                (Invoke-ContentCompare -Desired @{ operator = 'And'; groups = @() } -Current @{ operator = 'Or'; groups = @() }).Messages | Should -BeLike '*Current value is {Or} and is expected to be {And}.'
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-AutoSensitivityLabelRule -MockWith {
                    return @{
                        Comment                             = 'Detects when 1 to 9 credit card numbers are contained in Exchange items'
                        Disabled                            = $False
                        DocumentIsPasswordProtected         = $False
                        DocumentIsUnsupported               = $False
                        ExceptIfDocumentIsPasswordProtected = $False
                        ExceptIfDocumentIsUnsupported       = $False
                        ExceptIfProcessingLimitExceeded     = $False
                        Name                                = 'TestRule'
                        ParentPolicyName                    = 'TestPolicy'
                        ProcessingLimitExceeded             = $False
                        ReportSeverityLevel                 = 'Low'
                        LogicalWorkload                     = 'Exchange'
                        ContentContainsSensitiveInformation = @(@{maxconfidence = '100'; id = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'; minconfidence = '75'; rulePackId = '00000000-0000-0000-0000-000000000000'; classifiertype = 'Content'; name = 'ABA Routing Number'; mincount = '1'; maxcount = '-1'; })
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCAutoSensitivityLabelRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
