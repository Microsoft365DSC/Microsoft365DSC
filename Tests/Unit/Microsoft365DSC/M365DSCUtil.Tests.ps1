BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global

    $stubFunctions = @{
        'Microsoft365.psm1' = @('Get-MgGroup', 'Get-MgUser', 'Get-Team')
        'Generic.psm1'      = @('New-M365DSCLogEntry')
    }
    foreach ($stubModule in $stubFunctions.Keys)
    {
        $missingFunctions = @($stubFunctions[$stubModule] | Where-Object -FilterScript { -not (Test-Path -Path "Function:\$_") })
        if ($missingFunctions.Count -gt 0)
        {
            Import-Module -Name "$PSScriptRoot/../Stubs/$stubModule" -Function $missingFunctions -Global -WarningAction SilentlyContinue
        }
    }

    $Script:UtilModule = Get-Module -Name 'M365DSCUtil' -All | Select-Object -First 1
}

Describe 'Get-M365DSCArrayFromProperty' {
    It 'returns an array of the requested element type' {
        $result = Get-M365DSCArrayFromProperty -PropertyValue @('a', 'b') -ElementType ([System.String])
        $result.GetType().FullName | Should -Be 'System.String[]'
        $result | Should -Be @('a', 'b')

        $result = Get-M365DSCArrayFromProperty -PropertyValue $null -ElementType ([System.String])
        $result.GetType().FullName | Should -Be 'System.String[]'
        $result.Count | Should -Be 0
    }

    It 'keeps complex items for the default Object element type' {
        $result = Get-M365DSCArrayFromProperty -PropertyValue @(@{ id = '1' }, @{ id = '2' })
        $result.GetType().FullName | Should -Be 'System.Object[]'
        $result[0] | Should -BeOfType ([System.Collections.Hashtable])
        $result.Count | Should -Be 2
    }
}

