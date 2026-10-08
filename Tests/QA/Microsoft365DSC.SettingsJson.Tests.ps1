BeforeDiscovery {
    $resourcesPath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/DscResources'
    $settingsFiles = Get-ChildItem -Path $resourcesPath -Filter '*.json' -Recurse | ForEach-Object {
        @{
            ResourceName = $_.Directory.Name
            FullName     = $_.FullName
        }
    }

    $generatedFromAllowlist = @(
        'AADAuthenticationRequirement'
        'AADIdentityProtectionPolicySettings'
        'M365DSCGraphAPIRuleEvaluation'
        'M365DSCRuleEvaluation'
        'O365CopilotSettingsPeopleEnhancedPersonalization'
        'O365OrgCustomizationSetting'
        'O365OrgSettings'
        'O365SearchAndIntelligenceConfigurations'
    )

    $resolvedSettingsFiles = @($settingsFiles | Where-Object {
            ($_.ResourceName -replace '^MSFT_', '') -notin $generatedFromAllowlist
        })
    $allowlistedResources = @($generatedFromAllowlist | ForEach-Object {
            @{
                ResourceName = $_
                FullName     = Join-Path -Path $resourcesPath -ChildPath "MSFT_$_/settings.json"
            }
        })
}

Describe -Name 'Successfully import Settings.json files' {
    It "File for '<ResourceName>' should be read successfully" -TestCases $settingsFiles {
        $json = Get-Content -Path $FullName -Raw
        { ConvertFrom-Json -InputObject $json } | Should -Not -Throw
    }
}

