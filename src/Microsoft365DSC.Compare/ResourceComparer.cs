using Microsoft365DSC.Converter;
using Microsoft365DSC.Utilities;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;

namespace Microsoft365DSC.Compare
{
    /// <summary>
    /// High-level resource comparison entry point.
    /// Normalizes both sides to Hashtable trees, resolves schema metadata,
    /// aligns complex arrays by primary keys, then delegates to
    /// ComplexObjectComparer and SimpleObjectComparer for the actual diff.
    /// </summary>
    public static class ResourceComparer
    {
        private const string ClassNamePrefix = "MSFT_";

        /// <summary>
        /// Names dropped from the resource's own parameter set. They carry no meaning below the top
        /// level, where a nested Id identifies the referenced object rather than the resource.
        /// </summary>
        private static readonly HashSet<string> AlwaysExcludedProperties =
            new(Utilities.Utilities.AuthenticationPropertyNames, StringComparer.OrdinalIgnoreCase) { "Id", "Identity", "Verbose" };

        /// <summary>
        /// Compares desired vs current values for a single DSC resource.
        /// Both sides are normalized to Hashtable trees before comparison.
        /// </summary>
        /// <param name="desiredValues">Desired state hashtable (from PSBoundParameters)</param>
        /// <param name="currentValues">Current state hashtable (from Get-TargetResource)</param>
        /// <param name="valuesToCheck">Subset of keys from desiredValues to check (after filtering out keys/credentials/excluded)</param>
        /// <param name="schema">The full schema array (deserialized SchemaDefinition.json)</param>
        /// <param name="resourceName">Resource name without MSFT_ prefix (e.g. "AADUser")</param>
        /// <param name="excludedProperties">Properties to skip during comparison</param>
        /// <param name="includedProperties">Properties to force-include even if otherwise skipped</param>
        /// <returns>A CompareResult with test result, drift info, and value snapshots</returns>
        public static CompareResult Compare(
            Hashtable desiredValues,
            Hashtable currentValues,
            Hashtable valuesToCheck,
            IEnumerable<object> schema,
            string resourceName,
            string[]? excludedProperties = null,
            string[]? includedProperties = null)
        {
            if (schema is null)
            {
                throw new ArgumentNullException(nameof(schema));
            }

            return Compare(desiredValues, currentValues, valuesToCheck, SchemaIndex.For(schema), resourceName, excludedProperties, includedProperties);
        }

