using System;
using System.Collections;
using System.Collections.Generic;

namespace Microsoft365DSC.Utilities
{
    /// <summary>
    /// Builds the drift entries every comparer reports: PropertyName, CurrentValue, DesiredValue and,
    /// for collection drifts, DeltaValue.
    /// </summary>
    public static class DriftRecord
    {
        public const string PropertyNameKey = "PropertyName";
        public const string CurrentValueKey = "CurrentValue";
        public const string DesiredValueKey = "DesiredValue";
        public const string DeltaValueKey = "DeltaValue";

        public static Hashtable Create(string propertyName, object? currentValue, object? desiredValue, string? deltaValue = null)
        {
            Hashtable drift = new(StringComparer.OrdinalIgnoreCase)
            {
                { PropertyNameKey, propertyName },
                { CurrentValueKey, currentValue },
                { DesiredValueKey, desiredValue }
            };

            if (deltaValue is not null)
            {
                drift[DeltaValueKey] = deltaValue;
            }

            return drift;
        }

        public static Dictionary<string, object> ToDictionary(Hashtable drift)
        {
            Dictionary<string, object> result = new(drift.Count);
            foreach (DictionaryEntry entry in drift)
            {
                result[entry.Key.ToString()] = entry.Value!;
            }

            return result;
        }
    }
}
