using System;
using System.Collections.Concurrent;
using System.Collections.Generic;

namespace Microsoft365DSC.Intune
{
    /// <summary>
    /// A thread-safe cache for storing configuration policies by their template IDs.
    /// </summary>
    public static class ConfigurationPolicyCache
    {
        private static readonly ConcurrentDictionary<string, object[]> _cache = new();
        private static bool _isPopulated;
        private static readonly object _lock = new();

        public static void Populate(IEnumerable<object>? allPolicies, Func<object, string> templateIdSelector)
        {
            lock (_lock)
            {
                if (_isPopulated)
                    return;

                if (allPolicies is null)
                {
                    _isPopulated = true;
                    return;
                }

                var grouped = new Dictionary<string, List<object>>(StringComparer.OrdinalIgnoreCase);
                foreach (var policy in allPolicies)
                {
                    string templateId = templateIdSelector(policy);
                    if (string.IsNullOrEmpty(templateId))
                        continue;

                    if (!grouped.TryGetValue(templateId, out var policies))
                    {
                        policies = [];
                        grouped[templateId] = policies;
                    }
                    policies.Add(policy);
                }

                foreach (var entry in grouped)
                {
                    _cache[entry.Key] = entry.Value.ToArray();
                }
                _isPopulated = true;
            }
        }

        public static object[]? GetByTemplateId(string templateId) =>
            _cache.TryGetValue(templateId, out var policies) ? policies : null;

        public static void Reset()
        {
            lock (_lock) { _cache.Clear(); _isPopulated = false; }
        }
    }
}