        internal static CompareResult Compare(
            Hashtable desiredValues,
            Hashtable currentValues,
            Hashtable valuesToCheck,
            SchemaIndex schema,
            string resourceName,
            string[]? excludedProperties,
            string[]? includedProperties)
        {
            if (desiredValues is null)
            {
                throw new ArgumentNullException(nameof(desiredValues));
            }

            if (currentValues is null)
            {
                throw new ArgumentNullException(nameof(currentValues));
            }

            if (string.IsNullOrEmpty(resourceName))
            {
                throw new ArgumentNullException(nameof(resourceName));
            }

            var result = new CompareResult();
            var excludedSet = new HashSet<string>(AlwaysExcludedProperties, StringComparer.OrdinalIgnoreCase);
            var nestedExcludedSet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (excludedProperties is not null)
            {
                foreach (string prop in excludedProperties)
                {
                    excludedSet.Add(prop);
                    nestedExcludedSet.Add(prop);
                }
            }

            var includedSet = includedProperties is not null
                ? new HashSet<string>(includedProperties, StringComparer.OrdinalIgnoreCase)
                : new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            if (!schema.TryGetResource(resourceName, out ClassDefinition resourceDef))
            {
                throw new InvalidOperationException($"Resource definition not found in schema for '{ClassNamePrefix}{resourceName}'.");
            }

            var keysToCompare = BuildKeysToCompare(valuesToCheck, resourceDef, excludedSet, includedSet);

            string desiredEnsure = GetStringValue(desiredValues, "Ensure") ?? "Present";
            string? currentEnsure = GetStringValue(currentValues, "Ensure");

            bool desiredPresent = string.Equals(desiredEnsure, "Present", StringComparison.OrdinalIgnoreCase);
            bool desiredAbsent = string.Equals(desiredEnsure, "Absent", StringComparison.OrdinalIgnoreCase);
            bool currentPresent = string.Equals(currentEnsure, "Present", StringComparison.OrdinalIgnoreCase);
            bool currentAbsent = string.Equals(currentEnsure, "Absent", StringComparison.OrdinalIgnoreCase);

            if (desiredPresent && currentAbsent)
            {
                RecordEnsureDrift(result, excludedSet, keysToCompare, currentValue: "Absent", desiredValue: "Present");
            }
            else if (desiredAbsent && currentPresent)
            {
                RecordEnsureDrift(result, excludedSet, keysToCompare, currentValue: "Present", desiredValue: "Absent");
            }
            else if (desiredAbsent && currentAbsent)
            {
                return result;
            }

            List<string> complexKeys = [];
            List<string> simpleKeys = [];

            foreach (string key in keysToCompare)
            {
                if (excludedSet.Contains(key))
                {
                    continue;
                }

                if (resourceDef.TryGetParameter(key, out ParameterDefinition paramDef) && paramDef.IsComplex)
                {
                    complexKeys.Add(key);
                    continue;
                }

                object? desiredVal = desiredValues.ContainsKey(key) ? desiredValues[key] : null;
                if (desiredVal is not null && IsComplexValue(desiredVal))
                {
                    complexKeys.Add(key);
                    continue;
                }

                simpleKeys.Add(key);
            }

            foreach (string key in complexKeys)
            {
                object? desiredRaw = desiredValues.ContainsKey(key) ? desiredValues[key] : null;
                object? currentRaw = currentValues.ContainsKey(key) ? currentValues[key] : null;

                object? normalizedDesired = ObjectNormalizer.Normalize(desiredRaw);
                object? normalizedCurrent = ObjectNormalizer.Normalize(currentRaw);

                if (normalizedDesired is object[] desiredArray)
                {
                    object[] currentArray = normalizedCurrent as object[] ?? [];

                    string cimName = resourceDef.TryGetParameter(key, out ParameterDefinition arrayDef)
                        ? arrayDef.ElementClassName
                        : string.Empty;

                    List<string> primaryKeyNames = schema.TryGetClass(cimName, out ClassDefinition elementDef)
                        ? elementDef.Mandatory.Names
                        : [];
                    bool isIntunePolicyAssignment = IsIntunePolicyAssignmentType(cimName);

                    if (isIntunePolicyAssignment)
                    {
                        if (!IntunePolicyAssignmentComparer.Compare(desiredArray, currentArray, result.DriftInfo))
                        {
                            result.TestResult = false;
                        }
                        continue;
                    }

                    if (primaryKeyNames.Count > 0)
                    {
                        var (pairs, extras) = PrimaryKeyPairing.Pair(desiredArray, currentArray, primaryKeyNames);
                        HashSet<string> skippedKeys = PrimaryKeyPairing.SkippedKeys(primaryKeyNames, includedSet, isIntunePolicyAssignment);

                        foreach (var (desiredItem, currentItem, idx) in pairs)
                        {
                            if (currentItem is null)
                            {
                                result.AddDrift($"{key}[{idx}]", null, desiredItem);
                                result.TestResult = false;
                                continue;
                            }

                            if (!ComplexObjectComparer.CompareInto(desiredItem, currentItem, $"{key}[{idx}]", nestedExcludedSet, result.DriftInfo, skippedKeys, schema, cimName))
                            {
                                result.TestResult = false;
                            }
                        }

                        foreach (var (extraItem, idx) in extras)
                        {
                            result.AddDrift($"{key}[extra:{idx}]", extraItem, null);
                            result.TestResult = false;
                        }
                    }
                    else if (!ComplexObjectComparer.CompareInto(desiredArray, currentArray, key, nestedExcludedSet, result.DriftInfo, null, schema, cimName))
                    {
                        result.TestResult = false;
                    }
                }
                else
                {
                    string singleClassName = resourceDef.TryGetParameter(key, out ParameterDefinition singleDef)
                        ? singleDef.ElementClassName
                        : string.Empty;

                    if (!ComplexObjectComparer.CompareInto(normalizedDesired, normalizedCurrent, key, nestedExcludedSet, result.DriftInfo, null, schema, singleClassName))
                    {
                        result.TestResult = false;
                    }
                }
            }

            Hashtable simpleDesired = new(StringComparer.OrdinalIgnoreCase);
            foreach (string key in simpleKeys)
            {
                if (desiredValues.ContainsKey(key))
                {
                    simpleDesired[key] = MemberAccessor.Unwrap(desiredValues[key]);
                }
            }

            if (simpleKeys.Count > 0)
            {
                var simpleResult = SimpleObjectComparer.Compare(
                    currentValues,
                    simpleDesired,
                    simpleKeys.ToArray(),
                    null,
                    true,
                    true,
                    excludedProperties != null ? [.. excludedProperties] : null);

                bool simpleTestResult = (bool)simpleResult["TestResult"];
                if (!simpleTestResult)
                {
                    result.TestResult = false;

                    if (simpleResult["DriftObject"] is Hashtable driftObject)
                    {
                        if (driftObject["DriftInfo"] is List<Hashtable> driftInfoList)
                        {
                            foreach (Hashtable drift in driftInfoList)
                            {
                                result.DriftInfo.Add(drift);
                            }
                        }
                    }
                }

                if (simpleResult["DriftedParameters"] is Hashtable driftedParams)
                {
                    foreach (DictionaryEntry entry in driftedParams)
                    {
                        result.DriftedParameters[entry.Key] = entry.Value;
                    }
                }
            }

            return result;
        }