Describe -Name 'Successfully validate all used permissions in Settings.json files ' {
    BeforeAll {
        $knownPermissions = @{
            application = @(Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Graph.ApplicationPermissionList.txt'))
            delegated   = @(Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Graph.DelegatedPermissionList.txt'))
        }
    }

    It "Permissions used in settings.json file for '<ResourceName>' should exist" -TestCases $settingsFiles {
        $json = Get-Content -Path $FullName -Raw
        $settings = ConvertFrom-Json -InputObject $json
        foreach ($permissionType in @('application', 'delegated'))
        {
            foreach ($accessType in @('read', 'update'))
            {
                foreach ($permission in $settings.permissions.graph.$permissionType.$accessType)
                {
                    # GUID names are hidden permissions.
                    if (-not [System.Guid]::TryParse($permission.Name, [ref][System.Guid]::Empty))
                    {
                        $permission.Name | Should -BeIn $knownPermissions.$permissionType -Because "'$($permission.Name)' is listed as a $permissionType $accessType permission" -ErrorAction Continue
                    }
                }
            }
        }
    }

    It "Should use the least permissions for '<ResourceName>'" -TestCase $settingsFiles {
        $json = Get-Content -Path $FullName -Raw
        $settings = ConvertFrom-Json -InputObject $json

        $allowedPermissions = @()

        if ($settings.ResourceName -like 'Teams*')
        {
            $allowedPermissions = @(
                'Organization.Read.All',
                'User.Read.All',
                'Group.ReadWrite.All',
                'AppCatalog.ReadWrite.All',
                'TeamSettings.ReadWrite.All',
                'Channel.Delete.All',
                'ChannelSettings.ReadWrite.All',
                'ChannelMember.ReadWrite.All',
                'Team.ReadBasic.All'
            )
        }

        if ($settings.ResourceName -like 'VivaEngagement*')
        {
            $allowedPermissions = @(
                'User.ReadBasic.All'
            )
        }

        if ($settings.ResourceName -like 'AADAuthenticationMethod*' -or $settings.ResourceName -eq 'AADAuthenticationStrengthPolicy')
        {
            $allowedPermissions = @(
                'Policy.ReadWrite.AuthenticationMethod'
            )
        }

        if ($settings.ResourceName -eq 'O365OrgSettings')
        {
            $allowedPermissions = @(
                'Application.ReadWrite.All'
            )
        }

        if ($settings.ResourceName -eq 'IntuneDeviceConfigurationCustomPolicyWindows10')
        {
            $allowedPermissions = @(
                'DeviceManagementConfiguration.ReadWrite.All'
            )
        }

        foreach ($permission in $settings.permissions.graph.application.read)
        {
            # The portal shows Tasks.Read.All while the OAuth value is Tasks.Read.
            if (-not [System.Guid]::TryParse($permission.Name, [ref][System.Guid]::Empty) -and
                $permission.Name -ne 'Tasks.Read.All' -and -not ($permission.Name -in $allowedPermissions))
            {
                $permission.Name | Should -BeLike '*.Read.*' -ErrorAction Continue
            }
        }
    }
}

Describe -Name 'Every resource records what it was generated from' {
    BeforeAll {
        $graphWorkloads = @('MicrosoftGraph', 'Intune')
        $cmdletWorkloads = @('ExchangeOnline', 'SecurityComplianceCenter', 'MicrosoftTeams', 'PnP', 'PowerPlatforms')
        $restWorkloads = @('Azure', 'AzureDevOPS', 'PowerPlatformREST', 'AdminAPI', 'DefenderForEndpoint', 'EngageHub', 'Fabric', 'Licensing', 'Tasks')
        $knownWorkloads = $graphWorkloads + $cmdletWorkloads + $restWorkloads
        $exclusionReasons = @('ReadOnly', 'NotConfigurable', 'Deprecated', 'OwnedByOtherResource', 'Deferred', 'Accepted')
        $optionalOriginKeys = @('createOnlyProperties', 'textPayloadProperties')

        function Test-SettingsHasCrudCommand
        {
            param ($Settings)

            $crudVerbs = @('Get', 'New', 'Update', 'Set', 'Remove')
            $ignored = @('MSCloudLoginAssistant', 'Microsoft.Graph.Authentication')
            foreach ($group in @($Settings.commands))
            {
                if ($null -eq $group -or $group.module -in $ignored)
                {
                    continue
                }
                foreach ($cmdlet in @($group.cmdlets))
                {
                    if ($cmdlet -match '^([A-Za-z]+)-([A-Za-z0-9]+)$' -and $Matches[1] -in $crudVerbs)
                    {
                        return $true
                    }
                }
            }
            return $false
        }

        function Test-GeneratedFromResolved
        {
            param ($GeneratedFrom, $HasCrudCommand = $true)

            if ($null -eq $GeneratedFrom -or [System.String]::IsNullOrEmpty($GeneratedFrom.workload))
            {
                return $false
            }
            if ($GeneratedFrom.workload -in $graphWorkloads)
            {
                return -not [System.String]::IsNullOrEmpty($GeneratedFrom.entityType) -and
                    $GeneratedFrom.apiVersion -in @('v1.0', 'beta')
            }
            if ($GeneratedFrom.workload -in $cmdletWorkloads)
            {
                if (-not [System.String]::IsNullOrEmpty($GeneratedFrom.cmdletNoun))
                {
                    return $true
                }
                return -not $HasCrudCommand
            }
            return $true
        }
    }

    It "'<ResourceName>' has a resolved generatedFrom block" -TestCases $resolvedSettingsFiles {
        $settings = Get-Content -Path $FullName -Raw | ConvertFrom-Json
        $settings.PSObject.Properties.Name | Should -Contain 'generatedFrom' -Because "$ResourceName must record its origin (run Utilities/Update-ResourceOrigin.ps1)"

        $origin = $settings.generatedFrom
        $origin.workload | Should -Not -BeNullOrEmpty -Because "$ResourceName must name its workload"
        if ($origin.workload -in $graphWorkloads)
        {
            $origin.entityType | Should -Not -BeNullOrEmpty -Because "$ResourceName is a Graph resource and must resolve to a CSDL entity type"
            $origin.apiVersion | Should -BeIn @('v1.0', 'beta') -Because "$ResourceName is a Graph resource and must pin its API version"
        }
        elseif ($origin.workload -in $cmdletWorkloads -and (Test-SettingsHasCrudCommand -Settings $settings))
        {
            $origin.cmdletNoun | Should -Not -BeNullOrEmpty -Because "$ResourceName is a $($origin.workload) resource that declares a CRUD cmdlet and must name its cmdlet noun"
        }
        (Test-GeneratedFromResolved -GeneratedFrom $origin -HasCrudCommand (Test-SettingsHasCrudCommand -Settings $settings)) | Should -BeTrue -Because "$ResourceName is not on the unresolved allowlist"
    }

    It "'<ResourceName>' carries a well-formed origin block" -TestCases $settingsFiles {
        $settings = Get-Content -Path $FullName -Raw | ConvertFrom-Json
        $settings.PSObject.Properties.Name | Should -Contain 'generatedFrom' -Because "$ResourceName must carry a generatedFrom block, resolved or not (run Utilities/Update-ResourceOrigin.ps1)"

        $origin = $settings.generatedFrom
        $originNames = @($origin.PSObject.Properties.Name) | Where-Object -FilterScript { $_ -notin $optionalOriginKeys }
        @($originNames) | Should -Be @('workload', 'apiVersion', 'entityType', 'odataSubtype', 'cmdletNoun', 'cmdletVerb', 'includeNavigationProperties', 'generatorVersion') -Because "$ResourceName must follow the generatedFrom contract"
        if (-not [System.String]::IsNullOrEmpty($origin.workload))
        {
            $origin.workload | Should -BeIn $knownWorkloads -Because "$ResourceName must record a workload from the closed set"
        }
        $origin.includeNavigationProperties | Should -BeOfType [System.Boolean] -Because "$ResourceName must record includeNavigationProperties as a boolean"
        $settings.PSObject.Properties.Name | Should -Contain 'excludedProperties' -Because "$ResourceName must carry an excludedProperties array next to generatedFrom"
        foreach ($exclusion in @($settings.excludedProperties))
        {
            $exclusion.name | Should -Not -BeNullOrEmpty -Because "$ResourceName excludedProperties entries must name a property"
            $exclusion.reason | Should -BeIn $exclusionReasons -Because "$ResourceName excludedProperties reasons form a closed set"
        }
    }

    It "allowlisted '<ResourceName>' is still unresolved (remove it from the allowlist otherwise)" -TestCases $allowlistedResources {
        $FullName | Should -Exist -Because "$ResourceName is on the allowlist but no longer exists"
        $settings = Get-Content -Path $FullName -Raw | ConvertFrom-Json
        (Test-GeneratedFromResolved -GeneratedFrom $settings.generatedFrom -HasCrudCommand (Test-SettingsHasCrudCommand -Settings $settings)) | Should -BeFalse -Because "$ResourceName resolved; drop it from the allowlist so the ratchet keeps tightening"
    }
}

Describe -Name 'Every resource calls one Graph API version per cmdlet noun' {
    It "'<ResourceName>' does not mix Mg and MgBeta for the same noun" -TestCases $settingsFiles {
        $settings = Get-Content -Path $FullName -Raw | ConvertFrom-Json

        $byNoun = @{}
        foreach ($group in @($settings.commands))
        {
            foreach ($cmdlet in @($group.cmdlets))
            {
                if ($cmdlet -notmatch '^[A-Za-z]+-Mg(Beta)?([A-Za-z0-9]+)$')
                {
                    continue
                }

                $noun = $Matches[2]
                if (-not $byNoun.ContainsKey($noun))
                {
                    $byNoun[$noun] = @{ V1 = @(); Beta = @() }
                }
                if ($Matches[1] -eq 'Beta')
                {
                    $byNoun[$noun].Beta += $cmdlet
                }
                else
                {
                    $byNoun[$noun].V1 += $cmdlet
                }
            }
        }

        $twins = @($byNoun.Keys | Where-Object { $byNoun[$_].V1.Count -gt 0 -and $byNoun[$_].Beta.Count -gt 0 } |
                ForEach-Object { "$($byNoun[$_].V1 -join ', ') next to $($byNoun[$_].Beta -join ', ')" })

        $twins | Should -BeNullOrEmpty -Because "$ResourceName must call one API version per cmdlet noun, beta taking precedence"
    }
}

Describe -Name 'The Graph shim covers every cmdlet the resources declare' {
    BeforeAll {
        $repoRoot = Join-Path -Path $PSScriptRoot -ChildPath '../..' -Resolve
        $shimPath = Join-Path -Path $repoRoot -ChildPath 'Modules/Microsoft365DSC/Modules/M365DSCGraphShim.psm1'

        $shimFunctions = @()
        if (Test-Path -Path $shimPath)
        {
            $shimFunctions = @([regex]::Matches(
                    [System.IO.File]::ReadAllText($shimPath),
                    '(?m)^function\s+([A-Za-z]+-Mg[A-Za-z0-9]+)') | ForEach-Object { $_.Groups[1].Value })
        }

        $declared = [System.Collections.Generic.List[System.String]]::new()
        foreach ($file in (Get-ChildItem -Path (Join-Path -Path $repoRoot -ChildPath 'Modules/Microsoft365DSC/DscResources') -Filter 'settings.json' -Recurse -File))
        {
            $settings = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
            foreach ($group in @($settings.commands))
            {
                if ($group.module -notlike 'Microsoft.Graph*' -or $group.module -eq 'Microsoft.Graph.Authentication')
                {
                    continue
                }
                foreach ($cmdlet in @($group.cmdlets))
                {
                    $declared.Add($cmdlet)
                }
            }
        }

        $uncovered = @(@($declared | Sort-Object -Unique) | Where-Object { $_ -notin $shimFunctions })
    }

    It 'Shim module exists' {
        $shimPath | Should -Exist -Because 'the shim is generated by Utilities/New-M365DSCGraphShimModule.ps1'
    }

    It 'Every declared Graph cmdlet has a shim wrapper' {
        $uncovered | Should -BeNullOrEmpty -Because 'a resource whose cmdlet set changed needs Utilities/New-M365DSCGraphShimModule.ps1 re-run before the API surface baseline is captured'
    }
}
