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
    -DscResource 'PPTenantIsolationSettings' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $CredsCredential = New-Object System.Management.Automation.PSCredential ('tenantadmin@contoso.onmicrosoft.com', $secpasswd)

            Mock -CommandName Get-MgContext -MockWith {
                return @{
                    TenantId = '12345678-1234-1234-1234-123456789012'
                }
            }

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            function New-HashFromTenantName
            {
                param
                (
                    [Parameter(Mandatory = $true)]
                    [System.String]
                    $TenantName
                )

                $stringAsStream = [System.IO.MemoryStream]::new()
                $writer = [System.IO.StreamWriter]::new($stringAsStream)
                $writer.Write($TenantName)
                $writer.Flush()
                $stringAsStream.Position = 0
                $hash = (Get-FileHash -InputStream $stringAsStream).Hash

                $hashAsGuid = '{0}-{1}-{2}-{3}-{4}' -f $hash.Substring(0, 8), $hash.Substring(8, 4), $hash.Substring(12, 4), $hash.Substring(16, 4), $hash.Substring(20, 12)

                return $hashAsGuid
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'PP Tenant Isolation settings are not configured' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Enabled           = $true
                    Rules            = @(
                        ([MSFT_PPTenantRule] @{
                            TenantName = 'contoso.onmicrosoft.com'
                            Direction  = 'Outbound'
                        })
                    )
                    Credential       = $Credscredential
                }

                Mock -CommandName Set-PowerAppTenantIsolationPolicy -MockWith {
                }

                Mock -CommandName Invoke-WebRequest -MockWith {
                    if ($Uri -match 'https://login.windows.net/([A-Za-z0-9.]*)/.well-known/openid-configuration')
                    {
                        $tenantid = (New-HashFromTenantName -TenantName $Matches[1])
                        $returnval = '{{"token_endpoint":"https://login.windows.net/{0}/oauth2/token"}}' -f $tenantid
                        return $returnval
                    }
                    else
                    {
                        return $null
                    }
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        properties = @{
                            tenantId       = '12345678-1234-1234-1234-123456789012'
                            isDisabled     = $true
                            allowedTenants = @()
                        }
                    }
                }
            }

            It 'Should return Enabled=False from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Get().ToHashtable()).Enabled | Should -Be $false
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should enable the isolation settings and create a rule in Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Set()
                Should -Invoke -CommandName 'Invoke-M365DSCPowerPlatformRESTWebRequest' -Exactly 1
            }
        }

        Context -Name 'PP Tenant Isolation settings are correctly configured' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Enabled           = $true
                    Rules            = @(
                        ([MSFT_PPTenantRule] @{
                            TenantName = 'contoso.onmicrosoft.com'
                            Direction  = 'Outbound'
                        })
                    )
                    Credential       = $Credscredential
                }

                Mock -CommandName Invoke-WebRequest -MockWith {
                    if ($Uri -match 'https://login.windows.net/([A-Za-z0-9.]*)/.well-known/openid-configuration')
                    {
                        $tenantid = (New-HashFromTenantName -TenantName $Matches[1])
                        $returnval = '{{"token_endpoint":"https://login.windows.net/{0}/oauth2/token"}}' -f $tenantid
                        return $returnval
                    }
                    else
                    {
                        return $null
                    }
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        properties = @{
                            tenantId       = '12345678-1234-1234-1234-123456789012'
                            isDisabled     = $false
                            allowedTenants = @(
                                @{
                                    tenantId   = New-HashFromTenantName -TenantName 'contoso.onmicrosoft.com'
                                    tenantName = 'Contoso'
                                    direction  = @{
                                        inbound  = $false
                                        outbound = $true
                                    }
                                }
                            )
                        }
                    }
                }
            }

            It 'Should return Enabled=True and 1 rule from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Get().ToHashtable()
                $result.Enabled | Should -Be $true
                $result.Rules.Count | Should -Be 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'PP Tenant Isolation settings are enabled, but with the incorrect rules' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Enabled           = $false
                    Rules            = @(
                        ([MSFT_PPTenantRule] @{
                            TenantName = 'contoso.onmicrosoft.com'
                            Direction  = 'Both'
                        })
                    )
                    Credential       = $Credscredential
                }

                Mock -CommandName Invoke-WebRequest -MockWith {
                    if ($Uri -match 'https://login.windows.net/([A-Za-z0-9.]*)/.well-known/openid-configuration')
                    {
                        $tenantid = (New-HashFromTenantName -TenantName $Matches[1])
                        $returnval = '{{"token_endpoint":"https://login.windows.net/{0}/oauth2/token"}}' -f $tenantid
                        return $returnval
                    }
                    else
                    {
                        return $null
                    }
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        properties = @{
                            tenantId       = '12345678-1234-1234-1234-123456789012'
                            isDisabled     = $false
                            allowedTenants = @(
                                @{
                                    tenantId   = New-HashFromTenantName -TenantName 'fabrikam.onmicrosoft.com'
                                    tenantName = 'Fabrikam'
                                    direction  = @{
                                        inbound  = $false
                                        outbound = $true
                                    }
                                }
                            )
                        }
                    }
                }
            }

            It 'Should return Enabled=True and 1 rule from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Get().ToHashtable()
                $result.Enabled | Should -Be $true
                $result.Rules.Count | Should -Be 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Test() | Should -Be $false
            }

            $global:M365DSCTenantId = ''
            It 'Should enable the isolation settings and create a rule in Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Set()
                Should -Invoke -CommandName 'Invoke-M365DSCPowerPlatformRESTWebRequest' -Exactly 1
            }
        }

        Context -Name 'PP Tenant Isolation settings RulesToInclude specified, but rule is not included' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Enabled           = $true
                    RulesToInclude   = @(
                        ([MSFT_PPTenantRule] @{
                            TenantName = 'contoso.onmicrosoft.com'
                            Direction  = 'Both'
                        })
                    )
                    Credential       = $Credscredential
                }

                Mock -CommandName Invoke-WebRequest -MockWith {
                    if ($Uri -match 'https://login.windows.net/([A-Za-z0-9.]*)/.well-known/openid-configuration')
                    {
                        $tenantid = (New-HashFromTenantName -TenantName $Matches[1])
                        $returnval = '{{"token_endpoint":"https://login.windows.net/{0}/oauth2/token"}}' -f $tenantid
                        return $returnval
                    }
                    else
                    {
                        return $null
                    }
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        properties = @{
                            tenantId       = '12345678-1234-1234-1234-123456789012'
                            isDisabled     = $false
                            allowedTenants = @(
                                @{
                                    tenantId   = New-HashFromTenantName -TenantName 'fabrikam.onmicrosoft.com'
                                    tenantName = 'Fabrikam'
                                    direction  = @{
                                        inbound  = $false
                                        outbound = $true
                                    }
                                }
                            )
                        }
                    }
                }
            }

            It 'Should return Enabled=True and 1 rule from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Get().ToHashtable()
                $result.Enabled | Should -Be $true
                $result.Rules.Count | Should -Be 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Test() | Should -Be $false
            }

            $global:M365DSCTenantIds = ''
            It 'Should add a rule in Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Set()
                Should -Invoke -CommandName 'Invoke-M365DSCPowerPlatformRESTWebRequest' -Exactly 1
            }
        }

        Context -Name 'PP Tenant Isolation settings RulesToInclude specified and rule is included' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Enabled           = $true
                    RulesToInclude   = @(
                        ([MSFT_PPTenantRule] @{
                            TenantName = 'contoso.onmicrosoft.com'
                            Direction  = 'Both'
                        })
                    )
                    Credential       = $Credscredential
                }

                Mock -CommandName Invoke-WebRequest -MockWith {
                    if ($Uri -match 'https://login.windows.net/([A-Za-z0-9.]*)/.well-known/openid-configuration')
                    {
                        $tenantid = (New-HashFromTenantName -TenantName $Matches[1])
                        $returnval = '{{"token_endpoint":"https://login.windows.net/{0}/oauth2/token"}}' -f $tenantid
                        return $returnval
                    }
                    else
                    {
                        return $null
                    }
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        properties = @{
                            tenantId       = '12345678-1234-1234-1234-123456789012'
                            isDisabled     = $false
                            allowedTenants = @(
                                @{
                                    tenantId   = New-HashFromTenantName -TenantName 'contoso.onmicrosoft.com'
                                    tenantName = 'Contoso'
                                    direction  = @{
                                        inbound  = $true
                                        outbound = $true
                                    }
                                }
                            )
                        }
                    }
                }
            }

            It 'Should return Enabled=True and 1 rule from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Get().ToHashtable()
                $result.Enabled | Should -Be $true
                $result.Rules.Count | Should -Be 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'PP Tenant Isolation settings RulesToExclude specified, but rule is included' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Enabled           = $true
                    RulesToExclude   = @(
                        ([MSFT_PPTenantRule] @{
                            TenantName = 'contoso.onmicrosoft.com'
                            Direction  = 'Both'
                        })
                    )
                    Credential       = $Credscredential
                }

                Mock -CommandName Invoke-WebRequest -MockWith {
                    if ($Uri -match 'https://login.windows.net/([A-Za-z0-9.]*)/.well-known/openid-configuration')
                    {
                        $tenantid = (New-HashFromTenantName -TenantName $Matches[1])
                        $returnval = '{{"token_endpoint":"https://login.windows.net/{0}/oauth2/token"}}' -f $tenantid
                        return $returnval
                    }
                    else
                    {
                        return $null
                    }
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        properties = @{
                            tenantId       = '12345678-1234-1234-1234-123456789012'
                            isDisabled     = $false
                            allowedTenants = @(
                                @{
                                    tenantId   = New-HashFromTenantName -TenantName 'fabrikam.onmicrosoft.com'
                                    tenantName = 'Fabrikam'
                                    direction  = @{
                                        inbound  = $false
                                        outbound = $true
                                    }
                                }
                                @{
                                    tenantId   = New-HashFromTenantName -TenantName 'contoso.onmicrosoft.com'
                                    tenantName = 'Contoso'
                                    direction  = @{
                                        inbound  = $false
                                        outbound = $true
                                    }
                                }
                            )
                        }
                    }
                }
            }

            It 'Should return Enabled=True and 1 rule from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Get().ToHashtable()
                $result.Enabled | Should -Be $true
                $result.Rules.Count | Should -Be 2
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Test() | Should -Be $false
            }

            $global:M365DSCTenantIds = ''
            It 'Should remove a rule in Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Set()
                $global:M365DSCTenantIds.Count | Should -Be 1
                Should -Invoke -CommandName 'Invoke-M365DSCPowerPlatformRESTWebRequest' -Exactly 1
            }
        }

        Context -Name 'PP Tenant Isolation settings RulesToExclude specified and rule is not included' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Enabled           = $true
                    RulesToExclude   = @(
                        ([MSFT_PPTenantRule] @{
                            TenantName = 'contoso.onmicrosoft.com'
                            Direction  = 'Both'
                        })
                    )
                    Credential       = $Credscredential
                }

                Mock -CommandName Invoke-WebRequest -MockWith {
                    if ($Uri -match 'https://login.windows.net/([A-Za-z0-9.]*)/.well-known/openid-configuration')
                    {
                        $tenantid = (New-HashFromTenantName -TenantName $Matches[1])
                        $returnval = '{{"token_endpoint":"https://login.windows.net/{0}/oauth2/token"}}' -f $tenantid
                        return $returnval
                    }
                    else
                    {
                        return $null
                    }
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        properties = @{
                            tenantId       = '12345678-1234-1234-1234-123456789012'
                            isDisabled     = $false
                            allowedTenants = @(
                                @{
                                    tenantId   = New-HashFromTenantName -TenantName 'fabrikam.onmicrosoft.com'
                                    tenantName = 'Fabrikam'
                                    direction  = @{
                                        inbound  = $true
                                        outbound = $true
                                    }
                                }
                            )
                        }
                    }
                }
            }

            It 'Should return Enabled=True and 1 rule from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Get().ToHashtable()
                $result.Enabled | Should -Be $true
                $result.Rules.Count | Should -Be 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantIsolationSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $CredsCredential
                }

                Mock -CommandName Invoke-WebRequest -MockWith {
                    if ($Uri -match 'https://login.windows.net/([A-Za-z0-9.]*)/.well-known/openid-configuration')
                    {
                        $tenantid = (New-HashFromTenantName -TenantName $Matches[1])
                        $returnval = '{{"token_endpoint":"https://login.windows.net/{0}/oauth2/token"}}' -f $tenantid
                        return $returnval
                    }
                    else
                    {
                        return $null
                    }
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        properties = @{
                            tenantId       = '12345678-1234-1234-1234-123456789012'
                            isDisabled     = $false
                            allowedTenants = @(
                                @{
                                    tenantId   = New-HashFromTenantName -TenantName 'fabrikam.onmicrosoft.com'
                                    tenantName = 'Fabrikam'
                                    direction  = @{
                                        inbound  = $false
                                        outbound = $true
                                    }
                                }
                                @{
                                    tenantId   = New-HashFromTenantName -TenantName 'contoso.onmicrosoft.com'
                                    tenantName = 'Contoso'
                                    direction  = @{
                                        inbound  = $false
                                        outbound = $true
                                    }
                                }
                            )
                        }
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'PPTenantIsolationSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    } #inmodulescope
} #describe

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
