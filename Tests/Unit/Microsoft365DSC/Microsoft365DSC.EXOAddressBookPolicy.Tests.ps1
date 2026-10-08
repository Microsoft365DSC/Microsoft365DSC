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
    -DscResource 'EXOAddressBookPolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-AddressBookPolicy -MockWith {
                return @{
                    Name                = 'Contoso ABP'
                    AddressLists        = '\All Contoso'
                    GlobalAddressList   = '\All Contoso'
                    OfflineAddressBook  = '\Contoso-All-OAB'
                    RoomList            = '\All Contoso-Rooms'
                    FreeBusyAccessLevel = 'AvailabilityOnly'
                }
            }

            Mock -CommandName New-AddressBookPolicy -MockWith {
            }

            Mock -CommandName Set-AddressBookPolicy -MockWith {
            }

            Mock -CommandName Remove-AddressBookPolicy -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Address Book Policy should exist. Address Book Policy is missing. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name               = 'Contoso ABP'
                    AddressLists       = '\All Contoso Other'
                    GlobalAddressList  = '\All Contoso'
                    OfflineAddressBook = '\Contoso-All-OAB'
                    RoomList           = '\All Contoso-Rooms'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-AddressBookPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAddressBookPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAddressBookPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-AddressBookPolicy -Exactly 1
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAddressBookPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Address Book Policy should exist. Address Book Policy exists. Test should pass.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name               = 'Contoso ABP'
                    AddressLists       = '\All Contoso'
                    GlobalAddressList  = '\All Contoso'
                    OfflineAddressBook = '\Contoso-All-OAB'
                    RoomList           = '\All Contoso-Rooms'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAddressBookPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAddressBookPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Address Book Policy should exist. Address Book Policy exists, RoomList mismatch. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name               = 'Contoso ABP'
                    AddressLists       = '\All Contoso'
                    GlobalAddressList  = '\All Contoso'
                    OfflineAddressBook = '\Contoso-All-OAB'
                    RoomList           = '\All Fabrikam-Rooms' # Drift
                    Ensure             = 'Present'
                    Credential         = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAddressBookPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAddressBookPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-AddressBookPolicy -Exactly 1
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

            It 'Should Reverse Engineer resource from the Export method when single' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOAddressBookPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
