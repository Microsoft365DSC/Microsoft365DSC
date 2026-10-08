using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;

namespace Microsoft365DSC.Reporting.Configuration
{
    /// <summary>
    /// Supplies the properties that identify a resource instance, used to recognize duplicates.
    /// </summary>
    public interface IMandatoryPropertySource
    {
        /// <summary>
        /// Returns the mandatory properties of a resource type.
        /// </summary>
        /// <param name="resourceType">The resource type name.</param>
        /// <returns>The property names, empty when the type has none.</returns>
        IReadOnlyCollection<string> GetMandatoryProperties(string resourceType);
    }

    /// <summary>
    /// Supplies mandatory properties from a dictionary that maps a resource type to its property
    /// names.
    /// </summary>
    public sealed class DictionaryMandatoryPropertySource : IMandatoryPropertySource
    {
        private readonly Dictionary<string, string[]> _properties = new(StringComparer.OrdinalIgnoreCase);

        /// <summary>
        /// Creates a source over a dictionary of resource type to property names.
        /// </summary>
        /// <param name="propertiesByResourceType">The property names, keyed by resource type.</param>
        public DictionaryMandatoryPropertySource(IDictionary propertiesByResourceType)
        {
            foreach (DictionaryEntry entry in propertiesByResourceType)
            {
                object? value = ConfigurationResource.Unwrap(entry.Value);
                IEnumerable<object?> names = value is IEnumerable collection and not string
                    ? ConfigurationResource.Items(collection)
                    : [value];
                _properties[Convert.ToString(entry.Key) ?? string.Empty] = names
                    .Select(name => Convert.ToString(name, CultureInfo.InvariantCulture) ?? string.Empty)
                    .Where(name => name.Length > 0)
                    .ToArray();
            }
        }

        /// <inheritdoc />
        public IReadOnlyCollection<string> GetMandatoryProperties(string resourceType)
        {
            return _properties.TryGetValue(resourceType, out string[]? names) ? names : [];
        }
    }

    internal static class DuplicateSuppressor
    {
        private const string NullLiteral = "$null";

        private static readonly Regex DuplicateSuffix = new("-(\\d+)$", RegexOptions.Compiled);

        public static List<ConfigurationResource> Filter(
            IEnumerable<ConfigurationResource> resources,
            IMandatoryPropertySource mandatoryProperties,
            Action<string> warn)
        {
            HashSet<string> seenSignatures = new(StringComparer.OrdinalIgnoreCase);
            List<ConfigurationResource> kept = [];

            foreach (ConfigurationResource resource in resources)
            {
                string? signature = GetSignature(resource, mandatoryProperties.GetMandatoryProperties(resource.Type));
                if (signature is null || seenSignatures.Add(signature))
                {
                    kept.Add(resource);
                    continue;
                }

                warn($"Skipping duplicate resource instance '{resource.InstanceName}' of type '{resource.Type}'.");
            }

            return kept;
        }

        private static string? GetSignature(
            ConfigurationResource resource,
            IReadOnlyCollection<string> mandatoryProperties)
        {
            if (mandatoryProperties.Count == 0)
            {
                return null;
            }

            List<string> pairs = [];
            foreach (string property in mandatoryProperties)
            {
                if (!resource.TryGetProperty(property, out object? value))
                {
                    return null;
                }

                pairs.Add($"{property}={Normalize(value)}");
            }

            pairs.Sort(StringComparer.OrdinalIgnoreCase);
            return string.Join("\n", resource.Type, GetBaseName(resource.InstanceName), string.Join("|", pairs));
        }

        private static string GetBaseName(string instanceName)
        {
            Match match = DuplicateSuffix.Match(instanceName);
            return match.Success && int.TryParse(match.Groups[1].Value, out int number) && number >= 2
                ? instanceName.Substring(0, match.Index)
                : instanceName;
        }

        private static string Normalize(object? value)
        {
            return value switch
            {
                null => string.Empty,
                string text when string.Equals(text, NullLiteral, StringComparison.OrdinalIgnoreCase) => string.Empty,
                string text => text,
                IDictionary dictionary => "{" + string.Join(";", dictionary.Keys
                    .Cast<object>()
                    .Select(key => $"{key}={Normalize(ConfigurationResource.Unwrap(dictionary[key]))}")
                    .OrderBy(pair => pair, StringComparer.OrdinalIgnoreCase)) + "}",
                IEnumerable collection => string.Join(",", ConfigurationResource.Items(collection)
                    .Select(Normalize)
                    .OrderBy(item => item, StringComparer.OrdinalIgnoreCase)),
                _ => Convert.ToString(value, CultureInfo.InvariantCulture) ?? string.Empty
            };
        }
    }
}
