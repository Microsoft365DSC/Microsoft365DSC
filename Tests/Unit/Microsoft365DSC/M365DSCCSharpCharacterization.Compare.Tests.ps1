BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader

    $Script:Schema = [object[]]@(
        @{
            ClassName  = 'MSFT_TestResource'
            Parameters = @(
                @{ Name = 'Identity'; CIMType = 'String'; Option = 'Key' }
                @{ Name = 'DisplayName'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Count'; CIMType = 'UInt32'; Option = 'Write' }
                @{ Name = 'Tags'; CIMType = 'StringArray'; Option = 'Write' }
                @{ Name = 'Ensure'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Credential'; CIMType = 'PSCredential'; Option = 'Write' }
                @{ Name = 'Items'; CIMType = 'MSFT_TestItem[]'; Option = 'Write' }
                @{ Name = 'Plain'; CIMType = 'MSFT_TestNoKeyItem[]'; Option = 'Write' }
                @{ Name = 'Assignments'; CIMType = 'MSFT_IntuneTestPolicyAssignments[]'; Option = 'Write' }
                @{ Name = 'Id'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Targets'; CIMType = 'MSFT_TestTarget[]'; Option = 'Write' }
                @{ Name = 'Nesting'; CIMType = 'MSFT_TestNesting'; Option = 'Write' }
            )
        }
        @{
            ClassName  = 'MSFT_TestTarget'
            Parameters = @(
                @{ Name = 'Id'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'TargetType'; CIMType = 'String'; Option = 'Write' }
            )
        }
        @{
            ClassName  = 'MSFT_TestNesting'
            Parameters = @(
                @{ Name = 'State'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Target'; CIMType = 'MSFT_TestTarget'; Option = 'Write' }
                @{ Name = 'Targets'; CIMType = 'MSFT_TestTarget[]'; Option = 'Write' }
                @{ Name = 'KeyedTargets'; CIMType = 'MSFT_TestKeyedTarget[]'; Option = 'Write' }
            )
        }
        @{
            ClassName  = 'MSFT_TestKeyedTarget'
            Parameters = @(
                @{ Name = 'Id'; CIMType = 'String'; Option = 'Key' }
                @{ Name = 'Value'; CIMType = 'String'; Option = 'Write' }
            )
        }
        @{
            ClassName  = 'MSFT_TestItem'
            Parameters = @(
                @{ Name = 'Key'; CIMType = 'String'; Option = 'Required' }
                @{ Name = 'Value'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Tags'; CIMType = 'StringArray'; Option = 'Write' }
                @{ Name = 'Detail'; CIMType = 'MSFT_TestNoKeyItem'; Option = 'Write' }
            )
        }
        @{
            ClassName  = 'MSFT_TestNoKeyItem'
            Parameters = @(
                @{ Name = 'Name'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Value'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Key'; CIMType = 'String'; Option = 'Write' }
            )
        }
        @{
            ClassName  = 'MSFT_IntuneTestPolicyAssignments'
            Parameters = @(
                @{ Name = 'dataType'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'groupId'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'groupDisplayName'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'deviceAndAppManagementAssignmentFilterType'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'deviceAndAppManagementAssignmentFilterId'; CIMType = 'String'; Option = 'Write' }
            )
        }
        @{
            ClassName  = 'MSFT_TestNoKeyResource'
            Parameters = @(
                @{ Name = 'Setting'; CIMType = 'String'; Option = 'Write' }
            )
        }
        @{
            ClassName         = 'MSFT_TestExcluded'
            Parameters        = @(
                @{ Name = 'Identity'; CIMType = 'String'; Option = 'Key' }
                @{ Name = 'Ignored'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Kept'; CIMType = 'String'; Option = 'Write' }
            )
            CompareParameters = @{ ExcludedProperties = @('Ignored') }
        }
        @{
            ClassName  = 'MSFT_AADGroup'
            Parameters = @(
                @{ Name = 'DisplayName'; CIMType = 'String'; Option = 'Key' }
                @{ Name = 'MailNickname'; CIMType = 'String'; Option = 'Required' }
                @{ Name = 'Description'; CIMType = 'String'; Option = 'Write' }
            )
        }
        @{
            ClassName  = 'MSFT_TeamsChannel'
            Parameters = @(
                @{ Name = 'TeamName'; CIMType = 'String'; Option = 'Required' }
                @{ Name = 'DisplayName'; CIMType = 'String'; Option = 'Key' }
                @{ Name = 'Description'; CIMType = 'String'; Option = 'Write' }
            )
        }
        @{
            ClassName         = 'MSFT_TestRules'
            Parameters        = @(
                @{ Name = 'Identity'; CIMType = 'String'; Option = 'Key' }
                @{ Name = 'Mode'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Notes'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Window'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Members'; CIMType = 'StringArray'; Option = 'Write' }
                @{ Name = 'Owners'; CIMType = 'StringArray'; Option = 'Write' }
                @{ Name = 'Settings'; CIMType = 'MSFT_TestRuleSetting[]'; Option = 'Write' }
                @{ Name = 'ScheduleInfo'; CIMType = 'MSFT_TestRuleSchedule'; Option = 'Write' }
            )
            CompareParameters = @{
                CompareRules = @(
                    @{ Type = 'RemoveWhen'; Properties = @('Notes'); When = @{ Property = 'Mode'; Equals = 'Off' } }
                )
            }
        }
        @{
            ClassName  = 'MSFT_TestRuleSetting'
            Parameters = @(
                @{ Name = 'Name'; CIMType = 'String'; Option = 'Key' }
                @{ Name = 'Value'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Version'; CIMType = 'String'; Option = 'Write' }
            )
        }
        @{
            ClassName  = 'MSFT_TestRuleSchedule'
            Parameters = @(
                @{ Name = 'StartDateTime'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'Expiration'; CIMType = 'MSFT_TestRuleExpiration'; Option = 'Write' }
            )
        }
        @{
            ClassName  = 'MSFT_TestRuleExpiration'
            Parameters = @(
                @{ Name = 'type'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'duration'; CIMType = 'String'; Option = 'Write' }
                @{ Name = 'endDateTime'; CIMType = 'String'; Option = 'Write' }
            )
        }
    )

    function New-Resource
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)] [System.String] $ResourceName,
            [Parameter()] [System.String] $InstanceName,
            [Parameter()] [System.Collections.Hashtable] $Values = @{ }
        )

        $resource = @{ ResourceName = $ResourceName }
        $resource['ResourceInstanceName'] = if ($InstanceName) { $InstanceName } else { "$ResourceName-default" }
        foreach ($key in $Values.Keys)
        {
            $resource[$key] = $Values[$key]
        }

        return $resource
    }

    function Invoke-ConfigurationCompare
    {
        [CmdletBinding()]
        param
        (
            [Parameter()] [System.Object[]] $Source = @(),
            [Parameter()] [System.Object[]] $Destination = @(),
            [Parameter()] [System.String[]] $ExcludedProperties,
            [Parameter()] [System.String[]] $ExcludedResources,
            [Parameter()] $CompareParameters,
            [Parameter()] $SchemaOverride
        )

        $schema = $Script:Schema
        if ($null -ne $SchemaOverride)
        {
            $schema = $SchemaOverride
        }
        $deltas = [Microsoft365DSC.Compare.ConfigurationComparer]::Compare(
            [object[]] $Source, [object[]] $Destination, $schema, $ExcludedProperties, $ExcludedResources, $CompareParameters)

        return , [object[]] @($deltas | ForEach-Object -Process { $_.ToHashtable() })
    }

    function New-CompareParameters
    {
        [CmdletBinding()]
        param
        (
            [Parameter()] [System.String[]] $ExcludedProperties,
            [Parameter()] [System.String[]] $IncludedProperties,
            [Parameter()] [System.Management.Automation.ScriptBlock] $PostProcessing,
            [Parameter()] [System.Object[]] $PostProcessingArgs
        )

        $parameters = [Microsoft365DSC.Compare.ResourceCompareParameters]::new()
        $parameters.ExcludedProperties = $ExcludedProperties
        $parameters.IncludedProperties = $IncludedProperties
        if ($null -ne $PostProcessing)
        {
            $parameters.PostProcessing = [System.Func[System.Collections.Hashtable, System.Collections.Hashtable, System.Collections.Hashtable, System.Object[], System.Tuple[System.Collections.Hashtable, System.Collections.Hashtable, System.Collections.Hashtable]]] $PostProcessing
        }
        $parameters.PostProcessingArgs = $PostProcessingArgs

        return $parameters
    }

    function New-CompareParameterMap
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)] [System.String] $ResourceName,
            [Parameter(Mandatory = $true)] [Microsoft365DSC.Compare.ResourceCompareParameters] $Parameters
        )

        $map = [System.Collections.Generic.Dictionary[System.String, Microsoft365DSC.Compare.ResourceCompareParameters]]::new()
        $map.Add($ResourceName, $Parameters)
        return $map
    }

    function Invoke-ResourceCompare
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)] $Desired,
            [Parameter()] $Current,
            [Parameter()] $ValuesToCheck,
            [Parameter()] [System.String] $ResourceName = 'TestResource',
            [Parameter()] [System.String[]] $ExcludedProperties,
            [Parameter()] [System.String[]] $IncludedProperties,
            [Parameter()] $SchemaOverride
        )

        if ($null -eq $ValuesToCheck) { $ValuesToCheck = $Desired }
        $schema = $Script:Schema
        if ($null -ne $SchemaOverride)
        {
            $schema = $SchemaOverride
        }

        return [Microsoft365DSC.Compare.ResourceComparer]::Compare($Desired, $Current, $ValuesToCheck, $schema, $ResourceName, $ExcludedProperties, $IncludedProperties)
    }

    function Invoke-RuleCompare
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Object[]] $Rules,
            [Parameter(Mandatory = $true)] [System.Collections.Hashtable] $Source,
            [Parameter(Mandatory = $true)] [System.Collections.Hashtable] $Destination,
            [Parameter()] [System.Nullable[System.DateTimeOffset]] $Now,
            [Parameter()] [System.Management.Automation.ScriptBlock] $PostProcessing
        )

        $parameters = New-CompareParameters -PostProcessing $PostProcessing
        $parameters.Rules = [Microsoft365DSC.Compare.CompareRule]::ParseAll($Rules)
        $parameters.Now = $Now
        $map = New-CompareParameterMap -ResourceName 'TestRules' -Parameters $parameters
        $Source['Identity'] = 'a'
        $Destination['Identity'] = 'a'
        $deltas = Invoke-ConfigurationCompare -CompareParameters $map `
            -Source @(New-Resource -ResourceName 'TestRules' -InstanceName 'S' -Values $Source) `
            -Destination @(New-Resource -ResourceName 'TestRules' -InstanceName 'D' -Values $Destination)

        return , [string[]] @($deltas | ForEach-Object -Process { $_['Properties'][0]['ParameterName'] })
    }

    function Get-DriftNames
    {
        [CmdletBinding()]
        param([Parameter(Mandatory = $true)] $Result)

        return @($Result.DriftInfo | ForEach-Object -Process { $_['PropertyName'] })
    }
}

