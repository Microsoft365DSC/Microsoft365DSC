using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.RegularExpressions;

namespace Microsoft365DSC.Intune
{
    /// <summary>
    /// Internal representation of a Microsoft Graph DeviceManagementConfigurationSettingDefinition.
    /// Avoids a direct dependency on the Microsoft.Graph SDK types.
    /// </summary>
    public class SettingDefinitionInfo
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string OffsetUri { get; set; }

        /// <summary>
        /// Flattened list of unique parentSettingId values from dependentOn[].parentSettingId.
        /// </summary>
        public List<string> DependentOnParentSettingIds { get; set; } = [];

        /// <summary>
        /// Flattened list of unique parentSettingId values from options[].dependentOn[].parentSettingId.
        /// </summary>
        public List<string> OptionsDependentOnParentSettingIds { get; set; } = [];

        /// <summary>
        /// The OData type from ['@odata.type'].
        /// Used to determine the setting type (e.g., ChoiceSettingDefinition, GroupSettingCollectionDefinition).
        /// </summary>
        public string ODataType { get; set; }

        /// <summary>
        /// Maximum number of instances allowed for this setting (from maximumCount).
        /// Used in GroupSettingCollection logic to determine single vs. multi-instance handling.
        /// </summary>
        public int MaximumCount { get; set; }

        /// <summary>
        /// Child setting definition IDs (from childIds).
        /// Used in Export to find child definitions of a GroupSettingCollection.
        /// </summary>
        public List<string> ChildIds { get; set; } = [];

        /// <summary>
        /// Options for ChoiceSetting definitions (from options[]).
        /// Each option has an itemId and an optionValue with a value and OData type.
        /// </summary>
        public List<SettingDefinitionOption> Options { get; set; } = [];