        private static void RecordEnsureDrift(
            CompareResult result,
            HashSet<string> excludedSet,
            HashSet<string> keysToCompare,
            string currentValue,
            string desiredValue)
        {
            result.AddDrift("Ensure", currentValue, desiredValue);
            result.TestResult = false;
            _ = excludedSet.Add("Ensure");
            _ = keysToCompare.Remove("Ensure");
        }

        private static HashSet<string> BuildKeysToCompare(
            Hashtable desiredValues,
            ClassDefinition resourceDef,
            HashSet<string> excludedSet,
            HashSet<string> includedSet)
        {
            var keys = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (string key in desiredValues.Keys.Cast<string>())
            {
                if (string.Equals(key, "Id", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(key, "Identity", StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                if (excludedSet.Contains(key))
                {
                    continue;
                }

                if (resourceDef.TryGetParameter(key, out ParameterDefinition paramDef) && (paramDef.IsKey || paramDef.IsCredential))
                {
                    continue;
                }

                keys.Add(key);
            }

            foreach (string prop in includedSet)
            {
                if (desiredValues.ContainsKey(prop))
                {
                    keys.Add(prop);
                }
            }

            return keys;
        }

        private static bool IsIntunePolicyAssignmentType(string cimName)
        {
            if (string.IsNullOrEmpty(cimName))
            {
                return false;
            }

            if (string.Equals(cimName, "MSFT_IntuneDeviceRemediationPolicyAssignments", StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            bool matchesIntune = cimName.IndexOf("Intune", StringComparison.OrdinalIgnoreCase) > -1 &&
                                 cimName.EndsWith("PolicyAssignments", StringComparison.OrdinalIgnoreCase);
            bool matchesAppMgmt = cimName.IndexOf("DeviceManagement", StringComparison.OrdinalIgnoreCase) > -1 &&
                                  cimName.EndsWith("AppAssignment", StringComparison.OrdinalIgnoreCase);
            bool matchesDevMgmt = cimName.IndexOf("DeviceManagementConfigurationPolicyAssignments", StringComparison.OrdinalIgnoreCase) > -1;

            return matchesIntune || matchesDevMgmt || matchesAppMgmt;
        }

        private static string? GetStringValue(Hashtable hash, string key)
        {
            if (hash is null || !hash.ContainsKey(key))
            {
                return null;
            }

            return hash[key]?.ToString();
        }

        private static bool IsComplexValue(object value)
        {
            if (value is null)
            {
                return false;
            }

            if (value is PSObject psObj)
            {
                value = psObj.BaseObject;
            }

            string typeName = value.GetType().Name;
            if (typeName.IndexOf("CimInstance", StringComparison.OrdinalIgnoreCase) > -1)
            {
                return true;
            }

            if (value is Array array && array.Length > 0)
            {
                object first = array.GetValue(0);
                if (first is PSObject firstPs)
                {
                    first = firstPs.BaseObject;
                }

                if (first is Hashtable || first is IDictionary)
                {
                    return true;
                }

                if (first != null && first.GetType().Name.IndexOf("CimInstance", StringComparison.OrdinalIgnoreCase) > -1)
                {
                    return true;
                }
            }

            return false;
        }
    }

    /// <summary>
    /// Result object for ResourceComparer.Compare.
    /// Contains the test result (true = no drift), drift info entries,
    /// and drifted parameter event strings for telemetry.
    /// </summary>
    public class CompareResult
    {
        /// <summary>
        /// True if no drift was detected; false otherwise.
        /// </summary>
        public bool TestResult { get; set; } = true;

        /// <summary>
        /// List of drift entries. Each entry has PropertyName, CurrentValue, DesiredValue.
        /// </summary>
        public List<Hashtable> DriftInfo { get; } = [];

        /// <summary>
        /// Drifted parameter event strings for telemetry (key = param name, value = XML snippet).
        /// </summary>
        public Hashtable DriftedParameters { get; } = new Hashtable(StringComparer.OrdinalIgnoreCase);

        /// <summary>
        /// Adds a drift entry.
        /// </summary>
        public void AddDrift(string propertyName, object currentValue, object desiredValue)
        {
            DriftInfo.Add(DriftRecord.Create(propertyName, currentValue, desiredValue));
        }
    }
}
