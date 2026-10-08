<#
    Guards the conventions that the class-based conversion cleanup established.

    Every rule here corresponds to a defect class that was found - and fixed - across the whole
    resource set. They are cheap to reintroduce by copying an older resource as a template, and
    most of them fail silently at runtime rather than breaking a build or a unit test. To prevent
    this scenario, the rules are enforced as QA tests.

    Adding a resource to an exception list is a deliberate act. Always state why in the comment next to it.
#>

BeforeDiscovery {
    $resourcesPath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/DscResources'

    # Instance state the base class owns. Everything else on $this is resource schema and is
    # written by DSC, never by the resource itself.
    $sanctionedMembers = @('ExportedInstance', 'ResourceCache')

    # $Global: names the export/report framework legitimately shares with resources.
    $sanctionedGlobals = @(
        'M365DSCExportResourceInstancesCount', 'PartialExportFileName', 'CurrentModeIsExport',
        'AllDrifts', 'PotentialDrifts', 'MaximumFunctionCount', 'ConfigurationData',
        'M365DSCEmojiGreenCheckMark', 'M365DSCEmojiRedX', 'M365DSCEmojiYellowCircle',
        'M365DSCEmojiHourglass', 'M365DSCEmojiStopSign', 'M365DSCEmojiInformation',
        'M365DSCExportRelations',
        # PowerShell's own automatic variable; the base class reads it for the 5.1 dispatch.
        'PSVersionTable'
    )

    # The two rule-evaluation resources are meta-resources: they evaluate OTHER resources and
    # deliberately implement their own Get/Test/Export rather than the standard flow.
    $metaResources = @('MSFT_M365DSCRuleEvaluation', 'MSFT_M365DSCGraphAPIRuleEvaluation')

    $testCompareExceptions = @{
        # Skips the comparison entirely when the configured rollout window has already passed, so
        # the decision is "should we compare at all", which the comparer has no way to express.
        'MSFT_IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' =
            'short-circuits on past offer dates before any comparison happens'
    }

    $compareParamsExceptions = @{
        # Resolving a tenant name to a tenant id needs a network call, which the reporting path
        # must not make. The resolved map is therefore built while $this is populated and then
        # handed to PostProcessing through PostProcessingArgs. Reporting consequently compares
        # raw tenant names, see the TODO in the resource.
        'MSFT_PPTenantIsolationSettings' =
            'tenant-id resolution requires a connection that reporting must not open'
    }

    function Get-EnclosingMethodName
    {
        param([System.Management.Automation.Language.Ast] $Node)

        $parent = $Node.Parent
        while ($null -ne $parent)
        {
            if ($parent -is [System.Management.Automation.Language.FunctionMemberAst]) { return $parent.Name }
            $parent = $parent.Parent
        }
        return $null
    }

    function Test-InsideScriptBlock
    {
        param([System.Management.Automation.Language.Ast] $Node)

        $parent = $Node.Parent
        while ($null -ne $parent)
        {
            if ($parent -is [System.Management.Automation.Language.ScriptBlockExpressionAst]) { return $true }
            if ($parent -is [System.Management.Automation.Language.FunctionMemberAst]) { return $false }
            $parent = $parent.Parent
        }
        return $false
    }

    $offlineCommands = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($command in (Get-Command -CommandType Cmdlet -ErrorAction SilentlyContinue |
                Where-Object -FilterScript {
                    $_.Source -like 'Microsoft.PowerShell.*' -or
                    $_.Source -in @('CimCmdlets', 'PSDesiredStateConfiguration', 'Microsoft.WSMan.Management') }))
    {
        $null = $offlineCommands.Add($command.Name)
    }

    $modulesPath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/Modules'
    foreach ($moduleFile in (Get-ChildItem -Path $modulesPath -Filter '*.psm1' -File -Recurse))
    {
        foreach ($match in [regex]::Matches((Get-Content -Path $moduleFile.FullName -Raw), '(?im)^\s*function\s+([\w-]+)'))
        {
            $null = $offlineCommands.Add($match.Groups[1].Value)
        }
    }

    $thisWrites            = [System.Collections.Generic.List[string]]::new()
    $methodResultWrites    = [System.Collections.Generic.List[string]]::new()
    $fromHashtableInGet    = [System.Collections.Generic.List[string]]::new()
    $scriptEraVariables    = [System.Collections.Generic.List[string]]::new()
    $scriptScopeVariables  = [System.Collections.Generic.List[string]]::new()
    $unsanctionedGlobals   = [System.Collections.Generic.List[string]]::new()
    $thisInModuleFunction  = [System.Collections.Generic.List[string]]::new()
    $methodsWithoutReturn  = [System.Collections.Generic.List[string]]::new()
    $nonNullableProperties = [System.Collections.Generic.List[string]]::new()
    $testDoesOwnCompare    = [System.Collections.Generic.List[string]]::new()
    $compareParamsUseThis  = [System.Collections.Generic.List[string]]::new()
    $unguardedPostProcess  = [System.Collections.Generic.List[string]]::new()
    $exportMissingPlumbing = [System.Collections.Generic.List[string]]::new()

    foreach ($file in (Get-ChildItem -Path $resourcesPath -Filter 'MSFT_*.psm1' -File -Recurse))
    {
        $resourceName = $file.Directory.Name
        $isMeta = $resourceName -in $metaResources

        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile(
            $file.FullName, [ref] $null, [ref] $parseErrors)

        $classes = $ast.FindAll({
                param($a) $a -is [System.Management.Automation.Language.TypeDefinitionAst] -and $a.IsClass }, $true)
        $mainClass = $classes | Where-Object { $_.Name -eq ($resourceName -replace '^MSFT_', '') } | Select-Object -First 1
        if ($null -eq $mainClass) { continue }

        $methods = @{}
        foreach ($m in ($mainClass.Members | Where-Object {
                    $_ -is [System.Management.Automation.Language.FunctionMemberAst] })) { $methods[$m.Name] = $m }

        $isSingleInstance = @($mainClass.Members | Where-Object {
                $_ -is [System.Management.Automation.Language.PropertyMemberAst] -and $_.Name -eq 'IsSingleInstance' }).Count -gt 0

        #region writes to $this
        foreach ($assignment in $mainClass.FindAll({
                    param($a) $a -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true))
        {
            $lhs = $assignment.Left
            while ($lhs -is [System.Management.Automation.Language.AttributedExpressionAst] -or
                   $lhs -is [System.Management.Automation.Language.ConvertExpressionAst])
            {
                $lhs = $lhs.Child
            }

            # $this.GetBoundParameters().Foo = ... assigns into a hashtable that is rebuilt on every
            # call, so the write is discarded. It reads like state mutation and does nothing.
            if ($lhs -is [System.Management.Automation.Language.MemberExpressionAst] -and
                $lhs.Expression -is [System.Management.Automation.Language.InvokeMemberExpressionAst])
            {
                $methodResultWrites.Add(('{0} L{1}: {2}' -f $resourceName,
                        $assignment.Extent.StartLineNumber, $assignment.Extent.Text.Trim()))
                continue
            }

            $target = $lhs
            if ($target -is [System.Management.Automation.Language.IndexExpressionAst]) { $target = $target.Target }

            if ($target -is [System.Management.Automation.Language.MemberExpressionAst] -and
                $target.Expression -is [System.Management.Automation.Language.VariableExpressionAst] -and
                $target.Expression.VariablePath.UserPath -eq 'this' -and
                $target.Member -is [System.Management.Automation.Language.StringConstantExpressionAst] -and
                $target.Member.Value -notin $sanctionedMembers)
            {
                # A constructor is the one place a resource legitimately seeds its own properties.
                $owner = $assignment.Parent
                while ($null -ne $owner -and $owner -isnot [System.Management.Automation.Language.FunctionMemberAst])
                {
                    $owner = $owner.Parent
                }
                if ($null -ne $owner -and $owner.IsConstructor) { continue }

                $method = Get-EnclosingMethodName -Node $assignment
                $thisWrites.Add(('{0}.{1} L{2}: $this.{3} = ...' -f $resourceName, $method,
                        $assignment.Extent.StartLineNumber, $target.Member.Value))
            }
        }

        # Add()/Remove()/Clear() on the result of GetBoundParameters() is the same defect wearing a
        # different hat. The mutation lands on a throwaway copy and the caller keeps the original.
        foreach ($invocation in $mainClass.FindAll({
                    param($a) $a -is [System.Management.Automation.Language.InvokeMemberExpressionAst] }, $true))
        {
            $inner = $invocation.Expression
            if ($inner -isnot [System.Management.Automation.Language.InvokeMemberExpressionAst]) { continue }
            if ($inner.Expression -isnot [System.Management.Automation.Language.VariableExpressionAst]) { continue }
            if ($inner.Expression.VariablePath.UserPath -ne 'this') { continue }
            if ($inner.Member.Value -ne 'GetBoundParameters') { continue }
            if ($invocation.Member.Value -notin 'Add', 'Remove', 'Clear') { continue }

            $methodResultWrites.Add(('{0} L{1}: {2}' -f $resourceName,
                    $invocation.Extent.StartLineNumber, $invocation.Extent.Text.Trim()))
        }
        #endregion

        #region $this.FromHashtable() inside Get()
        if ($methods.ContainsKey('Get'))
        {
            foreach ($call in $methods['Get'].Body.FindAll({
                        param($a) $a -is [System.Management.Automation.Language.InvokeMemberExpressionAst] }, $true))
            {
                if ($call.Expression -is [System.Management.Automation.Language.VariableExpressionAst] -and
                    $call.Expression.VariablePath.UserPath -eq 'this' -and
                    $call.Member -is [System.Management.Automation.Language.StringConstantExpressionAst] -and
                    $call.Member.Value -eq 'FromHashtable')
                {
                    $fromHashtableInGet.Add(('{0} L{1}' -f $resourceName, $call.Extent.StartLineNumber))
                }
            }
        }
        #endregion

        #region script-era automatic variables and scope prefixes
        foreach ($variable in $ast.FindAll({
                    param($a) $a -is [System.Management.Automation.Language.VariableExpressionAst] }, $true))
        {
            $path = $variable.VariablePath.UserPath

            if ($path -in 'PSBoundParameters', 'MyInvocation', 'PSScriptRoot')
            {
                $scriptEraVariables.Add(('{0} L{1}: ${2}' -f $resourceName, $variable.Extent.StartLineNumber, $path))
            }
            elseif ($path -like 'Script:*')
            {
                $scriptScopeVariables.Add(('{0} L{1}: ${2}' -f $resourceName, $variable.Extent.StartLineNumber, $path))
            }
            elseif ($path -like 'Global:*' -and ($path -replace '^Global:', '') -notin $sanctionedGlobals)
            {
                $unsanctionedGlobals.Add(('{0} L{1}: ${2}' -f $resourceName, $variable.Extent.StartLineNumber, $path))
            }
        }
        #endregion

        #region module-level functions referencing $this
        $topLevelFunctions = @($ast.FindAll({
                    param($a) $a -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
                Where-Object {
                    $parent = $_.Parent
                    $inClass = $false
                    while ($null -ne $parent)
                    {
                        if ($parent -is [System.Management.Automation.Language.TypeDefinitionAst]) { $inClass = $true; break }
                        $parent = $parent.Parent
                    }
                    -not $inClass
                })

        foreach ($function in $topLevelFunctions)
        {
            $thisRefs = @($function.Body.FindAll({
                        param($a) $a -is [System.Management.Automation.Language.VariableExpressionAst] -and
                        $a.VariablePath.UserPath -eq 'this' }, $true))
            if ($thisRefs.Count -gt 0)
            {
                $thisInModuleFunction.Add(('{0}::{1} L{2} ({3} reference(s))' -f $resourceName, $function.Name,
                        $thisRefs[0].Extent.StartLineNumber, $thisRefs.Count))
            }
        }
        #endregion

        #region methods that declare a return type but never return a value
        foreach ($method in $methods.Values)
        {
            if ($null -eq $method.ReturnType) { continue }
            if ($method.ReturnType.TypeName.Name -in 'void', 'Void') { continue }

            $returns = @($method.Body.FindAll({
                        param($a) $a -is [System.Management.Automation.Language.ReturnStatementAst] -and
                        $null -ne $a.Pipeline }, $true))
            $throws = @($method.Body.FindAll({
                        param($a) $a -is [System.Management.Automation.Language.ThrowStatementAst] }, $true))

            if ($returns.Count -eq 0 -and $throws.Count -eq 0)
            {
                $methodsWithoutReturn.Add(('{0}.{1} L{2} declares [{3}]' -f $resourceName, $method.Name,
                        $method.Extent.StartLineNumber, $method.ReturnType.TypeName.Name))
            }
        }
        #endregion

        #region value-typed properties must be nullable, except keys
        $valueTypeNames = 'Boolean', 'Int32', 'UInt32', 'Int64', 'UInt64', 'Int16', 'UInt16',
                          'Byte', 'SByte', 'Double', 'Single', 'DateTime', 'TimeSpan', 'Char', 'Decimal'

        foreach ($property in ($mainClass.Members | Where-Object {
                    $_ -is [System.Management.Automation.Language.PropertyMemberAst] }))
        {
            $dscAttribute = $property.Attributes | Where-Object { $_.TypeName.Name -eq 'DscProperty' } | Select-Object -First 1
            if ($null -eq $dscAttribute) { continue }

            # The DSC engine rejects Nullable[T] on a key property outright ("the key property must
            # be of [string], signed/unsigned integer, or Enum types"), and a key is mandatory in a
            # configuration.
            if ($dscAttribute.Extent.Text -match 'Key') { continue }

            $simpleName = $property.PropertyType.TypeName.Name -replace '^System\.', ''
            if ($simpleName -in $valueTypeNames)
            {
                $nonNullableProperties.Add(('{0}.{1} is [{2}]' -f $resourceName, $property.Name, $simpleName))
            }
        }
        #endregion

        #region Test() delegates its comparison
        # Comparison behaviour has to live in GetCompareParameters(), because that is what the
        # reporting path (Get-M365DSCResourceComparisonParameters) reads. Logic inlined into Test()
        # is invisible to reporting and silently drifts away from it.
        if (-not $isMeta -and -not $testCompareExceptions.ContainsKey($resourceName) -and $methods.ContainsKey('Test'))
        {
            $callsCompare = @($methods['Test'].Body.FindAll({
                        param($a) $a -is [System.Management.Automation.Language.CommandAst] -and
                        $a.GetCommandName() -eq 'Test-M365DSCTargetResource' }, $true))
            if ($callsCompare.Count -gt 0)
            {
                $testDoesOwnCompare.Add(('{0} L{1}' -f $resourceName, $callsCompare[0].Extent.StartLineNumber))
            }
        }
        #endregion

        #region GetCompareParameters() must work on a bare instance
        # Reporting calls $type::new().GetCompareParameters() on an UNPOPULATED instance, so reading
        # bound property state while building the hashtable yields nulls there. Reads inside the
        # PostProcessing scriptblock are fine. There it runs later, against $DesiredValues.
        if ($methods.ContainsKey('GetCompareParameters') -and -not $compareParamsExceptions.ContainsKey($resourceName))
        {
            $allowedCalls = 'GetSchemaPropertyNames', 'GetSettingsCatalogCompareParameters',
                            'GetResourceName', 'ResourceCache'

            foreach ($member in $methods['GetCompareParameters'].Body.FindAll({
                        param($a) $a -is [System.Management.Automation.Language.MemberExpressionAst] }, $true))
            {
                if ($member.Expression -isnot [System.Management.Automation.Language.VariableExpressionAst]) { continue }
                if ($member.Expression.VariablePath.UserPath -ne 'this') { continue }
                if ($member.Member -isnot [System.Management.Automation.Language.StringConstantExpressionAst]) { continue }
                if ($member.Member.Value -in $allowedCalls) { continue }
                if (Test-InsideScriptBlock -Node $member) { continue }

                $compareParamsUseThis.Add(('{0} L{1}: $this.{2}' -f $resourceName,
                        $member.Extent.StartLineNumber, $member.Member.Value))
            }
        }
        #endregion

        #region
        if ($methods.ContainsKey('GetCompareParameters'))
        {
            $localFunctions = @($topLevelFunctions | ForEach-Object -Process { $_.Name })

            foreach ($block in $methods['GetCompareParameters'].Body.FindAll({
                        param($a) $a -is [System.Management.Automation.Language.ScriptBlockExpressionAst] }, $true))
            {
                $guard = @($block.FindAll({
                            param($a) $a -is [System.Management.Automation.Language.IfStatementAst] -and
                            $a.Clauses[0].Item1.Extent.Text -match 'IsReportContext' -and
                            $a.Clauses[0].Item2.Extent.Text -match '\breturn\b' }, $true)) | Select-Object -First 1

                foreach ($call in $block.FindAll({
                            param($a) $a -is [System.Management.Automation.Language.CommandAst] }, $true))
                {
                    $commandName = $call.GetCommandName()
                    if ([System.String]::IsNullOrEmpty($commandName)) { continue }
                    if ($offlineCommands.Contains($commandName) -or $commandName -in $localFunctions) { continue }
                    if ($null -ne $guard -and $guard.Extent.StartLineNumber -lt $call.Extent.StartLineNumber) { continue }

                    $unguardedPostProcess.Add(('{0} L{1}: {2}' -f $resourceName,
                            $call.Extent.StartLineNumber, $commandName))
                }
            }
        }
        #endregion

        #region Export() plumbing
        # Single-instance resources may legitimately call $this.Get() directly, or splat parameters
        # and use $this.ExportedInstance. Either shape is fine for a resource with one instance.
        if (-not $isMeta -and $methods.ContainsKey('Export'))
        {
            $exportText = $methods['Export'].Body.Extent.Text
            $missing = @()
            if ($exportText -notmatch 'Get-M365DSCExportContentForResource') { $missing += 'Get-M365DSCExportContentForResource' }
            if ($exportText -notmatch 'Save-M365DSCPartialExport') { $missing += 'Save-M365DSCPartialExport' }
            if (-not $isSingleInstance -and $exportText -notmatch '\$this\.GetForExport\(') { $missing += '$this.GetForExport()' }

            if ($missing.Count -gt 0)
            {
                $exportMissingPlumbing.Add(('{0}: missing {1}' -f $resourceName, ($missing -join ', ')))
            }
        }
        #endregion
    }

    $conventionRules = @(
        @{
            Name      = 'never writes to a $this schema property'
            Offenders = @($thisWrites)
            Because   = 'GetBoundParameters() reads live property values, so a write inside Get() replaces the ' +
                        'user''s desired value before Set() builds its payload, and Export() reuses one instance ' +
                        'so writes bleed between exported items. Use a local, a $results key, or $this.ResourceCache'
        }
        @{
            Name      = 'never assigns into the result of a method call'
            Offenders = @($methodResultWrites)
            Because   = 'GetBoundParameters() returns a freshly built hashtable, so assigning into it is a no-op ' +
                        'that silently discards the value. Capture it in a local first'
        }
        @{
            Name      = 'never calls $this.FromHashtable() inside Get()'
            Offenders = @($fromHashtableInGet)
            Because   = 'it overwrites the instance wholesale, which corrupts desired state for the rest of the run'
        }
        @{
            Name      = 'uses no script-era automatic variables'
            Offenders = @($scriptEraVariables)
            Because   = '$PSBoundParameters, $MyInvocation and $PSScriptRoot do not carry into a class. Use ' +
                        '$this.GetBoundParameters(), $this.GetResourceName() and $this.GetModulePath()'
        }
        @{
            Name      = 'uses no $Script: scope'
            Offenders = @($scriptScopeVariables)
            Because   = 'every generated Part<NN>.psm1 shares one module scope, so $Script: state cross-contaminates ' +
                        'between resources. Use $this.ResourceCache instead'
        }
        @{
            Name      = 'uses no unsanctioned $Global: state'
            Offenders = @($unsanctionedGlobals)
            Because   = 'only the export/report framework globals are shared with resources'
        }
        @{
            Name      = 'has no module-level function referencing $this'
            Offenders = @($thisInModuleFunction)
            Because   = '$this is always $null in a module-level function, so every such read silently yields ' +
                        'nothing. Make it a hidden method, or pass the values in as parameters'
        }
        @{
            Name      = 'has no method that declares a return type but never returns'
            Offenders = @($methodsWithoutReturn)
            Because   = 'a class method discards pipeline output - only an explicit return produces a value. A ' +
                        'helper converted from a function that emitted its result now returns nothing'
        }
        @{
            Name      = 'declares non-key value-typed properties as Nullable[T]'
            Offenders = @($nonNullableProperties)
            Because   = 'DSC leaves absent properties at their CLR default, so a plain [Boolean]/[UInt32] cannot ' +
                        'distinguish "omitted" from "specified as false/0"'
        }
        @{
            Name      = 'keeps comparison logic out of Test()'
            Offenders = @($testDoesOwnCompare)
            Because   = 'the base Test() already splats GetCompareParameters() into Test-M365DSCTargetResource. ' +
                        'Calling it directly means reporting, which reads GetCompareParameters(), compares differently'
        }
        @{
            Name      = 'builds GetCompareParameters() without reading bound state'
            Offenders = @($compareParamsUseThis)
            Because   = 'reporting calls it on a bare instance via $type::new(), where property reads are null. ' +
                        'Branch on $DesiredValues inside the PostProcessing scriptblock instead'
        }
        @{
            Name      = 'calls no connected cmdlet in PostProcessing without an IsReportContext() guard'
            Offenders = @($unguardedPostProcess)
            Because   = 'reporting invokes PostProcessing while comparing two configuration files, with no workload ' +
                        'connection and no try/catch around the call'
        }
        @{
            Name      = 'exports through the shared export plumbing'
            Offenders = @($exportMissingPlumbing)
            Because   = 'Get-M365DSCExportContentForResource and Save-M365DSCPartialExport produce the emitted ' +
                        'block and the partial-export file; GetForExport() is what routes a multi-instance export ' +
                        'through Get() instead of a hand-built hashtable that drifts from it'
        }
    )
}

Describe 'Class-based resource conventions' {

    It 'every resource <Name>' -ForEach $conventionRules {

        $detail = if ($Offenders.Count -eq 0) { '' }
                  else { "`n  " + (($Offenders | Select-Object -First 25) -join "`n  ") +
                         $(if ($Offenders.Count -gt 25) { "`n  ... and $($Offenders.Count - 25) more" } else { '' }) }

        $Offenders.Count | Should -Be 0 -Because ($Because + $detail)
    }
}
