using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;

namespace Microsoft365DSC.Reporting.Configuration
{
    internal sealed class ConfigurationResource
    {
        private const string ResourceNameKey = "ResourceName";
        private const string ResourceInstanceNameKey = "ResourceInstanceName";

        private ConfigurationResource(string type, string instanceName, IDictionary properties)
        {
            Type = type;
            InstanceName = instanceName;
            Properties = properties;
        }

        public string Type { get; }

        public string InstanceName { get; }

        public IDictionary Properties { get; }

        public static ConfigurationResource FromDictionary(IDictionary resource)
        {
            Find(resource, ResourceNameKey, out object? type);
            Find(resource, ResourceInstanceNameKey, out object? instanceName);
            return new(
                Convert.ToString(type) ?? string.Empty,
                Convert.ToString(instanceName) ?? string.Empty,
                resource);
        }

        public bool TryGetProperty(string name, out object? value)
        {
            if (string.Equals(name, ResourceNameKey, StringComparison.OrdinalIgnoreCase)
                || string.Equals(name, ResourceInstanceNameKey, StringComparison.OrdinalIgnoreCase))
            {
                value = null;
                return false;
            }

            return Find(Properties, name, out value);
        }

        public static bool Find(IDictionary dictionary, string name, out object? value)
        {
            foreach (DictionaryEntry entry in dictionary)
            {
                if (string.Equals(Convert.ToString(entry.Key), name, StringComparison.OrdinalIgnoreCase))
                {
                    value = Unwrap(entry.Value);
                    return true;
                }
            }

            value = null;
            return false;
        }

        public static object? Unwrap(object? value)
        {
            return value is PSObject psObject ? psObject.BaseObject : value;
        }

        public static IEnumerable<object?> Items(IEnumerable collection)
        {
            foreach (object? item in collection)
            {
                yield return Unwrap(item);
            }
        }
    }
}