Describe 'Test-M365DSCParameterState drift event' {
    BeforeEach {
        $Script:EventMessages = @()
        $Script:TelemetryData = @()
        Mock -ModuleName M365DSCUtil -CommandName Add-M365DSCEvent -MockWith { $Script:EventMessages += $Message }
        Mock -ModuleName M365DSCUtil -CommandName Test-IsM365DSCTelemetryEnabled -MockWith { $true }
        Mock -ModuleName M365DSCUtil -CommandName Add-M365DSCTelemetryEvent -MockWith {
            $Script:TelemetryData += @{ Type = $Type; Data = $Data }
        }
    }

    It 'writes well-formed XML with escaped values for every drift' {
        Mock -ModuleName M365DSCUtil -CommandName Get-M365DSCLCMState -MockWith { 'ConsistencyCheck' }
        $desired = @{ Identity = 'Policy'; Description = 'a & b <c>'; AccessTokens = [System.String[]]@('token1', 'token2') }
        $current = @{ Identity = 'Policy'; Description = 'old "value"'; AccessTokens = [System.String[]]@('token1', 'token2') }

        foreach ($i in 1..2)
        {
            Test-M365DSCParameterState -CurrentValues $current -DesiredValues $desired `
                -ValuesToCheck @('Identity', 'Description') -Source 'MSFT_AADGroup' | Should -BeFalse
        }

        $Script:EventMessages.Count | Should -Be 2
        foreach ($message in $Script:EventMessages)
        {
            $xml = [System.Xml.XmlDocument] $message
            ($xml.M365DSCEvent.DesiredValues.Param | Where-Object -Property Name -EQ 'Description').'#text' | Should -Be 'a & b <c>'
            ($xml.M365DSCEvent.DesiredValues.Param | Where-Object -Property Name -EQ 'AccessTokens').'#text' | Should -Be '***'
            ($xml.M365DSCEvent.CurrentValues.Param | Where-Object -Property Name -EQ 'AccessTokens').'#text' | Should -Be '***'
            $message | Should -Not -Match 'token1'
        }
        $desired.AccessTokens | Should -Be @('token1', 'token2')
    }

    It 'queries the LCM state for every drift' -Skip:(-not $IsWindows) {
        Mock -ModuleName M365DSCUtil -CommandName Test-M365DSCCurrentUserIsAdministrator -MockWith { $true }
        Mock -ModuleName M365DSCUtil -CommandName Get-DscLocalConfigurationManager -MockWith {
            [PSCustomObject]@{ LCMStateDetail = 'LCM is performing a consistency check.' }
        }
        $desired = @{ Identity = 'Policy'; Description = 'new' }
        $current = @{ Identity = 'Policy'; Description = 'old' }

        foreach ($i in 1..2)
        {
            Test-M365DSCParameterState -CurrentValues $current -DesiredValues $desired `
                -ValuesToCheck @('Identity', 'Description') -Source 'MSFT_AADGroup' | Should -BeFalse
        }

        $Script:EventMessages.Count | Should -Be 2
        foreach ($message in $Script:EventMessages)
        {
            ([System.Xml.XmlDocument] $message).M365DSCEvent.ConfigurationDrift.LCMState | Should -Be 'ConsistencyCheck'
        }
        Should -Invoke -ModuleName M365DSCUtil -CommandName Get-DscLocalConfigurationManager -Exactly -Times 2
    }

    It 'reports the number of checked parameters in the ResourceTesting telemetry event' {
        $desired = @{ Identity = 'Policy'; Description = 'same' }
        $current = @{ Identity = 'Policy'; Description = 'same' }

        Test-M365DSCParameterState -CurrentValues $current -DesiredValues $desired `
            -ValuesToCheck @('Identity', 'Description') -Source 'MSFT_AADGroup' | Should -BeTrue

        $testing = $Script:TelemetryData | Where-Object -FilterScript { $_.Type -eq 'ResourceTesting' }
        $testing.Data['ParametersCount'] | Should -Be 2
    }
}

Describe 'Write-M365DSCDriftsToEventLog' {
    BeforeEach {
        $Script:EventMessages = @()
        Mock -ModuleName M365DSCDRGUtil -CommandName Add-M365DSCEvent -MockWith { $Script:EventMessages += $Message }
        Mock -ModuleName M365DSCDRGUtil -CommandName Get-M365DSCLCMState -MockWith { 'Initial' }
    }

    It 'escapes values, renders complex values and does not mask the caller hashtables' {
        $credential = [System.Management.Automation.PSCredential]::new('user', (ConvertTo-SecureString -String 'pwd' -AsPlainText -Force))
        $assignment = New-CimInstance -ClassName 'MSFT_DeviceManagementConfigurationPolicyAssignments' -Property @{ dataType = 'allDevices' } -ClientOnly
        $current = @{ Description = 'x & y'; Credential = $credential; Settings = @{ Name = 'a<b' }; Assignments = @($assignment); Owner = [PSCustomObject]@{ Id = 'o1' } }
        $desired = @{ Description = '<z>'; Credential = $credential; Settings = @{ Name = 'c' } }
        $drifts = @{
            DriftInfo = @(
                @{ PropertyName = 'Description'; CurrentValue = 'x & y'; DesiredValue = '<z>' }
            )
        }

        Write-M365DSCDriftsToEventLog -Drifts $drifts -ResourceName 'IntuneFoo' -TenantName 'contoso.onmicrosoft.com' `
            -CurrentValues $current -DesiredValues $desired

        $Script:EventMessages.Count | Should -Be 1
        $xml = [System.Xml.XmlDocument] $Script:EventMessages[0]
        $xml.M365DSCEvent.ConfigurationDrift.Source | Should -Be 'MSFT_IntuneFoo'
        $xml.M365DSCEvent.ConfigurationDrift.LCMState | Should -Be 'Initial'
        $xml.M365DSCEvent.ConfigurationDrift.ParametersNotInDesiredState.Param.CurrentValue | Should -Be 'x & y'
        ($xml.M365DSCEvent.CurrentValues.Param | Where-Object -Property Name -EQ 'Settings').'#text' | Should -Be '{Name=a<b}'
        ($xml.M365DSCEvent.CurrentValues.Param | Where-Object -Property Name -EQ 'Credential').'#text' | Should -Be '***'
        ($xml.M365DSCEvent.CurrentValues.Param | Where-Object -Property Name -EQ 'Assignments').'#text' | Should -Be '{dataType=allDevices}'
        ($xml.M365DSCEvent.CurrentValues.Param | Where-Object -Property Name -EQ 'Owner').'#text' | Should -Be '{Id=o1}'

        $current.Credential | Should -Be $credential
        $desired.Credential | Should -Be $credential
    }
}