        /// <summary>
        /// Value definition metadata (from valueDefinition).
        /// Contains the OData type and isSecret flag.
        /// </summary>
        public SettingValueDefinition ValueDefinition { get; set; }
    }

    /// <summary>
    /// Maps Microsoft Graph DeviceManagementConfigurationSettingDefinition objects (passed as PSObject or Hashtable)
    /// to the internal <see cref="SettingDefinitionInfo"/> representation.
    /// </summary>
    internal static class SettingDefinitionMapper
    {
        private static BindingFlags _publicIgnoreCaseInstanceFlags = BindingFlags.Public | BindingFlags.IgnoreCase | BindingFlags.Instance;

        /// <summary>
        /// Maps a single Graph SettingDefinition (typically a PSObject or Hashtable) to <see cref="SettingDefinitionInfo"/>.
        /// Extracts Id, Name, OffsetUri, and the parentSettingId collections.
        /// </summary>
        public static SettingDefinitionInfo FromGraphObject(object settingDefinition)
        {
            var info = new SettingDefinitionInfo
            {
                Id = TryGetProperty(settingDefinition, "Id"),
                Name = TryGetProperty(settingDefinition, "Name"),
                OffsetUri = TryGetProperty(settingDefinition, "OffsetUri")
            };

            // Collect every property of the model that is not explicitly named
            IDictionary<string, object>? properties = null;
            List<string> defaultProperties = ["Id", "Name", "OffsetUri"];
            properties = new Dictionary<string, object>();
            foreach (DictionaryEntry entry in settingDefinition as Hashtable)
            {
                if (!defaultProperties.Contains(entry.Key.ToString(), StringComparer.OrdinalIgnoreCase))
                {
                    properties[entry.Key.ToString()] = entry.Value;
                }
            }

            if (properties is not null)
            {
                info.DependentOnParentSettingIds = ExtractParentSettingIds(properties, "dependentOn");
                info.OptionsDependentOnParentSettingIds = ExtractOptionsParentSettingIds(properties);

                // Extract OData type
                if (properties.TryGetValue("@odata.type", out object? odataTypeValue))
                {
                    info.ODataType = odataTypeValue?.ToString();
                }

                // Extract maximumCount
                if (properties.TryGetValue("maximumCount", out object? maxCountValue))
                {
                    if (maxCountValue is int maxInt)
                        info.MaximumCount = maxInt;
                    else if (int.TryParse(maxCountValue?.ToString(), out int parsed))
                        info.MaximumCount = parsed;
                }

                // Extract childIds
                if (properties.TryGetValue("childIds", out object? childIdsValue) && childIdsValue is IEnumerable childIdsEnumerable)
                {
                    foreach (var childId in childIdsEnumerable)
                    {
                        if (childId is not null)
                            info.ChildIds.Add(childId.ToString());
                    }
                }

                // Extract options
                info.Options = ExtractOptions(properties);

                // Extract valueDefinition
                if (properties.TryGetValue("valueDefinition", out object? valueDefValue) && valueDefValue is not null)
                {
                    info.ValueDefinition = new SettingValueDefinition
                    {
                        ODataType = TryGetProperty(valueDefValue, "@odata.type"),
                        IsSecret = string.Equals(TryGetProperty(valueDefValue, "isSecret"), "True", StringComparison.OrdinalIgnoreCase)
                    };
                }
            }

            return info;
        }

        /// <summary>
        /// Maps a collection of Graph SettingDefinition objects to a list of <see cref="SettingDefinitionInfo"/>.
        /// </summary>
        public static List<SettingDefinitionInfo> FromGraphObjects(IEnumerable<object> settingDefinitions)
        {
            return settingDefinitions.Select(FromGraphObject).ToList();
        }

        /// <summary>
        /// Extracts parentSettingId values from properties["dependentOn"][].parentSettingId.
        /// </summary>
        private static List<string> ExtractParentSettingIds(IDictionary<string, object> properties, string key)
        {
            if (!properties.TryGetValue(key, out object? value))
                return [];

            if (value is not IEnumerable dependentOnCollection)
                return [];

            List<string> result = [];
            foreach (var item in dependentOnCollection)
            {
                string parentSettingId = TryGetProperty(item, "parentSettingId");
                if (!string.IsNullOrEmpty(parentSettingId))
                    result.Add(parentSettingId);
            }

            return result.Distinct().ToList();
        }

        /// <summary>
        /// Extracts parentSettingId values from properties["options"][].dependentOn[].parentSettingId.
        /// </summary>
        private static List<string> ExtractOptionsParentSettingIds(IDictionary<string, object> properties)
        {
            if (!properties.TryGetValue("options", out object? value))
                return [];

            if (value is not IEnumerable optionsCollection)
                return [];

            List<string> result = [];
            foreach (var option in optionsCollection)
            {
                var dependentOnList = TryGetPropertyAsEnumerable(option, "dependentOn");
                if (dependentOnList is null)
                    continue;

                foreach (var dep in dependentOnList)
                {
                    string parentSettingId = TryGetProperty(dep, "parentSettingId");
                    if (!string.IsNullOrEmpty(parentSettingId))
                        result.Add(parentSettingId);
                }
            }

            return result.Distinct().ToList();
        }

        internal static string TryGetProperty(object obj, string propertyName)
        {
            return TryGetPropertyRaw(obj, propertyName)?.ToString();
        }

        internal static object? TryGetPropertyRaw(object obj, string propertyName)
        {
            if (obj is null)
                return null;

            if (obj is PSObject psobject)
                obj = psobject.BaseObject;

            // Try dictionary access (Hashtable / IDictionary)
            if (obj is IDictionary<string, object> dict && dict.TryGetValue(propertyName, out object? value))
                return value;
            if (obj is Hashtable ht && ht.ContainsKey(propertyName))
                return ht[propertyName];

            // Try reflection
            var prop = obj.GetType().GetProperty(propertyName, _publicIgnoreCaseInstanceFlags);
            return prop?.GetValue(obj);
        }

        internal static IEnumerable<object>? TryGetPropertyAsEnumerable(object obj, string propertyName)
        {
            if (obj is null)
                return null;

            if (obj is PSObject psobject)
                obj = psobject.BaseObject;

            if (obj is IDictionary<string, object> dict && dict.TryGetValue(propertyName, out object? value))
                return value as IEnumerable<object>;
            if (obj is Hashtable ht && ht.ContainsKey(propertyName))
                return ht[propertyName] as IEnumerable<object>;

            var prop = obj.GetType().GetProperty(propertyName, _publicIgnoreCaseInstanceFlags);
            return prop?.GetValue(obj) as IEnumerable<object>;
        }

        /// <summary>
        /// Extracts the options array from the properties the model does not name explicitly.
        /// Each option has an itemId, optionValue (with @odata.type and value), and dependentOn parent setting IDs.
        /// </summary>
        private static List<SettingDefinitionOption> ExtractOptions(IDictionary<string, object> properties)
        {
            var options = new List<SettingDefinitionOption>();

            if (!properties.TryGetValue("options", out object? optionsValue))
                return options;

            if (optionsValue is not IEnumerable optionsCollection)
                return options;

            foreach (var option in optionsCollection)
            {
                if (option is null) continue;

                var opt = new SettingDefinitionOption
                {
                    ItemId = TryGetProperty(option, "itemId")
                };

                // Extract optionValue
                var optionValueRaw = TryGetPropertyRaw(option, "optionValue");
                if (optionValueRaw is not null)
                {
                    opt.OptionValue = new OptionValue
                    {
                        ODataType = TryGetProperty(optionValueRaw, "@odata.type"),
                        Value = TryGetProperty(optionValueRaw, "value")
                    };
                }

                // Extract dependentOn for this option
                var dependentOnList = TryGetPropertyAsEnumerable(option, "dependentOn");
                if (dependentOnList is not null)
                {
                    foreach (var dep in dependentOnList)
                    {
                        string parentSettingId = TryGetProperty(dep, "parentSettingId");
                        if (!string.IsNullOrEmpty(parentSettingId))
                            opt.DependentOnParentSettingIds.Add(parentSettingId);
                    }
                }

                options.Add(opt);
            }

            return options;
        }
    }

    /// <summary>
    /// C# port of the PowerShell module M365DSCIntuneSettingsCatalogUtil.
    /// Provides deterministic setting name resolution for Intune Settings Catalog definitions.
    ///
    /// Each method maps 1:1 to its PowerShell counterpart. Deviations are documented inline.
    /// </summary>
    public static class SettingsCatalogHelper
    {
        /// <summary>
        /// Name simplification rules applied when the setting name was disambiguated (settingsWithSameName.Count > 1).
        /// Each entry is (wildcardPrefix, wildcardSuffix, searchString, replacementString).
        ///
        /// Corresponds to the "switch -wildcard" block in the PowerShell Get-SettingsCatalogSettingName.
        ///
        /// Optimization note: The PowerShell version uses a switch with -Wildcard patterns that are evaluated
        /// sequentially. Here we use a data-driven approach with a list of tuples, which is equivalent but
        /// more maintainable - adding a new simplification rule requires only one line instead of a new
        /// switch case block.
        /// </summary>
        private static readonly List<(string? ExactMatch, string? Prefix, string? Suffix, string? Search, string Replace)> NameSimplificationRules =
            [
                // Exact match: 'com.apple.managedclient.preferences_enforcementLevel' -> 'enforcementLevel'
                ("com.apple.managedclient.preferences_enforcementLevel", null, null, null, "enforcementLevel"),

                // Wildcard prefix replacements: 'prefix*' -> replace prefix portion
                (null, "access16v2~Policy~L_MicrosoftOfficeaccess~L_ApplicationSettings~", null,
                    "access16v2~Policy~L_MicrosoftOfficeaccess~L_ApplicationSettings", "MicrosoftAccess_"),
                (null, "excel16v2~Policy~L_MicrosoftOfficeExcel~L_ExcelOptions~", null,
                    "excel16v2~Policy~L_MicrosoftOfficeExcel~L_ExcelOptions", "MicrosoftExcel_"),
                (null, "word16v2~Policy~L_MicrosoftOfficeWord~L_WordOptions~", null,
                    "word16v2~Policy~L_MicrosoftOfficeWord~L_WordOptions", "MicrosoftWord_"),
                (null, "ppt16v2~Policy~L_MicrosoftOfficePowerPoint~L_PowerPointOptions~", null,
                    "ppt16v2~Policy~L_MicrosoftOfficePowerPoint~L_PowerPointOptions", "MicrosoftPowerPoint_"),
                (null, "proj16v2~Policy~L_Proj~L_ProjectOptions~", null,
                    "proj16v2~Policy~L_Proj~L_ProjectOptions", "MicrosoftProject_"),
                (null, "proj16v3~Policy~L_Proj~L_ProjectOptions~", null,
                    "proj16v3~Policy~L_Proj~L_ProjectOptions", "MicrosoftProjectV3_"),
                (null, "visio16v2~Policy~L_MicrosoftVisio~L_VisioOptions~", null,
                    "visio16v2~Policy~L_MicrosoftVisio~L_VisioOptions", "MicrosoftVisio_"),
                (null, "pub16v2~Policy~L_MicrosoftOfficePublisher~", null,
                    "pub16v2~Policy~L_MicrosoftOfficePublisher", "MicrosoftPublisherV2_"),
                (null, "pub16v3~Policy~L_MicrosoftOfficePublisher~", null,
                    "pub16v3~Policy~L_MicrosoftOfficePublisher", "MicrosoftPublisherV3_"),
                (null, "microsoft_edge~Policy~microsoft_edge~", null,
                    "microsoft_edge~Policy~microsoft_edge", "MicrosoftEdge_"),
                (null, "edge~httpauthentication", null,
                    "edge~httpauthentication", "MicrosoftEdge_HTTPAuthentication"),
                (null, "edge~contentsettings", null,
                    "edge~contentsettings", "MicrosoftEdge_ContentSettings"),
                (null, "edge~passwordmanager", null,
                    "edge~passwordmanager", "MicrosoftEdge_PasswordManager"),

                // Contains-style (wildcard on both sides): '*~X~*' or '*~X_*'
                (null, null, "~SmartScreen_", "~SmartScreen", "SmartScreen"),
                (null, null, "~L_Security~", "~L_Security", "Security"),
                (null, null, "~L_Security_", "~L_Security_", "Security_"),
                (null, null, "~L_TrustCenter", "~L_TrustCenter", "_TrustCenter"),
                (null, null, "~L_ProtectedView_", "~L_ProtectedView", "ProtectedView"),
                (null, null, "~L_FileBlockSettings_", "~L_FileBlockSettings", "FileBlockSettings"),
                (null, null, "~L_TrustedLocations", "~L_TrustedLocations", "TrustedLocations"),
                (null, null, "~HTTPAuthentication_", "~HTTPAuthentication", "HTTPAuthentication"),
            ];

        /// <summary>
        /// Port of Get-SettingsCatalogSettingName.
        /// Resolves a unique, human-readable setting name for a given setting definition.
        /// Accepts raw Graph SDK objects and maps them internally.
        /// </summary>
        /// <summary>
        /// Lower-cases the first character, which is how a Graph type name is turned into the
        /// corresponding property name.
        /// </summary>
        /// <param name="value">The value to convert.</param>
        /// <returns>The value with its first character lower-cased.</returns>
        internal static string ToCamelCase(string value)
        {
            return string.IsNullOrEmpty(value) ? value : char.ToLowerInvariant(value[0]) + value.Substring(1);
        }

        public static string GetSettingName(object settingDefinitionAsGraph, List<object> allSettingDefinitionsAsGraph)
        {
            var settingDefinition = SettingDefinitionMapper.FromGraphObject(settingDefinitionAsGraph);
            var allSettingDefinitions = SettingDefinitionMapper.FromGraphObjects(allSettingDefinitionsAsGraph);
            return GetSettingName(settingDefinition, allSettingDefinitions);
        }

        internal static string WithoutDoubledParent(string settingName)
        {
            if (string.IsNullOrEmpty(settingName) || settingName.Length % 2 == 0)
                return settingName;

            int half = settingName.Length / 2;
            if (settingName[half] != '_')
                return settingName;

            string head = settingName.Substring(0, half);
            string tail = settingName.Substring(half + 1);
            return string.Equals(head, tail, StringComparison.OrdinalIgnoreCase) ? tail : settingName;
        }

        /// <summary>
        /// Port of Get-SettingsCatalogSettingName.
        /// Resolves a unique, human-readable setting name for a given setting definition.
        /// Accepts pre-mapped <see cref="SettingDefinitionInfo"/> objects to avoid repeated reflection.
        /// </summary>
        public static string GetSettingName(SettingDefinitionInfo settingDefinition, List<SettingDefinitionInfo> allSettingDefinitions)
        {
            DefinitionLookups lookups = DefinitionLookups.For(allSettingDefinitions);
            return lookups.ResolveName(settingDefinition, definition => ResolveSettingName(definition, allSettingDefinitions, lookups));
        }

        private static string ResolveSettingName(SettingDefinitionInfo settingDefinition, List<SettingDefinitionInfo> allSettingDefinitions, DefinitionLookups lookups)
        {
            string settingName = SanitizeSettingName(settingDefinition.Name);

            var settingsWithSameName = lookups.ByName(settingName);

            // Edge case where the same setting is defined twice with identical name and id
            // Example is RDVAllowBDE_Name from the IntuneDiskEncryptionWindows10 resource
            if (settingsWithSameName.Count == 2)
            {
                if (settingsWithSameName[0].Id.Equals(settingsWithSameName[1].Id) &&
                    settingsWithSameName[0].Name.Equals(settingsWithSameName[1].Name, StringComparison.OrdinalIgnoreCase))
                {
                    settingsWithSameName = [settingsWithSameName[0]];
                }
            }

            if (settingsWithSameName.Count <= 1)
            {
                return settingName;
            }

            // Get the parent setting of the current setting
            var parentSetting = GetParentSettingDefinition(settingDefinition, allSettingDefinitions);

            if (parentSetting is not null)
            {
                // Check if parent+name combination is unique
                List<SettingDefinitionInfo> combinationMatchesWithParent = [];
                foreach (var s in settingsWithSameName)
                {
                    var innerParent = GetParentSettingDefinition(s, allSettingDefinitions);
                    if (innerParent is not null)
                    {
                        if ($"{innerParent.Name}_{s.Name}".Equals($"{parentSetting.Name}_{settingName}", StringComparison.OrdinalIgnoreCase))
                        {
                            combinationMatchesWithParent.Add(s);
                        }
                    }
                }

                // If the combination of parent setting and setting name is unique, add the parent setting name to the setting name
                if (combinationMatchesWithParent.Count == 1)
                {
                    // Unique with parent prefix
                    settingName = parentSetting.Name + "_" + settingName;
                }
                // If the combination of parent setting and setting name is still not unique, do it with the OffsetUri of the current setting
                else
                {
                    // Try disambiguating via OffsetUri traversal
                    var result = GetUniqueNameFromMultipleMatches(settingDefinition, settingName, settingsWithSameName);
                    if (result.Success)
                    {
                        settingName = result.SettingName;
                    }
                    else
                    {
                        // Fallback: derive from parent setting Id
                        // Alternative way if no unique setting name can be found
                        string[] parentIdParts = parentSetting.Id.Split('_');
                        string parentSettingIdProperty = parentIdParts[parentIdParts.Length - 1];
                        string parentSettingIdWithoutProperty = parentSetting.Id
                            .Substring(0, parentSetting.Id.Length - parentSettingIdProperty.Length - 1);

                        // We can't use the entire setting here because the child setting id does not have to come after the parent setting id
                        settingName = settingDefinition.Id
                            .Replace(parentSettingIdWithoutProperty + "_", "")
                            .Replace(parentSettingIdProperty + "_", "");
                    }
                }
            }

            // When there is no parent, we can't use the parent setting name to make the setting name unique
            // Instead, we traverse up the OffsetUri.
            if (parentSetting is null)
            {
                var result = GetUniqueNameFromMultipleMatches(settingDefinition, settingName, settingsWithSameName);
                if (result.Success)
                {
                    settingName = result.SettingName;
                }
                else
                {
                    // Can happen if both settings have the same name and the same OffsetUri, e.g. "enforcementLevel" in the IntuneAntivirusPolicyLinux resource
                    // Potential risk of overwriting settings with the same name but different OffsetUri
                    string settingIdWithoutName = Regex.Replace(settingDefinition.Id, "_" + settingName, "", RegexOptions.IgnoreCase);
                    string[] parts = settingIdWithoutName.Split('_');
                    string lastPart = parts[parts.Length - 1];
                    settingName = lastPart + "_" + settingName;
                }
            }

            settingName = ApplyNameSimplification(settingName);

            return settingName;
        }

        private static string SanitizeSettingName(string name)
        {
            StringBuilder builder = new(name.Length);
            foreach (char current in name)
            {
                switch (current)
                {
                    case '{':
                    case '}':
                    case '$':
                        break;
                    case ' ':
                    case '/':
                        builder.Append('_');
                        break;
                    default:
                        builder.Append(current);
                        break;
                }
            }

            return builder.ToString();
        }

        /// <summary>
        /// Port of Get-ParentSettingDefinition.
        /// Finds the parent setting by looking up the first unique parentSettingId
        /// from either dependentOn or options.dependentOn.
        /// </summary>
        private static SettingDefinitionInfo GetParentSettingDefinition(
            SettingDefinitionInfo settingDefinition,
            List<SettingDefinitionInfo> allSettingDefinitions)
        {
            if (settingDefinition.DependentOnParentSettingIds.Count > 0)
            {
                return DefinitionLookups.For(allSettingDefinitions).ById(settingDefinition.DependentOnParentSettingIds.First());
            }

            if (settingDefinition.OptionsDependentOnParentSettingIds.Count > 0)
            {
                return DefinitionLookups.For(allSettingDefinitions).ById(settingDefinition.OptionsDependentOnParentSettingIds.First());
            }

            return null;
        }

        /// <summary>
        /// Name and Id indexes over a definition list. A settings catalog policy resolves every one
        /// of its setting names against the same list, so without an index each resolution is a full
        /// scan and naming a policy is quadratic in the number of definitions.
        /// </summary>
        internal sealed class DefinitionLookups
        {
            private static readonly ConditionalWeakTable<List<SettingDefinitionInfo>, DefinitionLookups> _cache = new();
            private static readonly List<SettingDefinitionInfo> _empty = [];

            private readonly Dictionary<string, List<SettingDefinitionInfo>> _byName = new(StringComparer.OrdinalIgnoreCase);
            private readonly Dictionary<string, SettingDefinitionInfo> _byId = new(StringComparer.Ordinal);
            private readonly Dictionary<string, List<SettingDefinitionInfo>> _childrenByParent = new(StringComparer.Ordinal);
            private readonly ConcurrentDictionary<string, string> _resolvedNames = new(StringComparer.Ordinal);
            private readonly int _sourceCount;

            private DefinitionLookups(List<SettingDefinitionInfo> definitions)
            {
                _sourceCount = definitions.Count;
                foreach (var definition in definitions)
                {
                    if (definition.Name is not null)
                    {
                        if (!_byName.TryGetValue(definition.Name, out var sameName))
                        {
                            sameName = [];
                            _byName[definition.Name] = sameName;
                        }
                        sameName.Add(definition);
                    }

                    if (definition.Id is not null && !_byId.ContainsKey(definition.Id))
                    {
                        _byId[definition.Id] = definition;
                    }

                    foreach (string parentId in definition.DependentOnParentSettingIds.Concat(definition.OptionsDependentOnParentSettingIds).Distinct())
                    {
                        if (!_childrenByParent.TryGetValue(parentId, out var children))
                        {
                            children = [];
                            _childrenByParent[parentId] = children;
                        }
                        children.Add(definition);
                    }
                }
            }

            public string ResolveName(SettingDefinitionInfo definition, Func<SettingDefinitionInfo, string> resolve)
            {
                if (definition.Id is null)
                {
                    return resolve(definition);
                }

                return _resolvedNames.GetOrAdd(definition.Id, _ => resolve(definition));
            }

            public List<SettingDefinitionInfo> ChildrenOf(string parentSettingId)
            {
                return _childrenByParent.TryGetValue(parentSettingId, out var children) ? children : _empty;
            }

            public static DefinitionLookups For(List<SettingDefinitionInfo> definitions)
            {
                if (_cache.TryGetValue(definitions, out var lookups) && lookups._sourceCount == definitions.Count)
                {
                    return lookups;
                }

                lookups = new DefinitionLookups(definitions);
                _cache.Remove(definitions);
                _cache.Add(definitions, lookups);
                return lookups;
            }

            public List<SettingDefinitionInfo> ByName(string name)
            {
                return _byName.TryGetValue(name, out var matches) ? [.. matches] : _empty;
            }

            public SettingDefinitionInfo? ById(string id)
            {
                return _byId.TryGetValue(id, out var definition) ? definition : null;
            }
        }

        /// <summary>
        /// Port of Get-UniqueSettingDefinitionNameFromMultipleMatches.
        /// Iteratively traverses up the OffsetUri to find a unique prefix for the setting name.
        /// </summary>
        private static (bool Success, string SettingName) GetUniqueNameFromMultipleMatches(
            SettingDefinitionInfo settingDefinition,
            string settingName,
            List<SettingDefinitionInfo> settingsWithSameName)
        {
            int skip = 0;
            int breakCounter = 0;
            const int threshold = 8;
            string newSettingName = settingName;
            List<SettingDefinitionInfo> combinationMatches;

            do
            {
                string previousSettingName = newSettingName;
                newSettingName = GetSettingDefinitionNameFromOffsetUri(settingDefinition.OffsetUri, newSettingName, skip);

                combinationMatches = [];
                foreach (var s in settingsWithSameName)
                {
                    string newName = GetSettingDefinitionNameFromOffsetUri(s.OffsetUri, previousSettingName, skip);
                    if (newName.Equals(newSettingName, StringComparison.OrdinalIgnoreCase))
                    {
                        // Exclude v2 versions from the comparison
                        bool currentIsV2 = settingDefinition.Id.EndsWith("_v2");
                        if (currentIsV2 && s.Id != settingDefinition.Id.Replace("_v2", "") ||
                            !currentIsV2 && s.Id != settingDefinition.Id + "_v2")
                        {
                            combinationMatches.Add(s);
                        }
                    }
                }

                settingsWithSameName = combinationMatches;
                skip++;
                breakCounter++;
            } while (combinationMatches.Count > 1 && breakCounter < threshold);

            if (breakCounter < threshold)
            {
                if (settingDefinition.Id.EndsWith("_v2") && !newSettingName.EndsWith("_v2"))
                {
                    newSettingName += "_v2";
                }

                return (true, newSettingName);
            }

            return (false, settingName);
        }

        /// <summary>
        /// Port of Get-SettingDefinitionNameFromOffsetUri.
        /// Traverses up the OffsetUri segments to find a distinguishing prefix for the setting name.
        ///
        /// Optimization note: Instead of PowerShell array slicing ($arr[0..($arr.Length - 1 - $Skip)])
        /// which creates new arrays at each step, we use a List and track the effective length via an
        /// integer index. The algorithm is otherwise identical.
        /// </summary>
        private static string GetSettingDefinitionNameFromOffsetUri(string offsetUri, string settingName, int skip = 0)
        {
            // If the last part of the OffsetUri is the same as the setting name or it contains invalid characters, we traverse up until we reach the first element
            // Invalid characters are { and } which are used in the OffsetUri to indicate a variable
            var segments = offsetUri.Split('/').Where(s => !string.IsNullOrEmpty(s)).ToList();

            if (skip > segments.Count - 1)
            {
                return settingName;
            }

            // PS: $splittedOffsetUri = $splittedOffsetUri[0..($splittedOffsetUri.Length - 1 - $Skip)]
            // Effectively remove $skip elements from the end
            int effectiveLength = segments.Count - skip;

            // Traverse upward while the last element matches settingName, contains { or }, or settingName starts with it
            // PS: while (-not $traversed -and $splittedOffsetUri.Length -gt 1)
            bool traversed = false;
            while (!traversed && effectiveLength > 1)
            {
                traversed = true;
                string lastSegment = segments[effectiveLength - 1];

                // PS: if ($splittedOffsetUri[-1] -eq $SettingName -or $splittedOffsetUri[-1] -match '[\{\}]' -or $SettingName.StartsWith($splittedOffsetUri[-1]))
                if (lastSegment.Equals(settingName, StringComparison.OrdinalIgnoreCase) ||
                    lastSegment.IndexOfAny(['{', '}']) >= 0 ||
                    settingName.StartsWith(lastSegment, StringComparison.OrdinalIgnoreCase))
                {
                    effectiveLength--;
                    traversed = false;
                }
            }

            // PS: if ($splittedOffsetUri.Length -gt 1) { $splittedOffsetUri[-1] + '_' + $SettingName } else { $SettingName }
            return effectiveLength > 1
                ? segments[effectiveLength - 1] + "_" + settingName
                : settingName;
        }

        /// <summary>
        /// Applies the name simplification rules that correspond to the PowerShell switch -wildcard block.
        ///
        /// Important behavioral note: The PowerShell switch -Wildcard does NOT break after the first match -
        /// all matching cases are executed sequentially. This C# implementation replicates that behavior by
        /// iterating through ALL rules and applying every match. This matters for names that could match
        /// multiple rules (e.g., a name containing both a prefix pattern and a contains pattern like '~SmartScreen_').
        /// </summary>
        private static string ApplyNameSimplification(string settingName)
        {
            foreach (var (ExactMatch, Prefix, Suffix, Search, Replace) in NameSimplificationRules)
            {
                // Exact match
                if (ExactMatch is not null)
                {
                    if (settingName == ExactMatch)
                    {
                        settingName = Replace;
                    }
                    continue;
                }

                // Prefix match: 'prefix*'
                if (Prefix is not null)
                {
                    if (settingName.StartsWith(Prefix, StringComparison.OrdinalIgnoreCase))
                    {
                        settingName = settingName.Replace(Search, Replace);
                    }
                    continue;
                }

                // Contains match (Suffix is used as the contains-check string): '*contains*'
                if (Suffix is not null)
                {
                    if (settingName.IndexOf(Suffix, StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        settingName = settingName.Replace(Search, Replace);
                    }
                }
            }

            return settingName;
        }
    }
}
