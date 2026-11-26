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
    -DscResource 'SCAppRetentionCompliancePolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            Mock -CommandName New-AppRetentionCompliancePolicy -MockWith {
            }

            Mock -CommandName Set-AppRetentionCompliancePolicy -MockWith {
            }

            Mock -CommandName Remove-AppRetentionCompliancePolicy -MockWith {
            }

            $Script:NewAdaptivePolicy = {
                return [PSCustomObject]@{
                    Name                         = 'Teams Channel Messages Retention'
                    Applications                 = @('User:MicrosoftTeamsChannelMessages')
                    AdaptiveScopeLocation        = @([PSCustomObject]@{ Name = 'Finance Users' })
                    ExchangeLocation             = @()
                    ExchangeLocationException    = @()
                    ModernGroupLocation          = @()
                    ModernGroupLocationException = @()
                    Comment                      = 'Retains the channel messages of the finance department'
                    Enabled                      = $true
                    RestrictiveRetention         = $false
                    Mode                         = 'Enforce'
                }
            }

            Mock -CommandName Get-AppRetentionCompliancePolicy -MockWith {
                return & $Script:NewAdaptivePolicy
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                return "SCAppRetentionCompliancePolicy 'TestInstance' {}`r`n"
            }

            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                  = 'Teams Channel Messages Retention'
                    Applications          = @('User:MicrosoftTeamsChannelMessages')
                    AdaptiveScopeLocation = @('Finance Users')
                    Comment               = 'Retains the channel messages of the finance department'
                    Enabled               = $true
                    Ensure                = 'Present'
                    Credential            = $Credential
                }

                Mock -CommandName Get-AppRetentionCompliancePolicy -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-AppRetentionCompliancePolicy'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance with its adaptive scopes from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-AppRetentionCompliancePolicy' -Exactly 1 -ParameterFilter {
                    $Name -eq 'Teams Channel Messages Retention' -and $AdaptiveScopeLocation -eq 'Finance Users' -and $Applications -eq 'User:MicrosoftTeamsChannelMessages'
                }
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Teams Channel Messages Retention'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-AppRetentionCompliancePolicy' -Exactly 1
            }
        }

        Context -Name 'The instance is pending deletion' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Teams Channel Messages Retention'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }

                Mock -CommandName Get-AppRetentionCompliancePolicy -MockWith {
                    $instance = & $Script:NewAdaptivePolicy
                    $instance.Mode = 'PendingDeletion'
                    return $instance
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                  = 'Teams Channel Messages Retention'
                    Applications          = @('User:MicrosoftTeamsChannelMessages')
                    AdaptiveScopeLocation = @('Finance Users')
                    Comment               = 'Retains the channel messages of the finance department'
                    Enabled               = $true
                    RestrictiveRetention  = $false
                    Ensure                = 'Present'
                    Credential            = $Credential
                }
            }

            It 'Should return the expected values from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.Applications | Should -Be @('User:MicrosoftTeamsChannelMessages')
                $result.AdaptiveScopeLocation | Should -Be @('Finance Users')
                $result.Comment | Should -Be 'Retains the channel messages of the finance department'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                  = 'Teams Channel Messages Retention'
                    Applications          = @('User:MicrosoftTeamsChannelMessages')
                    AdaptiveScopeLocation = @('Sales Users')
                    Comment               = 'Retains the channel messages of the sales department'
                    Enabled               = $true
                    Ensure                = 'Present'
                    Credential            = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance and swap the adaptive scopes from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-AppRetentionCompliancePolicy' -Exactly 1 -ParameterFilter {
                    $Identity -eq 'Teams Channel Messages Retention' -and
                    $AddAdaptiveScopeLocation -eq 'Sales Users' -and
                    $RemoveAdaptiveScopeLocation -eq 'Finance Users' -and
                    $Comment -eq 'Retains the channel messages of the sales department' -and
                    -not $PSBoundParameters.ContainsKey('AdaptiveScopeLocation') -and
                    -not $PSBoundParameters.ContainsKey('Name')
                }
            }
        }

        Context -Name 'A static instance exists with different mailboxes' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name             = 'Teams Channel Messages Retention'
                    Applications     = @('User:MicrosoftTeamsChannelMessages')
                    ExchangeLocation = @('AdeleV@contoso.onmicrosoft.com')
                    Ensure           = 'Present'
                    Credential       = $Credential
                }

                Mock -CommandName Get-AppRetentionCompliancePolicy -MockWith {
                    $instance = & $Script:NewAdaptivePolicy
                    $instance.AdaptiveScopeLocation = @()
                    $instance.ExchangeLocation = @([PSCustomObject]@{ Name = 'All' })
                    return $instance
                }
            }

            It 'Should add and remove the mailboxes from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-AppRetentionCompliancePolicy' -Exactly 1 -ParameterFilter {
                    $AddExchangeLocation -eq 'AdeleV@contoso.onmicrosoft.com' -and $RemoveExchangeLocation -eq 'All'
                }
            }
        }

        Context -Name 'A static instance should become adaptive' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                  = 'Teams Channel Messages Retention'
                    AdaptiveScopeLocation = @('Finance Users')
                    Ensure                = 'Present'
                    Credential            = $Credential
                }

                Mock -CommandName Get-AppRetentionCompliancePolicy -MockWith {
                    $instance = & $Script:NewAdaptivePolicy
                    $instance.AdaptiveScopeLocation = @()
                    $instance.ExchangeLocation = @([PSCustomObject]@{ Name = 'All' })
                    return $instance
                }
            }

            It 'Should throw from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Set() } | Should -Throw '*cannot switch between adaptive and static locations*'
                Should -Invoke -CommandName 'Set-AppRetentionCompliancePolicy' -Exactly 0
            }
        }

        Context -Name 'The instance combines adaptive scopes with static locations' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                  = 'Teams Channel Messages Retention'
                    AdaptiveScopeLocation = @('Finance Users')
                    ExchangeLocation      = @('All')
                    Ensure                = 'Present'
                    Credential            = $Credential
                }

                Mock -CommandName Get-AppRetentionCompliancePolicy -MockWith {
                    return $null
                }
            }

            It 'Should throw from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Set() } | Should -Throw '*cannot combine AdaptiveScopeLocation with static locations*'
                Should -Invoke -CommandName 'New-AppRetentionCompliancePolicy' -Exactly 0
            }
        }

        Context -Name 'Changes to the instance are still being deployed' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                  = 'Teams Channel Messages Retention'
                    AdaptiveScopeLocation = @('Finance Users')
                    Comment               = 'Retains the channel messages of the sales department'
                    Ensure                = 'Present'
                    Credential            = $Credential
                }

                $Script:setAttempts = 0
                Mock -CommandName Set-AppRetentionCompliancePolicy -MockWith {
                    $Script:setAttempts++
                    if ($Script:setAttempts -eq 1)
                    {
                        throw "Previous changes to the policy 'x' are being deployed. Once deployed, additional actions can be performed."
                    }
                }
            }

            It 'Should wait and retry the update from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-AppRetentionCompliancePolicy' -Exactly 2
                Should -Invoke -CommandName 'Start-Sleep' -Exactly 1
            }
        }

        Context -Name 'The instance is created but its deployment fails' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                  = 'Teams Channel Messages Retention'
                    Applications          = @('User:MicrosoftTeamsChannelMessages')
                    AdaptiveScopeLocation = @('Finance Users')
                    Ensure                = 'Present'
                    Credential            = $Credential
                }

                Mock -CommandName Get-AppRetentionCompliancePolicy -MockWith {
                    return $null
                }

                Mock -CommandName New-AppRetentionCompliancePolicy -MockWith {
                    throw "Policy 'x' failed to be deployed. To fix this issue, please retry the policy operation after some time."
                }
            }

            It 'Should warn instead of throwing from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'SCAppRetentionCompliancePolicy' -Property $testParams).Set() } | Should -Not -Throw
                Should -Invoke -CommandName 'New-AppRetentionCompliancePolicy' -Exactly 1
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

            It 'Should reverse engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCAppRetentionCompliancePolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName 'Get-AppRetentionCompliancePolicy'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
