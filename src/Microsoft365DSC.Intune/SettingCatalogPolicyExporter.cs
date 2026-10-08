using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Reflection;

namespace Microsoft365DSC.Intune
{
    /// <summary>
    /// Lightweight representation of a setting instance coming from the Graph API response.
    /// The PowerShell version works with raw PSObjects or Hashtables; this C# model normalizes
    /// the data to avoid repeated reflection or dictionary lookups during recursive traversal.
    /// </summary>
    public class SettingInstanceInfo
    {
        /// <summary>The settingDefinitionId of this instance.</summary>
        public string SettingDefinitionId { get; set; }

        /// <summary>The @odata.type of this instance.</summary>
        public string ODataType { get; set; }

        // --- Simple settings ---
        /// <summary>For SimpleSettingInstance: the value object containing @odata.type and value.</summary>
        public SettingSimpleValue SimpleSettingValue { get; set; }

        // --- Choice settings ---
        /// <summary>For ChoiceSettingInstance: the choice setting value (value + children).</summary>
        public SettingChoiceValue ChoiceSettingValue { get; set; }

        // --- Choice setting collection ---
        /// <summary>For ChoiceSettingCollectionInstance: the collection of choice values.</summary>
        public List<string> ChoiceSettingCollectionValues { get; set; }

        // --- Group setting collection ---
        /// <summary>For GroupSettingCollectionInstance: the array of group values, each containing children.</summary>
        public List<SettingGroupValue> GroupSettingCollectionValue { get; set; }

        // --- Simple setting collection ---
        /// <summary>For SimpleSettingCollectionInstance: the array of simple values.</summary>
        public List<SettingSimpleValue> SimpleSettingCollectionValue { get; set; }
    }

    /// <summary>Represents a simple setting value (string or int).</summary>
    public class SettingSimpleValue
    {
        public string ODataType { get; set; }
        public object Value { get; set; }
    }

    /// <summary>Represents a choice setting value with a selected value and children.</summary>
    public class SettingChoiceValue
    {
        public string Value { get; set; }
        public List<SettingInstanceInfo> Children { get; set; } = [];
    }

    /// <summary>Represents one group in a GroupSettingCollection, containing child instances.</summary>
    public class SettingGroupValue
    {
        public List<SettingInstanceInfo> Children { get; set; } = [];
    }

    /// <summary>
    /// Maps raw Graph API response objects (PSObject, Hashtable, or Graph SDK types) to
    /// <see cref="SettingInstanceInfo"/> for use in the exporter.
    /// </summary>
    internal static class SettingInstanceMapper
    {

        /// <summary>
        /// Maps a raw setting instance to <see cref="SettingInstanceInfo"/>.
        /// </summary>
        /// <param name="instance">The setting instance (Graph SDK object or Hashtable).</param>
        public static SettingInstanceInfo? FromObject(object instance)
        {
            if (instance is null)
                return null;

            var info = new SettingInstanceInfo
            {
                // Extract settingDefinitionId
                SettingDefinitionId = GetStringProperty(instance, "settingDefinitionId"),
                // Determine the OData type based on root vs. child
                ODataType = GetStringProperty(instance, "@odata.type")
            };

            if (string.IsNullOrEmpty(info.ODataType))
                return info;

            switch (info.ODataType)
            {
                case "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance":
                    MapSimpleSetting(instance, info);
                    break;
                case "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance":
                    MapChoiceSetting(instance, info);
                    break;
                case "#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance":
                    MapChoiceSettingCollection(instance, info);
                    break;
                case "#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance":
                    MapGroupSettingCollection(instance, info);
                    break;
                case "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance":
                    MapSimpleSettingCollection(instance, info);
                    break;
            }

            return info;
        }

