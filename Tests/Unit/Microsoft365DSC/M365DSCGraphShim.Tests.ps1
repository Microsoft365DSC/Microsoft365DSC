BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global
    if (-not (Get-Module -Name M365DSCGraphShim))
    {
        Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCGraphShim.psd1" -Global -DisableNameChecking
    }

    if (-not (Get-Command -Name Invoke-MgxRequest -ErrorAction SilentlyContinue))
    {
        function global:Invoke-MgxRequest
        {
            [CmdletBinding()]
            param ($All, $ApiVersion, $Method, $Uri, $Skip, $Top, $PageSize, [switch] $NoPageSize, $Body, $Headers, [switch] $SkipForbidden, [switch] $SkipNotFound)
        }
    }
}

Describe 'M365DSCGraphShim' {
    Context 'Invoke-M365DSCGraphShimRequestV76 with a collection that caps the page size' {
        BeforeAll {
            $Script:TopLimitMessage = "The query specified in the URI is not valid. The limit of '50' for Top query has been exceeded. The value from the incoming request is '999'."
        }

        It 'Retries with the page size limit when the request throws' {
            Mock -ModuleName M365DSCGraphShim -CommandName Invoke-MgxRequest -MockWith {
                if ($PageSize -ne 50)
                {
                    throw $Script:TopLimitMessage
                }
                return @('first', 'second')
            }

            $result = InModuleScope -ModuleName M365DSCGraphShim {
                Invoke-M365DSCGraphShimRequestV76 -Method GET -Uri '/beta/roleManagement/cloudPC/roleDefinitions' -All -ErrorAction Stop
            }

            $result | Should -HaveCount 2
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName Invoke-MgxRequest -Exactly 1 -ParameterFilter { $PageSize -eq 50 }
        }

        It 'Retries with the page size limit when errors are silenced' {
            Mock -ModuleName M365DSCGraphShim -CommandName Invoke-MgxRequest -MockWith {
                if ($PageSize -ne 50)
                {
                    Write-Error -Message $Script:TopLimitMessage
                    return
                }
                return @('first', 'second')
            }

            $result = InModuleScope -ModuleName M365DSCGraphShim {
                Invoke-M365DSCGraphShimRequestV76 -Method GET -Uri '/beta/roleManagement/cloudPC/roleDefinitions' -All -ErrorAction SilentlyContinue
            }

            $result | Should -HaveCount 2
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName Invoke-MgxRequest -Exactly 1 -ParameterFilter { $PageSize -eq 50 }
        }

        It 'Retries without a page size when the collection allows no Top query' {
            Mock -ModuleName M365DSCGraphShim -CommandName Invoke-MgxRequest -MockWith {
                if (-not $NoPageSize)
                {
                    Write-Error -Message "The query specified in the URI is not valid. The limit of '0' for Top query has been exceeded. The value from the incoming request is '999'."
                    return
                }
                return @('first', 'second')
            }

            $result = InModuleScope -ModuleName M365DSCGraphShim {
                Invoke-M365DSCGraphShimRequestV76 -Method GET -Uri '/beta/deviceManagement/virtualEndpoint/userSettings' -All -ErrorAction SilentlyContinue
            }

            $result | Should -HaveCount 2
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName Invoke-MgxRequest -Exactly 1 -ParameterFilter { $NoPageSize -and -not $PageSize }
        }

        It 'Does not retry a single page request' {
            Mock -ModuleName M365DSCGraphShim -CommandName Invoke-MgxRequest -MockWith {
                throw $Script:TopLimitMessage
            }

            {
                InModuleScope -ModuleName M365DSCGraphShim {
                    Invoke-M365DSCGraphShimRequestV76 -Method GET -Uri '/beta/roleManagement/cloudPC/roleDefinitions' -Top 999 -ErrorAction Stop
                }
            } | Should -Throw '*Top query has been exceeded*'
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName Invoke-MgxRequest -Exactly 1
        }

        It 'Sends a page size when Top is 0' {
            Mock -ModuleName M365DSCGraphShim -CommandName Invoke-MgxRequest -MockWith {
                return @('first', 'second')
            }

            $result = InModuleScope -ModuleName M365DSCGraphShim {
                Invoke-M365DSCGraphShimRequestV76 -Method GET -Uri '/beta/teams/team/channels/channel/tabs' -All -Top 0 -ErrorAction Stop
            }

            $result | Should -HaveCount 2
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName Invoke-MgxRequest -Exactly 1 -ParameterFilter { -not $NoPageSize -and -not $Top }
        }

        It 'Reports Multi Admin Approval when the exception has no status code' {
            Mock -ModuleName M365DSCGraphShim -CommandName Invoke-MgxRequest -MockWith {
                throw "Response status code does not indicate success: 400. Header 'x-msft-approval-justification' is required to request approval."
            }

            {
                InModuleScope -ModuleName M365DSCGraphShim {
                    Invoke-M365DSCGraphShimRequestV76 -Method DELETE -Uri '/beta/deviceManagement/configurationPolicies/policy' -ErrorAction Stop
                }
            } | Should -Throw '*Multi Admin Approval*'
        }
    }

    Context 'Write and delete wrappers' {
        BeforeAll {
            $Script:RequestCommand = InModuleScope -ModuleName M365DSCGraphShim {
                if ($Script:IsPowerShell76OrGreater)
                {
                    return 'Invoke-M365DSCGraphShimRequestV76'
                }
                return 'Invoke-M365DSCGraphShimRequest'
            }
        }

        BeforeEach {
            Mock -ModuleName M365DSCGraphShim -CommandName $Script:RequestCommand -MockWith {
            }
        }

        It 'Sends the removed reference of a collection-level $ref DELETE as @id' {
            $target = 'https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackages/package2'
            M365DSCGraphShim\Remove-MgBetaEntitlementManagementAccessPackageIncompatibleAccessPackageByRef -AccessPackageId 'package1' -Id $target -IfMatch 'W/"1"' -ErrorAction Stop

            $expectedUri = '/beta/identityGovernance/entitlementManagement/accessPackages/package1/incompatibleAccessPackages/$ref?@id=' + [System.Uri]::EscapeDataString($target)
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName $Script:RequestCommand -Exactly 1 -ParameterFilter {
                $Method -eq 'DELETE' -and $Uri -eq $expectedUri -and $Headers['If-Match'] -eq 'W/"1"'
            }
        }

        It 'Rejects an empty identity value before sending a DELETE' {
            {
                M365DSCGraphShim\Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId '' -ErrorAction Stop
            } | Should -Throw "*parameter 'DeviceManagementConfigurationPolicyId' because it is an empty string*"
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName $Script:RequestCommand -Exactly 0
        }

        It 'Rejects every empty identity value before sending a PATCH' {
            {
                M365DSCGraphShim\Update-MgApplicationFederatedIdentityCredential -ApplicationId 'app' -FederatedIdentityCredentialId '' -BodyParameter @{ Name = 'Phoenix' } -ErrorAction Stop
            } | Should -Throw "*parameter 'FederatedIdentityCredentialId' because it is an empty string*"
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName $Script:RequestCommand -Exactly 0
        }

        It 'Throws for an empty identity of a DELETE without ErrorAction' {
            {
                M365DSCGraphShim\Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId ''
            } | Should -Throw "*parameter 'DeviceManagementConfigurationPolicyId' because it is an empty string*"
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName $Script:RequestCommand -Exactly 0
        }

        It 'Throws for an empty identity of a PATCH without ErrorAction' {
            {
                M365DSCGraphShim\Update-MgApplicationFederatedIdentityCredential -ApplicationId 'app' -FederatedIdentityCredentialId '' -BodyParameter @{ Name = 'Phoenix' }
            } | Should -Throw "*parameter 'FederatedIdentityCredentialId' because it is an empty string*"
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName $Script:RequestCommand -Exactly 0
        }

        It 'Does not throw for an empty identity of a DELETE when errors are silenced' {
            {
                M365DSCGraphShim\Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId '' -ErrorAction SilentlyContinue
            } | Should -Not -Throw
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName $Script:RequestCommand -Exactly 0
        }

        It 'Encodes # in the identity of a DELETE' {
            M365DSCGraphShim\Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId 'policy#1' -ErrorAction Stop

            Should -Invoke -ModuleName M365DSCGraphShim -CommandName $Script:RequestCommand -Exactly 1 -ParameterFilter {
                $Uri -eq '/beta/deviceManagement/configurationPolicies/policy%231'
            }
        }

        It 'Encodes # in the identity of a PATCH' {
            M365DSCGraphShim\Update-MgApplicationFederatedIdentityCredential -ApplicationId 'app#1' -FederatedIdentityCredentialId 'credential' -BodyParameter @{ Name = 'Phoenix' } -ErrorAction Stop

            Should -Invoke -ModuleName M365DSCGraphShim -CommandName $Script:RequestCommand -Exactly 1 -ParameterFilter {
                $Method -eq 'PATCH' -and $Uri -eq '/v1.0/applications/app%231/federatedIdentityCredentials/credential'
            }
        }
    }

    Context 'Shared request helpers' {
        It 'Encodes # in the path only and leaves the query unchanged' {
            $result = InModuleScope -ModuleName M365DSCGraphShim {
                ConvertTo-M365DSCGraphShimSafeUri -Uri '/beta/groups/a#b?$filter=displayName eq ''c#d'''
            }

            $result | Should -Be '/beta/groups/a%23b?$filter=displayName eq ''c#d'''
        }

        It 'Does not change the Headers dictionary of the caller' {
            $headers = @{ 'x-custom' = 'value' }
            $result = InModuleScope -ModuleName M365DSCGraphShim -Parameters @{ CallerHeaders = $headers } {
                param($CallerHeaders)

                $copy = Get-M365DSCGraphShimRequestHeaders -BoundParameters @{ Headers = $CallerHeaders }
                $copy['ConsistencyLevel'] = 'eventual'
                return $copy
            }

            $result['x-custom'] | Should -Be 'value'
            $headers.ContainsKey('ConsistencyLevel') | Should -BeFalse
        }
    }

    Context 'Get cmdlets with the NoPageSize switch' {
        BeforeAll {
            $Script:AllPagesCommand = InModuleScope -ModuleName M365DSCGraphShim {
                if ($Script:IsPowerShell76OrGreater)
                {
                    return 'Get-M365DSCGraphShimAllPagesV76'
                }
                return 'Get-M365DSCGraphShimAllPages'
            }
        }

        BeforeEach {
            Mock -ModuleName M365DSCGraphShim -CommandName $Script:AllPagesCommand -MockWith {
                return @('tab')
            }
        }

        It 'Reads the collection without a page size' {
            $result = M365DSCGraphShim\Get-MgBetaTeamChannelTab -TeamId 'team' -ChannelId 'channel' -All -NoPageSize -ErrorAction Stop
            M365DSCGraphShim\Get-MgBetaTeamChannelTab -TeamId 'team' -ChannelId 'channel' -All -PageSize 50 -NoPageSize -ErrorAction Stop | Out-Null

            $result | Should -Be 'tab'
            Should -Invoke -ModuleName M365DSCGraphShim -CommandName $Script:AllPagesCommand -Exactly 2 -ParameterFilter { $NoPageSize -and -not $PageSize }
        }

        It 'Treats Top 0 like an absent Top' {
            M365DSCGraphShim\Get-MgBetaTeamChannelTab -TeamId 'team' -ChannelId 'channel' -Filter "displayName eq 'Wiki'" -Top 0 -ErrorAction Stop | Out-Null

            Should -Invoke -ModuleName M365DSCGraphShim -CommandName $Script:AllPagesCommand -Exactly 1 -ParameterFilter { -not $NoPageSize -and -not $PageSize }
        }
    }

    Context 'ConvertTo-M365DSCGraphShimBody with switch parameters' {
        It 'Sends a switch parameter as a boolean' {
            $body = InModuleScope -ModuleName M365DSCGraphShim {
                ConvertTo-M365DSCGraphShimBody -NamedParams @{
                    Id       = 'Phoenix'
                    IsActive = [System.Management.Automation.SwitchParameter]::new($false)
                }
            }

            $body.isActive | Should -BeOfType [System.Boolean]
            $body.isActive | Should -BeFalse
            ConvertTo-Json $body -Compress | Should -Match '"isActive":false'
        }
    }
}
