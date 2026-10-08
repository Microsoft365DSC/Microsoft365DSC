using Microsoft.Management.Infrastructure;
using Microsoft365DSC.Converter;
using Microsoft365DSC.Utilities;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace Microsoft365DSC.Compare
{
    public static class SimpleObjectComparer
    {
        private static readonly HashSet<string> BaseExcludedProperties =
            new(Utilities.Utilities.AuthenticationPropertyNames, StringComparer.Ordinal) { "Verbose" };

        public static Dictionary<string, object> Compare(
            Hashtable currentValues,
            object desiredValues,
            ICollection valuesToCheck,
            Hashtable? includedDrifts = null,
            bool noEventMessage = false,
            bool noDriftReset = false,
            List<string>? excludedProperties = null)
        {
            Hashtable driftedParameters = [];
            List<Hashtable> driftInfo = [];
            Hashtable driftObject = new()
            {
                { "DriftInfo", driftInfo },
                { "CurrentValues", new Hashtable() },
                { "DesiredValues", new Hashtable() }
            };

            bool returnValue = true;

            if (includedDrifts is not null && includedDrifts.Keys.Count > 0)
            {
                driftedParameters = includedDrifts;
                foreach (DictionaryEntry existingDrift in includedDrifts)
                {
                    string propertyName = (string)existingDrift.Key;
                    string value = (string)existingDrift.Value;
                    int startIndex = value.IndexOf("</CurrentValue>");
                    string currentValue = value.Substring(0, startIndex)
                        .Replace("<CurrentValue>", "");
                    string desiredValue = value.Substring(startIndex + 15, value.Length - (startIndex + 15))
                        .Replace("<DesiredValue>", "")
                        .Replace("</DesiredValue>", "");

                    driftInfo.Add(DriftRecord.Create(propertyName, currentValue, desiredValue));
                }
            }

            if (desiredValues is not Hashtable and not CimInstance and not Dictionary<string, object>)
            {
                throw new ArgumentException($"Property 'DesiredValues' must be either a Hashtable or CimInstance. Type detected was {desiredValues.GetType().FullName}");
            }

            if (desiredValues is CimInstance && valuesToCheck is null)
            {
                throw new ArgumentException("If 'DesiredValues' is a CimInstance, then property 'ValuesToCheck' must contain a value");
            }

            List<string> keyList = valuesToCheck.Cast<string>().ToList();
            Hashtable desiredValuesHashtable = ComplexObjectConverter.ToHashtable(desiredValues)!;

            if (!keyList.Contains("Ensure") && !keyList.Contains("IsSingleInstance") && currentValues.ContainsKey("Ensure"))
            {
                keyList.Add("Ensure");
                if (desiredValuesHashtable is not null && !desiredValuesHashtable.ContainsKey("Ensure"))
                {
                    desiredValuesHashtable.Add("Ensure", "Present");
                }
            }

            foreach (string key in keyList)
            {
                if (BaseExcludedProperties.Contains(key) || (excludedProperties is not null && excludedProperties.Contains(key)))
                {
                    continue;
                }

                bool currentHasKey = currentValues.ContainsKey(key);
                object? currentValue = currentHasKey ? currentValues[key] : null;
                bool desiredHasKey = desiredValuesHashtable.ContainsKey(key);
                object? desiredValue = desiredHasKey ? desiredValuesHashtable[key] : null;

                if (desiredValue is null && currentHasKey && currentValue is null)
                {
                    continue;
                }

                bool valuesDiffer =
                    !currentHasKey ||
                    !(currentValue?.ToString().Equals(desiredValue?.ToString(), StringComparison.OrdinalIgnoreCase) ?? false) ||
                    (desiredHasKey && desiredValue is Array);

                if (!valuesDiffer || !desiredHasKey)
                {
                    continue;
                }

                Type desiredType = desiredValue is null
                    ? currentValue?.GetType() ?? typeof(object)
                    : desiredValue.GetType();

                if (desiredType.IsArray)
                {
                    if (!currentHasKey || currentValue is null)
                    {
                        driftInfo.Add(DriftRecord.Create(key, null, desiredValue));
                        AddDriftedParameter(driftedParameters, key, "null", "[Array]");
                        returnValue = false;
                        continue;
                    }

                    if (desiredType.Name.Equals("CimInstance[]"))
                    {
                        throw new NotSupportedException($"Comparing CimInstances with {typeof(SimpleObjectComparer).Name} is not supported.");
                    }

                    Array desiredValuesArray = desiredValue is null
                        ? Array.CreateInstance(desiredType, 0)
                        : (Array)desiredValue;
                    Array currentValuesArray = EnsureArray(currentValue, desiredType.GetElementType());
                    List<CompareObjectModel> arrayDifferences = ArrayComparer.CompareArrays(currentValuesArray, desiredValuesArray);
                    if (arrayDifferences.Count > 0)
                    {
                        string currentValuesString = ArrayComparer.FormatValues(currentValuesArray);
                        string desiredValuesString = ArrayComparer.FormatValues(desiredValuesArray);
                        string deltaString = ArrayComparer.FormatDelta(arrayDifferences);
                        driftInfo.Add(DriftRecord.Create(key, currentValuesString, desiredValuesString, deltaString));
                        AddDriftedParameter(driftedParameters, key, currentValuesString, desiredValuesString, deltaString);
                        returnValue = false;
                    }
                    continue;
                }

                switch (desiredValue)
                {
                    case null:
                        driftInfo.Add(DriftRecord.Create(key, currentValue as string ?? string.Empty, "$null"));
                        AddDriftedParameter(driftedParameters, key, currentValue as string ?? string.Empty, "$null");
                        returnValue = false;
                        break;

                    case string desiredValueString:
                        string? currentValueString = currentValue as string;
                        if (!string.IsNullOrEmpty(currentValueString))
                        {
                            currentValueString = Utilities.Utilities.NormalizeLineEndings(currentValueString!);
                        }
                        desiredValueString = Utilities.Utilities.NormalizeLineEndings(desiredValueString);

                        if (string.IsNullOrEmpty(currentValueString) && string.IsNullOrEmpty(desiredValueString))
                        {
                            continue;
                        }

                        if (!string.IsNullOrEmpty(currentValueString) && !string.IsNullOrEmpty(desiredValueString)
                            && string.Equals(desiredValueString, currentValueString, StringComparison.OrdinalIgnoreCase))
                        {
                            continue;
                        }

                        driftInfo.Add(DriftRecord.Create(key, currentValueString, desiredValueString));
                        AddDriftedParameter(driftedParameters, key, currentValueString, desiredValueString);
                        returnValue = false;
                        break;

                    default:
                        if (!desiredValue.GetType().IsValueType)
                        {
                            throw new NotSupportedException($"Comparing {desiredType.FullName} with {typeof(SimpleObjectComparer).Name} is not supported.");
                        }

                        driftInfo.Add(DriftRecord.Create(key, currentValue?.ToString() ?? string.Empty, desiredValue.ToString()));
                        AddDriftedParameter(driftedParameters, key, currentValue?.ToString() ?? string.Empty, desiredValue.ToString());
                        returnValue = false;
                        break;
                }
            }

            return new()
            {
                { "TestResult", returnValue },
                { "DriftObject", driftObject },
                { "DriftedParameters", driftedParameters }
            };
        }

        private static Array EnsureArray(object? value, Type? elementType = null)
        {
            if (value is null)
            {
                elementType = elementType ?? typeof(object);
                return Array.CreateInstance(elementType, 0);
            }

            if (value is PSObject psObject)
            {
                value = psObject.BaseObject;
            }

            if (value is Array array)
            {
                return array;
            }

            if (value is IList list)
            {
                Type[] genericArguments = list.GetType().GetGenericArguments();
                if (genericArguments.Length == 0)
                {
                    elementType = elementType ?? typeof(object);
                }
                else
                {
                    elementType = genericArguments[0];
                }

                Array newArray = Array.CreateInstance(elementType, list.Count);
                list.CopyTo(newArray, 0);
                return newArray;
            }

            elementType = elementType ?? value.GetType();
            Array result = Array.CreateInstance(elementType, 1);
            result.SetValue(value, 0);
            return result;
        }

        private static void AddDriftedParameter(Hashtable driftedParameters, string propertyName, string? currentValue, string? desiredValue, string? deltaValue = null)
        {
            string eventValue = $"<CurrentValue>{currentValue}</CurrentValue><DesiredValue>{desiredValue}</DesiredValue>";
            if (deltaValue is not null)
            {
                eventValue += $"<DeltaValue>{deltaValue}</DeltaValue>";
            }

            driftedParameters.Add(propertyName, eventValue);
        }
    }
}
