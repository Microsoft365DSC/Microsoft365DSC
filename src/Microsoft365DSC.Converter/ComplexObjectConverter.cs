using Microsoft.Management.Infrastructure;
using Microsoft365DSC.Utilities;
using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using System.Text;

namespace Microsoft365DSC.Converter
{
    /// <summary>
    /// Provides optimized CIM instance to hashtable conversion with cached reflection.
    /// Replaces repeated reflection-based property access with cached PropertyInfo lookups.
    /// </summary>
    public static class ComplexObjectConverter
    {
        private const string ClassNamePrefix = "MSFT_";
        private const string EntityItemProperty = "EntityItem";
        private const string GraphModelNamespacePrefix = "Microsoft.Graph.PowerShell.Models.";
        private const string GraphAdditionalPropertiesName = "Microsoft.Graph.Beta.PowerShell.Runtime.IAssociativeArray<System.Object>.AdditionalProperties";
        private const string AdditionalPropertiesKey = "AdditionalProperties";
        private const char RightSingleQuotationMark = (char)0x2019;

        private static readonly ConcurrentDictionary<Type, PropertyInfo[]> ClrProperties = new();
        private static readonly ConcurrentDictionary<Type, PropertyInfo[]> GraphProperties = new();
        private static readonly ConcurrentDictionary<Type, DscPropertySet> DscProperties = new();

        private sealed class DscPropertySet
        {
            public DscPropertySet(List<string> sortedNames, Dictionary<string, PropertyInfo> byName)
            {
                SortedNames = sortedNames;
                ByName = byName;
            }

            public List<string> SortedNames { get; }

            public Dictionary<string, PropertyInfo> ByName { get; }
        }

        /// <summary>
        /// Converts a CIM instance or object to a hashtable with cached property reflection.
        /// </summary>
        /// <param name="complexObject">Complex object instance to convert</param>
        /// <returns>Hashtable representation of the object</returns>
        public static Hashtable? ToHashtable(object complexObject)
        {
            if (complexObject is null)
            {
                return null;
            }

            complexObject = MemberAccessor.Unwrap(complexObject)!;

            if (complexObject is PSObject psObject)
            {
                var result = new Hashtable(StringComparer.OrdinalIgnoreCase);
                foreach (PSPropertyInfo prop in psObject.Properties)
                {
                    if (prop.MemberType != PSMemberTypes.NoteProperty &&
                        prop.MemberType != PSMemberTypes.Property)
                    {
                        continue;
                    }

                    try
                    {
                        result[prop.Name] = GetValueFromObject(prop.Value);
                    }
                    catch
                    {
                    }
                }
                return result;
            }

            if (complexObject is Hashtable hashtable)
            {
                return hashtable;
            }

            if (complexObject is IDictionary dictionary)
            {
                var dictionaryResult = new Hashtable(StringComparer.OrdinalIgnoreCase);
                foreach (DictionaryEntry entry in dictionary)
                {
                    dictionaryResult[entry.Key!] = GetValueFromObject(entry.Value);
                }
                return dictionaryResult;
            }

            if (complexObject is CimInstance cimInstance)
            {
                var cimResult = new Hashtable(StringComparer.OrdinalIgnoreCase);
                foreach (var property in cimInstance.CimInstanceProperties)
                {
                    if (property.Name.Equals("PSComputerName", StringComparison.OrdinalIgnoreCase) || !property.IsValueModified)
                    {
                        continue;
                    }

                    cimResult[property.Name] = GetValueFromObject(property.Value);
                }
                return cimResult;
            }

            if (ValueClassifier.IsGraphModel(complexObject.GetType()))
            {
                return GetValueFromGraphObject(complexObject);
            }

            return GetValueFromClrObject(complexObject);
        }

        private static Hashtable GetValueFromClrObject(object complexObject)
        {
            PropertyInfo[] properties = ClrProperties.GetOrAdd(complexObject.GetType(), static type =>
                type.GetProperties(BindingFlags.Public | BindingFlags.Instance)
                    .Where(property => property.CanRead && property.GetIndexParameters().Length == 0)
                    .ToArray());

            var result = new Hashtable(StringComparer.OrdinalIgnoreCase);
            foreach (var property in properties)
            {
                object? value;
                try
                {
                    value = property.GetValue(complexObject);
                }
                catch
                {
                    continue;
                }

                if (value is null)
                {
                    continue;
                }

                result[property.Name] = GetValueFromObject(value);
            }

            return result;
        }

