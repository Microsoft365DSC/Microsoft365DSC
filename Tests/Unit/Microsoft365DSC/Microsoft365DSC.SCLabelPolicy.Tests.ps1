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
    -DscResource 'SCLabelPolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Remove-LabelPolicy -MockWith {
            }

            Mock -CommandName New-LabelPolicy -MockWith {
                return @{

                }
            }

            Mock -CommandName Set-LabelPolicy -MockWith {
                return @{

                }
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Label Policy doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name             = 'TestLabelPolicy'
                    Comment          = 'This is a test label policy'
                    Labels           = @('Personal', 'General')
                    AdvancedSettings = @(
                        ([MSFT_SCLabelSetting] @{
                            Key   = 'LabelStatus'
                            Value = 'Enabled'
                        }),
                        ([MSFT_SCLabelSetting] @{
                            Key   = 'DefaultLabelStatus'
                            Value = 'None'
                        })
                    )
                    Credential       = $Credential
                    Ensure           = 'Present'
                }

                Mock -CommandName Get-LabelPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Set()
            }
        }

        Context -Name 'Label policy already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'TestLabelPolicy'
                    Comment    = 'This is a test label policy'
                    Labels     = @('Personal', 'General')
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-LabelPolicy -MockWith {
                    return @{
                        Name       = 'TestLabelPolicy'
                        Comment    = 'This is a test label policy'
                        Labels     = @('Personal', 'General')
                        Credential = $Credential
                        Ensure     = 'Present'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should update from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Label policy should not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'TestLabelPolicy'
                    Comment    = 'This is a test label policy'
                    Labels     = @('Personal', 'General')
                    Credential = $Credential
                    Ensure     = 'Absent'
                }
            }

            It 'Should return false from the Test method' {

                Mock -CommandName Get-LabelPolicy -MockWith {
                    return @{
                        Name = 'TestLabelPolicy'
                    }
                }
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should delete from the Set method' {
                Mock -CommandName Get-LabelPolicy -MockWith {
                    $null
                }
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Set()
            }

            It 'Should return Absent from the Get method' {
                Mock -CommandName Get-LabelPolicy -MockWith {
                    $null
                }
                ((New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Label policy locations match desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'TestLabelPolicy'
                    Comment                      = 'This is a test label policy'
                    Labels                       = @('Personal', 'General')
                    ExchangeLocation             = @('user1@contoso.com')
                    ExchangeLocationException    = @('except1@contoso.com')
                    ModernGroupLocation          = @('group1@contoso.com')
                    ModernGroupLocationException = @('exceptgroup1@contoso.com')
                    Credential                   = $Credential
                    Ensure                       = 'Present'
                }

                Mock -CommandName Get-LabelPolicy -MockWith {
                    return @{
                        Name                         = 'TestLabelPolicy'
                        Comment                      = 'This is a test label policy'
                        Labels                       = @('Personal', 'General')
                        ExchangeLocation             = @(@{ Name = 'user1@contoso.com' })
                        ExchangeLocationException    = @(@{ Name = 'except1@contoso.com' })
                        ModernGroupLocation          = @(@{ Name = 'group1@contoso.com' })
                        ModernGroupLocationException = @(@{ Name = 'exceptgroup1@contoso.com' })
                        Ensure                       = 'Present'
                    }
                }
            }

            It 'Should return true from the Test method when all four location properties match current state' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Label policy ExchangeLocation drift detected' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name             = 'TestLabelPolicy'
                    Comment          = 'This is a test label policy'
                    Labels           = @('Personal', 'General')
                    ExchangeLocation = @('new-user@contoso.com')
                    Credential       = $Credential
                    Ensure           = 'Present'
                }

                Mock -CommandName Get-LabelPolicy -MockWith {
                    return @{
                        Name             = 'TestLabelPolicy'
                        Comment          = 'This is a test label policy'
                        Labels           = @('Personal', 'General')
                        ExchangeLocation = @(@{ Name = 'old-user@contoso.com' })
                        Ensure           = 'Present'
                    }
                }
            }

            It 'Should return false from the Test method when ExchangeLocation drifts' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call Set-LabelPolicy with synthesized AddExchangeLocation and RemoveExchangeLocation' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-LabelPolicy -Exactly 1 -Scope It -ParameterFilter {
                    $AddExchangeLocation -contains 'new-user@contoso.com' -and `
                    $RemoveExchangeLocation -contains 'old-user@contoso.com'
                }
            }
        }

        Context -Name 'Label policy ExchangeLocationException drift detected' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                      = 'TestLabelPolicy'
                    Comment                   = 'This is a test label policy'
                    Labels                    = @('Personal', 'General')
                    ExchangeLocationException = @('new-except@contoso.com')
                    Credential                = $Credential
                    Ensure                    = 'Present'
                }

                Mock -CommandName Get-LabelPolicy -MockWith {
                    return @{
                        Name                      = 'TestLabelPolicy'
                        Comment                   = 'This is a test label policy'
                        Labels                    = @('Personal', 'General')
                        ExchangeLocationException = @(@{ Name = 'old-except@contoso.com' })
                        Ensure                    = 'Present'
                    }
                }
            }

            It 'Should return false from the Test method when ExchangeLocationException drifts' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call Set-LabelPolicy with synthesized AddExchangeLocationException and RemoveExchangeLocationException' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-LabelPolicy -Exactly 1 -Scope It -ParameterFilter {
                    $AddExchangeLocationException -contains 'new-except@contoso.com' -and `
                    $RemoveExchangeLocationException -contains 'old-except@contoso.com'
                }
            }
        }

        Context -Name 'Label policy ModernGroupLocation drift detected' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                = 'TestLabelPolicy'
                    Comment             = 'This is a test label policy'
                    Labels              = @('Personal', 'General')
                    ModernGroupLocation = @('newgroup@contoso.com')
                    Credential          = $Credential
                    Ensure              = 'Present'
                }

                Mock -CommandName Get-LabelPolicy -MockWith {
                    return @{
                        Name                = 'TestLabelPolicy'
                        Comment             = 'This is a test label policy'
                        Labels              = @('Personal', 'General')
                        ModernGroupLocation = @(@{ Name = 'oldgroup@contoso.com' })
                        Ensure              = 'Present'
                    }
                }
            }

            It 'Should return false from the Test method when ModernGroupLocation drifts' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call Set-LabelPolicy with synthesized AddModernGroupLocation and RemoveModernGroupLocation' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-LabelPolicy -Exactly 1 -Scope It -ParameterFilter {
                    $AddModernGroupLocation -contains 'newgroup@contoso.com' -and `
                    $RemoveModernGroupLocation -contains 'oldgroup@contoso.com'
                }
            }
        }

        Context -Name 'Label policy ModernGroupLocationException drift detected' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'TestLabelPolicy'
                    Comment                      = 'This is a test label policy'
                    Labels                       = @('Personal', 'General')
                    ModernGroupLocationException = @('newexceptgroup@contoso.com')
                    Credential                   = $Credential
                    Ensure                       = 'Present'
                }

                Mock -CommandName Get-LabelPolicy -MockWith {
                    return @{
                        Name                         = 'TestLabelPolicy'
                        Comment                      = 'This is a test label policy'
                        Labels                       = @('Personal', 'General')
                        ModernGroupLocationException = @(@{ Name = 'oldexceptgroup@contoso.com' })
                        Ensure                       = 'Present'
                    }
                }
            }

            It 'Should return false from the Test method when ModernGroupLocationException drifts' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call Set-LabelPolicy with synthesized AddModernGroupLocationException and RemoveModernGroupLocationException' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-LabelPolicy -Exactly 1 -Scope It -ParameterFilter {
                    $AddModernGroupLocationException -contains 'newexceptgroup@contoso.com' -and `
                    $RemoveModernGroupLocationException -contains 'oldexceptgroup@contoso.com'
                }
            }
        }

        Context -Name 'Label policy AddExchangeLocation only - entry already present' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                = 'TestLabelPolicy'
                    Comment             = 'This is a test label policy'
                    Labels              = @('Personal', 'General')
                    AddExchangeLocation = @('user1@contoso.com')
                    Credential          = $Credential
                    Ensure              = 'Present'
                }

                Mock -CommandName Get-LabelPolicy -MockWith {
                    return @{
                        Name             = 'TestLabelPolicy'
                        Comment          = 'This is a test label policy'
                        Labels           = @('Personal', 'General')
                        ExchangeLocation = @(@{ Name = 'user1@contoso.com' })
                        Ensure           = 'Present'
                    }
                }
            }

            It 'Should return true when AddExchangeLocation entry is already present in current state' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Label policy RemoveExchangeLocation only - entry still present' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                   = 'TestLabelPolicy'
                    Comment                = 'This is a test label policy'
                    Labels                 = @('Personal', 'General')
                    RemoveExchangeLocation = @('user1@contoso.com')
                    Credential             = $Credential
                    Ensure                 = 'Present'
                }

                Mock -CommandName Get-LabelPolicy -MockWith {
                    return @{
                        Name             = 'TestLabelPolicy'
                        Comment          = 'This is a test label policy'
                        Labels           = @('Personal', 'General')
                        ExchangeLocation = @(@{ Name = 'user1@contoso.com' })
                        Ensure           = 'Present'
                    }
                }
            }

            It 'Should return false when RemoveExchangeLocation entry still exists in current state' {
                (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'AdvancedSettings defaultlabel resolution uses bulk Get-Label cache' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'TestLabelPolicy'
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-LabelPolicy -MockWith {
                    return @{
                        Name     = 'TestLabelPolicy'
                        Settings = @(
                            '[defaultlabel,00000000-0000-0000-0000-000000000001]',
                            '[siodefaultlabelid,00000000-0000-0000-0000-000000000002]'
                        )
                    }
                }

                Mock -CommandName Get-Label -MockWith {
                    return @(
                        [pscustomobject]@{ ImmutableId = [Guid]'00000000-0000-0000-0000-000000000001'; DisplayName = 'Confidential' },
                        [pscustomobject]@{ ImmutableId = [Guid]'00000000-0000-0000-0000-000000000002'; DisplayName = 'Public' }
                    )
                }
            }

            It 'Should call Get-Label exactly once with no -Identity argument when resolving multiple defaultlabel settings' {
                $null = (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName Get-Label -Exactly 1 -Scope It -ParameterFilter {
                    $null -eq $Identity
                }
            }
        }

        Context -Name 'AdvancedSettings comparison' -Fixture {
            BeforeAll {
                $postProcessing = (New-M365DSCResourceInstance -ResourceName 'SCLabelPolicy' -Property @{
                        Name       = 'TestLabelPolicy'
                        Credential = $Credential
                    }).GetCompareParameters().PostProcessing
            }

            It 'Should compare array valued advanced settings as sets' {
                $desired = @(@{ Key = 'attachmentaction'; Value = @('a', 'b') })
                [SCLabelPolicy]::TestAdvancedSettings($desired, @(@{ Key = 'AttachmentAction'; Value = @('b', 'a') })) | Should -BeTrue
                [SCLabelPolicy]::TestAdvancedSettings($desired, @(@{ Key = 'attachmentaction'; Value = @('a') })) | Should -BeFalse
                [SCLabelPolicy]::TestAdvancedSettings(@(@{ Key = 'attachmentaction'; Value = [System.String[]] @('a') }), @(@{ Key = 'attachmentaction'; Value = 'a' })) | Should -BeTrue
                [SCLabelPolicy]::TestAdvancedSettings(@(@{ Key = 'attachmentaction'; Value = 'a' }), @(@{ Key = 'attachmentaction'; Value = @('a', 'b') })) | Should -BeFalse
            }

            It 'Should ignore desired settings the current side does not carry' {
                [SCLabelPolicy]::TestAdvancedSettings(@(@{ Key = 'missing'; Value = 'x' }), @()) | Should -BeTrue
                [SCLabelPolicy]::TestAdvancedSettings(@(@{ Key = 'missing'; Value = 'x' }), $null) | Should -BeTrue
            }

            It 'Should flag drift through PostProcessing only when array valued advanced settings differ' {
                $desiredValues = @{ AdvancedSettings = @(@{ Key = 'attachmentaction'; Value = @('a', 'b') }) }
                $currentValues = @{ AdvancedSettings = @(@{ Key = 'attachmentaction'; Value = @('a') }) }
                $drifted = $postProcessing.Invoke($desiredValues, $currentValues, $desiredValues.Clone(), @(@{ IsReport = $true }))
                $drifted.Item3.AdvancedSettings.Drift | Should -Be 'desired'
                Compare-M365DSCResourceState -ResourceName 'SCLabelPolicy' -DesiredValues @{ Name = 'TestLabelPolicy'; AdvancedSettings = @(@{ Key = 'attachmentaction'; Value = @('a', 'b') }) } `
                    -CurrentValues @{ Name = 'TestLabelPolicy'; AdvancedSettings = @(@{ Key = 'attachmentaction'; Value = @('a') }) } `
                    -PostProcessing $postProcessing -PostProcessingArgs @(@{ IsReport = $true }) | Should -BeFalse

                $desiredValues = @{ AdvancedSettings = @(@{ Key = 'attachmentaction'; Value = @('a', 'b') }) }
                $currentValues = @{ AdvancedSettings = @(@{ Key = 'attachmentaction'; Value = @('b', 'a') }) }
                $matching = $postProcessing.Invoke($desiredValues, $currentValues, $desiredValues.Clone(), @())
                $matching.Item3.ContainsKey('AdvancedSettings') | Should -BeFalse
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
                Mock -CommandName Get-LabelPolicy -MockWith {
                    return @{
                        Name     = 'TestPolicy'
                        Settings = '{"Key": "LabelStatus",
                                            "Value": "Enabled"}'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCLabelPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
