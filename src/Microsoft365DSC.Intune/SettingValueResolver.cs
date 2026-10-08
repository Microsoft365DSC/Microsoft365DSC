using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft365DSC.Intune
{
    /// <summary>
    /// Result of resolving a DSC parameter value for a setting definition.
    /// Corresponds to the hashtable returned by the PowerShell Get-IntuneSettingCatalogPolicySettingDSCValue.
    /// </summary>
    public class SettingDSCValueResult
    {
        /// <summary>The setting definition that was resolved.</summary>
        public SettingDefinitionInfo SettingDefinition { get; set; }

        /// <summary>The resolved OData type for the setting value.</summary>
        public string SettingValueType { get; set; }

        /// <summary>
        /// The resolved value. Can be a single string/int or an array (string[]/int[]).
        /// For ChoiceSetting, this is the itemId. For Simple settings, it is the raw DSC value.
        /// </summary>
        public object Value { get; set; }
    }

    /// <summary>
    /// C# port of Get-IntuneSettingCatalogPolicySettingDSCValue.
    /// Resolves the value for a given setting definition from the DSC parameters hashtable.
    ///
    /// This function does NOT call any Graph API. It operates purely on the pre-fetched
    /// setting definitions and the DSC parameters provided by the caller.
    /// </summary>
    public static class SettingValueResolver
    {
        private const string IntegerSettingValueType = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue";
        private const string StringSettingValueType = "#microsoft.graph.deviceManagementConfigurationStringSettingValue";

        /// <summary>
        /// Resolves the DSC parameter value for a setting definition.
        /// </summary>
        /// <param name="settingValueType">The OData type hint for the setting value (e.g., contains "Simple", "ChoiceSetting").</param>
        /// <param name="settingDefinition">The pre-mapped setting definition.</param>
        /// <param name="allSettingDefinitions">All setting definitions for name resolution.</param>
        /// <param name="dscParams">The DSC parameters hashtable (case-insensitive).</param>
        /// <returns>A <see cref="SettingDSCValueResult"/> or null if the key is not found in DSC params.</returns>
        public static SettingDSCValueResult? Resolve(
            string settingValueType,
            SettingDefinitionInfo settingDefinition,
            List<SettingDefinitionInfo> allSettingDefinitions,
            Hashtable dscParams)
        {
            if (settingDefinition is null || dscParams is null)
                return null;

            settingValueType ??= string.Empty;

            if (settingValueType.Length == 0)
            {
                settingValueType = settingDefinition.ODataType ?? string.Empty;
            }

            // Resolve the setting name using the already-ported C# helper
            string key = SettingsCatalogHelper.GetSettingName(settingDefinition, allSettingDefinitions);

            // Case-insensitive key lookup
            string resolvedKey = FindKeyIgnoreCase(dscParams, key);
            if (resolvedKey is null)
                return null;

            object dscValue = dscParams[resolvedKey];

            // Simple setting type resolution
            if (settingValueType.IndexOf("Simple", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return ResolveSimpleSettingValue(settingValueType, settingDefinition, dscValue);
            }

            // Already resolved to a concrete type
            if (string.Equals(settingValueType, IntegerSettingValueType, StringComparison.OrdinalIgnoreCase) ||
                string.Equals(settingValueType, StringSettingValueType, StringComparison.OrdinalIgnoreCase))
            {
                return new SettingDSCValueResult
                {
                    SettingDefinition = settingDefinition,
                    SettingValueType = settingValueType,
                    Value = dscValue
                };
            }

            // ChoiceSetting (not Collection)
            if (settingValueType.IndexOf("ChoiceSetting", StringComparison.OrdinalIgnoreCase) >= 0 &&
                settingValueType.IndexOf("Collection", StringComparison.OrdinalIgnoreCase) < 0)
            {
                return ResolveChoiceSettingValue(settingDefinition, dscValue);
            }

            // ChoiceSettingCollection
            if (settingValueType.IndexOf("ChoiceSettingCollection", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return ResolveChoiceSettingCollectionValue(settingDefinition, dscValue);
            }

            // Default: construct value from definition Id + DSC value
            return new SettingDSCValueResult
            {
                SettingDefinition = settingDefinition,
                SettingValueType = settingValueType,
                Value = $"{settingDefinition.Id}_{dscValue}"
            };
        }

        /// <summary>
        /// Resolves Simple setting values (string, int, or arrays thereof).
        /// </summary>
        private static SettingDSCValueResult ResolveSimpleSettingValue(
            string settingValueType,
            SettingDefinitionInfo settingDefinition,
            object dscValue)
        {
            string resolvedType = GetConcreteSimpleValueType(settingDefinition, dscValue) ?? settingValueType;

            return new SettingDSCValueResult
            {
                SettingDefinition = settingDefinition,
                SettingValueType = resolvedType,
                Value = dscValue
            };
        }

        private static string? GetConcreteSimpleValueType(SettingDefinitionInfo settingDefinition, object dscValue)
        {
            string declared = settingDefinition?.ValueDefinition?.ODataType ?? string.Empty;
            if (declared.IndexOf("IntegerSettingValueDefinition", StringComparison.OrdinalIgnoreCase) >= 0)
                return IntegerSettingValueType;
            if (declared.IndexOf("StringSettingValueDefinition", StringComparison.OrdinalIgnoreCase) >= 0)
                return StringSettingValueType;

            object? value = dscValue;
            if (value is not string && value is IEnumerable items)
            {
                value = items.Cast<object>().FirstOrDefault(item => item is not null);
            }

            return value switch
            {
                string => StringSettingValueType,
                sbyte or byte or short or ushort or int or uint or long or ulong => IntegerSettingValueType,
                _ => null,
            };
        }

        /// <summary>
        /// Resolves a ChoiceSetting value by looking up the itemId from the options.
        /// Mirrors the PowerShell logic:
        ///   1. Match by optionValue.value == DSC value
        ///   2. Fallback: match by itemId == "{definitionId}_{dscValue}"
        /// </summary>
        private static SettingDSCValueResult ResolveChoiceSettingValue(
            SettingDefinitionInfo settingDefinition,
            object dscValue)
        {
            string dscValueStr = dscValue?.ToString() ?? string.Empty;

            // Try matching by optionValue.value
            string settingValue = settingDefinition.Options
                .Where(o => o.OptionValue is not null && string.Equals(o.OptionValue.Value, dscValueStr, StringComparison.OrdinalIgnoreCase))
                .Select(o => o.ItemId)
                .FirstOrDefault();

            // Fallback: match by itemId pattern
            if (string.IsNullOrEmpty(settingValue))
            {
                string expectedItemId = $"{settingDefinition.Id}_{dscValueStr}";
                settingValue = settingDefinition.Options
                    .Where(o => string.Equals(o.ItemId, expectedItemId, StringComparison.OrdinalIgnoreCase))
                    .Select(o => o.ItemId)
                    .FirstOrDefault();
            }

            return new SettingDSCValueResult
            {
                SettingDefinition = settingDefinition,
                SettingValueType = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue",
                Value = settingValue
            };
        }

        /// <summary>
        /// Resolves a ChoiceSettingCollection value by looking up each value's itemId.
        /// </summary>
        private static SettingDSCValueResult ResolveChoiceSettingCollectionValue(
            SettingDefinitionInfo settingDefinition,
            object dscValue)
        {
            var values = new List<string>();

            IEnumerable items = dscValue is IEnumerable enumerable && !(dscValue is string)
                ? enumerable
                : (new[] { dscValue });
            foreach (var value in items)
            {
                string valueStr = value?.ToString() ?? string.Empty;

                // Try matching by optionValue.value
                string valueToAdd = settingDefinition.Options
                    .Where(o => o.OptionValue is not null && string.Equals(o.OptionValue.Value, valueStr, StringComparison.OrdinalIgnoreCase))
                    .Select(o => o.ItemId)
                    .FirstOrDefault();

                // Fallback: match by itemId pattern
                if (string.IsNullOrEmpty(valueToAdd))
                {
                    string expectedItemId = $"{settingDefinition.Id}_{valueStr}";
                    valueToAdd = settingDefinition.Options
                        .Where(o => string.Equals(o.ItemId, expectedItemId, StringComparison.OrdinalIgnoreCase))
                        .Select(o => o.ItemId)
                        .FirstOrDefault();
                }

                if (!string.IsNullOrEmpty(valueToAdd))
                    values.Add(valueToAdd);
            }

            return new SettingDSCValueResult
            {
                Value = values.ToArray()
            };
        }

        /// <summary>
        /// Case-insensitive key lookup in a Hashtable.
        /// </summary>
        private static string? FindKeyIgnoreCase(Hashtable hashtable, string key)
        {
            if (hashtable.ContainsKey(key))
            {
                return key;
            }

            foreach (var k in hashtable.Keys)
            {
                if (string.Equals(k?.ToString(), key, StringComparison.OrdinalIgnoreCase))
                    return k.ToString();
            }
            return null;
        }
    }
}