        private static void MapSimpleSetting(object instance, SettingInstanceInfo info)
        {
            object? simpleValue = SettingDefinitionMapper.TryGetPropertyRaw(instance, "simpleSettingValue");

            if (simpleValue is null) return;

            info.SimpleSettingValue = new SettingSimpleValue
            {
                ODataType = GetStringProperty(simpleValue, "@odata.type"),
                Value = SettingDefinitionMapper.TryGetPropertyRaw(simpleValue, "value")
            };
        }

        private static void MapChoiceSetting(object instance, SettingInstanceInfo info)
        {
            object? choiceValue = SettingDefinitionMapper.TryGetPropertyRaw(instance, "choiceSettingValue");

            if (choiceValue is null) return;

            info.ChoiceSettingValue = new SettingChoiceValue
            {
                Value = GetStringProperty(choiceValue, "value")
            };

            var children = SettingDefinitionMapper.TryGetPropertyRaw(choiceValue, "children") as IEnumerable;
            if (children is not null)
            {
                foreach (var child in children)
                {
                    var childInfo = FromObject(child);
                    if (childInfo is not null)
                        info.ChoiceSettingValue.Children.Add(childInfo);
                }
            }
        }

        private static void MapChoiceSettingCollection(object instance, SettingInstanceInfo info)
        {
            object? collectionValue = SettingDefinitionMapper.TryGetPropertyRaw(instance, "choiceSettingCollectionValue");

            if (collectionValue is null) return;

            info.ChoiceSettingCollectionValues = [];

            // The collection can be an array of objects, each with a "value" property
            if (collectionValue is IEnumerable enumerable)
            {
                foreach (var item in enumerable)
                {
                    // Each item may be an object with .value, or just a raw value string
                    string val = GetStringProperty(item, "value");
                    if (val is null && item is not null)
                        val = item.ToString();
                    if (val is not null)
                        info.ChoiceSettingCollectionValues.Add(val);
                }
            }
        }

        private static void MapGroupSettingCollection(object instance, SettingInstanceInfo info)
        {
            object? groupValue = SettingDefinitionMapper.TryGetPropertyRaw(instance, "groupSettingCollectionValue");

            if (groupValue is null) return;

            info.GroupSettingCollectionValue = [];

            if (groupValue is IEnumerable groups)
            {
                foreach (var group in groups)
                {
                    var groupInfo = new SettingGroupValue();
                    var children = SettingDefinitionMapper.TryGetPropertyRaw(group, "children") as IEnumerable;
                    if (children is not null)
                    {
                        foreach (var child in children)
                        {
                            var childInfo = FromObject(child);
                            if (childInfo is not null)
                                groupInfo.Children.Add(childInfo);
                        }
                    }
                    info.GroupSettingCollectionValue.Add(groupInfo);
                }
            }
        }

        private static void MapSimpleSettingCollection(object instance, SettingInstanceInfo info)
        {
            object? collectionValue = SettingDefinitionMapper.TryGetPropertyRaw(instance, "simpleSettingCollectionValue");

            if (collectionValue is null) return;

            info.SimpleSettingCollectionValue = [];

            if (collectionValue is IEnumerable enumerable)
            {
                foreach (var item in enumerable)
                {
                    info.SimpleSettingCollectionValue.Add(new SettingSimpleValue
                    {
                        ODataType = GetStringProperty(item, "@odata.type"),
                        Value = SettingDefinitionMapper.TryGetPropertyRaw(item, "value")
                    });
                }
            }
        }

        #region Property access helpers

        private static string GetStringProperty(object obj, string propertyName)
        {
            return SettingDefinitionMapper.TryGetPropertyRaw(obj, propertyName)?.ToString() ?? string.Empty;
        }

        #endregion
    }

