using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;
using Microsoft365DSC.Utilities;

namespace Microsoft365DSC.Cache
{
    /// <summary>
    /// Provides a centralized, thread-safe cache for expensive data structures
    /// shared across PowerShell and C# layers. Loading data here avoids repeated
    /// deserialization and the boxing overhead that occurs when passing rich
    /// objects from PowerShell to C#.
    /// </summary>
    public static class CacheManager
    {
        private static readonly object SchemaLock = new();
        private static List<object> _schema;

        /// <summary>
        /// Gets a value indicating whether the M365DSC schema has been loaded.
        /// </summary>
        public static bool IsSchemaLoaded
        {
            get
            {
                lock (SchemaLock)
                {
                    return _schema != null;
                }
            }
        }

        /// <summary>
        /// Gets the cached schema as an <see cref="IEnumerable{Object}"/> of Hashtables.
        /// Returns <c>null</c> if the schema has not been loaded yet.
        /// </summary>
        public static IEnumerable<object> Schema
        {
            get
            {
                lock (SchemaLock)
                {
                    return _schema;
                }
            }
        }

        /// <summary>
        /// Loads the schema from a list of objects,
        /// deserializes it into a list of <see cref="Hashtable"/> trees, and caches
        /// the result. Subsequent calls are no-ops unless <paramref name="force"/>
        /// is <c>true</c>.
        /// </summary>
        /// <param name="schema">List of schema objects to cache.</param>
        public static void LoadSchema(List<object> schema)
        {
            List<object> newSchema = [];
            foreach (object entry in schema)
            {
                newSchema.Add(ConvertObjectToHashtable(entry));
            }

            lock (SchemaLock)
            {
                _schema = newSchema;
            }
        }

        /// <summary>
        /// Clears the cached schema so the next caller reloads it.
        /// </summary>
        /// <remarks>
        /// The cache is process-wide and <see cref="LoadSchema"/> overwrites unconditionally, so a
        /// test that loads a fixture schema must clear it again or every later test in the same
        /// process resolves against the fixture.
        /// </remarks>
        public static void ClearSchema()
        {
            lock (SchemaLock)
            {
                _schema = null;
            }
        }

        /// <summary>
        /// Finds a CIM class in the cached schema by its ClassName.
        /// </summary>
        /// <param name="className">The class name to look for, including the MSFT_ prefix.</param>
        /// <returns>The matching schema entry, or <c>null</c> when the schema is not loaded or holds no such class.</returns>
        public static object? FilterLoadedCimClassesByName(string className)
        {
            // One read of the field, so the schema cannot be replaced between the load check and the scan.
            List<object> schema;
            lock (SchemaLock)
            {
                if (_schema is null)
                {
                    return null;
                }
                schema = _schema;
            }

            foreach (object obj in schema)
            {
                if (string.Equals(MemberAccessor.GetMemberAsString(obj, "ClassName"), className, StringComparison.Ordinal))
                {
                    return obj;
                }
            }

            return null;
        }

        /// <summary>
        /// Maps a CIM type onto the PowerShell type literal used in resource property descriptors.
        /// </summary>
        /// <param name="cimType">The CIM type, optionally suffixed with [] for an array.</param>
        /// <returns>The bracketed type literal, for example "[string[]]".</returns>
        public static string ConvertCimType(string? cimType)
        {
            string value = cimType ?? string.Empty;
            bool isArray = value.EndsWith("[]", StringComparison.Ordinal);
            string bare = isArray ? value.Substring(0, value.Length - 2) : value;
            string mapped = CimTypeMap.TryGetValue(bare, out string? match) ? match : bare;

            return isArray ? $"[{mapped}[]]" : $"[{mapped}]";
        }

        /// <summary>
        /// Builds the property descriptors of a cached CIM class.
        /// </summary>
        /// <param name="definition">A schema entry as returned by <see cref="FilterLoadedCimClassesByName"/>.</param>
        /// <returns>One object per declared property, in schema order. Empty when the class declares none.</returns>
        public static PSObject[] GetResourceProperties(object? definition)
        {
            var properties = new List<PSObject>();
            if (definition is null)
            {
                return properties.ToArray();
            }

            MemberAccessor.TryGetMember(definition, "Parameters", out object? declared);
            if (declared is IEnumerable parameters and not string)
            {
                foreach (object parameter in parameters)
                {
                    if (parameter is null)
                    {
                        continue;
                    }

                    MemberAccessor.TryGetMember(parameter, "Option", out object? option);
                    MemberAccessor.TryGetMember(parameter, "Name", out object? name);
                    MemberAccessor.TryGetMember(parameter, "Values", out object? values);
                    MemberAccessor.TryGetMember(parameter, "Description", out object? description);

                    PSObject property = new();
                    property.Properties.Add(new PSNoteProperty("Name", name));
                    property.Properties.Add(new PSNoteProperty("PropertyType", ConvertCimType(MemberAccessor.GetMemberAsString(parameter, "CIMType"))));
                    property.Properties.Add(new PSNoteProperty("IsMandatory", IsMandatoryOption(option?.ToString())));
                    property.Properties.Add(new PSNoteProperty("Values", ToStringArray(values)));
                    property.Properties.Add(new PSNoteProperty("Option", option));
                    property.Properties.Add(new PSNoteProperty("Description", description));
                    properties.Add(property);
                }
            }

            return properties.ToArray();
        }

        private static readonly Dictionary<string, string> CimTypeMap = new(StringComparer.OrdinalIgnoreCase)
        {
            ["String"] = "string",
            ["Boolean"] = "bool",
            ["DateTime"] = "datetime",
            ["SInt16"] = "int16",
            ["SInt32"] = "Int32",
            ["SInt64"] = "long",
            ["UInt16"] = "uint16",
            ["UInt32"] = "uint32",
            ["UInt64"] = "uint64",
            ["Real64"] = "double",
            ["MSFT_Credential"] = "PSCredential",
        };

        private static bool IsMandatoryOption(string? option) =>
            string.Equals(option, "Key", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(option, "Required", StringComparison.OrdinalIgnoreCase);

        /// <summary>
        /// Renders a declared value list. A property with no allowed values yields an empty array.
        /// </summary>
        private static string[] ToStringArray(object? value)
        {
            if (value is null)
            {
                return [];
            }

            if (value is string text)
            {
                return [text];
            }

            if (value is IEnumerable enumerable)
            {
                var items = new List<string>();
                foreach (object item in enumerable)
                {
                    if (item is not null)
                    {
                        items.Add(item.ToString());
                    }
                }
                return items.ToArray();
            }

            return [value.ToString()];
        }

        private static object ConvertObjectToHashtable(object entry)
        {
            Hashtable result = new(StringComparer.OrdinalIgnoreCase);

            if (entry is PSObject psObject)
            {
                foreach (var prop in psObject.Properties)
                {
                    result[prop.Name] = ConvertObjectToHashtable(prop.Value);
                }
            }
            else if (entry is IDictionary dict)
            {
                foreach (DictionaryEntry kvp in dict)
                {
                    result[kvp.Key.ToString()] = ConvertObjectToHashtable(kvp.Value);
                }
            }
            else if (entry is IEnumerable enumerable && entry is not string)
            {
                return ConvertEnumerableToHashtableArray(enumerable);
            }
            else
            {
                return entry;
            }
            return result;
        }

        private static object[] ConvertEnumerableToHashtableArray(IEnumerable enumerable)
        {
            var list = new List<object>();
            foreach (object item in enumerable)
            {
                list.Add(ConvertObjectToHashtable(item));
            }
            return list.ToArray();
        }
    }
}
