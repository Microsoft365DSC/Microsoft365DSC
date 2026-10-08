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
    -DscResource 'SPOSearchResultSource' -GenericStubModule $GenericStubPath

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
            $existingValueXML = "<SearchConfigurationSettings xmlns=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Portability`" xmlns:i=`"http://www.w3.org/2001/XMLSchema-instance`">
            <SearchQueryConfigurationSettings><SearchQueryConfigurationSettings>
            <BestBets xmlns:d4p1=`"http://www.microsoft.com/sharepoint/search/KnownTypes/2008/08`" />
            <DefaultSourceId>00000000-0000-0000-0000-000000000000</DefaultSourceId>
            <DefaultSourceIdSet>true</DefaultSourceIdSet>
            <DeployToParent>false</DeployToParent>
            <DisableInheritanceOnImport>false</DisableInheritanceOnImport>
            <QueryRuleGroups xmlns:d4p1=`"http://www.microsoft.com/sharepoint/search/KnownTypes/2008/08`" />
            <QueryRules xmlns:d4p1=`"http://www.microsoft.com/sharepoint/search/KnownTypes/2008/08`" />
            <ResultTypes xmlns:d4p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`" />
            <Sources xmlns:d4p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration.Query`">
            <d4p1:Source>
            <d4p1:ConnectionUrlTemplate></d4p1:ConnectionUrlTemplate>
            <d4p1:CreatedDate>2019-03-01T09:18:13.00</d4p1:CreatedDate>
            <d4p1:Description>New Result Source</d4p1:Description>
            <d4p1:Id>4483418f-8ccc-4628-b9de-0a89be1e14e8</d4p1:Id>
            <d4p1:Name>This is a Test</d4p1:Name>
            <d4p1:ProviderId>fa947043-6046-4f97-9714-40d4c113963d</d4p1:ProviderId>
            <d6p1:ParentType xmlns:d6p1=`"http://www.microsoft.com/sharepoint/search/KnownTypes/2008/08`">
            <d6p1:Id>Source</d6p1:Id>
            <d6p1:QueryPropertyExpressions>
            <d6p1:MaxSize>2147483647</d6p1:MaxSize>
            <d6p1:OrderedItems /></d6p1:QueryPropertyExpressions>
            <d6p1:_IsReadOnly>true</d6p1:_IsReadOnly>
            <d6p1:_QueryTemplate></d6p1:_QueryTemplate>
            <d6p1:_SourceId nil=`"true`" />
            </d6p1:ParentType>
            </d4p1:Source>
            </Sources>
            <UserSegments xmlns:d4p1=`"http://www.microsoft.com/sharepoint/search/KnownTypes/2008/08`" />
            </SearchQueryConfigurationSettings></SearchQueryConfigurationSettings>
            <SearchRankingModelConfigurationSettings>
            <RankingModels xmlns:d3p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`" />
            </SearchRankingModelConfigurationSettings>
            <SearchSchemaConfigurationSettings>
            <Aliases xmlns:d3p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`">
            <d3p1:LastItemName i:nil=`"true`" />
            <d3p1:dictionary xmlns:d4p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`" />
            </Aliases>
            <CategoriesAndCrawledProperties xmlns:d3p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`" />
            <CrawledProperties xmlns:d3p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`" i:nil=`"true`" />
            <ManagedProperties xmlns:d3p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`">
            <d3p1:LastItemName i:nil=`"true`" />
            <d3p1:dictionary xmlns:d4p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`" />
            <d3p1:TotalCount>0</d3p1:TotalCount>
            </ManagedProperties>
            <Mappings xmlns:d3p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`">
            <d3p1:LastItemName i:nil=`"true`" />
            <d3p1:dictionary xmlns:d4p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`" />
            </Mappings>
            <Overrides xmlns:d3p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`">
            <d3p1:LastItemName i:nil=`"true`" />
            <d3p1:dictionary xmlns:d4p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`" />
            </Overrides>
            </SearchSchemaConfigurationSettings>
            <SearchSubscriptionSettingsConfigurationSettings i:nil=`"true`" />
            <SearchTaxonomyConfigurationSettings i:nil=`"true`" />
            </SearchConfigurationSettings>"

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the Result Source doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name            = 'TestRS'
                    Description     = 'New Result Source'
                    Protocol        = 'Exchange'
                    UseAutoDiscover = $true
                    Type            = 'SharePoint'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }
                $xmlTemplatePath = Join-Path -Path $PSScriptRoot `
                    -ChildPath '..\..\..\Modules\Microsoft365DSC\Dependencies\SearchConfigurationSettings.xml' `
                    -Resolve
                $emptyXMLTemplate = Get-Content $xmlTemplatePath
                Mock -CommandName Get-PnPSearchConfiguration -MockWith {

                    return $emptyXMLTemplate
                }

                Mock -CommandName Set-PnPSearchConfiguration -MockWith {
                }

                Mock -CommandName Remove-PnPSearchConfiguration -MockWith {
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSearchResultSource' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSearchResultSource' -Property $testParams).Test() | Should -Be $false
            }

            It 'Creates the result source in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSearchResultSource' -Property $testParams).Set()
                Should -Invoke -CommandName Set-PnPSearchConfiguration -Exactly 1 -ParameterFilter {
                    (Get-Content -Path $Path -Raw) -like '*<d4p1:ConnectionUrlTemplate>http://auto?autodiscover=true</d4p1:ConnectionUrlTemplate>*<d4p1:ProviderId>3a17e140-1574-4093-bad6-e19cdf1c0122</d4p1:ProviderId>*'
                }
                Should -Invoke -CommandName Remove-PnPSearchConfiguration -Exactly 0
            }
        }

        Context -Name 'When the Result Source already exists' -Fixture {
            BeforeAll {
                $Script:RecentExtract = $null
                $testParams = @{
                    Name            = 'This is a Test'
                    Description     = 'New Result Source'
                    Protocol        = 'Exchange'
                    UseAutoDiscover = $true
                    Type            = 'SharePoint'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }
                Mock -CommandName Get-PnPSearchConfiguration -MockWith {
                    return $existingValueXML.Replace('<d4p1:ConnectionUrlTemplate></d4p1:ConnectionUrlTemplate>', '<d4p1:ConnectionUrlTemplate>http://auto?autodiscover=true</d4p1:ConnectionUrlTemplate>').Replace('fa947043-6046-4f97-9714-40d4c113963d', '3a17e140-1574-4093-bad6-e19cdf1c0122')
                }

                Mock -CommandName Set-PnPSearchConfiguration -MockWith {

                }

                Mock -CommandName Remove-PnPSearchConfiguration -MockWith {
                }
            }

            It 'Should return Present from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'SPOSearchResultSource' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.Protocol | Should -Be 'Exchange'
                $result.UseAutoDiscover | Should -Be $true
                $result.SourceURL | Should -BeNullOrEmpty
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSearchResultSource' -Property $testParams).Test() | Should -Be $true
            }

            It 'Update the managed property in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSearchResultSource' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-PnPSearchConfiguration -Exactly 1 -ParameterFilter { $Configuration -like '*<d4p1:Name>This is a Test</d4p1:Name>*' }
                Should -Invoke -CommandName Set-PnPSearchConfiguration -Exactly 1

                $absentParams = $testParams.Clone()
                $absentParams.Ensure = 'Absent'
                (New-M365DSCResourceInstance -ResourceName 'SPOSearchResultSource' -Property $absentParams).Set()
                Should -Invoke -CommandName Remove-PnPSearchConfiguration -Exactly 2 -ParameterFilter { $Configuration -like '*4483418f-8ccc-4628-b9de-0a89be1e14e8*' }
                Should -Invoke -CommandName Set-PnPSearchConfiguration -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPSearchConfiguration -MockWith {
                    return $existingValueXML
                }

                Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
                    return @{ AdminUrl = 'https://contoso-admin.sharepoint.com' }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOSearchResultSource' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Should skip a result source with a retired protocol in the Export method' {
                Mock -CommandName Get-PnPSearchConfiguration -MockWith {
                    return $existingValueXML.Replace('fa947043-6046-4f97-9714-40d4c113963d', '1e0c8601-2e5d-4ccb-9561-53743b5dbde7')
                }

                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOSearchResultSource' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -Match 'This is a Test'
            }

            It 'Should connect to the tenant administration site' {
                Invoke-M365DSCResourceMethod -ResourceName 'SPOSearchResultSource' -MethodName 'Export' -Parameters $testParams
                Should -Invoke -CommandName New-M365DSCConnection -ModuleName '_Shared' -ParameterFilter {
                    $Workload -eq 'PnP' -and $Url -eq 'https://contoso-admin.sharepoint.com'
                }
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
