using Microsoft365DSC.Utilities;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Microsoft365DSC.Relations
{
    /// <summary>
    /// Inputs needed to render stub blocks for dependency targets that were not exported.
    /// </summary>
    /// <remarks>
    /// Both values are supplied by PowerShell rather than looked up here, so this assembly
    /// never has to call back into the module while it is rewriting the document.
    /// </remarks>
    public sealed class StubBlockOptions
    {
        /// <summary>
        /// Mandatory property names per resource type, as a hashtable of
        /// resource name to a collection of property names.
        /// </summary>
        public object? MandatoryPropertiesByResource { get; set; }

        /// <summary>
        /// The authentication property names to emit on each stub, for the connection mode
        /// the export is running under.
        /// </summary>
        public string[] AuthenticationProperties { get; set; } = [];
    }

    /// <summary>
    /// Injects DependsOn declarations into exported DSC content and appends stub blocks for
    /// unresolved targets.
    /// </summary>
    /// <remarks>
    /// The document is scanned once to locate every resource block, then rebuilt once. The
    /// previous implementation searched the whole document from the start and reallocated it
    /// in full for every single source block, which on a large export dominated the entire
    /// dependency phase.
    /// </remarks>
    public static class DependsOnInjector
    {
        private const string BlockIndent = "        ";
        private const string ClosingBrace = "        }";
        private const string NewLine = "\r\n";
        private const string StubHeader = "        # Dependency stubs - minimal resource blocks for referenced resources";

        /// <summary>
        /// The order Get-M365DSCExportContentForResource uses to pick an instance's primary
        /// key, minus IsSingleInstance, which is driven by its allowed values instead.
        /// </summary>
        private static readonly string[] KeyPropertyPrecedence =
        [
            "DisplayName", "Name", "Title", "Identity", "Id",
            "UserPrincipalName", "DomainName", "OrganizationName", "WorkspaceName", "CDNType"
        ];

        /// <summary>
        /// Rewrites exported content with DependsOn declarations and dependency stubs.
        /// </summary>
        /// <param name="content">The concatenated resource blocks.</param>
        /// <param name="dependencies">The dependencies discovered during export.</param>
        /// <param name="instances">The instances that were actually exported.</param>
        /// <param name="stubOptions">Inputs for rendering stub blocks.</param>
        /// <returns>The rewritten content.</returns>
        public static string Inject(
            string content,
            IReadOnlyList<DependencyRecord> dependencies,
            IReadOnlyCollection<ExportedInstance> instances,
            StubBlockOptions stubOptions)
        {
            if (string.IsNullOrEmpty(content) || dependencies is null || dependencies.Count == 0)
            {
                return content;
            }

            TargetLookup lookup = TargetLookup.Build(instances);

            // Grouped by source. A parallel export discovers dependencies in whatever order
            // the runspaces happen to finish, so nothing here may depend on arrival order:
            // both the per-source lists and the stub blocks are sorted before rendering.
            Dictionary<string, List<string>> targetsBySource = new(StringComparer.OrdinalIgnoreCase);
            Dictionary<string, HashSet<string>> seenBySource = new(StringComparer.OrdinalIgnoreCase);
            Dictionary<string, UnresolvedTarget> unresolved = new(StringComparer.OrdinalIgnoreCase);

            foreach (DependencyRecord dependency in dependencies)
            {
                string? targetReference = lookup.Resolve(dependency);
                if (targetReference is null)
                {
                    string stubKey = dependency.TargetResourceType + DependencyCollector.KeySeparator + dependency.TargetKey;
                    if (!unresolved.ContainsKey(stubKey))
                    {
                        unresolved[stubKey] = new UnresolvedTarget(
                            dependency.TargetResourceType, dependency.TargetKey, dependency.TargetKeyProperty);
                    }

                    targetReference = $"[{dependency.TargetResourceType}]{GetStubInstanceName(dependency.TargetResourceType, dependency.TargetKey)}";
                }

                string sourceReference = dependency.SourceReference;
                if (!targetsBySource.TryGetValue(sourceReference, out List<string>? targets))
                {
                    targets = [];
                    targetsBySource[sourceReference] = targets;
                    seenBySource[sourceReference] = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                }

                if (seenBySource[sourceReference].Add(targetReference))
                {
                    targets.Add(targetReference);
                }
            }

            foreach (List<string> targets in targetsBySource.Values)
            {
                targets.Sort(StringComparer.Ordinal);
            }

            string rewritten = InjectDependsOnLines(content, targetsBySource);

            if (unresolved.Count > 0)
            {
                List<UnresolvedTarget> orderedStubs = [.. unresolved.Values];
                orderedStubs.Sort(static (left, right) =>
                {
                    int byType = string.CompareOrdinal(left.ResourceType, right.ResourceType);
                    return byType != 0 ? byType : string.CompareOrdinal(left.TargetKey, right.TargetKey);
                });

                rewritten += RenderStubBlocks(orderedStubs, stubOptions ?? new StubBlockOptions());
            }

            return rewritten;
        }

        /// <summary>
        /// Locates every source block in one pass and rebuilds the document once.
        /// </summary>
        /// <param name="content">The content to rewrite.</param>
        /// <param name="targetsBySource">DependsOn targets keyed by source reference.</param>
        /// <returns>The content with DependsOn lines inserted.</returns>
        private static string InjectDependsOnLines(string content, Dictionary<string, List<string>> targetsBySource)
        {
            // Header text -> source reference, so each scanned line is a single lookup.
            Dictionary<string, string> headers = new(targetsBySource.Count, StringComparer.Ordinal);
            foreach (string sourceReference in targetsBySource.Keys)
            {
                if (TrySplitReference(sourceReference, out string resourceName, out string instanceName))
                {
                    headers[$"{BlockIndent}{resourceName} \"{instanceName}\""] = sourceReference;
                }
            }

            if (headers.Count == 0)
            {
                return content;
            }

            StringBuilder builder = new(content.Length + (targetsBySource.Count * 64));
            string? pendingSource = null;
            int copiedTo = 0;
            int lineStart = 0;

            while (lineStart <= content.Length)
            {
                int lineBreak = content.IndexOf('\n', lineStart);
                int lineEnd = lineBreak < 0 ? content.Length : lineBreak;

                int trimmedEnd = lineEnd;
                if (trimmedEnd > lineStart && content[trimmedEnd - 1] == '\r')
                {
                    trimmedEnd--;
                }

                string line = content.Substring(lineStart, trimmedEnd - lineStart);

                if (pendingSource is null)
                {
                    if (headers.TryGetValue(line, out string? sourceReference))
                    {
                        pendingSource = sourceReference;
                    }
                }
                else if (line == ClosingBrace)
                {
                    // Emit the DependsOn line immediately above this block's closing brace.
                    builder.Append(content, copiedTo, lineStart - copiedTo);
                    builder.Append(RenderDependsOnLine(targetsBySource[pendingSource]));
                    builder.Append(NewLine);
                    copiedTo = lineStart;
                    pendingSource = null;
                }

                if (lineBreak < 0)
                {
                    break;
                }

                lineStart = lineBreak + 1;
            }

            builder.Append(content, copiedTo, content.Length - copiedTo);
            return builder.ToString();
        }

        /// <summary>
        /// Renders one DependsOn assignment line.
        /// </summary>
        /// <param name="targets">The target references.</param>
        /// <returns>The rendered line, without a trailing newline.</returns>
        private static string RenderDependsOnLine(List<string> targets)
        {
            StringBuilder builder = new();
            builder.Append("            DependsOn = @(");

            for (int i = 0; i < targets.Count; i++)
            {
                if (i > 0)
                {
                    builder.Append(", ");
                }

                builder.Append('"');
                builder.Append(targets[i]);
                builder.Append('"');
            }

            builder.Append(')');
            return builder.ToString();
        }

        /// <summary>
        /// Builds the instance name a stub block is declared under.
        /// </summary>
        /// <param name="resourceType">The stubbed resource type.</param>
        /// <param name="targetKey">The value identifying the target.</param>
        /// <returns>The instance name.</returns>
        private static string GetStubInstanceName(string resourceType, string targetKey)
        {
            return resourceType + "-" + Utilities.Utilities.RemoveSpecialCharacters(targetKey);
        }

        /// <summary>
        /// Escapes a value for a double quoted PowerShell string.
        /// </summary>
        /// <param name="value">The raw value.</param>
        /// <returns>The escaped value.</returns>
        private static string EscapeValue(string value)
        {
            string escaped = value
                .Replace("`", "``")
                .Replace("\"", "`\"")
                .Replace("$", "`$");

            return Utilities.Utilities.UpdateSpecialCharacters(escaped);
        }

        /// <summary>
        /// Splits a <c>[ResourceName]InstanceName</c> reference.
        /// </summary>
        /// <param name="reference">The reference to split.</param>
        /// <param name="resourceName">Receives the resource type.</param>
        /// <param name="instanceName">Receives the instance name.</param>
        /// <returns>True when the reference is well formed.</returns>
        private static bool TrySplitReference(string reference, out string resourceName, out string instanceName)
        {
            resourceName = string.Empty;
            instanceName = string.Empty;

            if (string.IsNullOrEmpty(reference) || reference[0] != '[')
            {
                return false;
            }

            int close = reference.IndexOf(']');
            if (close <= 1 || close == reference.Length - 1)
            {
                return false;
            }

            resourceName = reference.Substring(1, close - 1);
            instanceName = reference.Substring(close + 1);
            return true;
        }

        /// <summary>
        /// Renders minimal resource blocks for targets described by loose objects.
        /// </summary>
        /// <param name="targets">
        /// Items exposing <c>ResourceType</c> and <c>TargetKey</c> members, such as hashtables.
        /// </param>
        /// <param name="stubOptions">Inputs for rendering.</param>
        /// <returns>The stub block text, or an empty string when there is nothing to render.</returns>
        public static string RenderStubs(IEnumerable targets, StubBlockOptions stubOptions)
        {
            if (targets is null)
            {
                return string.Empty;
            }

            List<UnresolvedTarget> resolved = [];
            foreach (object? item in targets)
            {
                string? resourceType = MemberAccessor.GetMemberAsString(item, "ResourceType");
                string? targetKey = MemberAccessor.GetMemberAsString(item, "TargetKey");
                if (resourceType is not null && targetKey is not null)
                {
                    resolved.Add(new UnresolvedTarget(
                        resourceType, targetKey, MemberAccessor.GetMemberAsString(item, "TargetKeyProperty")));
                }
            }

            return resolved.Count == 0
                ? string.Empty
                : RenderStubBlocks(resolved, stubOptions ?? new StubBlockOptions());
        }

        /// <summary>
        /// Renders minimal resource blocks so unresolved references still compile.
        /// </summary>
        /// <param name="targets">The unresolved targets.</param>
        /// <param name="options">Inputs for rendering.</param>
        /// <returns>The stub block text.</returns>
        private static string RenderStubBlocks(IEnumerable<UnresolvedTarget> targets, StubBlockOptions options)
        {
            StringBuilder builder = new();
            builder.Append(NewLine).Append(StubHeader).Append(NewLine);

            foreach (UnresolvedTarget target in targets)
            {
                string key = EscapeValue(target.TargetKey);
                builder.Append(BlockIndent).Append(target.ResourceType)
                    .Append(" \"").Append(GetStubInstanceName(target.ResourceType, target.TargetKey)).Append('"').Append(NewLine);
                builder.Append(BlockIndent).Append('{').Append(NewLine);

                List<StubProperty> properties = GetMandatoryProperties(options.MandatoryPropertiesByResource, target.ResourceType);

                if (properties.Count > 0)
                {
                    string? keyProperty = ChooseKeyProperty(properties, target.TargetKeyProperty);

                    foreach (StubProperty property in properties)
                    {
                        // Authentication and Ensure are emitted below; emitting them here too
                        // would produce a duplicate assignment and refuse to compile.
                        if (IsHandledSeparately(property.Name, options.AuthenticationProperties))
                        {
                            continue;
                        }

                        bool isKey = keyProperty is not null &&
                            string.Equals(property.Name, keyProperty, StringComparison.OrdinalIgnoreCase);

                        builder.Append("            ").Append(property.Name).Append(" = ")
                            .Append(property.RenderValue(isKey ? key : null)).Append(NewLine);
                    }

                    foreach (string property in options.AuthenticationProperties)
                    {
                        builder.Append("            ").Append(property).Append(" = ")
                            .Append(string.Equals(property, "ManagedIdentity", StringComparison.OrdinalIgnoreCase)
                                ? "$true"
                                : "$ConfigurationData.NonNodeData." + property)
                            .Append(NewLine);
                    }
                }
                else
                {
                    // The resource is not in the dictionary, so the best that can be done is to
                    // assume the conventional key property.
                    builder.Append("            DisplayName = \"").Append(key).Append('"').Append(NewLine);
                }

                builder.Append("            Ensure      = \"Present\"").Append(NewLine);
                builder.Append(BlockIndent).Append('}').Append(NewLine);
            }

            return builder.ToString();
        }

        /// <summary>
        /// Decides which mandatory property should carry the referenced key.
        /// </summary>
        /// <param name="properties">The resource's mandatory properties.</param>
        /// <param name="declaredKeyProperty">The property named by the relation, if any.</param>
        /// <returns>The property name to assign the key to, or null when none fits.</returns>
        /// <remarks>
        /// The relation's own <c>targetKeyProperty</c> wins. Without one, this falls back to
        /// the same precedence Get-M365DSCExportContentForResource uses to pick a primary key,
        /// so a stub is keyed the same way the real instance would have been.
        /// </remarks>
        private static string? ChooseKeyProperty(List<StubProperty> properties, string? declaredKeyProperty)
        {
            if (declaredKeyProperty is not null &&
                properties.Any(p => string.Equals(p.Name, declaredKeyProperty, StringComparison.OrdinalIgnoreCase)))
            {
                return declaredKeyProperty;
            }

            foreach (string candidate in KeyPropertyPrecedence)
            {
                StubProperty? match = properties.FirstOrDefault(
                    p => p.CanHoldKey && string.Equals(p.Name, candidate, StringComparison.OrdinalIgnoreCase));
                if (match is not null)
                {
                    return match.Name;
                }
            }

            // Otherwise the first mandatory property that can hold a name at all.
            return properties.FirstOrDefault(p => p.CanHoldKey)?.Name;
        }

        /// <summary>
        /// Reports whether a property is already emitted elsewhere in the stub block.
        /// </summary>
        /// <param name="name">The property name.</param>
        /// <param name="authenticationProperties">The authentication properties being emitted.</param>
        /// <returns>True when the property must be skipped in the mandatory loop.</returns>
        private static bool IsHandledSeparately(string name, string[] authenticationProperties)
        {
            if (string.Equals(name, "Ensure", StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            return Utilities.Utilities.IsAuthenticationProperty(name) ||
                authenticationProperties.Any(p => string.Equals(p, name, StringComparison.OrdinalIgnoreCase));
        }

        /// <summary>
        /// Reads the mandatory properties for a resource type out of the supplied map.
        /// </summary>
        /// <param name="source">The map of resource name to property descriptors.</param>
        /// <param name="resourceType">The resource type to look up.</param>
        /// <returns>The mandatory properties, empty when the resource type is unknown.</returns>
        /// <remarks>
        /// Entries may be plain names or objects carrying Name, PropertyType and Values, so a
        /// caller that only knows the names still gets a usable, if less precise, stub.
        /// </remarks>
        private static List<StubProperty> GetMandatoryProperties(object? source, string resourceType)
        {
            List<StubProperty> properties = [];

            if (source is null || !MemberAccessor.TryGetMember(source, resourceType, out object? value) || value is null)
            {
                return properties;
            }

            if (value is string single)
            {
                properties.Add(new StubProperty(single, null, null));
                return properties;
            }

            if (value is IEnumerable enumerable)
            {
                foreach (object? item in enumerable)
                {
                    object? entry = MemberAccessor.Unwrap(item);
                    if (entry is null)
                    {
                        continue;
                    }

                    if (entry is string name)
                    {
                        properties.Add(new StubProperty(name, null, null));
                        continue;
                    }

                    string? entryName = MemberAccessor.GetMemberAsString(entry, "Name");
                    if (entryName is null)
                    {
                        continue;
                    }

                    string? propertyType = MemberAccessor.GetMemberAsString(entry, "PropertyType");
                    List<string> values = [];
                    if (MemberAccessor.TryGetMember(entry, "Values", out object? rawValues) &&
                        MemberAccessor.Unwrap(rawValues) is IEnumerable valueList and not string)
                    {
                        foreach (object? allowed in valueList)
                        {
                            object? unwrapped = MemberAccessor.Unwrap(allowed);
                            if (unwrapped is not null)
                            {
                                values.Add(unwrapped.ToString());
                            }
                        }
                    }

                    properties.Add(new StubProperty(entryName, propertyType, values));
                }
            }

            return properties;
        }

        /// <summary>
        /// A mandatory property of a resource, and enough type information to synthesize a
        /// placeholder value for it.
        /// </summary>
        private sealed class StubProperty
        {
            private static readonly HashSet<string> NumericTypes = new(StringComparer.OrdinalIgnoreCase)
            {
                "byte", "sbyte", "int16", "uint16", "int32", "uint32", "int64", "uint64",
                "int", "long", "short", "single", "double", "decimal", "float"
            };

            internal StubProperty(string name, string? propertyType, List<string>? values)
            {
                Name = name;
                Values = values ?? [];

                // Property types arrive as they appear in the schema, for example "[string]",
                // "[bool]" or "[string[]]". Only the outer pair of brackets is removed: a
                // blanket trim would also eat the "[]" that marks an array.
                string type = (propertyType ?? string.Empty).Trim();
                if (type.Length > 1 && type[0] == '[' && type[type.Length - 1] == ']')
                {
                    type = type.Substring(1, type.Length - 2);
                }

                IsArray = type.EndsWith("[]", StringComparison.Ordinal);
                BaseType = IsArray ? type.Substring(0, type.Length - 2) : type;
            }

            internal string Name { get; }

            internal List<string> Values { get; }

            internal bool IsArray { get; }

            private string BaseType { get; }

            /// <summary>
            /// True when the property could carry the referenced key: it has to be textual,
            /// and it must not be restricted to a fixed set of values the key would violate.
            /// </summary>
            internal bool CanHoldKey =>
                Values.Count == 0 &&
                (BaseType.Length == 0 || string.Equals(BaseType, "string", StringComparison.OrdinalIgnoreCase));

            /// <summary>
            /// Produces a value for this property in a stub block.
            /// </summary>
            /// <param name="key">The referenced key when this property carries it, otherwise null.</param>
            /// <returns>The rendered right-hand side of the assignment.</returns>
            internal string RenderValue(string? key)
            {
                if (key is not null)
                {
                    return IsArray ? $"@(\"{key}\")" : $"\"{key}\"";
                }

                // A constrained property must use one of its allowed values.
                if (Values.Count > 0)
                {
                    return IsArray ? $"@(\"{Values[0]}\")" : $"\"{Values[0]}\"";
                }

                if (IsArray)
                {
                    return "@()";
                }

                if (string.Equals(BaseType, "bool", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(BaseType, "boolean", StringComparison.OrdinalIgnoreCase))
                {
                    // A security group is the common case, and a group that is neither mail
                    // enabled nor security enabled is rejected outright.
                    return string.Equals(Name, "SecurityEnabled", StringComparison.OrdinalIgnoreCase) ? "$true" : "$false";
                }

                if (NumericTypes.Contains(BaseType))
                {
                    return "0";
                }

                return "\"\"";
            }
        }

        /// <summary>
        /// A dependency target that was referenced but never exported.
        /// </summary>
        private sealed class UnresolvedTarget
        {
            internal UnresolvedTarget(string resourceType, string targetKey, string? targetKeyProperty)
            {
                ResourceType = resourceType;
                TargetKey = targetKey;
                TargetKeyProperty = targetKeyProperty;
            }

            internal string ResourceType { get; }

            internal string TargetKey { get; }

            /// <summary>The property the key belongs in, when the relation declared one.</summary>
            internal string? TargetKeyProperty { get; }
        }

        /// <summary>
        /// Resolves dependency records to exported instance references.
        /// </summary>
        private sealed class TargetLookup
        {
            private readonly Dictionary<string, string> _byKeyProperty = new(StringComparer.OrdinalIgnoreCase);
            private readonly Dictionary<string, string> _byPrimaryKey = new(StringComparer.OrdinalIgnoreCase);

            internal static TargetLookup Build(IReadOnlyCollection<ExportedInstance> instances)
            {
                TargetLookup lookup = new();
                if (instances is null)
                {
                    return lookup;
                }

                foreach (ExportedInstance instance in instances)
                {
                    string reference = instance.Reference;
                    Claim(lookup._byPrimaryKey, instance.ResourceName + DependencyCollector.KeySeparator + instance.PrimaryKey, reference);

                    if (instance.KeyValues is null)
                    {
                        continue;
                    }

                    foreach (KeyValuePair<string, string> keyValue in instance.KeyValues)
                    {
                        string composite = instance.ResourceName + DependencyCollector.KeySeparator
                            + keyValue.Key + DependencyCollector.KeySeparator + keyValue.Value;
                        Claim(lookup._byKeyProperty, composite, reference);
                    }
                }

                return lookup;
            }

            /// <summary>
            /// Records a reference for a key, keeping the ordinally first reference when two
            /// instances claim the same key.
            /// </summary>
            /// <param name="map">The map to write to.</param>
            /// <param name="key">The composite lookup key.</param>
            /// <param name="reference">The candidate instance reference.</param>
            /// <remarks>
            /// Last-write-wins would make the result depend on the order instances were
            /// registered, which a parallel export does not fix.
            /// </remarks>
            private static void Claim(Dictionary<string, string> map, string key, string reference)
            {
                if (!map.TryGetValue(key, out string? existing) || string.CompareOrdinal(reference, existing) < 0)
                {
                    map[key] = reference;
                }
            }

            /// <summary>
            /// Finds the exported instance a dependency points at.
            /// </summary>
            /// <param name="dependency">The dependency to resolve.</param>
            /// <returns>The instance reference, or null when the target was not exported.</returns>
            /// <remarks>
            /// The relation's declared target key property is preferred. Falling back to the
            /// primary key keeps every match the previous implementation made, so honouring
            /// the declared property can only resolve more references, never fewer.
            /// </remarks>
            internal string? Resolve(DependencyRecord dependency)
            {
                if (dependency.TargetKeyProperty is not null)
                {
                    string composite = dependency.TargetResourceType + DependencyCollector.KeySeparator
                        + dependency.TargetKeyProperty + DependencyCollector.KeySeparator + dependency.TargetKey;
                    if (_byKeyProperty.TryGetValue(composite, out string? byProperty))
                    {
                        return byProperty;
                    }
                }

                return _byPrimaryKey.TryGetValue(
                    dependency.TargetResourceType + DependencyCollector.KeySeparator + dependency.TargetKey,
                    out string? byPrimary)
                    ? byPrimary
                    : null;
            }
        }
    }
}