Describe 'Get-M365DSCGroupIdByDisplayName' {
    It 'escapes single quotes for the OData filter' {
        Mock -ModuleName M365DSCUtil -CommandName Get-MgGroup -MockWith { [PSCustomObject]@{ Id = 'group-id' } }

        Get-M365DSCGroupIdByDisplayName -GroupDisplayName "O'Brien Team" | Should -Be 'group-id'
        Should -Invoke -ModuleName M365DSCUtil -CommandName Get-MgGroup -Exactly -Times 1 -ParameterFilter {
            $Filter -eq "displayName eq 'O''Brien Team'"
        }
    }

    It 'returns null and warns when the display name is ambiguous' {
        Mock -ModuleName M365DSCUtil -CommandName Get-MgGroup -MockWith {
            [PSCustomObject]@{ Id = 'id-1' }
            [PSCustomObject]@{ Id = 'id-2' }
        }
        Mock -ModuleName M365DSCUtil -CommandName Write-Warning

        Get-M365DSCGroupIdByDisplayName -GroupDisplayName 'Duplicate' | Should -BeNullOrEmpty
        Should -Invoke -ModuleName M365DSCUtil -CommandName Write-Warning -Exactly -Times 1
    }
}

Describe 'Update-M365DSCAuthenticationTargets' {
    It 'passes the user principal name and group display name unescaped to the lookups' {
        Mock -ModuleName M365DSCUtil -CommandName Get-M365DSCUserIdByPrincipalName -MockWith { 'user-id' }
        Mock -ModuleName M365DSCUtil -CommandName Get-M365DSCGroupIdByDisplayName -MockWith { 'group-id' }
        $userTarget = [PSCustomObject]@{ Id = "o'brien@contoso.com"; TargetType = 'User' }
        $groupTarget = [PSCustomObject]@{ Id = "O'Brien Team"; TargetType = 'Group' }

        Update-M365DSCAuthenticationTargets -Targets @($userTarget, $groupTarget)

        $userTarget.Id | Should -Be 'user-id'
        $groupTarget.Id | Should -Be 'group-id'
        Should -Invoke -ModuleName M365DSCUtil -CommandName Get-M365DSCUserIdByPrincipalName -Exactly -Times 1 -ParameterFilter {
            $UserPrincipalName -eq "o'brien@contoso.com"
        }
        Should -Invoke -ModuleName M365DSCUtil -CommandName Get-M365DSCGroupIdByDisplayName -Exactly -Times 1 -ParameterFilter {
            $GroupDisplayName -eq "O'Brien Team"
        }
    }
}

Describe 'Assert-M365DSCBlueprint' {
    BeforeAll {
        $Script:BlueprintPath = Join-Path -Path $TestDrive -ChildPath 'blueprint.ps1'
        $content = "Configuration M365TenantConfig`n{`n    Import-DscResource -ModuleName 'Microsoft365DSC' -ModuleVersion '1.0.0'`n    Node localhost`n    {`n    }`n}`n"
        [System.IO.File]::WriteAllText($Script:BlueprintPath, $content)
    }

    BeforeEach {
        $Script:ParsedContent = @()
        Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies
        Mock -ModuleName M365DSCUtil -CommandName Add-M365DSCTelemetryEvent
        Mock -ModuleName M365DSCUtil -CommandName Write-Host
        Mock -ModuleName M365DSCUtil -CommandName Invoke-WebRequest -MockWith { throw 'not a url' }
        Mock -ModuleName M365DSCUtil -CommandName ConvertTo-DSCObject -MockWith {
            $Script:ParsedContent += $Content
            @{ ResourceName = 'AADGroup'; ResourceInstanceName = 'Group' }
        }
        Mock -ModuleName M365DSCUtil -CommandName Export-M365DSCConfiguration
        Mock -ModuleName M365DSCUtil -CommandName New-M365DSCDeltaReport
    }

    It 'strips the module version from a blueprint' {
        Assert-M365DSCBlueprint -BluePrintUrl $Script:BlueprintPath -OutputReportPath (Join-Path $TestDrive 'report.html')

        $Script:ParsedContent.Count | Should -Be 1
        $Script:ParsedContent[0] | Should -Not -Match '-ModuleVersion'
        $Script:ParsedContent[0] | Should -Match "Import-DscResource -ModuleName 'Microsoft365DSC'`n"
        Should -Invoke -ModuleName M365DSCUtil -CommandName New-M365DSCDeltaReport -Exactly -Times 1
        Should -Invoke -ModuleName M365DSCUtil -CommandName Export-M365DSCConfiguration -Exactly -Times 1 -ParameterFilter {
            -not $PesterBoundParameters.ContainsKey('Credential') -and -not $PesterBoundParameters.ContainsKey('TenantId') -and -not $PesterBoundParameters.ContainsKey('ApplicationSecret')
        }
        Should -Invoke -ModuleName M365DSCUtil -CommandName Add-M365DSCTelemetryEvent -Exactly -Times 1 -ParameterFilter {
            $Data['BluePrintSource'] -eq 'File' -and -not $Data.ContainsKey('BluePrint')
        }

        $secret = [System.Management.Automation.PSCredential]::new('app', (ConvertTo-SecureString -String 'secret-value' -AsPlainText -Force))
        Assert-M365DSCBlueprint -BluePrintUrl $Script:BlueprintPath -OutputReportPath (Join-Path $TestDrive 'report.html') `
            -ApplicationId 'app-id' -TenantId 'contoso.onmicrosoft.com' -ApplicationSecret $secret
        Should -Invoke -ModuleName M365DSCUtil -CommandName Export-M365DSCConfiguration -Exactly -Times 1 -ParameterFilter {
            $ApplicationSecret -eq 'secret-value' -and $TenantId -eq 'contoso.onmicrosoft.com' -and -not $PesterBoundParameters.ContainsKey('Credential')
        }
    }

    It 'returns to the caller and removes the temp blueprint when every resource is excluded' {
        $before = @(Get-ChildItem -Path $env:TEMP -Filter 'TempBlueprint_*.M365' -ErrorAction SilentlyContinue).Count
        $iterations = 0
        foreach ($i in 1..2)
        {
            Assert-M365DSCBlueprint -BluePrintUrl $Script:BlueprintPath -OutputReportPath (Join-Path $TestDrive 'report.html') `
                -ExcludedResources @('AADGroup')
            $iterations++
        }

        $iterations | Should -Be 2
        Should -Invoke -ModuleName M365DSCUtil -CommandName Export-M365DSCConfiguration -Exactly -Times 0
        @(Get-ChildItem -Path $env:TEMP -Filter 'TempBlueprint_*.M365' -ErrorAction SilentlyContinue).Count | Should -Be $before
    }
}