        /// <summary>
        /// Converts an array of complex objects to an array of hashtables.
        /// </summary>
        /// <param name="complexObjects">Array of complex objects to convert</param>
        /// <returns>Array of hashtables representing the complex objects</returns>
        public static Array ToHashtableArray(Array complexObjects)
        {
            var result = new Hashtable?[complexObjects.Length];
            for (int i = 0; i < complexObjects.Length; i++)
            {
                var item = complexObjects.GetValue(i);
                result[i] = ToHashtable(item!);
            }
            return result;
        }

        private static Array ConvertArray(Array source)
        {
            var result = new object?[source.Length];

            for (int i = 0; i < source.Length; i++)
            {
                var item = source.GetValue(i);

                if (item is null)
                {
                    result[i] = null;
                }
                else if (item is Array nestedArray)
                {
                    result[i] = ConvertArray(nestedArray);
                }
                else if (item is Hashtable)
                {
                    result[i] = item;
                }
                else if (ValueClassifier.HasReflectableProperties(item))
                {
                    result[i] = ToHashtable(item);
                }
                else
                {
                    result[i] = item;
                }
            }

            return result;
        }

        private static bool EndsWithNewLine(StringBuilder builder)
        {
            return builder.Length >= 2 && builder[builder.Length - 2] == '\r' && builder[builder.Length - 1] == '\n';
        }

        private static object? GetValueFromObject(object? value)
        {
            value = MemberAccessor.Unwrap(value);

            if (value is null)
            {
                return null;
            }
            else if (value is PSObject)
            {
                return ToHashtable(value);
            }
            else if (value is Array array)
            {
                return ConvertArray(array);
            }
            else if (value is Hashtable hashValue)
            {
                return hashValue;
            }
            else if (ValueClassifier.HasReflectableProperties(value))
            {
                return ToHashtable(value);
            }
            else
            {
                return value;
            }
        }

        private static Hashtable GetValueFromGraphObject(object complexObject)
        {
            PropertyInfo[] properties = GraphProperties.GetOrAdd(complexObject.GetType(), static type =>
            {
                PropertyInfo[] publicProperties = type.GetProperties(BindingFlags.Public | BindingFlags.Instance)
                    .Where(property => !property.Name.Equals(EntityItemProperty)).ToArray();
                PropertyInfo[] additionalProperties = type.GetProperties(BindingFlags.NonPublic | BindingFlags.Instance)
                    .Where(property => property.Name.Contains(AdditionalPropertiesKey)).ToArray();
                return publicProperties.Concat(additionalProperties).ToArray();
            });

            var graphResult = new Hashtable(StringComparer.OrdinalIgnoreCase);
            foreach (var property in properties)
            {
                var value = property.GetValue(complexObject);
                if (property.Name.Equals(GraphAdditionalPropertiesName))
                {
                    graphResult[AdditionalPropertiesKey] = GetValueFromObject(value);
                }
                else
                {
                    graphResult[property.Name] = GetValueFromObject(value);
                }
            }

            return graphResult;
        }

        /// <summary>
        /// Converts a complex object to its DSC configuration string representation.
        /// </summary>
        /// <param name="complexObject">The complex object to convert (can be null, object, or array)</param>
        /// <param name="cimInstanceName">The name of the CIM instance type</param>
        /// <param name="complexTypeMapping">Optional mapping of complex type properties</param>
        /// <param name="whitespace">Optional whitespace for formatting</param>
        /// <param name="indentLevel">The indentation level (default is 3)</param>
        /// <param name="isArray">Indicates if the object is part of an array</param>
        /// <returns>A formatted DSC configuration string</returns>
        public static object ToDscString(
            object complexObject,
            string cimInstanceName,
            List<ComplexTypeMapping> complexTypeMapping,
            string whitespace = "",
            uint indentLevel = 3,
            bool isArray = false)
        {
            if (complexObject is null)
            {
                return string.Empty;
            }

            complexTypeMapping ??= [];

            Dictionary<string, ComplexTypeMapping> mappingByName = new(complexTypeMapping.Count, StringComparer.OrdinalIgnoreCase);
            Dictionary<string, ComplexTypeMapping> mappingByExactName = new(complexTypeMapping.Count, StringComparer.Ordinal);
            foreach (ComplexTypeMapping mapping in complexTypeMapping)
            {
                if (!mappingByName.ContainsKey(mapping.Name))
                {
                    mappingByName[mapping.Name] = mapping;
                }

                if (!mappingByExactName.ContainsKey(mapping.Name))
                {
                    mappingByExactName[mapping.Name] = mapping;
                }
            }

            return ToDscStringCore(complexObject, cimInstanceName, mappingByName, mappingByExactName, indentLevel, isArray);
        }