Describe 'ConfigurationComparer.Compare' {
    Context 'Presence' {
        It 'Reports a source-only instance as Present in the source and Absent in the destination' {
            $deltas = Invoke-ConfigurationCompare -Source @(New-Resource -ResourceName 'TestResource' -InstanceName 'Inst' -Values @{ Identity = 'a'; DisplayName = 'x' })

            $deltas.Count | Should -Be 1
            $deltas[0]['ResourceName'] | Should -Be 'TestResource'
            $deltas[0]['ResourceInstanceName'] | Should -Be 'Inst'
            $deltas[0]['Key'] | Should -Be 'Identity'
            $deltas[0]['KeyValue'] | Should -Be 'a'
            $deltas[0]['Properties'].Count | Should -Be 1
            $deltas[0]['Properties'][0]['ParameterName'] | Should -Be '_IsInConfiguration_'
            $deltas[0]['Properties'][0]['ValueInSource'] | Should -Be 'Present'
            $deltas[0]['Properties'][0]['ValueInDestination'] | Should -Be 'Absent'
        }

        It 'Reports a destination-only instance as Absent in the source and Present in the destination' {
            $deltas = Invoke-ConfigurationCompare -Destination @(New-Resource -ResourceName 'TestResource' -InstanceName 'Inst' -Values @{ Identity = 'a' })

            $deltas.Count | Should -Be 1
            $deltas[0]['Properties'][0]['ParameterName'] | Should -Be '_IsInConfiguration_'
            $deltas[0]['Properties'][0]['ValueInSource'] | Should -Be 'Absent'
            $deltas[0]['Properties'][0]['ValueInDestination'] | Should -Be 'Present'
        }

        It 'Reports an instance of a resource without mandatory parameters as missing on both sides' {
            $resource = New-Resource -ResourceName 'TestNoKeyResource' -InstanceName 'Only' -Values @{ Setting = 'v' }
            $deltas = Invoke-ConfigurationCompare -Source @($resource) -Destination @($resource)

            $deltas.Count | Should -Be 2
            $deltas[0]['Key'] | Should -Be ''
            $deltas[0]['KeyValue'] | Should -Be ''
            $deltas[0]['Properties'][0]['ValueInSource'] | Should -Be 'Present'
            $deltas[1]['Properties'][0]['ValueInDestination'] | Should -Be 'Present'
        }

        It 'Reports an instance of a resource that is not in the schema as missing on both sides' {
            $resource = New-Resource -ResourceName 'NotInSchema' -InstanceName 'Only' -Values @{ Identity = 'a' }
            $deltas = Invoke-ConfigurationCompare -Source @($resource) -Destination @($resource)

            $deltas.Count | Should -Be 2
        }
    }

    Context 'Property drift' {
        It 'Reports one delta per drifted property with source and destination values' {
            $source = New-Resource -ResourceName 'TestResource' -InstanceName 'SourceInst' -Values @{ Identity = 'a'; DisplayName = 'x'; Count = 1 }
            $destination = New-Resource -ResourceName 'TestResource' -InstanceName 'DestInst' -Values @{ Identity = 'a'; DisplayName = 'y'; Count = 2 }
            $deltas = Invoke-ConfigurationCompare -Source @($source) -Destination @($destination)

            $deltas.Count | Should -Be 2
            $deltas | ForEach-Object -Process { $_['ResourceInstanceName'] | Should -Be 'SourceInst' }
            $displayName = $deltas | Where-Object -FilterScript { $_['Properties'][0]['ParameterName'] -eq 'DisplayName' }
            $displayName['Properties'][0]['ValueInSource'] | Should -Be 'x'
            $displayName['Properties'][0]['ValueInDestination'] | Should -Be 'y'
            $displayName['Key'] | Should -Be 'Identity'
            $displayName['KeyValue'] | Should -Be 'a'
        }

        It 'Reports nothing for identical instances' {
            $source = New-Resource -ResourceName 'TestResource' -InstanceName 'Inst' -Values @{ Identity = 'a'; DisplayName = 'x'; Tags = @('t1', 't2'); Ensure = 'Present' }
            $destination = New-Resource -ResourceName 'TestResource' -InstanceName 'Inst' -Values @{ Identity = 'a'; DisplayName = 'x'; Tags = @('t1', 't2'); Ensure = 'Present' }

            (Invoke-ConfigurationCompare -Source @($source) -Destination @($destination)).Count | Should -Be 0
        }

        It 'Carries DeltaValue only for array drifts' {
            $source = New-Resource -ResourceName 'TestResource' -InstanceName 'Inst' -Values @{ Identity = 'a'; DisplayName = 'x'; Tags = @('x', 'z') }
            $destination = New-Resource -ResourceName 'TestResource' -InstanceName 'Inst' -Values @{ Identity = 'a'; DisplayName = 'y'; Tags = @('x', 'y') }
            $deltas = Invoke-ConfigurationCompare -Source @($source) -Destination @($destination)

            $tags = ($deltas | Where-Object -FilterScript { $_['Properties'][0]['ParameterName'] -eq 'Tags' })['Properties'][0]
            $tags['ValueInSource'] | Should -Be 'x, z'
            $tags['ValueInDestination'] | Should -Be 'x, y'
            $tags['DeltaValue'] | Should -Be '<= y; => z'

            $displayName = ($deltas | Where-Object -FilterScript { $_['Properties'][0]['ParameterName'] -eq 'DisplayName' })['Properties'][0]
            $displayName.ContainsKey('DeltaValue') | Should -BeFalse
        }

        It 'Emits presence and property deltas in source order followed by destination-only instances' {
            $source = @(
                New-Resource -ResourceName 'TestResource' -InstanceName 'A' -Values @{ Identity = 'a'; DisplayName = 'x' }
                New-Resource -ResourceName 'TestResource' -InstanceName 'B' -Values @{ Identity = 'b'; DisplayName = 'x' }
            )
            $destination = @(
                New-Resource -ResourceName 'TestResource' -InstanceName 'C' -Values @{ Identity = 'c'; DisplayName = 'x' }
                New-Resource -ResourceName 'TestResource' -InstanceName 'A2' -Values @{ Identity = 'a'; DisplayName = 'y' }
            )
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination

            $deltas.Count | Should -Be 3
            $deltas[0]['KeyValue'] | Should -Be 'a'
            $deltas[0]['Properties'][0]['ParameterName'] | Should -Be 'DisplayName'
            $deltas[1]['KeyValue'] | Should -Be 'b'
            $deltas[1]['Properties'][0]['ValueInDestination'] | Should -Be 'Absent'
            $deltas[2]['KeyValue'] | Should -Be 'c'
            $deltas[2]['Properties'][0]['ValueInSource'] | Should -Be 'Absent'
        }
    }

    Context 'Pairing' {
        It 'Diffs against the first destination with the same key and does not report later duplicates as missing' {
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a'; DisplayName = 'x' })
            $destination = @(
                New-Resource -ResourceName 'TestResource' -InstanceName 'D1' -Values @{ Identity = 'a'; DisplayName = 'y1' }
                New-Resource -ResourceName 'TestResource' -InstanceName 'D2' -Values @{ Identity = 'a'; DisplayName = 'y2' }
            )
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination

            $deltas.Count | Should -Be 1
            $deltas[0]['Properties'][0]['ValueInDestination'] | Should -Be 'y1'
        }

        It 'Diffs every source duplicate against the same first destination' {
            $source = @(
                New-Resource -ResourceName 'TestResource' -InstanceName 'S1' -Values @{ Identity = 'a'; DisplayName = 'x1' }
                New-Resource -ResourceName 'TestResource' -InstanceName 'S2' -Values @{ Identity = 'a'; DisplayName = 'x2' }
            )
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'y' })
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination

            $deltas.Count | Should -Be 2
            $deltas[0]['ResourceInstanceName'] | Should -Be 'S1'
            $deltas[1]['ResourceInstanceName'] | Should -Be 'S2'
            $deltas | ForEach-Object -Process { $_['Properties'][0]['ValueInDestination'] | Should -Be 'y' }
        }

        It 'Matches key values as strings, ordinal and case-sensitive' {
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'A'; DisplayName = 'x' })
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'x' })

            (Invoke-ConfigurationCompare -Source $source -Destination $destination).Count | Should -Be 2
        }

        It 'Pairs a TeamsChannel by team name and display name' {
            $source = @(New-Resource -ResourceName 'TeamsChannel' -InstanceName 'S' -Values @{ TeamName = 't'; DisplayName = 'c'; Description = 'd1' })
            $destination = @(New-Resource -ResourceName 'TeamsChannel' -InstanceName 'D' -Values @{ TeamName = 't'; DisplayName = 'c'; Description = 'd2' })
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination

            $deltas.Count | Should -Be 1
            $deltas[0]['Key'] | Should -Be 'TeamName\DisplayName'
            $deltas[0]['KeyValue'] | Should -Be 't\c'
            $deltas[0]['Properties'][0]['ParameterName'] | Should -Be 'Description'
        }

        It 'Pairs an AADGroup by display name and mail nickname when the first instance carries one' {
            $source = @(New-Resource -ResourceName 'AADGroup' -InstanceName 'S' -Values @{ DisplayName = 'g'; MailNickname = 'a' })
            $destination = @(New-Resource -ResourceName 'AADGroup' -InstanceName 'D' -Values @{ DisplayName = 'g'; MailNickname = 'b' })
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination

            $deltas.Count | Should -Be 2
            $deltas[0]['Key'] | Should -Be 'DisplayName\MailNickname'
            $deltas[0]['KeyValue'] | Should -Be 'g\a'
        }

        It 'Lets the first instance of a resource decide the key for the whole comparison' {
            $source = @(
                New-Resource -ResourceName 'AADGroup' -InstanceName 'S1' -Values @{ DisplayName = 'first' }
                New-Resource -ResourceName 'AADGroup' -InstanceName 'S2' -Values @{ DisplayName = 'g'; MailNickname = 'a' }
            )
            $destination = @(New-Resource -ResourceName 'AADGroup' -InstanceName 'D' -Values @{ DisplayName = 'g'; MailNickname = 'b' })
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination

            $keyed = @($deltas | Where-Object -FilterScript { $_['KeyValue'] -eq 'g' })
            $keyed.Count | Should -Be 1
            $keyed[0]['Key'] | Should -Be 'DisplayName'
            $keyed[0]['Properties'][0]['ParameterName'] | Should -Be 'MailNickname'
        }
    }

    Context 'Exclusions and overrides' {
        It 'Skips excluded resources entirely' {
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a'; DisplayName = 'x' })

            (Invoke-ConfigurationCompare -Source $source -ExcludedResources @('TestResource')).Count | Should -Be 0
        }

        It 'Skips excluded properties and the always-excluded instance name and credentials' {
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a'; DisplayName = 'x'; Count = 1; Credential = 'c1' })
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'y'; Count = 1; Credential = 'c2' })

            (Invoke-ConfigurationCompare -Source $source -Destination $destination -ExcludedProperties @('DisplayName')).Count | Should -Be 0
        }

        It 'Honours the compare parameters declared in the schema' {
            $source = @(New-Resource -ResourceName 'TestExcluded' -InstanceName 'S' -Values @{ Identity = 'a'; Ignored = 'i1'; Kept = 'k1' })
            $destination = @(New-Resource -ResourceName 'TestExcluded' -InstanceName 'D' -Values @{ Identity = 'a'; Ignored = 'i2'; Kept = 'k2' })
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination

            $deltas.Count | Should -Be 1
            $deltas[0]['Properties'][0]['ParameterName'] | Should -Be 'Kept'
        }

        It 'Lets supplied compare parameters replace the schema declaration' {
            $source = @(New-Resource -ResourceName 'TestExcluded' -InstanceName 'S' -Values @{ Identity = 'a'; Ignored = 'i1'; Kept = 'k1' })
            $destination = @(New-Resource -ResourceName 'TestExcluded' -InstanceName 'D' -Values @{ Identity = 'a'; Ignored = 'i2'; Kept = 'k2' })
            $map = New-CompareParameterMap -ResourceName 'TestExcluded' -Parameters (New-CompareParameters -ExcludedProperties @('Kept'))
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination -CompareParameters $map

            $deltas.Count | Should -Be 1
            $deltas[0]['Properties'][0]['ParameterName'] | Should -Be 'Ignored'
        }

        It 'Copies a blueprint annotation onto the drift it explains and does not report the annotation itself' {
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a'; DisplayName = 'x' })
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'y'; _metadata_DisplayName = '### L1|Must match' })
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination

            $displayName = ($deltas | Where-Object -FilterScript { $_['Properties'][0]['ParameterName'] -eq 'DisplayName' })['Properties'][0]
            $displayName['_Metadata_Level'] | Should -Be 'L1'
            $displayName['_Metadata_Info'] | Should -Be 'Must match'
            @($deltas | Where-Object -FilterScript { $_['Properties'][0]['ParameterName'] -eq '_metadata_DisplayName' }).Count | Should -Be 0
        }

        It 'Copies a blueprint annotation written with spaces around the separator' {
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a'; DisplayName = 'x' })
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'y'; _metadata_DisplayName = '### L2 | Must match' })
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination

            $displayName = ($deltas | Where-Object -FilterScript { $_['Properties'][0]['ParameterName'] -eq 'DisplayName' })['Properties'][0]
            $displayName['_Metadata_Level'] | Should -Be 'L2'
            $displayName['_Metadata_Info'] | Should -Be 'Must match'
        }

        It 'Keeps a separator that is part of the annotation information' {
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a'; DisplayName = 'x' })
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'y'; _metadata_DisplayName = '### L3|Either a|b is allowed' })
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination

            $displayName = ($deltas | Where-Object -FilterScript { $_['Properties'][0]['ParameterName'] -eq 'DisplayName' })['Properties'][0]
            $displayName['_Metadata_Level'] | Should -Be 'L3'
            $displayName['_Metadata_Info'] | Should -Be 'Either a|b is allowed'
        }

        It 'Ignores a malformed blueprint annotation' {
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a'; DisplayName = 'x' })
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'y'; _metadata_DisplayName = 'no separator' })
            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination

            $displayName = ($deltas | Where-Object -FilterScript { $_['Properties'][0]['ParameterName'] -eq 'DisplayName' })['Properties'][0]
            $displayName.ContainsKey('_Metadata_Level') | Should -BeFalse
        }

        It 'Copies the Ensure annotation of a blueprint resource missing from the source onto its presence delta' {
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; Ensure = 'Present'; _metadata_Ensure = '### L3|Mandatory requirement'; _metadata_Identity = '### L1|Key annotation' })
            $deltas = Invoke-ConfigurationCompare -Destination $destination

            $presence = $deltas[0]['Properties'][0]
            $presence['ParameterName'] | Should -Be '_IsInConfiguration_'
            $presence['_Metadata_Level'] | Should -Be 'L3'
            $presence['_Metadata_Info'] | Should -Be 'Mandatory requirement'
        }

        It 'Falls back to the key annotation of a blueprint resource missing from the source' {
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; _metadata_Identity = '### L2|Key annotation' })
            $deltas = Invoke-ConfigurationCompare -Destination $destination

            $presence = $deltas[0]['Properties'][0]
            $presence['_Metadata_Level'] | Should -Be 'L2'
            $presence['_Metadata_Info'] | Should -Be 'Key annotation'
        }

        It 'Leaves the presence delta of an unannotated blueprint resource without metadata' {
            $deltas = Invoke-ConfigurationCompare -Destination @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'y'; _metadata_DisplayName = '### L1|Not a key' })

            $deltas[0]['Properties'][0].ContainsKey('_Metadata_Level') | Should -BeFalse
        }
    }

    Context 'PostProcessing' {
        It 'Invokes PostProcessing once per matched pair with destination as desired, source as current and the supplied arguments' {
            $Script:Calls = [System.Collections.Generic.List[object]]::new()
            $postProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $Arguments)
                $Script:Calls.Add(@{ Desired = $DesiredValues['DisplayName']; Current = $CurrentValues['DisplayName']; ToCheck = $ValuesToCheck['DisplayName']; Args = $Arguments })
                return $null
            }
            $map = New-CompareParameterMap -ResourceName 'TestResource' -Parameters (New-CompareParameters -PostProcessing $postProcessing -PostProcessingArgs @('arg1', 2))
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a'; DisplayName = 'x' })
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'y' })

            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination -CompareParameters $map

            $Script:Calls.Count | Should -Be 1
            $Script:Calls[0].Desired | Should -Be 'y'
            $Script:Calls[0].Current | Should -Be 'x'
            $Script:Calls[0].ToCheck | Should -Be 'y'
            $Script:Calls[0].Args | Should -Be @('arg1', 2)
            $deltas.Count | Should -Be 1
        }

        It 'Uses the tuple PostProcessing returns' {
            $postProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $Arguments)
                $ValuesToCheck.Remove('DisplayName')
                return [System.Tuple[System.Collections.Hashtable, System.Collections.Hashtable, System.Collections.Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
            $map = New-CompareParameterMap -ResourceName 'TestResource' -Parameters (New-CompareParameters -PostProcessing $postProcessing)
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a'; DisplayName = 'x' })
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'y' })

            (Invoke-ConfigurationCompare -Source $source -Destination $destination -CompareParameters $map).Count | Should -Be 0
        }

        It 'Hands clones to PostProcessing, so writes do not reach the caller''s data' {
            $postProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $Arguments)
                $DesiredValues['DisplayName'] = 'rewritten'
                return $null
            }
            $map = New-CompareParameterMap -ResourceName 'TestResource' -Parameters (New-CompareParameters -PostProcessing $postProcessing)
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a'; DisplayName = 'x' })
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'y' })

            $null = Invoke-ConfigurationCompare -Source $source -Destination $destination -CompareParameters $map

            $destination[0]['DisplayName'] | Should -Be 'y'
        }
    }

    Context 'Input shapes' {
        It 'Unwraps PSObject-wrapped hashtables and skips entries that are not hashtables' -Tag 'CurrentBehaviour' {
            $wrapped = [System.Management.Automation.PSObject]::new((New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a' }))
            $custom = [PSCustomObject]@{ ResourceName = 'TestResource'; ResourceInstanceName = 'C'; Identity = 'b' }

            $deltas = Invoke-ConfigurationCompare -Source @($wrapped, $custom)

            $deltas.Count | Should -Be 1
            $deltas[0]['KeyValue'] | Should -Be 'a'
        }

        It 'Accepts the schema as PSCustomObjects from ConvertFrom-Json' {
            $jsonSchema = [object[]] ($Script:Schema | ConvertTo-Json -Depth 6 | ConvertFrom-Json)
            $source = @(New-Resource -ResourceName 'TestResource' -InstanceName 'S' -Values @{ Identity = 'a'; DisplayName = 'x' })
            $destination = @(New-Resource -ResourceName 'TestResource' -InstanceName 'D' -Values @{ Identity = 'a'; DisplayName = 'y' })

            $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination -SchemaOverride $jsonSchema

            $deltas.Count | Should -Be 1
            $deltas[0]['Properties'][0]['ParameterName'] | Should -Be 'DisplayName'
        }
    }
}

Describe 'ResourceComparer.Compare complex properties' {
    It 'Aligns array elements by primary key and reports matched, missing and extra elements' {
        $desired = @{ Identity = 'a'; Items = @(@{ Key = 'k1'; Value = 'v1' }, @{ Key = 'k2'; Value = 'v2' }) }
        $current = @{ Identity = 'a'; Items = @(@{ Key = 'k1'; Value = 'vX' }, @{ Key = 'k3'; Value = 'v3' }) }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        $result.TestResult | Should -BeFalse
        Get-DriftNames -Result $result | Should -Be @('Items[0].Value', 'Items[1]', 'Items[extra:1]')
        $result.DriftInfo[0]['CurrentValue'] | Should -Be 'vX'
        $result.DriftInfo[0]['DesiredValue'] | Should -Be 'v1'
        $result.DriftInfo[1]['CurrentValue'] | Should -BeNullOrEmpty
        $result.DriftInfo[1]['DesiredValue']['Key'] | Should -Be 'k2'
        $result.DriftInfo[2]['CurrentValue']['Key'] | Should -Be 'k3'
        $result.DriftInfo[2]['DesiredValue'] | Should -BeNullOrEmpty
    }

    It 'Matches primary keys case-insensitively and does not report the key itself' {
        $desired = @{ Identity = 'a'; Items = @(@{ Key = 'k1'; Value = 'v1' }) }
        $current = @{ Identity = 'a'; Items = @(@{ Key = 'K1'; Value = 'v1' }) }

        (Invoke-ResourceCompare -Desired $desired -Current $current).TestResult | Should -BeTrue
    }

    It 'Reports a count mismatch for arrays without primary keys' {
        $desired = @{ Identity = 'a'; Plain = @(@{ Name = 'a'; Value = 1 }) }
        $current = @{ Identity = 'a'; Plain = @(@{ Name = 'a'; Value = 1 }, @{ Name = 'b'; Value = 2 }) }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        Get-DriftNames -Result $result | Should -Be @('Plain')
        $result.DriftInfo[0]['CurrentValue'] | Should -Be 'Current value has {2} items'
        $result.DriftInfo[0]['DesiredValue'] | Should -Be 'Desired value has {1} items'
    }

    It 'Keeps only the failed attempts of the first unmatched element, in candidate order, for arrays without primary keys' {
        $desired = @{ Identity = 'a'; Plain = @(@{ Name = 'a'; Value = 1 }, @{ Name = 'b'; Value = 2 }, @{ Name = 'c'; Value = 3 }) }
        $current = @{ Identity = 'a'; Plain = @(@{ Name = 'z'; Value = 2 }, @{ Name = 'a'; Value = 1 }, @{ Name = 'y'; Value = 2 }) }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        $result.TestResult | Should -BeFalse
        Get-DriftNames -Result $result | Should -Be @('Plain[1].Name', 'Plain[1].Name')
        $result.DriftInfo[0]['CurrentValue'] | Should -Be 'z'
        $result.DriftInfo[0]['DesiredValue'] | Should -Be 'b'
        $result.DriftInfo[1]['CurrentValue'] | Should -Be 'y'
        $result.DriftInfo[1]['DesiredValue'] | Should -Be 'b'
    }

    It 'Reports no drift when every element of an array without primary keys has a match' {
        $desired = @{ Identity = 'a'; Plain = @(@{ Name = 'a'; Value = 1 }, @{ Name = 'b'; Value = 2 }) }
        $current = @{ Identity = 'a'; Plain = @(@{ Name = 'b'; Value = 2 }, @{ Name = 'a'; Value = 1 }) }

        (Invoke-ResourceCompare -Desired $desired -Current $current).TestResult | Should -BeTrue
    }

    It 'Applies an excluded property name at every nesting level' {
        $desired = @{ Identity = 'a'; Items = @(@{ Key = 'k1'; Value = 'v1'; Detail = @{ Value = 'd1' } }) }
        $current = @{ Identity = 'a'; Items = @(@{ Key = 'k1'; Value = 'v2'; Detail = @{ Value = 'd2' } }) }

        (Get-DriftNames -Result (Invoke-ResourceCompare -Desired $desired -Current $current) | Sort-Object) | Should -Be @('Items[0].Detail.Value', 'Items[0].Value')
        (Invoke-ResourceCompare -Desired $desired -Current $current -ExcludedProperties @('Value')).TestResult | Should -BeTrue
    }

    It 'Removes the primary key from the element root only' {
        $desired = @{ Identity = 'a'; Items = @(@{ Key = 'k1'; Detail = @{ Key = 'inner1' } }) }
        $current = @{ Identity = 'a'; Items = @(@{ Key = 'k1'; Detail = @{ Key = 'inner2' } }) }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        Get-DriftNames -Result $result | Should -Be @('Items[0].Detail.Key')
    }

    It 'Reports a nested array drift with its delta' {
        $desired = @{ Identity = 'a'; Items = @(@{ Key = 'k1'; Tags = @('a', 'b') }) }
        $current = @{ Identity = 'a'; Items = @(@{ Key = 'k1'; Tags = @('a', 'c') }) }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        Get-DriftNames -Result $result | Should -Be @('Items[0].Tags')
        $result.DriftInfo[0]['CurrentValue'] | Should -Be 'a, c'
        $result.DriftInfo[0]['DesiredValue'] | Should -Be 'a, b'
        $result.DriftInfo[0]['DeltaValue'] | Should -Be '<= b; => c'
    }

    It 'Compares a single complex property as one object' {
        $desired = @{ Identity = 'a'; Detail = @{ Name = 'n'; Value = 'v1' } }
        $current = @{ Identity = 'a'; Detail = @{ Name = 'n'; Value = 'v2' } }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current -ResourceName 'TestItem'

        Get-DriftNames -Result $result | Should -Be @('Detail.Value')
    }

    It 'Compares the Id of an element of a nested array' {
        $desired = @{ Identity = 'a'; Nesting = @{ State = 'enabled'; Targets = @(@{ Id = 'group-a'; TargetType = 'group' }) } }
        $current = @{ Identity = 'a'; Nesting = @{ State = 'enabled'; Targets = @(@{ Id = 'group-b'; TargetType = 'group' }) } }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        $result.TestResult | Should -BeFalse
        Get-DriftNames -Result $result | Should -Be @('Nesting.Targets[0].Id')
        $result.DriftInfo[0]['CurrentValue'] | Should -Be 'group-b'
        $result.DriftInfo[0]['DesiredValue'] | Should -Be 'group-a'
    }

    It 'Compares the Id of a nested single complex property' {
        $desired = @{ Identity = 'a'; Nesting = @{ State = 'enabled'; Target = @{ Id = 'group-a'; TargetType = 'group' } } }
        $current = @{ Identity = 'a'; Nesting = @{ State = 'enabled'; Target = @{ Id = 'group-b'; TargetType = 'group' } } }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        $result.TestResult | Should -BeFalse
        Get-DriftNames -Result $result | Should -Be @('Nesting.Target.Id')
    }

    It 'Compares the Id of an element of a top-level array without primary keys' {
        $desired = @{ Identity = 'a'; Targets = @(@{ Id = 'group-a'; TargetType = 'group' }) }
        $current = @{ Identity = 'a'; Targets = @(@{ Id = 'group-b'; TargetType = 'group' }) }

        (Invoke-ResourceCompare -Desired $desired -Current $current).TestResult | Should -BeFalse
    }

    It 'Ignores the Id of the resource itself' {
        $desired = @{ Identity = 'a'; Id = 'server-assigned-1'; DisplayName = 'x' }
        $current = @{ Identity = 'a'; Id = 'server-assigned-2'; DisplayName = 'x' }

        (Invoke-ResourceCompare -Desired $desired -Current $current).TestResult | Should -BeTrue
    }

    It 'Reports no drift when a nested Id matches' {
        $desired = @{ Identity = 'a'; Nesting = @{ State = 'enabled'; Targets = @(@{ Id = 'group-a'; TargetType = 'group' }) } }

        (Invoke-ResourceCompare -Desired $desired -Current $desired).TestResult | Should -BeTrue
    }

    It 'Aligns the elements of a nested array by primary key' {
        $desired = @{ Identity = 'a'; Nesting = @{ KeyedTargets = @(@{ Id = '1'; Value = 'a' }, @{ Id = '2'; Value = 'b' }) } }
        $current = @{ Identity = 'a'; Nesting = @{ KeyedTargets = @(@{ Id = '2'; Value = 'Y' }, @{ Id = '1'; Value = 'X' }) } }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        $result.TestResult | Should -BeFalse
        Get-DriftNames -Result $result | Should -Be @('Nesting.KeyedTargets[0].Value', 'Nesting.KeyedTargets[1].Value')
        $result.DriftInfo[0]['CurrentValue'] | Should -Be 'X'
        $result.DriftInfo[0]['DesiredValue'] | Should -Be 'a'
        $result.DriftInfo[1]['CurrentValue'] | Should -Be 'Y'
        $result.DriftInfo[1]['DesiredValue'] | Should -Be 'b'
    }

    It 'Reports a missing and an extra element of a nested array when a primary key changes' {
        $desired = @{ Identity = 'a'; Nesting = @{ KeyedTargets = @(@{ Id = '1'; Value = 'a' }) } }
        $current = @{ Identity = 'a'; Nesting = @{ KeyedTargets = @(@{ Id = '9'; Value = 'a' }) } }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        $result.TestResult | Should -BeFalse
        Get-DriftNames -Result $result | Should -Be @('Nesting.KeyedTargets[0]', 'Nesting.KeyedTargets[extra:0]')
        $result.DriftInfo[0]['DesiredValue']['Id'] | Should -Be '1'
        $result.DriftInfo[1]['CurrentValue']['Id'] | Should -Be '9'
    }

    It 'Does not report the primary key of a paired nested element' {
        $desired = @{ Identity = 'a'; Nesting = @{ KeyedTargets = @(@{ Id = '1'; Value = 'a' }) } }

        (Invoke-ResourceCompare -Desired $desired -Current $desired).TestResult | Should -BeTrue
    }

    It 'Reports the simple array drift text and delta' {
        $desired = @{ Identity = 'a'; Tags = @('x', 'y') }
        $current = @{ Identity = 'a'; Tags = @('x', 'z') }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        $result.DriftInfo[0]['CurrentValue'] | Should -Be 'x, z'
        $result.DriftInfo[0]['DesiredValue'] | Should -Be 'x, y'
        $result.DriftInfo[0]['DeltaValue'] | Should -Be '<= y; => z'
        $result.DriftedParameters['Tags'] | Should -Be '<CurrentValue>x, z</CurrentValue><DesiredValue>x, y</DesiredValue><DeltaValue><= y; => z</DeltaValue>'
    }
}

Describe 'ResourceComparer.Compare Intune policy assignments' {
    BeforeAll {
        function New-Assignment
        {
            param([System.String] $GroupId, [System.String] $GroupDisplayName, [System.String] $FilterType = 'none', [System.String] $FilterId)

            $assignment = @{
                dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                groupId                                    = $GroupId
                groupDisplayName                           = $GroupDisplayName
                deviceAndAppManagementAssignmentFilterType = $FilterType
            }
            if ($FilterId) { $assignment['deviceAndAppManagementAssignmentFilterId'] = $FilterId }
            return $assignment
        }
    }

    It 'Reports no drift for identical assignments' {
        $desired = @{ Identity = 'a'; Assignments = @((New-Assignment -GroupId 'g1' -GroupDisplayName 'Group 1')) }
        $current = @{ Identity = 'a'; Assignments = @((New-Assignment -GroupId 'g1' -GroupDisplayName 'Group 1')) }

        (Invoke-ResourceCompare -Desired $desired -Current $current).TestResult | Should -BeTrue
    }

    It 'Reports a count mismatch as Assignments.Count with integer values' {
        $desired = @{ Identity = 'a'; Assignments = @((New-Assignment -GroupId 'g1' -GroupDisplayName 'Group 1'), (New-Assignment -GroupId 'g2' -GroupDisplayName 'Group 2')) }
        $current = @{ Identity = 'a'; Assignments = @((New-Assignment -GroupId 'g1' -GroupDisplayName 'Group 1')) }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        Get-DriftNames -Result $result | Should -Be @('Assignments.Count')
        $result.DriftInfo[0]['CurrentValue'] | Should -Be 1
        $result.DriftInfo[0]['DesiredValue'] | Should -Be 2
    }

    It 'Falls back to the group display name and reports it when neither id nor name is found' {
        $desired = @{ Identity = 'a'; Assignments = @((New-Assignment -GroupId 'g2' -GroupDisplayName 'Group 2')) }
        $current = @{ Identity = 'a'; Assignments = @((New-Assignment -GroupId 'g1' -GroupDisplayName 'Group 1')) }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        Get-DriftNames -Result $result | Should -Be @('Assignments[0].groupDisplayName')
        $result.DriftInfo[0]['CurrentValue'] | Should -Be 'Group 1'
        $result.DriftInfo[0]['DesiredValue'] | Should -Be 'Group 2'
    }

    It 'Matches by display name when the group id differs' {
        $desired = @{ Identity = 'a'; Assignments = @((New-Assignment -GroupId 'g2' -GroupDisplayName 'Group 1')) }
        $current = @{ Identity = 'a'; Assignments = @((New-Assignment -GroupId 'g1' -GroupDisplayName 'Group 1')) }

        (Invoke-ResourceCompare -Desired $desired -Current $current).TestResult | Should -BeTrue
    }

    It 'Reports a filter drift with the desired filter type under CurrentValue' -Tag 'CurrentBehaviour' {
        $desired = @{ Identity = 'a'; Assignments = @((New-Assignment -GroupId 'g1' -GroupDisplayName 'Group 1' -FilterType 'include' -FilterId 'f1')) }
        $current = @{ Identity = 'a'; Assignments = @((New-Assignment -GroupId 'g1' -GroupDisplayName 'Group 1' -FilterType 'exclude' -FilterId 'f1')) }
        $result = Invoke-ResourceCompare -Desired $desired -Current $current

        Get-DriftNames -Result $result | Should -Be @('Assignments[0].Filters')
        $result.DriftInfo[0]['CurrentValue'] | Should -Be 'include'
        $result.DriftInfo[0]['DesiredValue'] | Should -Be 'exclude'
    }
}

Describe 'ResourceComparer.Compare schema handling' {
    AfterAll {
        [Microsoft365DSC.Cache.CacheManager]::ClearSchema()
    }

    It 'Keeps reference identity when PowerShell casts the schema array, so a cache keyed by reference is hit' {
        [object]::ReferenceEquals(([object[]] $Script:Schema), $Script:Schema) | Should -BeTrue
    }

    It 'Reports the Ensure drift twice when the resource is desired Present but is Absent' -Tag 'CurrentBehaviour' {
        $desired = @{ Identity = 'a'; DisplayName = 'Contoso'; Ensure = 'Present' }
        $result = Invoke-ResourceCompare -Desired $desired -Current @{ Identity = 'a'; Ensure = 'Absent' }

        @(Get-DriftNames -Result $result | Where-Object -FilterScript { $_ -eq 'Ensure' }).Count | Should -Be 2
    }

    It 'Skips a Key parameter by default and compares it when it is force-included' {
        $desired = @{ TeamName = 't'; DisplayName = 'c1' }
        $current = @{ TeamName = 't'; DisplayName = 'c2' }

        (Invoke-ResourceCompare -Desired $desired -Current $current -ResourceName 'TeamsChannel').TestResult | Should -BeTrue

        $result = Invoke-ResourceCompare -Desired $desired -Current $current -ResourceName 'TeamsChannel' -IncludedProperties @('DisplayName')
        Get-DriftNames -Result $result | Should -Be @('DisplayName')
    }

    It 'Never compares Identity even when it is force-included' -Tag 'CurrentBehaviour' {
        $desired = @{ Identity = 'a'; DisplayName = 'x' }
        $current = @{ Identity = 'b'; DisplayName = 'x' }

        (Invoke-ResourceCompare -Desired $desired -Current $current -IncludedProperties @('Identity')).TestResult | Should -BeTrue
    }

    It 'Resolves against a different schema list when one is passed' {
        $altered = [object[]]@(
            @{
                ClassName  = 'MSFT_TestResource'
                Parameters = @(
                    @{ Name = 'Identity'; CIMType = 'String'; Option = 'Key' }
                    @{ Name = 'DisplayName'; CIMType = 'String'; Option = 'Key' }
                )
            }
            @{ ClassName = 'MSFT_Other'; Parameters = @() }
        )
        $desired = @{ Identity = 'a'; DisplayName = 'x' }
        $current = @{ Identity = 'a'; DisplayName = 'y' }

        (Invoke-ResourceCompare -Desired $desired -Current $current).TestResult | Should -BeFalse
        (Invoke-ResourceCompare -Desired $desired -Current $current -SchemaOverride $altered).TestResult | Should -BeTrue
    }

    It 'Follows the schema CacheManager currently holds after a reload' {
        $desired = @{ Identity = 'a'; DisplayName = 'x' }
        $current = @{ Identity = 'a'; DisplayName = 'y' }

        [Microsoft365DSC.Cache.CacheManager]::LoadSchema([System.Collections.Generic.List[object]] $Script:Schema)
        (Invoke-ResourceCompare -Desired $desired -Current $current -SchemaOverride ([Microsoft365DSC.Cache.CacheManager]::Schema)).TestResult | Should -BeFalse

        $altered = [System.Collections.Generic.List[object]]@(
            @{
                ClassName  = 'MSFT_TestResource'
                Parameters = @(
                    @{ Name = 'Identity'; CIMType = 'String'; Option = 'Key' }
                    @{ Name = 'DisplayName'; CIMType = 'String'; Option = 'Key' }
                )
            }
            @{ ClassName = 'MSFT_Other'; Parameters = @() }
        )
        [Microsoft365DSC.Cache.CacheManager]::LoadSchema($altered)
        (Invoke-ResourceCompare -Desired $desired -Current $current -SchemaOverride ([Microsoft365DSC.Cache.CacheManager]::Schema)).TestResult | Should -BeTrue
    }
}

Describe 'SimpleObjectComparer.Compare' {
    BeforeAll {
        function Invoke-SimpleCompare
        {
            param($Current, $Desired, [System.String[]] $Keys, $IncludedDrifts, [System.String[]] $Excluded)

            $excludedList = $null
            if ($null -ne $Excluded) { $excludedList = [System.Collections.Generic.List[string]] $Excluded }
            return [Microsoft365DSC.Compare.SimpleObjectComparer]::Compare($Current, $Desired, [string[]] $Keys, $IncludedDrifts, $false, $false, $excludedList)
        }
    }

    It 'Returns the legacy result shape' {
        $result = Invoke-SimpleCompare -Current @{ A = 'x' } -Desired @{ A = 'y' } -Keys @('A')

        $result['TestResult'] | Should -BeFalse
        $result['DriftObject'] | Should -BeOfType ([System.Collections.Hashtable])
        $result['DriftObject']['DriftInfo'].Count | Should -Be 1
        $result['DriftObject']['DriftInfo'][0]['PropertyName'] | Should -Be 'A'
        $result['DriftObject']['DriftInfo'][0]['CurrentValue'] | Should -Be 'x'
        $result['DriftObject']['DriftInfo'][0]['DesiredValue'] | Should -Be 'y'
        $result['DriftedParameters']['A'] | Should -Be '<CurrentValue>x</CurrentValue><DesiredValue>y</DesiredValue>'
    }

    It 'Round-trips included drifts into DriftInfo and keeps them in DriftedParameters' {
        $included = @{ Foo = '<CurrentValue>a</CurrentValue><DesiredValue>b</DesiredValue>' }
        $result = Invoke-SimpleCompare -Current @{ A = 'x' } -Desired @{ A = 'x' } -Keys @('A') -IncludedDrifts $included

        $result['TestResult'] | Should -BeTrue
        $result['DriftObject']['DriftInfo'][0]['PropertyName'] | Should -Be 'Foo'
        $result['DriftObject']['DriftInfo'][0]['CurrentValue'] | Should -Be 'a'
        $result['DriftObject']['DriftInfo'][0]['DesiredValue'] | Should -Be 'b'
        $result['DriftedParameters']['Foo'] | Should -Be $included['Foo']
    }

    It 'Treats CRLF and LF line endings as equal' {
        (Invoke-SimpleCompare -Current @{ A = "l1`r`nl2" } -Desired @{ A = "l1`nl2" } -Keys @('A'))['TestResult'] | Should -BeTrue
    }

    It 'Treats a null current and an empty desired string as equal but not the other way round' -Tag 'CurrentBehaviour' {
        (Invoke-SimpleCompare -Current @{ A = $null } -Desired @{ A = '' } -Keys @('A'))['TestResult'] | Should -BeTrue

        $result = Invoke-SimpleCompare -Current @{ A = '' } -Desired @{ A = $null } -Keys @('A')
        $result['TestResult'] | Should -BeFalse
        $result['DriftObject']['DriftInfo'][0]['DesiredValue'] | Should -Be '$null'
    }

    It 'Renders a null desired value as $null' {
        $result = Invoke-SimpleCompare -Current @{ A = 'x' } -Desired @{ A = $null } -Keys @('A')

        $result['DriftObject']['DriftInfo'][0]['CurrentValue'] | Should -Be 'x'
        $result['DriftObject']['DriftInfo'][0]['DesiredValue'] | Should -Be '$null'
    }

    It 'Adds a default Ensure of Present when the current values carry Ensure and the keys do not' {
        $result = Invoke-SimpleCompare -Current @{ A = 'x'; Ensure = 'Absent' } -Desired @{ A = 'x' } -Keys @('A')

        $result['TestResult'] | Should -BeFalse
        $result['DriftObject']['DriftInfo'][0]['PropertyName'] | Should -Be 'Ensure'
        $result['DriftObject']['DriftInfo'][0]['DesiredValue'] | Should -Be 'Present'
    }

    It 'Excludes property names ordinally, so a different casing is still compared' -Tag 'CurrentBehaviour' {
        (Invoke-SimpleCompare -Current @{ DisplayName = 'x' } -Desired @{ DisplayName = 'y' } -Keys @('DisplayName') -Excluded @('DisplayName'))['TestResult'] | Should -BeTrue
        (Invoke-SimpleCompare -Current @{ DisplayName = 'x' } -Desired @{ DisplayName = 'y' } -Keys @('DisplayName') -Excluded @('displayname'))['TestResult'] | Should -BeFalse
    }

    It 'Compares value types through their string form' {
        (Invoke-SimpleCompare -Current @{ A = 1 } -Desired @{ A = [long] 1 } -Keys @('A'))['TestResult'] | Should -BeTrue
        $result = Invoke-SimpleCompare -Current @{ A = $true } -Desired @{ A = $false } -Keys @('A')
        $result['DriftObject']['DriftInfo'][0]['CurrentValue'] | Should -Be 'True'
        $result['DriftObject']['DriftInfo'][0]['DesiredValue'] | Should -Be 'False'
    }

    It 'Rejects a desired value that is neither a hashtable, a CIM instance nor a dictionary' {
        { Invoke-SimpleCompare -Current @{ A = 1 } -Desired 'text' -Keys @('A') } | Should -Throw
    }

    It 'Rejects a reference-type desired property value that differs from the current value' {
        { Invoke-SimpleCompare -Current @{ A = 'text' } -Desired @{ A = @{ B = 2 } } -Keys @('A') } | Should -Throw
    }
}

Describe 'ComplexObjectComparer.Compare drift shapes' {
    BeforeAll {
        function Invoke-ComplexCompare
        {
            param($Source, $Target, [System.String] $Name = 'Prop')

            return [Microsoft365DSC.Compare.ComplexObjectComparer]::Compare($Source, $Target, $Name, $null)
        }
    }

    It 'Describes a null mismatch at the root and at key level' {
        $root = Invoke-ComplexCompare -Source $null -Target @{ A = 1 }
        $root.Item1[0]['PropertyName'] | Should -Be 'Prop'
        $root.Item1[0]['CurrentValue'] | Should -Be 'Current value is NOT null'
        $root.Item1[0]['DesiredValue'] | Should -Be 'Desired value is null'

        $key = Invoke-ComplexCompare -Source @{ A = $null } -Target @{ A = 1 }
        $key.Item1[0]['PropertyName'] | Should -Be 'Prop.A'
        $key.Item1[0]['CurrentValue'] | Should -Be 'Current value is NOT null'
        $key.Item1[0]['DesiredValue'] | Should -Be 'Desired value is null'
    }

    It 'Treats numerically equal values of different types as equal' {
        (Invoke-ComplexCompare -Source @{ A = 1 } -Target @{ A = [long] 1 }).Item2 | Should -BeTrue
        (Invoke-ComplexCompare -Source @{ A = 1 } -Target @{ A = 1.0 }).Item2 | Should -BeTrue
    }

    It 'Falls back to string comparison across a string and a number' {
        (Invoke-ComplexCompare -Source @{ A = '1' } -Target @{ A = 1 }).Item2 | Should -BeTrue
        (Invoke-ComplexCompare -Source @{ A = '1.0' } -Target @{ A = 1.0 }).Item2 | Should -BeFalse
    }

    It 'Compares strings case-insensitively and ignores line-ending differences' {
        (Invoke-ComplexCompare -Source @{ A = "Ab`r`nc" } -Target @{ A = "aB`nC" }).Item2 | Should -BeTrue
    }

    It 'Reports a nested array drift with its delta' {
        $result = Invoke-ComplexCompare -Source @{ Tags = @('a', 'b') } -Target @{ Tags = @('a', 'c') }

        $result.Item1.Count | Should -Be 1
        $result.Item1[0]['PropertyName'] | Should -Be 'Prop.Tags'
        $result.Item1[0]['CurrentValue'] | Should -Be 'a, c'
        $result.Item1[0]['DesiredValue'] | Should -Be 'a, b'
        $result.Item1[0]['DeltaValue'] | Should -Be '<= b; => c'
    }

    It 'Skips source keys that the target does not have and ignores extra target keys' {
        (Invoke-ComplexCompare -Source @{ A = 1; B = 2 } -Target @{ A = 1 }).Item2 | Should -BeTrue
        (Invoke-ComplexCompare -Source @{ A = 1 } -Target @{ A = 1; C = 3 }).Item2 | Should -BeTrue
    }

    It 'Ignores PSComputerName' {
        (Invoke-ComplexCompare -Source @{ A = 1; PSComputerName = 'x' } -Target @{ A = 1; PSComputerName = 'y' }).Item2 | Should -BeTrue
    }

    It 'Reports nested object drifts in reverse key order' {
        $source = [ordered]@{ N1 = [ordered]@{ X = 1 }; N2 = [ordered]@{ X = 2 } }
        $target = [ordered]@{ N1 = [ordered]@{ X = 9 }; N2 = [ordered]@{ X = 8 } }
        $result = Invoke-ComplexCompare -Source $source -Target $target

        @($result.Item1 | ForEach-Object -Process { $_['PropertyName'] }) | Should -Be @('Prop.N2.X', 'Prop.N1.X')
    }

    It 'Reports a count mismatch for complex arrays before comparing elements' {
        $result = Invoke-ComplexCompare -Source @(@{ A = 1 }) -Target @(@{ A = 1 }, @{ A = 2 })

        $result.Item1[0]['CurrentValue'] | Should -Be 'Current value has {2} items'
        $result.Item1[0]['DesiredValue'] | Should -Be 'Desired value has {1} items'
    }

    It 'Reports a drift for value-type arrays reached directly' {
        $result = Invoke-ComplexCompare -Source @{ A = [int[]] @(1, 2) } -Target @{ A = [int[]] @(1, 3) }

        $result.Item2 | Should -BeFalse
        $result.Item1[0]['CurrentValue'] | Should -Be '1, 3'
        $result.Item1[0]['DesiredValue'] | Should -Be '1, 2'
        $result.Item1[0]['DeltaValue'] | Should -Be '<= 2; => 3'
    }
}

Describe 'ConfigurationComparer.Compare with compare rules' {
    It 'Applies the rules the schema declares when the caller doesn''t supply any' {
        $source = @(New-Resource -ResourceName 'TestRules' -InstanceName 'S' -Values @{ Identity = 'a'; Mode = 'Off'; Notes = 'x' })
        $destination = @(New-Resource -ResourceName 'TestRules' -InstanceName 'D' -Values @{ Identity = 'a'; Mode = 'Off'; Notes = 'y' })
        (Invoke-ConfigurationCompare -Source $source -Destination $destination).Count | Should -Be 0

        $source[0]['Mode'] = 'On'
        $destination[0]['Mode'] = 'On'
        $deltas = Invoke-ConfigurationCompare -Source $source -Destination $destination
        $deltas[0]['Properties'][0]['ParameterName'] | Should -Be 'Notes'
    }

    It 'CheckAllSchemaProperties compares what either side contains and skips empty collections' {
        $rules = @(@{ Type = 'CheckAllSchemaProperties' })

        Invoke-RuleCompare -Rules $rules -Source @{ Notes = 'x'; Members = @(); Owners = @('o') } -Destination @{ Owners = @('o') } |
            Should -Be @('Notes')
    }

    It 'RemoveWhen removes listed and matching properties when all or any conditions are met' {
        $rules = @(
            @{ Type = 'RemoveWhen'; PropertyPattern = '^Own'; When = @{ All = @(@{ Property = 'Mode'; Equals = 'Off' }, @{ Side = 'Current'; Property = 'Window'; NotNullOrEmpty = $true }) } }
            @{ Type = 'RemoveWhen'; Properties = @('Notes'); When = @{ Any = @(@{ Property = 'Mode'; Equals = 'Never' }, @{ Side = 'Current'; Property = 'Members'; IsNullOrEmpty = $true }) } }
        )

        Invoke-RuleCompare -Rules $rules -Source @{ Mode = 'Off'; Window = 'w'; Owners = @('a'); Notes = 'x' } -Destination @{ Mode = 'Off'; Window = 'w'; Owners = @('b'); Notes = 'y' } |
            Should -BeNullOrEmpty
        Invoke-RuleCompare -Rules $rules -Source @{ Mode = 'On'; Window = 'w'; Owners = @('a'); Notes = 'x' } -Destination @{ Mode = 'On'; Window = 'w'; Owners = @('b'); Notes = 'y' } |
            Should -Be @('Owners')
    }

    It 'CheckWhen compares a property the desired side leaves out' {
        $rules = @(@{ Type = 'CheckWhen'; Property = 'Window'; When = @{ Side = 'Current'; Property = 'Window'; NotNullOrEmpty = $true } })

        Invoke-RuleCompare -Rules @() -Source @{ Window = 'w' } -Destination @{ } | Should -BeNullOrEmpty
        Invoke-RuleCompare -Rules $rules -Source @{ Window = 'w' } -Destination @{ } | Should -Be @('Window')
    }

    It 'SetWhen writes a value on one side when the condition is met' {
        $rules = @(@{ Type = 'SetWhen'; Side = 'Current'; Property = 'Mode'; Value = 'On'; When = @{ Side = 'Current'; Property = 'Mode'; Equals = 'Default' } })

        Invoke-RuleCompare -Rules $rules -Source @{ Mode = 'Default' } -Destination @{ Mode = 'On' } | Should -BeNullOrEmpty
        Invoke-RuleCompare -Rules $rules -Source @{ Mode = 'Off' } -Destination @{ Mode = 'On' } | Should -Be @('Mode')
    }

    It 'Normalize rewrites scalars, array items and nested paths on copies of the caller''s data' {
        $rules = @(
            @{ Type = 'Normalize'; Paths = @('Notes'); Using = 'StripNewlines' }
            @{ Type = 'Normalize'; Paths = @('Members'); Using = 'RegexReplace'; Pattern = '@contoso\.com$'; Replacement = '' }
            @{ Type = 'Normalize'; Paths = @('Settings[].Value'); Side = 'Current'; Using = 'PrefixUnless'; Pattern = '^v:'; Format = 'v:{0}' }
        )
        $setting = @{ Name = 's'; Value = '1' }

        Invoke-RuleCompare -Rules $rules -Source @{ Notes = "a`r`nb"; Members = @('x@contoso.com'); Settings = @($setting) } -Destination @{ Notes = 'ab'; Members = @('x'); Settings = @(@{ Name = 's'; Value = 'v:1' }) } |
            Should -BeNullOrEmpty
        $setting['Value'] | Should -Be '1'
    }

    It 'Normalize formats durations, dates, times of day, sizes and date formats the same way on both sides' {
        $rules = @(
            @{ Type = 'Normalize'; Paths = @('Window'); Using = 'FormatDuration' }
            @{ Type = 'Normalize'; Paths = @('Notes'); Using = 'FormatDateTime' }
            @{ Type = 'Normalize'; Paths = @('Mode'); Using = 'FormatTimeOfDay' }
            @{ Type = 'Normalize'; Paths = @('Members'); Using = 'FormatSize' }
            @{ Type = 'Normalize'; Paths = @('Settings'); Using = 'FormatDuration' }
            @{ Type = 'Normalize'; Paths = @('Settings[].Value'); Using = 'ReformatDateTime'; InputFormats = @('d/M/yyyy H:mm', 'd/M/yyyy'); Format = 'd/M/yyyy H:mm' }
        )
        $source = @{ Window = 'P90DT0H0M0S'; Notes = '2026-05-01T02:00:00+02:00'; Mode = '9:00'; Members = @('10 kb (10,240 bytes)'); Settings = @(@{ Name = 's'; Value = '1/5/2026' }) }
        $destination = @{ Window = 'P90D'; Notes = '2026-05-01T00:00:00Z'; Mode = '09:00:00'; Members = @('10KB'); Settings = @(@{ Name = 's'; Value = '1/5/2026 0:00' }) }

        Invoke-RuleCompare -Rules @() -Source $source.Clone() -Destination $destination.Clone() | Should -Not -BeNullOrEmpty
        Invoke-RuleCompare -Rules $rules -Source $source -Destination $destination | Should -BeNullOrEmpty
    }

    It 'SameInstant takes the current text of a date that is the same instant' {
        $rules = @(@{ Type = 'SameInstant'; Path = 'ScheduleInfo.StartDateTime' })

        Invoke-RuleCompare -Rules $rules -Source @{ ScheduleInfo = @{ StartDateTime = '2026-05-01T02:00:00+02:00' } } -Destination @{ ScheduleInfo = @{ StartDateTime = '2026-05-01T00:00:00Z' } } |
            Should -BeNullOrEmpty
        Invoke-RuleCompare -Rules $rules -Source @{ ScheduleInfo = @{ StartDateTime = '2026-05-02T00:00:00Z' } } -Destination @{ ScheduleInfo = @{ StartDateTime = '2026-05-01T00:00:00Z' } } |
            Should -Be @('ScheduleInfo.StartDateTime')
    }

    It 'Equivalent treats the listed values as one' {
        $rules = @(@{ Type = 'Equivalent'; Property = 'Mode'; Values = @('Default', 'HighConfidencePhish') })

        Invoke-RuleCompare -Rules $rules -Source @{ Mode = 'HighConfidencePhish' } -Destination @{ Mode = 'Default' } | Should -BeNullOrEmpty
        Invoke-RuleCompare -Rules $rules -Source @{ Mode = 'Off' } -Destination @{ Mode = 'Default' } | Should -Be @('Mode')
    }

    It 'NullEqualsEmpty reads a missing current array as empty' {
        $rules = @(@{ Type = 'NullEqualsEmpty'; PropertyPattern = '^Members$' })

        Invoke-RuleCompare -Rules @() -Source @{ } -Destination @{ Members = @() } | Should -Be @('Members')
        Invoke-RuleCompare -Rules $rules -Source @{ } -Destination @{ Members = @() } | Should -BeNullOrEmpty
    }

    It 'Tolerance skips time spans within the allowed difference' {
        $rules = @(@{ Type = 'Tolerance'; Properties = @('Window'); Within = '00:05:00' })

        Invoke-RuleCompare -Rules $rules -Source @{ Window = '01:02:00' } -Destination @{ Window = '01:00:00' } | Should -BeNullOrEmpty
        Invoke-RuleCompare -Rules $rules -Source @{ Window = '01:10:00' } -Destination @{ Window = '01:00:00' } | Should -Be @('Window')
    }

    It 'IgnoreNested leaves nested properties out on both sides, objects that aren''t hashtables included' {
        $rules = @(@{ Type = 'IgnoreNested'; Paths = @('Settings[].Version') })

        Invoke-RuleCompare -Rules $rules -Source @{ Settings = @(@{ Name = 's'; Value = '1'; Version = '2' }) } -Destination @{ Settings = @([PSCustomObject] @{ Name = 's'; Value = '1'; Version = '1' }) } |
            Should -BeNullOrEmpty
    }

    It 'IgnoreWhenPast takes the current date when the desired one has passed' {
        $rules = @(@{ Type = 'IgnoreWhenPast'; Path = 'ScheduleInfo.StartDateTime' })
        $now = [System.DateTimeOffset]::Parse('2026-06-01T00:00:00Z')

        Invoke-RuleCompare -Rules $rules -Now $now -Source @{ ScheduleInfo = @{ StartDateTime = '2026-05-20T00:00:00Z' } } -Destination @{ ScheduleInfo = @{ StartDateTime = '2026-05-01T00:00:00Z' } } |
            Should -BeNullOrEmpty
        Invoke-RuleCompare -Rules $rules -Now $now -Source @{ ScheduleInfo = @{ StartDateTime = '2026-05-20T00:00:00Z' } } -Destination @{ ScheduleInfo = @{ StartDateTime = '2026-07-01T00:00:00Z' } } |
            Should -Be @('ScheduleInfo.StartDateTime')
    }

    It 'Rename moves a property to its new name on both sides' {
        Invoke-RuleCompare -Rules @(@{ Type = 'Rename'; From = 'Notes'; To = 'Window' }) -Source @{ Notes = 'x' } -Destination @{ Notes = 'y' } |
            Should -Be @('Window')
    }

    It 'DurationMatchesEnd treats a duration as equal to the end date it reaches' {
        $rules = @(@{ Type = 'DurationMatchesEnd'; Expiration = 'ScheduleInfo.Expiration'; Start = 'ScheduleInfo.StartDateTime' })
        $current = { @{ ScheduleInfo = @{ StartDateTime = '2026-05-01T00:00:00Z'; Expiration = @{ type = 'afterDateTime'; endDateTime = '2026-05-31T00:00:00Z' } } } }

        Invoke-RuleCompare -Rules $rules -Source (& $current) -Destination @{ ScheduleInfo = @{ StartDateTime = '2026-05-01T00:00:00Z'; Expiration = @{ type = 'afterDuration'; duration = 'P30D' } } } |
            Should -BeNullOrEmpty
        Invoke-RuleCompare -Rules $rules -Source (& $current) -Destination @{ ScheduleInfo = @{ StartDateTime = '2026-05-01T00:00:00Z'; Expiration = @{ type = 'afterDuration'; duration = 'P29D' } } } |
            Should -Not -BeNullOrEmpty
    }

    It 'AllowCurrentExtras accepts items only the current side has, when the desired side has the property' {
        $rules = @(@{ Type = 'AllowCurrentExtras'; Property = 'Settings'; MatchKey = 'Name' })

        Invoke-RuleCompare -Rules $rules -Source @{ Settings = @(@{ Name = 'a'; Value = '1' }, @{ Name = 'b'; Value = '2' }) } -Destination @{ Settings = @(@{ Name = 'a'; Value = '1' }) } |
            Should -BeNullOrEmpty
        Invoke-RuleCompare -Rules ($rules[0], @{ Type = 'CheckAllSchemaProperties' }) -Source @{ Settings = @(@{ Name = 'b'; Value = '2' }) } -Destination @{ } |
            Should -Not -BeNullOrEmpty
    }

    It 'CustomCompare runs the comparer registered under its name with the declaration and refuses an unknown one' {
        [Microsoft365DSC.Compare.CompareRuleRegistry]::RegisterComparer('TestDropNotes', [System.Func[System.Object, System.Action[Microsoft365DSC.Compare.CompareRuleContext]]] {
                param($declaration)

                [System.Action[Microsoft365DSC.Compare.CompareRuleContext]] {
                    param($context)
                    $context.ValuesToCheck.Remove($declaration.Property)
                }.GetNewClosure()
            })

        Invoke-RuleCompare -Rules @(@{ Type = 'CustomCompare'; Name = 'TestDropNotes'; Property = 'Notes' }) -Source @{ Notes = 'x' } -Destination @{ Notes = 'y' } |
            Should -BeNullOrEmpty
        { Invoke-RuleCompare -Rules @(@{ Type = 'CustomCompare'; Name = 'TestMissing' }) -Source @{ Notes = 'x' } -Destination @{ Notes = 'y' } } |
            Should -Throw '*TestMissing*'
    }

    It 'Normalize groups an Exchange filter with -and before -or' {
        $rules = @(@{ Type = 'Normalize'; Paths = @('Notes'); Using = 'ExchangeFilter' })

        Invoke-RuleCompare -Rules $rules -Source @{ Notes = '((A -eq 1) -and (B -eq 2)) -or (C -eq 3)' } -Destination @{ Notes = '(A -eq 1) -AND (B -eq 2) -or (C -eq 3)' } |
            Should -BeNullOrEmpty
        Invoke-RuleCompare -Rules $rules -Source @{ Notes = '(A -eq 1) -and ((B -eq 2) -or (C -eq 3))' } -Destination @{ Notes = '(A -eq 1) -AND (B -eq 2) -or (C -eq 3)' } |
            Should -Be @('Notes')
        Invoke-RuleCompare -Rules $rules -Source @{ Notes = '-and A' } -Destination @{ Notes = '-and A' } | Should -BeNullOrEmpty
    }

    It 'TenantIsolationRules applies included and excluded rules to the current ones and maps each tenant to its id' {
        $rules = [Microsoft365DSC.Compare.CompareRule]::ParseAll(@(@{ Type = 'CustomCompare'; Name = 'TenantIsolationRules'; TenantIds = @{ contoso = 'id-1'; fabrikam = 'id-3' } }))
        $desired = @{ RulesToInclude = @(@{ TenantName = 'contoso'; Direction = 'Inbound' }); RulesToExclude = @(@{ TenantName = 'fabrikam' }) }
        $current = @{ Rules = @(@{ TenantName = 'id-2'; Direction = 'Outbound' }, @{ TenantName = 'id-3'; Direction = 'Both' }) }

        $rewritten = [Microsoft365DSC.Compare.CompareRule]::ApplyAll($rules, $desired, $current, $desired.Clone(), [System.Object[]] @(), 'PPTenantIsolationSettings')

        @($rewritten.Item1.Rules | ForEach-Object -Process { $_.TenantName }) | Should -Be @('id-2', 'id-1')
        $rewritten.Item1.ContainsKey('RulesToInclude') | Should -BeFalse
        $rewritten.Item3.ContainsKey('RulesToExclude') | Should -BeFalse
    }

    It 'FeatureUpdateRollout accepts a different start date in the past and reports one in the future' {
        $rules = [Microsoft365DSC.Compare.CompareRule]::ParseAll(@(@{ Type = 'CustomCompare'; Name = 'FeatureUpdateRollout' }))
        $current = @{ RolloutSettings = @{ OfferStartDateTimeInUTC = '2024-01-01T00:00:00Z' } }

        $past = @{ RolloutSettings = @{ OfferStartDateTimeInUTC = '2020-01-01T00:00:00Z' } }
        [Microsoft365DSC.Compare.CompareRule]::ApplyAll($rules, $past, $current, $past.Clone(), [System.Object[]] @(), 'X').Item3.ContainsKey('RolloutSettings') |
            Should -BeFalse

        $future = @{ RolloutSettings = @{ OfferStartDateTimeInUTC = '2099-01-01T00:00:00Z' } }
        [Microsoft365DSC.Compare.CompareRule]::ApplyAll($rules, $future, $current, $future.Clone(), [System.Object[]] @(), 'X').Item3.RolloutSettings.Drift |
            Should -Be 'desired'
    }

    It 'Reads the compare rules of every shipped resource' {
        $schemaPath = "$PSScriptRoot/../../../Modules/Microsoft365DSC/SchemaDefinition.json"
        if (-not (Test-Path -Path $schemaPath))
        {
            Set-ItResult -Skipped -Because 'the schema has not been built'
            return
        }

        $declared = @([System.IO.File]::ReadAllText($schemaPath) | ConvertFrom-Json | Where-Object -FilterScript { $null -ne $_.CompareParameters.CompareRules })

        $declared.Count | Should -BeGreaterThan 0
        foreach ($entry in $declared)
        {
            { [Microsoft365DSC.Compare.CompareRule]::ParseAll($entry.CompareParameters.CompareRules) } | Should -Not -Throw -Because $entry.ClassName
        }
    }

    It 'Refuses an unknown rule type, a condition on both sides and an unreadable time span' {
        { [Microsoft365DSC.Compare.CompareRule]::ParseAll(@(@{ Type = 'Nope' })) } | Should -Throw '*Nope*'
        { [Microsoft365DSC.Compare.CompareRule]::ParseAll(@(@{ Type = 'RemoveWhen'; Properties = @('Notes'); When = @{ Side = 'Both'; Property = 'Mode'; Truthy = $true } })) } | Should -Throw '*Mode*'
        { [Microsoft365DSC.Compare.CompareRule]::ParseAll(@(@{ Type = 'Tolerance'; Properties = @('Window'); Within = 'soon' })) } | Should -Throw '*Within*'
    }

    It 'Applies the rules before PostProcessing' {
        $Script:SeenWindow = $false
        $postProcessing = {
            param($DesiredValues, $CurrentValues, $ValuesToCheck, $Arguments)
            $Script:SeenWindow = $ValuesToCheck.ContainsKey('Window')
            return $null
        }

        $null = Invoke-RuleCompare -Rules @(@{ Type = 'Rename'; From = 'Notes'; To = 'Window' }) -PostProcessing $postProcessing -Source @{ Notes = 'x' } -Destination @{ Notes = 'y' }
        $Script:SeenWindow | Should -BeTrue
    }
}

Describe 'Compare-M365DSCResourceState with compare rules' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCCompare.psm1" -Force
    }

    It 'Applies the rules before the comparison and leaves the caller''s values unchanged' {
        $desired = @{ DisplayName = 'Group'; MailNickname = 'group'; Description = 'new' }
        $current = @{ DisplayName = 'Group'; MailNickname = 'group'; Description = 'old' }
        $rules = @(@{ Type = 'Normalize'; Paths = @('Description'); Side = 'Current'; Using = 'RegexReplace'; Pattern = '^old$'; Replacement = 'new' })

        Compare-M365DSCResourceState -ResourceName 'AADGroup' -DesiredValues $desired -CurrentValues $current | Should -BeFalse
        Compare-M365DSCResourceState -ResourceName 'AADGroup' -DesiredValues $desired -CurrentValues $current -CompareRules $rules | Should -BeTrue
        $current['Description'] | Should -Be 'old'
    }
}
