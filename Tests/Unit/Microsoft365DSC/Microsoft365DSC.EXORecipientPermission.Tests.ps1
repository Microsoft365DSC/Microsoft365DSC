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
    -DscResource EXORecipientPermission -GenericStubModule $GenericStubPath
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

            Mock -CommandName Add-RecipientPermission -MockWith {
            }

            Mock -CommandName Remove-RecipientPermission -MockWith {
            }

            Mock -CommandName Get-RecipientPermission -MockWith {
                return @{
                    Identity            = 'john.smith'
                    Trustee             = 'john.doe'
                    'AccessControlType' = 'Allow'
                    AccessRights        = @('SendAs')
                    IsInherited         = $false
                    InheritanceType     = 'None'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                switch ($Collection)
                {
                    'exoMailboxes'
                    {
                        return @(Get-Mailbox -ResultSize 'Unlimited')
                    }
                    'exoUsers'
                    {
                        return @(Get-User -ResultSize 'Unlimited')
                    }
                }
            }
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Permission doesnt exist and it should' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure     = 'Present'
                    Credential = $Credential
                    Identity   = 'john.smith'
                    Trustee    = 'john.doe'
                }

                Mock -CommandName Get-RecipientPermission -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORecipientPermission' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return absent from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXORecipientPermission' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should add the permission in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORecipientPermission' -Property $testParams).Set()
                Should -Invoke -CommandName Add-RecipientPermission -Exactly 1
            }
        }

        Context -Name 'Permission exists and is not the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure     = 'Present'
                    Credential = $Credential
                    Identity   = 'john.smith'
                    Trustee    = 'john.doe'
                }

                Mock -CommandName Get-RecipientPermission -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORecipientPermission' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXORecipientPermission' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be Absent
            }
        }

        Context -Name 'Permission exist and it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure     = 'Absent'
                    Credential = $Credential
                    Identity   = 'john.smith'
                    Trustee    = 'john.doe'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORecipientPermission' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return absent from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXORecipientPermission' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be Present
            }

            It 'Should remove the permission in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORecipientPermission' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-RecipientPermission -Exactly 1 -ParameterFilter { $AccessRights -contains 'SendAs' }
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

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXORecipientPermission' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
