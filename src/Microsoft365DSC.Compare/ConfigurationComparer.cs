using Microsoft365DSC.Utilities;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft365DSC.Compare
{
    /// <summary>
    /// Compares two whole configurations by pairing their resource instances by key, diffs each pair
    /// with <see cref="ResourceComparer"/>, and reports instances that exist on only one side.
    /// </summary>
    public static class ConfigurationComparer
    {
        /// <summary>
        /// Marks a resource that is not present on both sides, as opposed to a property that differs.
        /// </summary>
        public const string PresenceMarker = "_IsInConfiguration_";

        private const string AnnotationPrefix = "_metadata_";

        private static readonly string[] AlwaysExcludedProperties =
            [.. Microsoft365DSC.Utilities.Utilities.AuthenticationPropertyNames.Prepend("ResourceInstanceName")];
        private static readonly string[] first = new[] { "Ensure" };

        /// <summary>
        /// Compares a source configuration against a destination configuration.
        /// </summary>
        /// <param name="source">Parsed resources of the source, each a hashtable carrying ResourceName.</param>
        /// <param name="destination">Parsed resources of the destination, in the same shape.</param>
        /// <param name="schema">The deserialized SchemaDefinition.json.</param>
        /// <param name="excludedProperties">Property names to skip on every resource.</param>
        /// <param name="excludedResources">Resource names to skip entirely.</param>
        /// <param name="compareParameters">
        /// Per-resource comparison overrides, keyed by resource name. Merged with the schema's own
        /// declarations, and the only way to supply a post-processing callback, which cannot be
        /// expressed in the schema.
        /// </param>
        /// <returns>One entry per differing property, plus one per resource missing on either side.</returns>
        public static List<ConfigurationDelta> Compare(
            IEnumerable<object> source,
            IEnumerable<object> destination,
            IEnumerable<object> schema,
            string[]? excludedProperties = null,
            string[]? excludedResources = null,
            IDictionary<string, ResourceCompareParameters>? compareParameters = null)
        {
            if (source is null)
                throw new ArgumentNullException(nameof(source));
            if (destination is null)
                throw new ArgumentNullException(nameof(destination));
            if (schema is null)
                throw new ArgumentNullException(nameof(schema));

            SchemaIndex index = SchemaIndex.For(schema);
            Dictionary<string, string[]> keysByResource = new(StringComparer.OrdinalIgnoreCase);

            var excludedResourceSet = new HashSet<string>(
                excludedResources ?? [], StringComparer.OrdinalIgnoreCase);

            string[] globalExclusions = [.. AlwaysExcludedProperties.Concat(excludedProperties ?? []).Distinct(StringComparer.OrdinalIgnoreCase)];

            List<Hashtable> sourceResources = Materialize(source, excludedResourceSet);
            List<Hashtable> destinationResources = Materialize(destination, excludedResourceSet);

            List<ConfigurationDelta> delta = [];

            List<KeyedInstance> sources = new(sourceResources.Count);
            foreach (Hashtable resource in sourceResources)
            {
                sources.Add(KeyedInstance.From(resource, index, keysByResource));
            }

            List<KeyedInstance> destinations = new(destinationResources.Count);
            Dictionary<InstanceKey, Hashtable> firstDestinationByKey = [];
            foreach (Hashtable resource in destinationResources)
            {
                KeyedInstance instance = KeyedInstance.From(resource, index, keysByResource);
                destinations.Add(instance);
                if (instance.Key is { } key && !firstDestinationByKey.ContainsKey(key))
                {
                    firstDestinationByKey[key] = resource;
                }
            }

            HashSet<InstanceKey> sourceKeys = [];
            foreach (KeyedInstance sourceInstance in sources)
            {
                if (sourceInstance.Key is { } key)
                {
                    sourceKeys.Add(key);
                }

                string keyName = KeyName(sourceInstance.Keys);
                string keyValue = KeyValue(sourceInstance.Resource, sourceInstance.Keys);

                if (sourceInstance.Key is null || !firstDestinationByKey.TryGetValue(sourceInstance.Key.Value, out Hashtable? match))
                {
                    delta.Add(Presence(sourceInstance.Resource, keyName, keyValue, inSource: "Present", inDestination: "Absent"));
                    continue;
                }

                AddPropertyDeltas(delta, sourceInstance.Resource, match, sourceInstance.ResourceName, keyName, keyValue, index, globalExclusions, compareParameters);
            }

            foreach (KeyedInstance destinationInstance in destinations)
            {
                if (destinationInstance.Key is null || !sourceKeys.Contains(destinationInstance.Key.Value))
                {
                    ConfigurationDelta missing = Presence(destinationInstance.Resource, KeyName(destinationInstance.Keys), KeyValue(destinationInstance.Resource, destinationInstance.Keys), inSource: "Absent", inDestination: "Present");
                    ApplyPresenceAnnotation(missing.Properties[0], destinationInstance.Resource, destinationInstance.Keys);
                    delta.Add(missing);
                }
            }

            return delta;
        }

        private sealed class KeyedInstance
        {
            private KeyedInstance(Hashtable resource, string resourceName, string[] keys, InstanceKey? key)
            {
                Resource = resource;
                ResourceName = resourceName;
                Keys = keys;
                Key = key;
            }

            public Hashtable Resource { get; }

            public string ResourceName { get; }

            public string[] Keys { get; }

            public InstanceKey? Key { get; }

            public static KeyedInstance From(Hashtable resource, SchemaIndex index, Dictionary<string, string[]> keysByResource)
            {
                string resourceName = resource["ResourceName"]?.ToString() ?? string.Empty;
                string[] keys = ResourceKeyResolver.Resolve(resource, index, keysByResource);
                InstanceKey? key = keys.Length == 0 ? null : InstanceKey.From(resource, resourceName, keys);
                return new KeyedInstance(resource, resourceName, keys, key);
            }
        }

        private readonly struct InstanceKey : IEquatable<InstanceKey>
        {
            private readonly string _resourceName;
            private readonly string?[] _values;

            private InstanceKey(string resourceName, string?[] values)
            {
                _resourceName = resourceName;
                _values = values;
            }

            public static InstanceKey From(Hashtable resource, string resourceName, string[] keys)
            {
                string?[] values = new string?[keys.Length];
                for (int i = 0; i < keys.Length; i++)
                {
                    values[i] = resource[keys[i]]?.ToString();
                }

                return new InstanceKey(resourceName, values);
            }

            public bool Equals(InstanceKey other)
            {
                if (!string.Equals(_resourceName, other._resourceName, StringComparison.Ordinal) || _values.Length != other._values.Length)
                {
                    return false;
                }

                for (int i = 0; i < _values.Length; i++)
                {
                    if (!string.Equals(_values[i], other._values[i], StringComparison.Ordinal))
                    {
                        return false;
                    }
                }

                return true;
            }

            public override bool Equals(object? obj) => obj is InstanceKey other && Equals(other);

            public override int GetHashCode()
            {
                int hash = StringComparer.Ordinal.GetHashCode(_resourceName);
                foreach (string? value in _values)
                {
                    hash = unchecked((hash * 31) + (value is null ? 0 : StringComparer.Ordinal.GetHashCode(value)));
                }

                return hash;
            }
        }

        private static void AddPropertyDeltas(
            List<ConfigurationDelta> delta,
            Hashtable source,
            Hashtable destination,
            string resourceName,
            string keyName,
            string keyValue,
            SchemaIndex index,
            string[] globalExclusions,
            IDictionary<string, ResourceCompareParameters>? compareParameters)
        {
            ResourceCompareParameters? overrides = Overrides(resourceName, index, compareParameters);

            string[] excluded = overrides?.ExcludedProperties is { Length: > 0 } resourceExclusions
                ? [.. globalExclusions.Concat(resourceExclusions).Distinct(StringComparer.OrdinalIgnoreCase)]
                : globalExclusions;

            Hashtable desiredValues = destination;
            Hashtable currentValues = source;
            Hashtable valuesToCheck = (Hashtable)destination.Clone();

            if (overrides?.PostProcessing is { } postProcessing)
            {
                desiredValues = (Hashtable)destination.Clone();
                currentValues = (Hashtable)source.Clone();
                Tuple<Hashtable, Hashtable, Hashtable>? processed = postProcessing(
                    desiredValues, currentValues, valuesToCheck, overrides.PostProcessingArgs ?? []);

                if (processed is not null)
                {
                    desiredValues = processed.Item1;
                    currentValues = processed.Item2;
                    valuesToCheck = processed.Item3;
                }
            }

            foreach (string annotationKey in valuesToCheck.Keys.Cast<object>()
                .Select(key => key.ToString())
                .Where(key => key.StartsWith(AnnotationPrefix, StringComparison.OrdinalIgnoreCase))
                .ToArray())
            {
                valuesToCheck.Remove(annotationKey);
            }

            CompareResult result = ResourceComparer.Compare(
                desiredValues,
                currentValues,
                valuesToCheck,
                index,
                resourceName,
                excluded,
                overrides?.IncludedProperties);

            if (result.TestResult)
            {
                return;
            }

            foreach (Hashtable drift in result.DriftInfo)
            {
                string propertyName = drift["PropertyName"]?.ToString() ?? string.Empty;

                ConfigurationDeltaProperty property = new()
                {
                    ParameterName = propertyName,
                    ValueInSource = drift["CurrentValue"],
                    ValueInDestination = drift["DesiredValue"],
                    DeltaValue = drift.ContainsKey("DeltaValue") ? drift["DeltaValue"] : null
                };

                ApplyAnnotation(property, destination, propertyName);

                delta.Add(new ConfigurationDelta
                {
                    ResourceName = resourceName,
                    ResourceInstanceName = source["ResourceInstanceName"]?.ToString(),
                    Key = keyName,
                    KeyValue = keyValue,
                    Properties = [property]
                });
            }
        }

        /// <summary>
        /// Copies a blueprint annotation onto the drift it explains. The comment travels with the
        /// destination resource as "_metadata_&lt;Property&gt;" holding "### Level|Information".
        /// </summary>
        private static void ApplyAnnotation(ConfigurationDeltaProperty property, Hashtable destination, string propertyName)
        {
            if (destination[AnnotationPrefix + propertyName]?.ToString() is not { } annotation)
            {
                return;
            }

            string[] parts = annotation.Split(['|'], 2);
            if (parts.Length < 2)
            {
                return;
            }

            property.MetadataLevel = parts[0].TrimStart('#').Trim();
            property.MetadataInfo = parts[1].Trim();
        }

        /// <summary>
        /// Copies the blueprint annotation of a resource missing from the source onto its presence
        /// delta. The annotation on Ensure wins, then the first annotated key property.
        /// </summary>
        private static void ApplyPresenceAnnotation(ConfigurationDeltaProperty property, Hashtable destination, string[] keys)
        {
            foreach (string propertyName in first.Concat(keys))
            {
                ApplyAnnotation(property, destination, propertyName);
                if (property.MetadataLevel is not null)
                {
                    return;
                }
            }
        }

        private static ResourceCompareParameters? Overrides(
            string resourceName,
            SchemaIndex index,
            IDictionary<string, ResourceCompareParameters>? compareParameters)
        {
            if (compareParameters is not null && compareParameters.TryGetValue(resourceName, out ResourceCompareParameters? supplied))
            {
                return supplied;
            }

            return index.GetCompareParameters(resourceName);
        }

        private static ConfigurationDelta Presence(
            Hashtable resource, string keyName, string keyValue, string inSource, string inDestination)
        {
            return new ConfigurationDelta
            {
                ResourceName = resource["ResourceName"]?.ToString(),
                ResourceInstanceName = resource["ResourceInstanceName"]?.ToString(),
                Key = keyName,
                KeyValue = keyValue,
                Properties =
                [
                    new ConfigurationDeltaProperty
                    {
                        ParameterName = PresenceMarker,
                        ValueInSource = inSource,
                        ValueInDestination = inDestination
                    }
                ]
            };
        }

        private static List<Hashtable> Materialize(IEnumerable<object> resources, HashSet<string> excludedResources)
        {
            List<Hashtable> result = [];

            foreach (object entry in resources)
            {
                if (MemberAccessor.Unwrap(entry) is not Hashtable resource)
                {
                    continue;
                }

                if (resource["ResourceName"]?.ToString() is { } name && excludedResources.Contains(name))
                {
                    continue;
                }

                result.Add(resource);
            }

            return result;
        }

        // The first two keys, which is what the report shows as the identity of an instance.
        private static string KeyName(string[] keys) => string.Join("\\", keys.Take(2));

        private static string KeyValue(Hashtable resource, string[] keys) =>
            string.Join("\\", keys.Select(key => resource[key]?.ToString()));
    }

    /// <summary>
    /// One resource instance's difference between two configurations.
    /// </summary>
    public class ConfigurationDelta
    {
        public string? ResourceName { get; set; }

        public string? ResourceInstanceName { get; set; }

        /// <summary>The property names the instance is identified by, backslash separated.</summary>
        public string? Key { get; set; }

        public string? KeyValue { get; set; }

        public List<ConfigurationDeltaProperty> Properties { get; set; } = [];

        /// <summary>
        /// Projects the entry into the shape PowerShell callers render and serialize.
        /// </summary>
        public Hashtable ToHashtable()
        {
            return new Hashtable(StringComparer.OrdinalIgnoreCase)
            {
                { "ResourceName", ResourceName },
                { "ResourceInstanceName", ResourceInstanceName },
                { "Key", Key },
                { "KeyValue", KeyValue },
                { "Properties", Properties.Select(property => property.ToHashtable()).ToArray() }
            };
        }
    }

    /// <summary>
    /// One differing property, or the presence marker when the resource is missing on a side.
    /// </summary>
    public class ConfigurationDeltaProperty
    {
        public string? ParameterName { get; set; }

        public object? ValueInSource { get; set; }

        public object? ValueInDestination { get; set; }

        /// <summary>Set only for collection drifts, holding the added and removed entries.</summary>
        public object? DeltaValue { get; set; }

        /// <summary>Blueprint severity of the annotated property, when the destination carries one.</summary>
        public string? MetadataLevel { get; set; }

        public string? MetadataInfo { get; set; }

        public Hashtable ToHashtable()
        {
            Hashtable result = new(StringComparer.OrdinalIgnoreCase)
            {
                { "ParameterName", ParameterName },
                { "ValueInSource", ValueInSource },
                { "ValueInDestination", ValueInDestination }
            };

            if (DeltaValue is not null)
            {
                result["DeltaValue"] = DeltaValue;
            }

            if (MetadataLevel is not null)
            {
                result["_Metadata_Level"] = MetadataLevel;
                result["_Metadata_Info"] = MetadataInfo;
            }

            return result;
        }
    }

    /// <summary>
    /// Per-resource overrides of how its instances are compared.
    /// </summary>
    public class ResourceCompareParameters
    {
        public string[]? ExcludedProperties { get; set; }

        public string[]? IncludedProperties { get; set; }

        /// <summary>
        /// Rewrites desired, current and checked values before the diff. Supplied by the resource
        /// itself, so it exists only where a caller can run the resource's own code.
        /// </summary>
        public Func<Hashtable, Hashtable, Hashtable, object[], Tuple<Hashtable, Hashtable, Hashtable>>? PostProcessing { get; set; }

        public object[]? PostProcessingArgs { get; set; }
    }
}
