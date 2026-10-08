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

            Mock -CommandName Set-ExoPhishSimOverrideRule -MockWith {
            }

            Mock -CommandName Remove-ExoPhishSimOverrideRule -MockWith {
            }

            Mock -CommandName New-ExoPhishSimOverrideRule -MockWith {
            }

            Mock -CommandName New-PhishSimOverridePolicy -MockWith {
                return @{
                    Identity = 'PhishSimOverridePolicy'
                    Mode     = 'Enable'
                }
            }

            Mock -CommandName Get-PhishSimOverridePolicy -MockWith {
                return @{
                    Identity = 'PhishSimOverridePolicy'
                    Mode     = 'Enable'
                }
            }

            Mock -CommandName Get-ExoPhishSimOverrideRule -MockWith {
                return @(
                    @{
                        Identity       = '_Exe:PhishSimOverr:6fed4b63-3563-495d-a481-b24a311f8329'
                        Mode           = 'PendingDeletion'
                        Comment        = 'Previous vendor'
                        Domains        = @('contoso.net')
                        SenderIpRanges = @('192.168.1.1')
                    },
                    @{
                        Identity       = '_Exe:PhishSimOverr:d779965e-ab14-4dd8-b3f5-0876a99f988b'
                        Mode           = 'Enforce'
                        Comment        = 'Comment note'
                        Domains        = @('fabrikam.com', 'wingtiptoys.com')
                        SenderIpRanges = @('192.168.1.55')
                    }
                )
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance    = 'Yes'
                    Ensure              = 'Present'
                    Credential          = $Credential;
                    Comment             = "Comment note";
                    Domains             = @("fabrikam.com","wingtiptoys.com");
                    SenderIpRanges      = @("192.168.1.55");
                }

                Mock -CommandName Get-ExoPhishSimOverrideRule -MockWith {
                    return @{
                        Identity       = '_Exe:PhishSimOverr:6fed4b63-3563-495d-a481-b24a311f8329'
                        Mode           = 'PendingDeletion'
                        Domains        = @('fabrikam.com', 'wingtiptoys.com')
                        SenderIpRanges = @('192.168.1.55')
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance against the existing policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-PhishSimOverridePolicy -Exactly 0
                Should -Invoke -CommandName New-ExoPhishSimOverrideRule -Exactly 1 -ParameterFilter {
                    $Policy -eq 'PhishSimOverridePolicy' -and $Comment -eq 'Comment note' -and $Domains.Count -eq 2 -and $SenderIpRanges -contains '192.168.1.55'
                }
            }

            It 'Should create the policy and the rule from the Set method when no policy exists' {
                Mock -CommandName Get-PhishSimOverridePolicy -MockWith {
                    return $null
                }

                (New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-PhishSimOverridePolicy -Exactly 1 -ParameterFilter { $Name -eq 'PhishSimOverridePolicy' }
                Should -Invoke -CommandName New-ExoPhishSimOverrideRule -Exactly 1
            }

            It 'Should throw from the Get method when the service returns an error' {
                Mock -CommandName Get-ExoPhishSimOverrideRule -MockWith {
                    Write-Error -Message 'A server side error has occurred because of which the operation could not be completed.'
                }

                { (New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Get() } | Should -Throw '*server side error*'
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance    = 'Yes'
                    Ensure              = 'Absent'
                    Credential          = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the active rule and keep the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-ExoPhishSimOverrideRule -Exactly 1 -ParameterFilter {
                    $Identity -eq '_Exe:PhishSimOverr:d779965e-ab14-4dd8-b3f5-0876a99f988b'
                }
                Should -Invoke -CommandName New-PhishSimOverridePolicy -Exactly 0
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance    = 'Yes'
                    Ensure              = 'Present'
                    Credential          = $Credential;
                    Comment             = "Comment note";
                    Domains             = @("fabrikam.com","wingtiptoys.com");
                    SenderIpRanges      = @("192.168.1.55");
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance    = 'Yes'
                    Ensure              = 'Present'
                    Credential          = $Credential;
                    Comment             = "Comment note";
                    Domains             = @("fabrikam.com","newdomain.com");
                    SenderIpRanges      = @("192.168.1.55");
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should add and remove the drifted domains only from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOPhishSimOverrideRule' -Property $testParams).Set()
                Should -Invoke -CommandName Set-ExoPhishSimOverrideRule -Exactly 1 -ParameterFilter {
                    $Identity -eq '_Exe:PhishSimOverr:d779965e-ab14-4dd8-b3f5-0876a99f988b' -and
                    $AddDomains -contains 'newdomain.com' -and
                    $RemoveDomains -contains 'wingtiptoys.com' -and
                    -not $PesterBoundParameters.ContainsKey('Comment') -and
                    -not $PesterBoundParameters.ContainsKey('AddSenderIpRanges') -and
                    -not $PesterBoundParameters.ContainsKey('RemoveSenderIpRanges')
                }
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOPhishSimOverrideRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                $result | Should -Match 'IsSingleInstance\s+=\s+"Yes"'
                $result | Should -Not -Match 'contoso\.net'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