Describe 'Get-TeamByName' {
    BeforeAll {
        Mock -ModuleName M365DSCUtil -CommandName Start-Sleep -MockWith {}
    }

    It 'Queries once without sleeping when the team is missing and no retry is requested' {
        Mock -ModuleName M365DSCUtil -CommandName Get-Team -MockWith { return $null }

        $result = & $Script:UtilModule { Get-TeamByName -TeamName 'Missing%20Team' }

        $result | Should -BeNullOrEmpty
        Should -Invoke -ModuleName M365DSCUtil -CommandName Get-Team -Exactly -Times 1
        Should -Invoke -ModuleName M365DSCUtil -CommandName Start-Sleep -Exactly -Times 0
    }

    It 'Retries the requested number of times without sleeping after the last attempt' {
        Mock -ModuleName M365DSCUtil -CommandName Get-Team -MockWith { return $null }

        $result = & $Script:UtilModule { Get-TeamByName -TeamName 'Missing' -RetryCount 2 }

        $result | Should -BeNullOrEmpty
        Should -Invoke -ModuleName M365DSCUtil -CommandName Get-Team -Exactly -Times 3
        Should -Invoke -ModuleName M365DSCUtil -CommandName Start-Sleep -Exactly -Times 2
    }

    It 'Stops retrying as soon as the team is found' {
        Mock -ModuleName M365DSCUtil -CommandName Get-Team -MockWith {
            return [PSCustomObject] @{ DisplayName = 'Test Team'; GroupId = '12345' }
        }

        $result = & $Script:UtilModule { Get-TeamByName -TeamName 'Test%20Team' -RetryCount 5 }

        $result.GroupId | Should -Be '12345'
        Should -Invoke -ModuleName M365DSCUtil -CommandName Get-Team -Exactly -Times 1
        Should -Invoke -ModuleName M365DSCUtil -CommandName Start-Sleep -Exactly -Times 0
    }
}

