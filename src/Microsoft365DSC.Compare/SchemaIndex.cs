using Microsoft365DSC.Utilities;
using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;

namespace Microsoft365DSC.Compare
{
    /// <summary>
    /// Random access over a deserialized SchemaDefinition.json. One index is built per schema list
    /// and shared by every comparison that receives that same list.
    /// </summary>
    internal sealed class SchemaIndex
    {
        private const string ClassNamePrefix = "MSFT_";

        private static readonly ConditionalWeakTable<IEnumerable<object>, SchemaIndex> Indexes = new();
        private readonly Dictionary<string, object> _byClassName = new(StringComparer.OrdinalIgnoreCase);
        private readonly ConcurrentDictionary<string, ClassDefinition> _classes = new(StringComparer.OrdinalIgnoreCase);

        private SchemaIndex(IEnumerable<object> schema)
        {
            foreach (object entry in schema)
            {
                string? className = MemberAccessor.GetMemberAsString(entry, "ClassName");
                if (!string.IsNullOrEmpty(className) && !_byClassName.ContainsKey(className!))
                {
                    _byClassName[className!] = entry;
                }
            }
        }

        public static SchemaIndex For(IEnumerable<object> schema)
        {
            if (schema is null)
            {
                throw new ArgumentNullException(nameof(schema));
            }

            return Indexes.GetValue(schema, static s => new SchemaIndex(s));
        }

        public bool TryGetClass(string? className, out ClassDefinition definition)
        {
            definition = null!;
            if (string.IsNullOrEmpty(className) || !_byClassName.TryGetValue(className!, out object entry))
            {
                return false;
            }

            definition = _classes.GetOrAdd(className!, name => ClassDefinition.From(name, entry));
            return true;
        }

        public bool TryGetResource(string resourceName, out ClassDefinition definition)
        {
            return TryGetClass(ClassNamePrefix + resourceName, out definition);
        }

        public MandatoryParameters GetMandatory(string resourceName)
        {
            return TryGetResource(resourceName, out ClassDefinition definition) ? definition.Mandatory : MandatoryParameters.Empty;
        }

        public ResourceCompareParameters? GetCompareParameters(string resourceName)
        {
            if (!_byClassName.TryGetValue(ClassNamePrefix + resourceName, out object? definition) ||
                !MemberAccessor.TryGetMember(definition, "CompareParameters", out object? declared) ||
                declared is null)
            {
                return null;
            }

            return new ResourceCompareParameters
            {
                ExcludedProperties = AsStrings(declared, "ExcludedProperties"),
                IncludedProperties = AsStrings(declared, "IncludedProperties")
            };
        }

        private static string[]? AsStrings(object source, string name)
        {
            if (!MemberAccessor.TryGetMember(source, name, out object? value) || value is null)
            {
                return null;
            }

            List<string> result = [];
            foreach (object item in AsSequence(value))
            {
                if (item is not null)
                {
                    result.Add(item.ToString());
                }
            }

            return result.Count == 0 ? null : [.. result];
        }

        internal static IEnumerable<object> AsSequence(object? value)
        {
            return value switch
            {
                null => [],
                string => [],
                IEnumerable<object> typed => typed,
                IEnumerable sequence => sequence.Cast<object>(),
                _ => [value]
            };
        }
    }

    internal sealed class ClassDefinition
    {
        private readonly Dictionary<string, ParameterDefinition> _parameters;

        private ClassDefinition(string className, Dictionary<string, ParameterDefinition> parameters, MandatoryParameters mandatory)
        {
            ClassName = className;
            _parameters = parameters;
            Mandatory = mandatory;
        }

        public string ClassName { get; }

        public MandatoryParameters Mandatory { get; }

        public bool TryGetParameter(string name, out ParameterDefinition parameter)
        {
            return _parameters.TryGetValue(name, out parameter);
        }

        public static ClassDefinition From(string className, object entry)
        {
            Dictionary<string, ParameterDefinition> parameters = new(StringComparer.OrdinalIgnoreCase);
            List<string> mandatory = [];

            if (MemberAccessor.TryGetMember(entry, "Parameters", out object? declared))
            {
                foreach (object parameter in SchemaIndex.AsSequence(declared))
                {
                    string? name = MemberAccessor.GetMemberAsString(parameter, "Name");
                    if (string.IsNullOrEmpty(name))
                    {
                        continue;
                    }

                    ParameterDefinition definition = new(
                        name!,
                        MemberAccessor.GetMemberAsString(parameter, "CIMType"),
                        MemberAccessor.GetMemberAsString(parameter, "Option"));
                    parameters[name!] = definition;

                    if (definition.IsKey || definition.IsRequired)
                    {
                        mandatory.Add(name!);
                    }
                }
            }

            return new ClassDefinition(className, parameters, new MandatoryParameters(mandatory));
        }
    }

    internal sealed class ParameterDefinition
    {
        private const string ComplexTypeMarker = "MSFT_";
        private const string ArraySuffix = "[]";

        public ParameterDefinition(string name, string? cimType, string? option)
        {
            Name = name;
            CimType = cimType;
            Option = option;
            IsKey = string.Equals(option, "Key", StringComparison.OrdinalIgnoreCase);
            IsRequired = string.Equals(option, "Required", StringComparison.OrdinalIgnoreCase);
            IsCredential = string.Equals(cimType, "PSCredential", StringComparison.OrdinalIgnoreCase);
            IsComplex = cimType?.IndexOf(ComplexTypeMarker, StringComparison.OrdinalIgnoreCase) > -1;
            ElementClassName = cimType?.Replace(ArraySuffix, string.Empty) ?? string.Empty;
        }

        public string Name { get; }

        public string? CimType { get; }

        public string? Option { get; }

        public bool IsKey { get; }

        public bool IsRequired { get; }

        public bool IsCredential { get; }

        public bool IsComplex { get; }

        public string ElementClassName { get; }
    }

    internal readonly struct MandatoryParameters
    {
        private readonly HashSet<string> _lookup;

        public MandatoryParameters(List<string> names)
        {
            Names = names;
            _lookup = new HashSet<string>(names, StringComparer.OrdinalIgnoreCase);
        }

        public static MandatoryParameters Empty { get; } = new([]);

        public List<string> Names { get; }

        public int Count => Names.Count;

        public bool Contains(string name) => _lookup.Contains(name);
    }
}