        private static object ToDscStringCore(
            object complexObject,
            string cimInstanceName,
            Dictionary<string, ComplexTypeMapping> mappingByName,
            Dictionary<string, ComplexTypeMapping> mappingByExactName,
            uint indentLevel,
            bool isArray)
        {
            if (complexObject is null)
            {
                return string.Empty;
            }

            if (complexObject is PSObject psObject)
            {
                complexObject = psObject.BaseObject;
            }

            var indent = new string(' ', (int)indentLevel * 4);

            if (complexObject is IEnumerable enumerable and not string and not IDictionary)
            {
                List<object> currentProperty = [];
                indentLevel++;

                foreach (var item in enumerable)
                {
                    var itemResult = ToDscStringCore(item, cimInstanceName, mappingByName, mappingByExactName, indentLevel, true);
                    currentProperty.Add((string)itemResult);
                }

                if (currentProperty.Count > 0)
                {
                    int lastIndex = currentProperty.Count - 1;
                    currentProperty[lastIndex] += $"\r\n{indent}";
                }

                return currentProperty.ToArray();
            }

            var currentPropertyBuilder = new StringBuilder();
            if (isArray)
            {
                currentPropertyBuilder.AppendLine();
                currentPropertyBuilder.Append(indent);
            }

            cimInstanceName = cimInstanceName.Replace(ClassNamePrefix, string.Empty);
            _ = currentPropertyBuilder.Append(ClassNamePrefix).Append(cimInstanceName).Append('{');
            _ = currentPropertyBuilder.AppendLine();
            int contentStart = currentPropertyBuilder.Length;

            indentLevel++;
            indent = new string(' ', (int)indentLevel * 4);

            IEnumerable<string> keys;
            IDictionary? dict = null;
            CimInstance? cimInstance = null;
            DscPropertySet? propertySet = null;

            if (complexObject is IDictionary dictionary)
            {
                dict = dictionary;
                var keyList = new List<string>(dictionary.Count);
                foreach (var key in dictionary.Keys)
                {
                    keyList.Add(key.ToString());
                }
                keyList.Sort();
                keys = keyList;
            }
            else if (complexObject is CimInstance instance)
            {
                cimInstance = instance;
                keys = cimInstance.CimInstanceProperties
                    .Where(p => p.IsValueModified && p.Name != "PSComputerName")
                    .Select(p => p.Name);
            }
            else
            {
                propertySet = DscProperties.GetOrAdd(complexObject.GetType(), static type =>
                {
                    IEnumerable<PropertyInfo> properties = type.GetProperties(BindingFlags.Public | BindingFlags.Instance);
                    if (ValueClassifier.IsGraphModel(type))
                    {
                        properties = properties.Where(property => !property.Name.Equals(EntityItemProperty));
                    }

                    Dictionary<string, PropertyInfo> byName = new(StringComparer.Ordinal);
                    foreach (PropertyInfo property in properties)
                    {
                        byName[property.Name] = property;
                    }

                    List<string> sortedNames = [.. byName.Keys];
                    sortedNames.Sort();
                    return new DscPropertySet(sortedNames, byName);
                });

                if (propertySet.SortedNames.Count == 0)
                {
                    return string.Empty;
                }

                keys = propertySet.SortedNames;
            }

            foreach (var key in keys)
            {
                object? value;
                if (dict is not null)
                {
                    value = dict[key];
                }
                else if (cimInstance is not null)
                {
                    value = cimInstance.CimInstanceProperties[key]?.Value;
                }
                else
                {
                    value = propertySet!.ByName[key].GetValue(complexObject);
                }

                if (value is not null)
                {
                    if (value is PSObject psObjectValue)
                    {
                        value = psObjectValue.BaseObject;
                    }
                    if (value is ArrayList arrayList)
                    {
                        value = arrayList.ToArray();
                    }

                    var valueType = value.GetType();
                    var valueTypeName = valueType.FullName ?? valueType.Name;

                    bool hasMapping = mappingByName.TryGetValue(key, out ComplexTypeMapping mappedType);
                    if (valueTypeName.StartsWith(GraphModelNamespacePrefix, StringComparison.Ordinal) || hasMapping)
                    {
                        var itemValue = value;
                        var hashPropertyType = valueType.Name.ToLower();

                        bool isNestedArray = value is Array;

                        if (hasMapping)
                        {
                            hashPropertyType = mappedType.CimInstanceName;
                        }

                        if (isNestedArray && hasMapping)
                        {
                            if (itemValue is Array)
                            {
                                _ = currentPropertyBuilder.Append(indent).Append(key).Append(" = @(");
                            }
                        }

                        if (isNestedArray)
                        {
                            indentLevel++;
                            var arrayItems = (Array)value;
                            for (int i = 0; i < arrayItems.Length; i++)
                            {
                                object item = arrayItems.GetValue(i);
                                var itemHash = ToHashtable(item);
                                var nestedPropertyString = (string)ToDscStringCore(
                                    itemHash!,
                                    hashPropertyType,
                                    mappingByName,
                                    mappingByExactName,
                                    indentLevel,
                                    true);

                                if (string.IsNullOrWhiteSpace(nestedPropertyString))
                                {
                                    nestedPropertyString = "@()\r\n";
                                }

                                if (i != 0)
                                {
                                    nestedPropertyString = nestedPropertyString.Substring(2);
                                }
                                _ = currentPropertyBuilder.Append(nestedPropertyString);
                                if (!EndsWithNewLine(currentPropertyBuilder))
                                {
                                    _ = currentPropertyBuilder.AppendLine();
                                }
                            }
                            indentLevel--;

                            _ = arrayItems.Length > 0
                                ? currentPropertyBuilder.Append(indent).Append(')').AppendLine()
                                : currentPropertyBuilder.Append(')').AppendLine();
                        }
                        else
                        {
                            Hashtable hashProperty = ToHashtable(itemValue)!;
                            _ = currentPropertyBuilder.Append(indent).Append(key).Append(" = ");
                            var nestedPropertyString = ToDscStringCore(
                                hashProperty,
                                hashPropertyType,
                                mappingByName,
                                mappingByExactName,
                                indentLevel,
                                false);

                            if (string.IsNullOrWhiteSpace((string)nestedPropertyString))
                            {
                                nestedPropertyString = "$null\r\n";
                            }
                            _ = currentPropertyBuilder.Append(nestedPropertyString).AppendLine();
                        }
                    }
                    else
                    {
                        var currentValue = value;

                        if (currentValue is not null && !currentValue.GetType().Name.Contains("Dictionary"))
                        {
                            if (currentValue is string stringValue)
                            {
                                currentValue = stringValue.IndexOf(RightSingleQuotationMark) < 0
                                    ? stringValue
                                    : stringValue.Replace(RightSingleQuotationMark.ToString(), "''");
                            }
                            _ = currentPropertyBuilder.Append(SimpleObjectConverter.ToDscString(key, currentValue, indent));
                        }
                    }
                }
                else if (mappingByExactName.TryGetValue(key, out ComplexTypeMapping mappedKey) && mappedKey.IsRequired)
                {
                    _ = mappedKey.IsArray
                        ? currentPropertyBuilder.Append(indent).Append(key).Append(" = @()").AppendLine()
                        : currentPropertyBuilder.Append(indent).Append(key).Append(" = $null").AppendLine();
                }
            }

            int contentEnd = currentPropertyBuilder.Length;
            indent = new string(' ', (int)(indentLevel - 1) * 4);
            _ = currentPropertyBuilder.Append(indent).Append('}');

            return HasContent(currentPropertyBuilder, contentStart, contentEnd)
                ? currentPropertyBuilder.ToString()
                : string.Empty;
        }

        private static bool HasContent(StringBuilder builder, int start, int end)
        {
            for (int i = start; i < end; i++)
            {
                char current = builder[i];
                if (current != ' ' && current != '\r' && current != '\n')
                {
                    return true;
                }
            }

            return false;
        }
    }
}
