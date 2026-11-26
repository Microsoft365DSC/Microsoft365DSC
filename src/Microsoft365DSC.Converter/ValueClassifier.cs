using System;
using System.Collections.Concurrent;
using System.Management.Automation;
using System.Reflection;

namespace Microsoft365DSC.Converter
{
    /// <summary>
    /// Type tests shared by the converters. Each predicate keeps the rule its original call site
    /// applied; they are grouped here so the differences between them stay visible.
    /// </summary>
    public static class ValueClassifier
    {
        private const string GraphNamespacePrefix = "Microsoft.Graph.";
        private const string CimInstanceTypeName = "CimInstance";

        private static readonly ConcurrentDictionary<Type, bool> HasPropertiesByType = new();

        public static bool IsLeaf(object? value)
        {
            if (value is null)
            {
                return true;
            }

            Type type = value.GetType();

            if (type.IsPrimitive || type.IsEnum)
            {
                return true;
            }

            return type == typeof(string) ||
                type == typeof(DateTime) ||
                type == typeof(DateTimeOffset) ||
                type == typeof(decimal) ||
                type == typeof(Guid) ||
                type == typeof(TimeSpan) ||
                type == typeof(SwitchParameter);
        }

        public static bool IsReflectableComplex(Type type)
        {
            if (type.Namespace is null)
            {
                return true;
            }

            return type.FullName?.StartsWith(GraphNamespacePrefix, StringComparison.OrdinalIgnoreCase) == true;
        }

        public static bool IsGraphModel(Type type)
        {
            return type.FullName?.Contains(GraphNamespacePrefix) == true;
        }

        public static bool HasReflectableProperties(object? value)
        {
            if (value is null)
            {
                return false;
            }

            return HasPropertiesByType.GetOrAdd(value.GetType(), static type =>
            {
                string typeName = type.FullName ?? string.Empty;

                if (typeName.IndexOf(CimInstanceTypeName, StringComparison.OrdinalIgnoreCase) > -1 ||
                    typeName.StartsWith(GraphNamespacePrefix, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }

                if (type.IsPrimitive || type == typeof(string) || type == typeof(DateTime) ||
                    type == typeof(decimal) || type == typeof(Guid))
                {
                    return false;
                }

                return type.GetProperties(BindingFlags.Public | BindingFlags.Instance).Length > 0;
            });
        }
    }
}