    /// <summary>
    /// C# port of Export-IntuneSettingCatalogPolicySettings.
    /// Converts Graph API setting response data into flat DSC parameter hashtables.
    ///
    /// <para><b>Design notes:</b></para>
    /// <list type="bullet">
    /// <item>This C# version pre-maps
    /// all data to <see cref="SettingInstanceInfo"/> and <see cref="SettingDefinitionInfo"/>
    /// at the boundary, then works purely with C# models internally.</item>
    /// <item>Parts that require Graph API calls (e.g., fetching setting templates) remain in
    /// PowerShell. This class only handles the data transformation.</item>
    /// <item>The recursive export logic is preserved exactly as in PowerShell, including the
    /// GroupSettingCollection flattening heuristics.</item>
    /// </list>
    /// </summary>
    public static class SettingCatalogPolicyExporter
    {
        /// <summary>
        /// Exports settings from Graph API response into a flat hashtable of DSC parameters.
        /// Entry point corresponding to the 'Start' parameter set in PowerShell.
        /// </summary>
        /// <param name="settings">
        /// Array of setting objects from the Graph API, each with SettingInstance and SettingDefinitions.
        /// These are the raw Graph SDK objects or Hashtables.
        /// </param>
        /// <param name="returnHashtable">
        /// Hashtable to store the exported DSC parameters.
        /// </param>
        /// <param name="allSettingDefinitions">
        /// All setting definitions for the policy (pre-mapped). If empty, definitions are extracted from settings.
        /// </param>
        /// <param name="containsDeviceAndUserSettings">
        /// True if the policy has separate device_ and user_ prefixed settings.
        /// </param>
        /// <returns>A hashtable with the exported DSC parameters.</returns>
        public static Hashtable Export(
            IList<object> settings,
            Hashtable returnHashtable,
            IList<object>? allSettingDefinitions = null,
            bool containsDeviceAndUserSettings = false)
        {
            List<SettingExportItem> convertedSettings = new(settings.Count);
            foreach (var setting in settings)
            {
                convertedSettings.Add(new()
                {
                    SettingInstance = SettingInstanceMapper.FromObject(SettingDefinitionMapper.TryGetPropertyRaw(setting, "SettingInstance")),
                    SettingDefinitions = SettingDefinitionMapper.FromGraphObjects(SettingDefinitionMapper.TryGetPropertyAsEnumerable(setting, "SettingDefinitions") ?? [])
                });
            }

            List<SettingDefinitionInfo> convertedAllSettingDefinitions = allSettingDefinitions is not null && allSettingDefinitions.Count > 0
                ? SettingDefinitionMapper.FromGraphObjects(allSettingDefinitions)
                : convertedSettings.SelectMany(s => s.SettingDefinitions).ToList();

            if (containsDeviceAndUserSettings)
            {
                ExportDeviceAndUserSettings(convertedSettings, convertedAllSettingDefinitions, returnHashtable);
            }
            else
            {
                foreach (var setting in convertedSettings)
                {
                    ExportSettingInstance(
                        setting.SettingInstance,
                        setting.SettingDefinitions,
                        convertedAllSettingDefinitions,
                        returnHashtable);
                }
            }

            return returnHashtable;
        }

