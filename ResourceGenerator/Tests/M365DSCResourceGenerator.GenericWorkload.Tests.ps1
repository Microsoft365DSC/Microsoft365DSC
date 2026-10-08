<#
    Offline unit tests for the non-Graph acquisition and the pieces that depend on it: key
    selection, parameter filtering, description cleanup, filter and paging detection, workload
    defaults and stub file placement. Fake global functions stand in for the workload cmdlets.
#>

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\M365DSCResourceGenerator.psd1') -Force

InModuleScope -ModuleName 'M365DSCResourceGenerator' {

    BeforeAll {
        function global:New-M365DSCFakeWidget
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $true)]
                [System.String]
                $Name,

                [Parameter(Mandatory = $true)]
                [System.String]
                $LanguageId,

                [Parameter()]
                [System.String]
                $Description,

                [Parameter()]
                [System.Object[]]
                $HttpPipelinePrepend,

                [Parameter()]
                [System.Management.Automation.SwitchParameter]
                $Break,

                [Parameter()]
                [System.Management.Automation.PSObject]
                $Menu
            )
        }

        function global:Get-M365DSCFakeWidget
        {
            [CmdletBinding()]
            param
            (
                [Parameter()]
                [System.String]
                $Identity,

                [Parameter()]
                [System.String]
                $NameFilter,

                [Parameter()]
                [System.Int32]
                $First,

                [Parameter()]
                [System.Int32]
                $Skip
            )
        }

        function global:Remove-M365DSCFakeWidget
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $true)]
                [System.String]
                $Id
            )
        }

        function global:New-M365DSCFakeScope
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
                [System.Object]
                $FilterConditions,

                [Parameter(Mandatory = $true, ParameterSetName = 'RawQuery')]
                [System.String]
                $RawQuery,

                [Parameter(Mandatory = $true)]
                [System.Object]
                $LocationType,

                [Parameter(Mandatory = $true)]
                [System.String]
                $Name,

                [Parameter()]
                [System.String]
                $Comment
            )
        }

        function global:Get-M365DSCFakeGadget
        {
            [CmdletBinding()]
            param
            (
                [Parameter()]
                [System.String]
                $Id
            )
        }

        # Created from unbound script blocks, so they resolve like workload cmdlets and not like generator functions.
        Set-Item -Path 'Function:\global:Get-ContosoGadget' -Value ([System.Management.Automation.ScriptBlock]::Create('[CmdletBinding()] param([System.String] $Id)'))
        Set-Item -Path 'Function:\global:New-ContosoWidget' -Value ([System.Management.Automation.ScriptBlock]::Create('[CmdletBinding()] param([System.String] $Name)'))

        function Get-ParseError
        {
            param([System.String] $Content)

            $errors = $null
            $null = [System.Management.Automation.Language.Parser]::ParseInput($Content, [ref] $null, [ref] $errors)
            return $errors
        }
    }

    AfterAll {
        Remove-Item -Path 'Function:\New-M365DSCFakeWidget', 'Function:\Get-M365DSCFakeWidget', 'Function:\Remove-M365DSCFakeWidget', 'Function:\New-M365DSCFakeScope', 'Function:\Get-M365DSCFakeGadget', 'Function:\Get-ContosoGadget', 'Function:\New-ContosoWidget' -ErrorAction SilentlyContinue
    }

    Describe 'Get-M365DSCGenericCmdletInfo' {
        BeforeAll {
            $script:info = Get-M365DSCGenericCmdletInfo -CmdLetNoun 'M365DSCFakeWidget' -Workload 'MicrosoftTeams' -WarningAction SilentlyContinue
        }

        It 'Marks only the primary key as key when several parameters are mandatory' {
            $script:info.PrimaryKey | Should -Be 'Name'
            @($script:info.Properties | Where-Object -FilterScript { $_.IsKey }).Name | Should -Be @('Name')
            ($script:info.Properties | Where-Object -FilterScript { $_.Name -eq 'LanguageId' }).IsMandatory | Should -BeTrue
        }

        It 'Leaves out the pipeline and proxy plumbing parameters' {
            $script:info.Properties.Name | Should -Not -Contain 'HttpPipelinePrepend'
            $script:info.Properties.Name | Should -Not -Contain 'Break'
        }

        It 'Detects NameFilter as the filter parameter and -First/-Skip as paging' {
            $script:info.FilterParameterName | Should -Be 'NameFilter'
            $script:info.SupportsFilter | Should -BeTrue
            $script:info.SupportsPaging | Should -BeTrue
        }

        It 'Looks the instance up through NameFilter when the Get cmdlet has no parameter named after the key' {
            $script:info.GetLookup.Mode | Should -Be 'NameFilter'
        }

        It 'Records the key parameters of the Remove cmdlet and whether it supports Confirm' {
            $script:info.RemoveKeyParameters | Should -Be @('Id')
            $script:info.RemoveSupportsConfirm | Should -BeFalse
        }
    }

    Describe 'Get-M365DSCGenericCmdletInfo for a cmdlet without a default parameter set' {
        BeforeAll {
            $script:scopeInfo = Get-M365DSCGenericCmdletInfo -CmdLetNoun 'M365DSCFakeScope' -Workload 'SecurityComplianceCenter' -WarningAction SilentlyContinue
        }

        It 'Takes the parameters of every parameter set' {
            $script:scopeInfo.Properties.Name | Should -Contain 'FilterConditions'
            $script:scopeInfo.Properties.Name | Should -Contain 'RawQuery'
        }

        It 'Marks a parameter mandatory only when every parameter set requires it' {
            ($script:scopeInfo.Properties | Where-Object -FilterScript { $_.Name -eq 'LocationType' }).IsMandatory | Should -BeTrue
            ($script:scopeInfo.Properties | Where-Object -FilterScript { $_.Name -eq 'FilterConditions' }).IsMandatory | Should -BeFalse
            ($script:scopeInfo.Properties | Where-Object -FilterScript { $_.Name -eq 'RawQuery' }).IsMandatory | Should -BeFalse
        }

        It 'Prefers a mandatory Name over an earlier mandatory parameter as primary key' {
            $script:scopeInfo.PrimaryKey | Should -Be 'Name'
        }
    }

    Describe 'A Security & Compliance resource generated from implicit remoting proxy cmdlets' {
        BeforeAll {
            New-Module -Name 'tmpEXO_m365dscfake' -ScriptBlock {
                function Get-M365DSCFakeProxyScope
                {
                    [CmdletBinding()]
                    param([System.Object] $Identity)
                }

                function New-M365DSCFakeProxyScope
                {
                    [CmdletBinding()]
                    param(
                        [Parameter(Mandatory = $true)] [System.String] $Name,
                        [Parameter(Mandatory = $true)] [System.Object] $LocationType,
                        [System.String] $Comment
                    )
                }

                function Set-M365DSCFakeProxyScope
                {
                    [CmdletBinding()]
                    param(
                        [Parameter(Mandatory = $true)] [System.Object] $Identity,
                        [System.String] $Comment
                    )
                }

                function Remove-M365DSCFakeProxyScope
                {
                    [CmdletBinding(SupportsShouldProcess = $true)]
                    param([Parameter(Mandatory = $true)] [System.Object] $Identity)
                }
            } | Import-Module -Global

            $cmdletInfo = Get-M365DSCGenericCmdletInfo -CmdLetNoun 'M365DSCFakeProxyScope' -Workload 'SecurityComplianceCenter' -WarningAction SilentlyContinue
            $script:proxyModel = New-M365DSCResourceModel -ResourceName 'SCFakeProxyScope' `
                -Workload 'SecurityComplianceCenter' `
                -CmdletInfo $cmdletInfo `
                -Properties $cmdletInfo.Properties `
                -CmdLetNoun 'M365DSCFakeProxyScope' `
                -CmdLetVerb 'New'
        }

        AfterAll {
            Remove-Module -Name 'tmpEXO_m365dscfake' -Force -ErrorAction SilentlyContinue
        }

        It 'Records the real module instead of the temporary proxy module in settings.json' {
            $settings = (New-M365DSCSettingsFile -ResourceModel $script:proxyModel -WarningAction SilentlyContinue) | ConvertFrom-Json

            @($settings.commands.module) | Should -Be @('ExchangeOnlineManagement')
        }

        It 'Declares Exchange.ManageAsApp as the application permission in settings.json' {
            $settings = (New-M365DSCSettingsFile -ResourceModel $script:proxyModel -WarningAction SilentlyContinue) | ConvertFrom-Json

            $settings.permissions.'Office 365 Exchange Online'.application.read.name | Should -Be 'Exchange.ManageAsApp'
            $settings.permissions.'Office 365 Exchange Online'.application.update.name | Should -Be 'Exchange.ManageAsApp'
        }

        It 'Removes what the Set cmdlet does not accept and passes the key as Identity on update' {
            $block = New-M365DSCSetInvocationBlock -ResourceModel $script:proxyModel -Operation 'Update'

            $block | Should -Match ([System.Text.RegularExpressions.Regex]::Escape("`$updateParameters.Remove('Name') | Out-Null"))
            $block | Should -Match ([System.Text.RegularExpressions.Regex]::Escape("`$updateParameters.Remove('LocationType') | Out-Null"))
            $block | Should -Match ([System.Text.RegularExpressions.Regex]::Escape('$updateParameters.Identity = $this.Name'))
            $block | Should -Not -Match "Remove\('Comment'\)"
            Get-ParseError -Content $block | Should -BeNullOrEmpty
        }

        It 'Keeps Confirm in the stub of a cmdlet that supports it' {
            $stub = Get-M365DSCCommandStub -Command (Get-Command -Name 'Remove-M365DSCFakeProxyScope')

            $stub | Should -Match '\$Confirm'
            $stub | Should -Not -Match '\$WhatIf'
            Get-ParseError -Content $stub | Should -BeNullOrEmpty
        }
    }

    Describe 'Parameters without a System type' {
        It 'Warns about a parameter that is generated as a string' {
            $info = Get-M365DSCGenericCmdletInfo -CmdLetNoun 'M365DSCFakeWidget' -Workload 'MicrosoftTeams' -WarningAction SilentlyContinue
            @($info.Warnings | Where-Object -FilterScript { $_ -like "Parameter 'Menu'*" }).Count | Should -Be 1
            @($info.Warnings | Where-Object -FilterScript { $_ -like "Parameter 'Name'*" }).Count | Should -Be 0
        }
    }

    Describe 'New-M365DSCResourceModel for an entity read through a path parameter' {
        BeforeAll {
            $script:cmdletInfo = @{
                APIVersion          = 'v1.0'
                ActualType          = 'crossTenantIdentitySyncPolicyPartner'
                GetCmdlet           = 'Get-MgFakePartnerSync'
                NewCmdlet           = 'Set-MgFakePartnerSync'
                UpdateCmdlet        = 'Set-MgFakePartnerSync'
                UpdateVerb          = 'Set'
                RemoveCmdlet        = 'Remove-MgFakePartnerSync'
                GetKeyParameters    = @('CrossTenantAccessPolicyConfigurationPartnerTenantId')
                NewKeyParameters    = @('CrossTenantAccessPolicyConfigurationPartnerTenantId')
                UpdateKeyParameters = @('CrossTenantAccessPolicyConfigurationPartnerTenantId')
                RemoveKeyParameters = @('CrossTenantAccessPolicyConfigurationPartnerTenantId')
                SupportsAll         = $false
                SupportsFilter      = $false
                SupportsNew         = $false
                HasAssignments      = $false
                Warnings            = @("Cmdlet 'New-MgFakePartnerSync' does not exist.")
            }
            $properties = @(
                New-M365DSCPropertyModel -Name 'DisplayName' -GraphName 'displayName'
                New-M365DSCPropertyModel -Name 'TenantId' -GraphName 'tenantId'
                New-M365DSCPropertyModel -Name 'IsSyncAllowed' -GraphName 'isSyncAllowed' -Type 'Edm.Boolean'
            )
            $script:model = New-M365DSCResourceModel -ResourceName 'AADFakePartnerSync' -Workload 'MicrosoftGraph' `
                -CmdletInfo $script:cmdletInfo -Properties $properties -CmdLetNoun 'MgFakePartnerSync' -WarningAction SilentlyContinue
        }

        It 'Leaves out an entity property that collides with an authentication property' {
            $script:model.SchemaProperties.Name | Should -Not -Contain 'TenantId'
            $script:model.ExcludedPropertyReasons['TenantId'] | Should -Be 'CollidesWithAuthenticationProperty'
            @($script:model.Properties | Where-Object -FilterScript { $_.Name -eq 'TenantId' }).Count | Should -Be 1
        }

        It 'Uses the Get path parameter as the key instead of DisplayName' {
            $script:model.PrimaryKey | Should -Be 'CrossTenantAccessPolicyConfigurationPartnerTenantId'
            $script:model.AlternativeKey | Should -BeNullOrEmpty
            @($script:model.SchemaProperties | Where-Object -FilterScript { $_.IsKey }).Name | Should -Be @('CrossTenantAccessPolicyConfigurationPartnerTenantId')
        }

        It 'Carries the acquisition and collision warnings for the summary' {
            @($script:model.Warnings | Where-Object -FilterScript { $_ -like "Cmdlet 'New-MgFakePartnerSync'*" }).Count | Should -Be 1
            @($script:model.Warnings | Where-Object -FilterScript { $_ -like "Property 'TenantId'*" }).Count | Should -Be 1
        }

        It 'Records the collision reason in settings.json' {
            $settings = New-M365DSCSettingsFile -ResourceModel $script:model -WarningAction SilentlyContinue | ConvertFrom-Json
            ($settings.excludedProperties | Where-Object -FilterScript { $_.name -eq 'TenantId' }).reason | Should -Be 'CollidesWithAuthenticationProperty'
        }

        It 'Generates a module that reads the key from the instance and has no duplicate hashtable keys' {
            $module = New-M365DSCClassModuleFile -ResourceModel $script:model
            $module | Should -Match ([System.Text.RegularExpressions.Regex]::Escape('= $this.CrossTenantAccessPolicyConfigurationPartnerTenantId'))
            $module | Should -Match ([System.Text.RegularExpressions.Regex]::Escape('Set-MgFakePartnerSync -CrossTenantAccessPolicyConfigurationPartnerTenantId $this.CrossTenantAccessPolicyConfigurationPartnerTenantId -BodyParameter $createParameters'))
            $errors = Get-ParseError -Content $module
            @($errors | Where-Object -FilterScript { $_.Message -notlike '*M365DSCResourceBase*' }) | Should -BeNullOrEmpty
        }
    }

    Describe 'Get-M365DSCGraphCmdletInfo without a New cmdlet' {
        BeforeAll {
            if ($null -eq (Get-Command -Name 'Find-MgGraphCommand' -ErrorAction SilentlyContinue))
            {
                Set-Item -Path 'Function:\global:Find-MgGraphCommand' -Value ([System.Management.Automation.ScriptBlock]::Create('param($Command, $ApiVersion)'))
            }
            $fakeGraphModule = [System.Management.Automation.ScriptBlock]::Create(@'
function Get-MgFakePartnerSync
{
    [CmdletBinding(DefaultParameterSetName = 'Get')]
    param([Parameter(Mandatory = $true, ParameterSetName = 'Get')] [System.String] $CrossTenantAccessPolicyConfigurationPartnerTenantId)
}

function Set-MgFakePartnerSync
{
    [CmdletBinding(DefaultParameterSetName = 'Set')]
    param([Parameter(Mandatory = $true, ParameterSetName = 'Set')] [System.String] $CrossTenantAccessPolicyConfigurationPartnerTenantId, [Parameter(ParameterSetName = 'Set')] [System.Collections.Hashtable] $BodyParameter)
}
'@)
            New-Module -Name 'M365DSCFakeGraphModule' -ScriptBlock $fakeGraphModule | Import-Module -Global

            Mock -CommandName Find-MgGraphCommand -MockWith {
                if ($Command -like 'Get-*')
                {
                    return [PSCustomObject] @{ OutputType = 'IMicrosoftGraphCrossTenantIdentitySyncPolicyPartner'; URI = '/policies/fake'; Variants = @('Get') }
                }
                return $null
            }
            Mock -CommandName Import-Module -MockWith {
            }
        }

        AfterAll {
            Remove-Module -Name 'M365DSCFakeGraphModule' -ErrorAction SilentlyContinue
        }

        It 'Creates through the Set cmdlet and its key parameters' {
            $info = Get-M365DSCGraphCmdletInfo -CmdLetNoun 'MgFakePartnerSync' -AllowPrompt $false -WarningAction SilentlyContinue
            $info.SupportsNew | Should -BeFalse
            $info.NewCmdlet | Should -Be 'Set-MgFakePartnerSync'
            $info.NewKeyParameters | Should -Be @('CrossTenantAccessPolicyConfigurationPartnerTenantId')
            @($info.Warnings | Where-Object -FilterScript { $_ -like "Cmdlet 'New-MgFakePartnerSync'*" }).Count | Should -Be 1
        }

        It 'Warns that Export() must enumerate the parent collection when the Get cmdlet cannot list' {
            $info = Get-M365DSCGraphCmdletInfo -CmdLetNoun 'MgFakePartnerSync' -AllowPrompt $false -WarningAction SilentlyContinue
            @($info.Warnings | Where-Object -FilterScript { $_ -like "Cmdlet 'Get-MgFakePartnerSync' cannot list instances*" }).Count | Should -Be 1
        }
    }

    Describe 'Get-M365DSCGenericLookup' {
        It 'Passes the key directly when the Get cmdlet has a parameter of the same name' {
            $lookup = Get-M365DSCGenericLookup -GetCommand (Get-Command -Name 'Get-M365DSCFakeWidget') -PrimaryKey 'Identity' -Workload 'MicrosoftTeams'
            $lookup.Mode | Should -Be 'Direct'
            $lookup.Parameter | Should -Be 'Identity'
        }

        It 'Passes a name to Identity for Exchange Online' {
            $lookup = Get-M365DSCGenericLookup -GetCommand (Get-Command -Name 'Get-M365DSCFakeWidget') -PrimaryKey 'Name' -Workload 'ExchangeOnline'
            $lookup.Mode | Should -Be 'Direct'
            $lookup.Parameter | Should -Be 'Identity'
        }

        It 'Does not pass a name to Identity for Teams' {
            $lookup = Get-M365DSCGenericLookup -GetCommand (Get-Command -Name 'Get-M365DSCFakeGadget') -PrimaryKey 'Name' -Workload 'MicrosoftTeams'
            $lookup.Mode | Should -Be 'List'
        }
    }

    Describe 'New-M365DSCGetInstanceBlock for a non-Graph resource' {
        BeforeAll {
            function New-FakeModel
            {
                param([System.String] $Mode, [System.String] $Parameter)

                return [PSCustomObject] @{
                    Workload   = 'MicrosoftTeams'
                    PrimaryKey = 'Name'
                    Cmdlets    = @{
                        GetCmdlet             = 'Get-M365DSCFakeGadget'
                        RemoveCmdlet          = 'Remove-M365DSCFakeWidget'
                        GetLookup             = @{ Mode = $Mode; Parameter = $Parameter }
                        RemoveKeyParameters   = @('Id')
                        RemoveSupportsConfirm = $false
                    }
                }
            }
        }

        It 'Lists and matches the key through a local, never through $this inside the script block' {
            $block = New-M365DSCGetInstanceBlock -ResourceModel (New-FakeModel -Mode 'List')

            $block | Should -Match ([System.Text.RegularExpressions.Regex]::Escape('$lookupKey = $this.Name'))
            $block | Should -Match ([System.Text.RegularExpressions.Regex]::Escape('Where-Object -FilterScript { $_.Name -eq $lookupKey }'))
            $block | Should -Not -Match 'FilterScript \{[^}]*\$this'
            Get-ParseError -Content $block | Should -BeNullOrEmpty
        }

        It 'Narrows the list with NameFilter' {
            New-M365DSCGetInstanceBlock -ResourceModel (New-FakeModel -Mode 'NameFilter' -Parameter 'NameFilter') |
                Should -Match ([System.Text.RegularExpressions.Regex]::Escape('Get-M365DSCFakeGadget -NameFilter $lookupKey'))
        }

        It 'Removes the instance with the Id of the service object instead of the key' {
            $block = New-M365DSCSetInvocationBlock -ResourceModel (New-FakeModel -Mode 'List') -Operation 'Remove'

            $block | Should -Match ([System.Text.RegularExpressions.Regex]::Escape('$instanceToRemove = $null'))
            $block | Should -Match ([System.Text.RegularExpressions.Regex]::Escape('Remove-M365DSCFakeWidget -Id $instanceToRemove.Id | Out-Null'))
            $block | Should -Not -Match 'Confirm'
            Get-ParseError -Content $block | Should -BeNullOrEmpty
        }
    }

    Describe 'Update-M365DSCResourceStub' {
        BeforeEach {
            $script:resourceRoot = Join-Path -Path $TestDrive -ChildPath 'DscResources'
            $resourceFolder = Join-Path -Path $script:resourceRoot -ChildPath 'MSFT_FakeResource'
            $null = New-Item -Path $resourceFolder -ItemType Directory -Force
            Set-Content -Path (Join-Path -Path $resourceFolder -ChildPath 'MSFT_FakeResource.psm1') -Value @(
                'function Get-FakeResourceHelper { New-ContosoWidget -Name "a" }'
                'Get-FakeResourceHelper'
                'Get-ContosoGadget -Id "x" | Write-Verbose'
                'Write-M365DSCHost -Message "x"'
            )
            Set-Content -Path (Join-Path -Path $resourceFolder -ChildPath 'settings.json') -Value '{ "generatedFrom": { "workload": "MicrosoftTeams" } }'

            $script:stubFile = Join-Path -Path $TestDrive -ChildPath 'ResourceStubs.psm1'
            Set-Content -Path $script:stubFile -Value @('#region MicrosoftTeams', '#endregion')
        }

        It 'Adds stubs for the workload cmdlets the module calls and nothing else' {
            $added = Update-M365DSCResourceStub -ResourceName 'FakeResource' -Path $script:resourceRoot -StubFilePath $script:stubFile

            $added | Should -Be @('Get-ContosoGadget', 'New-ContosoWidget')
            $functions = @(Get-Content -Path $script:stubFile | Where-Object -FilterScript { $_ -like 'function *' })
            $functions | Should -Be @('function Get-ContosoGadget', 'function New-ContosoWidget')
        }

        It 'Adds nothing on a second run' {
            $null = Update-M365DSCResourceStub -ResourceName 'FakeResource' -Path $script:resourceRoot -StubFilePath $script:stubFile

            Update-M365DSCResourceStub -ResourceName 'FakeResource' -Path $script:resourceRoot -StubFilePath $script:stubFile |
                Should -BeNullOrEmpty
        }
    }

    Describe 'ConvertTo-M365DSCPlainDescription' {
        It 'Removes note callouts' {
            ConvertTo-M365DSCPlainDescription -Description 'Enables the feature. > [!NOTE] > The account needs a license.' |
                Should -Be 'Enables the feature. The account needs a license.'
        }

        It 'Removes link targets in parentheses' {
            ConvertTo-M365DSCPlainDescription -Description 'Create it with `New-CsThing` (https://learn.microsoft.com/powershell/module/microsoftteams/new-csthing)cmdlet.' |
                Should -Be 'Create it with `New-CsThing` cmdlet.'
        }

        It 'Turns a numbered list into sentences' {
            ConvertTo-M365DSCPlainDescription -Description 'Enables the feature. 1. The account must have a license 1. Voice response is enabled automatically' |
                Should -Be 'Enables the feature. The account must have a license. Voice response is enabled automatically.'
        }

        It 'Turns a bulleted list into sentences' {
            ConvertTo-M365DSCPlainDescription -Description 'Possible values are: - None: No extension - Office: Adds the office' |
                Should -Be 'Possible values are: None: No extension. Office: Adds the office.'
        }

        It 'Keeps a single dash inside a sentence' {
            ConvertTo-M365DSCPlainDescription -Description 'The name - usually the display name.' |
                Should -Be 'The name - usually the display name.'
        }

        It 'Turns a PARAMVALUE list into a sentence' {
            ConvertTo-M365DSCPlainDescription -Description 'The voice to use. PARAMVALUE: Alloy | Echo | Shimmer' |
                Should -Be 'The voice to use. Possible values are Alloy, Echo, Shimmer.'
        }
    }

    Describe 'New-M365DSCExportGetAllBlock' {
        It 'Pages with -First/-Skip and passes the filter through the detected parameter' {
            $model = [PSCustomObject] @{
                Cmdlets              = @{
                    GetCmdlet           = 'Get-M365DSCFakeWidget'
                    SupportsFilter      = $true
                    FilterParameterName = 'NameFilter'
                    SupportsPaging      = $true
                }
                IsAdditionalProperty = $false
                HasAssignments       = $false
                SelectedODataType    = $null
            }

            $block = New-M365DSCExportGetAllBlock -ResourceModel $model

            $block | Should -Match ([System.Text.RegularExpressions.Regex]::Escape('$getParameters.NameFilter = $this.Filter'))
            $block | Should -Match ([System.Text.RegularExpressions.Regex]::Escape('Get-M365DSCFakeWidget @getParameters -Skip $offset'))
            Get-ParseError -Content $block | Should -BeNullOrEmpty
        }

        It 'Keeps the single call with -Filter when the cmdlet does not page' {
            $model = [PSCustomObject] @{
                Cmdlets              = @{
                    GetCmdlet      = 'Get-M365DSCFakeWidget'
                    SupportsFilter = $true
                }
                IsAdditionalProperty = $false
                HasAssignments       = $false
                SelectedODataType    = $null
            }

            New-M365DSCExportGetAllBlock -ResourceModel $model |
                Should -Match ([System.Text.RegularExpressions.Regex]::Escape('Get-M365DSCFakeWidget -Filter $this.Filter'))
        }
    }

    Describe 'Get-M365DSCWorkloadDefault' {
        It 'Returns the Teams module, roles and stub region' {
            $defaults = Get-M365DSCWorkloadDefault -Workload 'MicrosoftTeams'
            $defaults.RequiredModules | Should -Be @('MicrosoftTeams')
            $defaults.ReadRoles | Should -Be @('Teams Reader')
            $defaults.UpdateRoles | Should -Be @('Teams Administrator')
            $defaults.StubRegion | Should -Be 'MicrosoftTeams'
        }

        It 'Returns empty defaults for a Graph workload' {
            $defaults = Get-M365DSCWorkloadDefault -Workload 'MicrosoftGraph'
            $defaults.RequiredModules | Should -BeNullOrEmpty
            $defaults.StubRegion | Should -BeNullOrEmpty
        }
    }

    Describe 'Update-M365DSCStubFile' {
        BeforeEach {
            $script:stubFile = Join-Path -Path $TestDrive -ChildPath 'Microsoft365.psm1'
            Set-Content -Path $script:stubFile -Value @(
                '#region Azure'
                'function Get-AzThing'
                '{'
                '}'
                ''
                '#endregion'
                ''
                '#region MicrosoftTeams'
                'function Get-CsAlpha'
                '{'
                '}'
                ''
                'function Set-CsZulu'
                '{'
                '}'
                ''
                '#endregion'
                ''
                '#region PnP.PowerShell'
                '#endregion'
            )
        }

        It 'Inserts each missing stub into the region in alphabetical order' {
            Update-M365DSCStubFile -CmdletNoun 'M365DSCFakeWidget' -StubFilePath $script:stubFile -RegionName 'MicrosoftTeams'

            $lines = @(Get-Content -Path $script:stubFile)
            $functions = @($lines | Where-Object -FilterScript { $_ -like 'function *' })
            $functions | Should -Be @(
                'function Get-AzThing'
                'function Get-CsAlpha'
                'function Get-M365DSCFakeWidget'
                'function New-M365DSCFakeWidget'
                'function Remove-M365DSCFakeWidget'
                'function Set-CsZulu'
            )
            ($lines -join "`n") | Should -Not -Match "`n`n`n"
            ($lines -join "`n") | Should -Not -Match 'HttpPipelinePrepend'
            Get-ParseError -Content ($lines -join "`r`n") | Should -BeNullOrEmpty
        }

        It 'Skips a function that already has a stub and adds the others' {
            Add-Content -Path $script:stubFile -Value @('', '#region Other', 'function Get-M365DSCFakeWidget', '{', '}', '', '#endregion')

            Update-M365DSCStubFile -CmdletNoun 'M365DSCFakeWidget' -StubFilePath $script:stubFile -RegionName 'MicrosoftTeams'

            $lines = @(Get-Content -Path $script:stubFile)
            @($lines | Where-Object -FilterScript { $_ -eq 'function Get-M365DSCFakeWidget' }).Count | Should -Be 1
            @($lines | Where-Object -FilterScript { $_ -eq 'function New-M365DSCFakeWidget' }).Count | Should -Be 1
        }

        It 'Creates a missing region in alphabetical order among the regions' {
            Update-M365DSCStubFile -CmdletNoun 'M365DSCFakeWidget' -StubFilePath $script:stubFile -RegionName 'Microsoft.Graph.Fake'

            $regions = @(Get-Content -Path $script:stubFile | Where-Object -FilterScript { $_ -like '#region *' })
            $regions | Should -Be @('#region Azure', '#region Microsoft.Graph.Fake', '#region MicrosoftTeams', '#region PnP.PowerShell')
        }
    }
}
