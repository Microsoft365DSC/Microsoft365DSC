using System;
using Microsoft365DSC.Cache;
using System.Collections.Concurrent;

namespace Microsoft365DSC.Intune
{
    /// <summary>
    /// Export-scoped cache of Entra groups resolved while converting Intune assignments. Active only
    /// while <see cref="ExportCollectionCache.IsEnabled"/>; misses are never stored.
    /// </summary>
    public static class IntuneGroupCache
    {
        private static readonly ConcurrentDictionary<string, object> _byId = new(StringComparer.OrdinalIgnoreCase);
        private static readonly ConcurrentDictionary<string, object[]> _byName = new(StringComparer.OrdinalIgnoreCase);

        /// <summary>Whether an export session has enabled the export caches.</summary>
        public static bool IsEnabled => ExportCollectionCache.IsEnabled;

        /// <summary>Number of cached ids and names.</summary>
        public static int Count => _byId.Count + _byName.Count;

        /// <summary>Clears every cached group.</summary>
        public static void Reset()
        {
            _byId.Clear();
            _byName.Clear();
        }

        /// <summary>Returns the cached group for an id when enabled and present.</summary>
        public static bool TryGetById(string groupId, out object? group)
        {
            group = null;
            return IsEnabled && !string.IsNullOrEmpty(groupId) && _byId.TryGetValue(groupId, out group);
        }

        /// <summary>Stores a resolved group by id; null results are ignored.</summary>
        public static void SetById(string groupId, object? group)
        {
            if (IsEnabled && !string.IsNullOrEmpty(groupId) && group is not null)
            {
                _byId[groupId] = group;
            }
        }

        /// <summary>Returns the cached groups for a display name when enabled and present.</summary>
        public static bool TryGetByName(string displayName, out object[]? groups)
        {
            groups = null;
            return IsEnabled && !string.IsNullOrEmpty(displayName) && _byName.TryGetValue(displayName, out groups);
        }

        /// <summary>Stores the groups matching a display name; null or empty results are ignored.</summary>
        public static void SetByName(string displayName, object[]? groups)
        {
            if (IsEnabled && !string.IsNullOrEmpty(displayName) && groups is { Length: > 0 })
            {
                _byName[displayName] = groups;
            }
        }
    }
}
