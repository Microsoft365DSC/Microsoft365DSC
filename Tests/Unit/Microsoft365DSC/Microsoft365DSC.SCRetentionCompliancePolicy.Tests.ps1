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
    -DscResource 'SCRetentionCompliancePolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Remove-RetentionCompliancePolicy -MockWith {
            }

            Mock -CommandName New-RetentionCompliancePolicy -MockWith {
                return @{

                }
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            Mock -CommandName Set-RetentionCompliancePolicy -MockWith {
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
                    SharePointLocation = 'https://contoso.sharepoint.com/sites/demo'
                    Name               = 'TestPolicy'
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Set()
            }
        }

        Context -Name 'Policy already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                    ExchangeLocation            = 'https://contoso.sharepoint.com/sites/demo'
                    ExchangeLocationException   = 'https://contoso.sharepoint.com'
                    OneDriveLocation            = 'https://contoso.sharepoint.com/sites/demo'
                    OneDriveLocationException   = 'https://contoso.com'
                    PublicFolderLocation        = '\\contoso\PF'
                    SkypeLocation               = 'https://contoso.sharepoint.com/sites/demo'
                    SkypeLocationException      = 'https://contoso.sharepoint.com/'
                    SharePointLocation          = 'https://contoso.sharepoint.com/sites/demo'
                    SharePointLocationException = 'https://contoso.com'
                    Name                        = 'TestPolicy'
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name                        = 'TestPolicy'
                        ExchangeLocation            = @{
                            Name = 'https://contoso.sharepoint.com/sites/demo'
                        }
                        ExchangeLocationException   = @{
                            Name = 'https://contoso.sharepoint.com'
                        }
                        OneDriveLocation            = @{
                            Name = 'https://contoso.sharepoint.com/sites/demo'
                        }
                        OneDriveLocationException   = @{
                            Name = 'https://contoso.com'
                        }
                        PublicFolderLocation        = @{
                            Name = '\\contoso\PF'
                        }
                        SkypeLocation               = @{
                            Name = 'https://contoso.sharepoint.com/sites/demo'
                        }
                        SkypeLocationException      = @{
                            Name = 'https://contoso.sharepoint.com/'
                        }
                        SharePointLocation          = @{
                            Name = 'https://contoso.sharepoint.com/sites/demo'
                        }
                        SharePointLocationException = @{
                            Name = 'https://contoso.com'
                        }
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should recreate from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
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

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name = 'TestPolicy'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should delete from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-RetentionCompliancePolicy' -Exactly 1 -ParameterFilter { $Confirm -eq $false -and -not $ForceDeletion }
                Should -Invoke -CommandName 'Remove-RetentionCompliancePolicy' -Exactly 1 -ParameterFilter { $Confirm -eq $false -and $ForceDeletion }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Adaptive policy does not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                = 'Present'
                    Credential            = $Credential
                    AdaptiveScopeLocation = @('Finance Users')
                    Applications          = @('User:Exchange,OneDriveForBusiness')
                    Name                  = 'TestPolicy'
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return $null
                }
            }

            It 'Should create the policy with its adaptive scopes and applications from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-RetentionCompliancePolicy' -Exactly 1 -ParameterFilter {
                    $Name -eq 'TestPolicy' -and $AdaptiveScopeLocation -eq 'Finance Users' -and $Applications -eq 'User:Exchange,OneDriveForBusiness'
                }
            }
        }

        Context -Name 'Adaptive policy exists with different adaptive scopes' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                = 'Present'
                    Credential            = $Credential
                    AdaptiveScopeLocation = @('Finance Users')
                    Applications          = @('User:Exchange')
                    Name                  = 'TestPolicy'
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name                  = 'TestPolicy'
                        AdaptiveScopeLocation = @(@{ Name = 'Sales Users' })
                        Applications          = @('User:Exchange')
                        IsAdaptivePolicy      = $true
                    }
                }
            }

            It 'Should return the adaptive scopes and applications from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Get().ToHashtable()
                $result.AdaptiveScopeLocation | Should -Be @('Sales Users')
                $result.Applications | Should -Be @('User:Exchange')
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should add and remove the adaptive scopes from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-RetentionCompliancePolicy' -Exactly 1 -ParameterFilter {
                    $AddAdaptiveScopeLocation -eq 'Finance Users' -and
                    $RemoveAdaptiveScopeLocation -eq 'Sales Users' -and
                    -not $PSBoundParameters.ContainsKey('AdaptiveScopeLocation')
                }
            }
        }

        Context -Name 'Static policy should become adaptive' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                = 'Present'
                    Credential            = $Credential
                    AdaptiveScopeLocation = @('Finance Users')
                    Applications          = @('User:Exchange')
                    Name                  = 'TestPolicy'
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name             = 'TestPolicy'
                        ExchangeLocation = @(@{ Name = 'All' })
                    }
                }
            }

            It 'Should throw from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Set() } | Should -Throw '*cannot switch between adaptive and static locations*'
                Should -Invoke -CommandName 'Set-RetentionCompliancePolicy' -Exactly 0
            }
        }

        Context -Name 'Policy combines adaptive scopes with static locations' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                = 'Present'
                    Credential            = $Credential
                    AdaptiveScopeLocation = @('Finance Users')
                    ExchangeLocation      = @('All')
                    Name                  = 'TestPolicy'
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return $null
                }
            }

            It 'Should throw from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Set() } | Should -Throw '*cannot combine AdaptiveScopeLocation with static locations*'
                Should -Invoke -CommandName 'New-RetentionCompliancePolicy' -Exactly 0
            }
        }

        Context -Name 'Updating the policy fails for a reason other than a pending deployment' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure             = 'Present'
                    Credential         = $Credential
                    SharePointLocation = 'https://contoso.sharepoint.com/sites/demo'
                    Comment            = 'Updated comment'
                    Name               = 'TestPolicy'
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name               = 'TestPolicy'
                        SharePointLocation = @(@{ Name = 'https://contoso.sharepoint.com/sites/demo' })
                    }
                }

                Mock -CommandName Set-RetentionCompliancePolicy -MockWith {
                    throw 'The comment is too long.'
                }
            }

            It 'Should throw from the Set method instead of reporting success' {
                { (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Set() } | Should -Throw '*The comment is too long.*'
            }
        }

        Context -Name 'Policy is pending deletion' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure     = 'Absent'
                    Credential = $Credential
                    Name       = 'TestPolicy'
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name = 'TestPolicy'
                        Mode = 'PendingDeletion'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Static policy applied from its own export' -Fixture {
            BeforeAll {
                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name               = 'TestPolicy'
                        Comment            = 'Old comment'
                        SharePointLocation = @(@{ Name = 'https://contoso.sharepoint.com/sites/demo' })
                    }
                }
            }

            It 'Should update the policy without treating it as adaptive' {
                $exported = (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property @{ Name = 'TestPolicy'; Credential = $Credential }).Get().ToHashtable()
                $exported.AdaptiveScopeLocation | Should -BeNullOrEmpty
                $exported.Comment = 'New comment'

                { (New-M365DSCResourceInstance -ResourceName 'SCRetentionCompliancePolicy' -Property $exported).Set() } | Should -Not -Throw
                Should -Invoke -CommandName 'Set-RetentionCompliancePolicy' -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-RetentionCompliancePolicy -MockWith {
                    return @{
                        Name               = 'Test Policy'
                        SharePointLocation = 'https://o365dsc1.sharepoint.com'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCRetentionCompliancePolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