        private static void ExportDeviceAndUserSettings(
            IList<SettingExportItem> settings,
            List<SettingDefinitionInfo> allSettingDefinitions,
            Hashtable returnHashtable)
        {
            // User scope is always announced through the user_ prefix. Everything else is
            // device-scoped, including settings whose base URI goes straight to ./Vendor/MSFT
            // without a device_ prefix (e.g. the firewall settings of the Defender for
            // Endpoint baseline) - the device context is the CSP default.
            var userSettings = settings.Where(s =>
                s.SettingInstance.SettingDefinitionId?.StartsWith("user_", StringComparison.OrdinalIgnoreCase) == true).ToList();
            var deviceSettings = settings.Where(s =>
                s.SettingInstance.SettingDefinitionId?.StartsWith("user_", StringComparison.OrdinalIgnoreCase) != true).ToList();

            var allUserDefs = (allSettingDefinitions?.Count > 0)
                ? allSettingDefinitions.Where(d => d.Id?.StartsWith("user_", StringComparison.OrdinalIgnoreCase) == true).ToList()
                : userSettings.SelectMany(s => s.SettingDefinitions).ToList();

            var allDeviceDefs = (allSettingDefinitions?.Count > 0)
                ? allSettingDefinitions.Where(d => d.Id?.StartsWith("user_", StringComparison.OrdinalIgnoreCase) != true).ToList()
                : deviceSettings.SelectMany(s => s.SettingDefinitions).ToList();

            var deviceResult = new Hashtable(StringComparer.OrdinalIgnoreCase);
            foreach (var setting in deviceSettings)
            {
                ExportSettingInstance(setting.SettingInstance, setting.SettingDefinitions, allDeviceDefs, deviceResult);
            }

            var userResult = new Hashtable(StringComparer.OrdinalIgnoreCase);
            foreach (var setting in userSettings)
            {
                ExportSettingInstance(setting.SettingInstance, setting.SettingDefinitions, allUserDefs, userResult);
            }

            if (deviceResult.Count > 0)
                returnHashtable["DeviceSettings"] = deviceResult;
            if (userResult.Count > 0)
                returnHashtable["UserSettings"] = userResult;
        }

        /// <summary>
        /// Recursively exports a setting instance into the return hashtable.
        /// Corresponds to the 'Setting' parameter set in the PowerShell version.
        /// </summary>
        private static void ExportSettingInstance(
            SettingInstanceInfo settingInstance,
            List<SettingDefinitionInfo> settingDefinitions,
            List<SettingDefinitionInfo> allSettingDefinitions,
            Hashtable returnHashtable)
        {
            if (settingInstance is null || string.IsNullOrEmpty(settingInstance.ODataType))
                return;

            var settingDefinition = settingDefinitions
                .FirstOrDefault(d => string.Equals(d.Id, settingInstance.SettingDefinitionId, StringComparison.OrdinalIgnoreCase));

            if (settingDefinition is null)
                return;

            string settingName = SettingsCatalogHelper.GetSettingName(settingDefinition, allSettingDefinitions);

            bool addToParameters = true;
            object? settingValue = null;

            switch (settingInstance.ODataType)
            {
                case "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance":
                    settingValue = ExportSimpleSetting(settingInstance);
                    break;

                case "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance":
                    settingValue = ExportChoiceSetting(settingInstance, settingDefinition, settingDefinitions, allSettingDefinitions, returnHashtable);
                    break;

                case "#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance":
                    settingValue = ExportChoiceSettingCollection(settingInstance, settingDefinition);
                    break;

                case "#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance":
                    var groupResult = ExportGroupSettingCollection(
                        settingInstance, settingDefinition, settingDefinitions, allSettingDefinitions, returnHashtable);
                    settingValue = groupResult.Value;
                    addToParameters = groupResult.AddToParameters;
                    settingName = SettingsCatalogHelper.WithoutDoubledParent(settingName);
                    break;

                case "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance":
                    settingValue = ExportSimpleSettingCollection(settingInstance);
                    break;
            }

            if (addToParameters && settingValue is not null)
            {
                if (!returnHashtable.ContainsKey(settingName))
                {
                    returnHashtable[settingName] = settingValue;
                }
                else
                {
                    // Multiple entries for same key: combine into array
                    var existing = returnHashtable[settingName];
                    var combined = new List<object>();
                    if (existing is IList existingList)
                    {
                        foreach (var item in existingList)
                            combined.Add(item);
                    }
                    else
                    {
                        combined.Add(existing);
                    }

                    if (settingValue is IList newList)
                    {
                        foreach (var item in newList)
                            combined.Add(item);
                    }
                    else
                    {
                        combined.Add(settingValue);
                    }

                    returnHashtable[settingName] = combined.ToArray();
                }
            }
        }

        private static object? ExportSimpleSetting(SettingInstanceInfo instance)
        {
            if (instance.SimpleSettingValue is null)
                return null;

