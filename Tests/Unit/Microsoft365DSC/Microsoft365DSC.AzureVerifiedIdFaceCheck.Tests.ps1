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

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-AzResourceGroup -MockWith {
                return @(
                    @{
                        id                = '12345-12345-12345-12345-12345'
                        resourceId        = '/subscriptions/2dbaf4c4-78f8-4ac9-8188-536d921cf690/providers'
                        ResourceGroupName = 'testrg'
                    }
                )
            }

            Mock -CommandName Invoke-AzRestMethod -MockWith {
                return @{
                    Content =  '{"location":"westus2","id" : "12345-12345-12345-12345-12345"}'
                }
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
                    FaceCheckEnabled            = $True;
                    ResourceGroupName           = "testrg";
                    SubscriptionId              = "2dbaf4c4-78f8-4ac9-8188-536d921cf690";
                    VerifiedIdAuthorityId       = "30961e04-9c35-42db-b80f-c1b6515eb4b2";
                    VerifiedIdAuthorityLocation = "westus2";
                    Ensure                      = 'Present'
                    Credential                  = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureVerifiedIdFaceCheck' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    FaceCheckEnabled            = $False;
                    ResourceGroupName           = "testrg";
                    SubscriptionId              = "2dbaf4c4-78f8-4ac9-8188-536d921cf690";
                    VerifiedIdAuthorityId       = "30961e04-9c35-42db-b80f-c1b6515eb4b2";
                    VerifiedIdAuthorityLocation = "westus2";
                    Ensure                      = 'Present'
                    Credential                  = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AzureVerifiedIdFaceCheck' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureVerifiedIdFaceCheck' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureVerifiedIdFaceCheck' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-AzRestMethod -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }

                Mock -CommandName Invoke-WebRequest -MockWith {
                    return @{
                        content = ConvertTo-Json (@{
                        value = @(
                            @{
                                id   = '12345-12345-12345-12345-12345'
                                name = 'MyAuthority'
                            }
                        )}) -Depth 10 -Compress
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AzureVerifiedIdFaceCheck' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
