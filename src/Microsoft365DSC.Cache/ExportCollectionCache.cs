using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Management.Automation;
using System.Threading;
using Microsoft365DSC.Utilities;

namespace Microsoft365DSC.Cache
{
    /// <summary>
    /// Thread-safe, export-scoped cache of whole Microsoft Graph collections, filtered client-side on
    /// '@odata.type'. Disabled outside Export-M365DSCConfiguration. Entries are released when their last
    /// registered consumer completes.
    /// </summary>
    public static class ExportCollectionCache
    {
        private sealed class Entry
        {
            public object[]? Items;
            public bool Populated;
            public int Consumers;
        }

        private static readonly ConcurrentDictionary<string, Entry> _entries = new(StringComparer.OrdinalIgnoreCase);
        private static readonly object _lock = new();
        private static volatile bool _enabled;

        /// <summary>Whether an export session has enabled the cache.</summary>
        public static bool IsEnabled => _enabled;

        public static void Enable()
        {
            _enabled = true;
        }

        public static void Disable()
        {
            _enabled = false;
        }

        /// <summary>Clears every entry and disables the cache.</summary>
        public static void Reset()
        {
            lock (_lock)
            {
                _entries.Clear();
                _enabled = false;
            }
        }

        /// <summary>Keys currently tracked.</summary>
        public static string[] Keys
        {
            get
            {
                var keys = new List<string>(_entries.Keys);
                return keys.ToArray();
            }
        }

        /// <summary>Returns the cached items when enabled and populated.</summary>
        public static bool TryGet(string key, out object[]? items)
        {
            items = null;
            if (!_enabled || string.IsNullOrEmpty(key))
            {
                return false;
            }

            if (_entries.TryGetValue(key, out var entry) && entry.Populated)
            {
                items = entry.Items;
                return true;
            }

            return false;
        }

        /// <summary>Whether the caller should download the whole collection.</summary>
        public static bool ShouldPopulate(string key)
        {
            if (!_enabled || string.IsNullOrEmpty(key))
            {
                return false;
            }

            return !_entries.TryGetValue(key, out var entry) || !entry.Populated;
        }

        /// <summary>Stores the collection; first writer wins. Returns whether the items are cached.</summary>
        public static bool TrySet(string key, object[]? items)
        {
            if (!_enabled || string.IsNullOrEmpty(key) || items is null)
            {
                return false;
            }

            var entry = _entries.GetOrAdd(key, _ => new Entry());
            lock (_lock)
            {
                if (!entry.Populated)
                {
                    entry.Items = items;
                    entry.Populated = true;
                }

                return true;
            }
        }

        /// <summary>Cached items matching the include list and not the exclude list, or null when not served from the cache.</summary>
        public static object[]? GetByODataType(string key, string[]? include, string[]? exclude) =>
            TryGet(key, out var items)
                ? FilterByODataType(items!, include, exclude)
                : null;

        /// <summary>Filters items on their top-level '@odata.type'. An empty include list matches every item.</summary>
        public static object[] FilterByODataType(object[]? items, string[]? include, string[]? exclude)
        {
            if (items is null || items.Length == 0)
            {
                return [];
            }

            var includeSet = NormalizeSet(include);
            var excludeSet = NormalizeSet(exclude);
            var result = new List<object>(items.Length);
            foreach (var item in items)
            {
                string? type = NormalizeODataType(GetODataType(item));
                if (excludeSet.Count > 0 && type != null && excludeSet.Contains(type))
                {
                    continue;
                }

                if (includeSet.Count == 0 || (type != null && includeSet.Contains(type)))
                {
                    result.Add(item);
                }
            }

            return result.ToArray();
        }

        /// <summary>Filters items on a top-level property. An empty property name or value list matches every item.</summary>
        public static object[] FilterByProperty(object[]? items, string? propertyName, string[]? values)
        {
            if (items is null || items.Length == 0)
            {
                return [];
            }

            if (string.IsNullOrEmpty(propertyName))
            {
                return items;
            }

            var wanted = NormalizeValueSet(values);
            if (wanted.Count == 0)
            {
                return items;
            }

            var result = new List<object>(items.Length);
            foreach (var item in items)
            {
                if (MemberAccessor.TryGetMember(item, propertyName!, out object? raw) &&
                    raw is string value &&
                    wanted.Contains(value))
                {
                    result.Add(item);
                }
            }

            return result.ToArray();
        }

        /// <summary>Records how many resources will consume the collection.</summary>
        public static void RegisterConsumers(string key, int count)
        {
            if (string.IsNullOrEmpty(key) || count <= 0)
            {
                return;
            }

            var entry = _entries.GetOrAdd(key, _ => new Entry());
            Interlocked.Exchange(ref entry.Consumers, count);
        }

        /// <summary>Decrements the consumer count and drops the entry at zero. Returns the remaining count.</summary>
        public static int Release(string key)
        {
            if (string.IsNullOrEmpty(key) || !_entries.TryGetValue(key, out var entry))
            {
                return 0;
            }

            int remaining = Interlocked.Decrement(ref entry.Consumers);
            if (remaining <= 0)
            {
                _entries.TryRemove(key, out _);
            }

            return Math.Max(remaining, 0);
        }

        public static int GetConsumerCount(string key) =>
            !string.IsNullOrEmpty(key) && _entries.TryGetValue(key, out var entry) ? entry.Consumers : 0;

        /// <summary>Strips the leading '#' and whitespace. Returns null for empty input.</summary>
        public static string? NormalizeODataType(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return null;
            }

            string trimmed = value!.Trim();
            if (trimmed.StartsWith("#", StringComparison.Ordinal))
            {
                trimmed = trimmed.Substring(1);
            }

            return trimmed;
        }

        /// <summary>Reads the top-level '@odata.type' of a hashtable or PSObject item.</summary>
        public static string? GetODataType(object? item) => MemberAccessor.GetMemberAsString(item, "@odata.type");

        private static HashSet<string> NormalizeValueSet(string[]? values)
        {
            var set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (values is null)
            {
                return set;
            }

            foreach (var value in values)
            {
                if (!string.IsNullOrWhiteSpace(value))
                {
                    set.Add(value.Trim());
                }
            }

            return set;
        }

        private static HashSet<string> NormalizeSet(string[]? values)
        {
            var set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (values is null)
            {
                return set;
            }

            foreach (var value in values)
            {
                string? normalized = NormalizeODataType(value);
                if (normalized != null)
                {
                    set.Add(normalized);
                }
            }

            return set;
        }
    }
}