            if (instance.SimpleSettingValue.ODataType == "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue")
            {
                if (instance.SimpleSettingValue.Value is int intVal)
                    return intVal;

                if (int.TryParse(instance.SimpleSettingValue.Value?.ToString(), out int parsed))
                    return parsed;
            }

            return instance.SimpleSettingValue.Value;
        }

        private static string? ExportChoiceSetting(
            SettingInstanceInfo instance,
            SettingDefinitionInfo settingDefinition,
            List<SettingDefinitionInfo> settingDefinitions,
            List<SettingDefinitionInfo> allSettingDefinitions,
            Hashtable returnHashtable)
        {
            if (instance.ChoiceSettingValue is null)
                return null;

            string beforeSettingValue = instance.ChoiceSettingValue.Value;
            string? settingValue = ResolveChoiceOptionValue(settingDefinition, beforeSettingValue);

            // Recursively export child settings
            foreach (var child in instance.ChoiceSettingValue.Children)
            {
                ExportSettingInstance(child, settingDefinitions, allSettingDefinitions, returnHashtable);
            }

            return settingValue;
        }

        private static object? ExportChoiceSettingCollection(
            SettingInstanceInfo instance,
            SettingDefinitionInfo settingDefinition)
        {
            if (instance.ChoiceSettingCollectionValues is null) return null;

            List<object>? values = [];
            foreach (var value in instance.ChoiceSettingCollectionValues)
            {
                string? resolved = ResolveChoiceOptionValue(settingDefinition, value);
                values.Add(resolved ?? string.Empty);
            }

            // Determine typing based on first option's value definition type
            if (settingDefinition.Options.Count > 0 && settingDefinition.Options[0].OptionValue is not null)
            {
                string optType = settingDefinition.Options[0].OptionValue.ODataType ?? string.Empty;
                if (optType.IndexOf("Integer", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    var intValues = new List<int>();
                    foreach (var v in values)
                    {
                        if (int.TryParse(v?.ToString(), out int parsed))
                            intValues.Add(parsed);
                    }
                    return intValues.ToArray();
                }
            }

            return values.Select(v => v?.ToString()).ToArray();
        }

        private static string GetChildNameFromId(string parentId, string childId)
        {
            if (string.IsNullOrEmpty(parentId) || string.IsNullOrEmpty(childId))
                return string.Empty;

            string prefix = parentId + "_";
            if (!childId.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                return string.Empty;

            string suffix = childId.Substring(prefix.Length);
            return string.Equals(suffix, "key", StringComparison.OrdinalIgnoreCase)
                || string.Equals(suffix, "value", StringComparison.OrdinalIgnoreCase)
                ? suffix
                : string.Empty;
        }

        private static (object? Value, bool AddToParameters) ExportGroupSettingCollection(
            SettingInstanceInfo instance,
            SettingDefinitionInfo settingDefinition,
            List<SettingDefinitionInfo> settingDefinitions,
            List<SettingDefinitionInfo> allSettingDefinitions,
            Hashtable returnHashtable)
        {
            if (instance.GroupSettingCollectionValue is null)
                return (null, false);

            var childSettingDefinitions = settingDefinitions
                .Where(d => settingDefinition.ChildIds.Contains(d.Id))
                .ToArray();

            // Find parent definition for multi-instance logic
            var parentSettingDefinition = settingDefinitions
                .FirstOrDefault(d =>
                    settingDefinition.DependentOnParentSettingIds.Contains(d.Id));

            // Case 1: max > 1 with only one child definition -> skip to child
            if (settingDefinition.MaximumCount > 1 && childSettingDefinitions.Length == 1)
            {
                foreach (var group in instance.GroupSettingCollectionValue)
                {
                    foreach (var child in group.Children)
                    {
                        ExportSettingInstance(child, settingDefinitions, allSettingDefinitions, returnHashtable);
                    }
                }
                return (null, false);
            }

            // Case 2: multi-instance with multiple children -> create nested hashtables
            bool isMulti = (settingDefinition.MaximumCount > 1) ||
                           (parentSettingDefinition is not null && parentSettingDefinition.MaximumCount > 1);

            if (isMulti && childSettingDefinitions.Length > 1)
            {
                var childValues = new List<Hashtable>();

                Hashtable? childHashtable = null;
                foreach (var group in instance.GroupSettingCollectionValue)
                {
                    childHashtable = new Hashtable(StringComparer.OrdinalIgnoreCase);
                    foreach (var child in group.Children)
                    {
                        var childEntry = new Hashtable(StringComparer.OrdinalIgnoreCase);
                        ExportSettingInstance(child, settingDefinitions, allSettingDefinitions, childEntry);

                        string suffix = GetChildNameFromId(settingDefinition.Id, child.SettingDefinitionId);
                        foreach (DictionaryEntry entry in childEntry)
                        {
                            string name = childEntry.Count == 1 && suffix.Length > 0
                                ? suffix
                                : entry.Key?.ToString() ?? string.Empty;
                            childHashtable[name] = entry.Value;
                        }
                    }
                    childValues.Add(childHashtable);
                }

                return (childValues.ToArray(), true);
            }

            // Case 3: single instance -> flatten children directly
            foreach (var group in instance.GroupSettingCollectionValue)
            {
                foreach (var child in group.Children)
                {
                    ExportSettingInstance(child, settingDefinitions, allSettingDefinitions, returnHashtable);
                }
            }
            return (null, false);
        }

        private static object[]? ExportSimpleSettingCollection(SettingInstanceInfo instance)
        {
            if (instance.SimpleSettingCollectionValue is null) return null;

            var values = new List<object>();
            foreach (var item in instance.SimpleSettingCollectionValue)
            {
                if (item.ODataType == "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue")
                {
                    if (item.Value is int intVal)
                        values.Add(intVal);
                    else if (int.TryParse(item.Value?.ToString(), out int parsed))
                        values.Add(parsed);
                    else
                        values.Add(item.Value);
                }
                else
                {
                    values.Add(item.Value);
                }
            }

            return values.ToArray();
        }

        /// <summary>
        /// Resolves a choice option value from its itemId.
        /// Mirrors the PowerShell logic: look up optionValue.value, fall back to stripping prefix if it contains '=' or '{}'.
        /// </summary>
        private static string? ResolveChoiceOptionValue(SettingDefinitionInfo settingDefinition, string itemIdValue)
        {
            if (string.IsNullOrEmpty(itemIdValue)) return null;

            var matchingOption = settingDefinition.Options
                .FirstOrDefault(o => string.Equals(o.ItemId, itemIdValue, StringComparison.Ordinal));

            if (matchingOption?.OptionValue is not null)
            {
                string optionValueStr = matchingOption.OptionValue.Value;

                // Check for assignment-style values that should fall back to stripped itemId
                if (!string.IsNullOrEmpty(optionValueStr) &&
                    (optionValueStr.Contains('=') || (optionValueStr.Contains('{') && optionValueStr.Contains('}'))))
                {
                    string prefix = settingDefinition.Id + "_";
                    return matchingOption.ItemId.StartsWith(prefix, StringComparison.Ordinal)
                        ? matchingOption.ItemId.Substring(prefix.Length)
                        : matchingOption.ItemId;
                }

                return optionValueStr;
            }

            return itemIdValue;
        }
    }

    /// <summary>
    /// A pre-mapped setting export item containing a setting instance and its definitions.
    /// </summary>
    public class SettingExportItem
    {
        /// <summary>The setting instance (pre-mapped from Graph response).</summary>
        public SettingInstanceInfo SettingInstance { get; set; }

        /// <summary>The setting definitions for this particular setting (pre-mapped).</summary>
        public List<SettingDefinitionInfo> SettingDefinitions { get; set; } = [];
    }
}
