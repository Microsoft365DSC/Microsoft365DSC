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

            Mock -CommandName Invoke-M365DSCAzureDevOPSWebRequest -MockWith {
                if ($Script:callCount -eq 0)
                {
                    $Script:callCount++
                    return @{
                        owner = '12345-12345-12345-12345-12345'
                    }
                }
                elseif ($Script:callCount -eq 1)
                {
                    $Script:callCount++
                    return @{
                        items = @(
                            @{
                                id = '12345-12345-12345-12345-12345'
                                user = @{
                                    principalName = 'john.smith@contoso.com'
                                }
                            }
                            @{
                                id = '12345-12345-12345-12345-12346'
                                user = @{
                                    principalName = 'bob.houle@contoso.com'
                                }
                            }
                        )
                    }
                }
                else
                {
                    return $null
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    OrganizationName = 'MyOrg'
                    Owner            = "john.smith@contoso.com"
                    Credential       = $Credential;
                }

                $Script:callCount = 0
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'ADOOrganizationOwner' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    OrganizationName = 'MyOrg'
                    Owner            = "bob.houle@contoso.com"
                    Credential       = $Credential;
                }

                $Script:callCount = 0
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'ADOOrganizationOwner' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                $Script:callCount = 1
                (New-M365DSCResourceInstance -ResourceName 'ADOOrganizationOwner' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCAzureDevOPSWebRequest -Exactly 2
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {

                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
                $testParams = @{
                    Credential       = $Credential;
                }

                $Script:callCount = 0
                Mock -CommandName Invoke-M365DSCAzureDevOPSWebRequest -MockWith {
                    if ($Script:callCount -eq 0)
                    {
                        $Script:callCount++
                        return @{
                            id = '12345-12345-12345-12345-12345'
                        }
                    }
                    elseif ($Script:callCount -eq 1)
                    {
                        $Script:callCount++
                        return @(
                        @{
                            Value = @{
                                accountName = 'MyOrg'
                            }
                            }
                        )
                    }
                    elseif ($Script:callCount -eq 2)
                    {
                        $Script:callCount++
                        return @{
                            owner = '12345-12345-12345-12345-12345'
                        }
                    }
                    elseif ($Script:callCount -eq 3)
                    {
                        $Script:callCount++
                        return @{
                            items = @(
                                @{
                                    id = '12345-12345-12345-12345-12345'
                                    user = @{
                                        principalName = 'john.smith@contoso.com'
                                    }
                                }
                            )
                        }
                    }
                    else
                    {
                        return $null
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'ADOOrganizationOwner' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