Describe 'Get-M365DSCConfigurationConflict' {
    BeforeAll {
        Mock -ModuleName M365DSCUtil -CommandName Get-M365DSCResourceDefinition -ParameterFilter { $ResourceName -eq 'TestResource' } -MockWith {
            return [PSCustomObject] @{
                Name       = 'TestResource'
                Properties = @(
                    [PSCustomObject] @{ Name = 'Identity'; Option = 'Key'; IsMandatory = $true },
                    [PSCustomObject] @{ Name = 'DisplayName'; Option = 'Required'; IsMandatory = $true },
                    [PSCustomObject] @{ Name = 'Description'; Option = 'Write'; IsMandatory = $false }
                )
            }
        }
        Mock -ModuleName M365DSCUtil -CommandName Get-M365DSCResourceDefinition -ParameterFilter { $ResourceName -eq 'UnknownResource' } -MockWith {
            return $null
        }
    }

    It 'Reports key collisions that differ only in case or in Required properties' {
        Mock -ModuleName M365DSCUtil -CommandName ConvertTo-DSCObject -MockWith {
            return @(
                @{ ResourceName = 'TestResource'; ResourceInstanceName = 'First'; Identity = 'Contoso'; DisplayName = 'One' },
                @{ ResourceName = 'TestResource'; ResourceInstanceName = 'Second'; Identity = 'contoso'; DisplayName = 'Two' },
                @{ ResourceName = 'TestResource'; ResourceInstanceName = 'Third'; Identity = 'Fabrikam'; DisplayName = 'One' }
            )
        }

        [Array]$results = & $Script:UtilModule { Get-M365DSCConfigurationConflict -ConfigurationContent 'content' }

        $results.Count | Should -Be 1
        $results[0].InstanceName | Should -Be 'Second'
        $results[0].Reason | Should -Be 'DuplicatePrimaryKey'
        $results[0].AdditionalProperties.Keys | Should -Be @('Identity')
        $results[0].AdditionalProperties.Identity | Should -Be 'contoso'
    }

    It 'Skips resources without a definition' {
        Mock -ModuleName M365DSCUtil -CommandName ConvertTo-DSCObject -MockWith {
            return @(
                @{ ResourceName = 'UnknownResource'; ResourceInstanceName = 'First'; Name = 'A' },
                @{ ResourceName = 'UnknownResource'; ResourceInstanceName = 'Second'; Name = 'B' }
            )
        }

        [Array]$results = & $Script:UtilModule { Get-M365DSCConfigurationConflict -ConfigurationContent 'content' }

        $results.Count | Should -Be 0
    }
}

Describe 'Directory name cache' {
    BeforeAll {
        Mock -ModuleName M365DSCUtil -CommandName Get-MgGroup -MockWith {
            return [PSCustomObject] @{ DisplayName = 'Group Name' }
        }
        Mock -ModuleName M365DSCUtil -CommandName Get-MgUser -MockWith {
            return [PSCustomObject] @{ UserPrincipalName = 'user@contoso.com' }
        }
    }

    BeforeEach {
        $Script:PreviousExportFlag = $Global:M365DSCExportInProgress
        & $Script:UtilModule { Clear-M365DSCDirectoryNameCache }
    }

    AfterEach {
        $Global:M365DSCExportInProgress = $Script:PreviousExportFlag
        & $Script:UtilModule { Clear-M365DSCDirectoryNameCache }
    }

    It 'Resolves each id once during an export until the cache is cleared' {
        $Global:M365DSCExportInProgress = $true

        & $Script:UtilModule { Get-M365DSCGroupDisplayNameById -GroupId 'aaaa' } | Should -Be 'Group Name'
        & $Script:UtilModule { Get-M365DSCGroupDisplayNameById -GroupId 'AAAA' } | Should -Be 'Group Name'
        & $Script:UtilModule { Get-M365DSCUserPrincipalNameById -UserId 'bbbb' } | Should -Be 'user@contoso.com'
        & $Script:UtilModule { Get-M365DSCUserPrincipalNameById -UserId 'bbbb' } | Should -Be 'user@contoso.com'

        Should -Invoke -ModuleName M365DSCUtil -CommandName Get-MgGroup -Exactly -Times 1 -Scope It
        Should -Invoke -ModuleName M365DSCUtil -CommandName Get-MgUser -Exactly -Times 1 -Scope It

        & $Script:UtilModule { Clear-M365DSCDirectoryNameCache }
        & $Script:UtilModule { Get-M365DSCGroupDisplayNameById -GroupId 'aaaa' } | Should -Be 'Group Name'
        Should -Invoke -ModuleName M365DSCUtil -CommandName Get-MgGroup -Exactly -Times 2 -Scope It
    }

    It 'Does not cache outside of an export' {
        $Global:M365DSCExportInProgress = $false

        & $Script:UtilModule { Get-M365DSCGroupDisplayNameById -GroupId 'aaaa' } | Should -Be 'Group Name'
        & $Script:UtilModule { Get-M365DSCGroupDisplayNameById -GroupId 'aaaa' } | Should -Be 'Group Name'

        Should -Invoke -ModuleName M365DSCUtil -CommandName Get-MgGroup -Exactly -Times 2 -Scope It
    }
}
