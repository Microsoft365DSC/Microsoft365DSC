using System;
using System.Collections.Generic;

namespace Microsoft365DSC.Intune
{
    /// <summary>
    /// Process-wide cache of the tenant's Intune role scope tags, holding the display name of every
    /// tag id and the ids behind every display name.
    /// </summary>
    public static class RoleScopeTagCache
    {
        private static readonly Dictionary<string, string> _byId = new(StringComparer.OrdinalIgnoreCase);
        private static readonly Dictionary<string, List<string>> _byName = new(StringComparer.OrdinalIgnoreCase);
        private static readonly object _lock = new();
        private static bool _isPopulated;
        private static bool _isAvailable = true;

        /// <summary>Whether a load has already been attempted, successfully or not.</summary>
        public static bool IsPopulated
        {
            get { lock (_lock) { return _isPopulated; } }
        }

        /// <summary>Whether the tags could be read. False once a load has failed.</summary>
        public static bool IsAvailable
        {
            get { lock (_lock) { return _isAvailable; } }
        }

        /// <summary>Number of cached tags.</summary>
        public static int Count
        {
            get { lock (_lock) { return _byId.Count; } }
        }

        /// <summary>
        /// Stores every tag of the tenant. The first call wins, later ones are ignored until
        /// <see cref="Reset"/>.
        /// </summary>
        /// <param name="tags">The role scope tags as Graph returned them.</param>
        /// <param name="idSelector">Reads the id off one tag.</param>
        /// <param name="nameSelector">Reads the display name off one tag.</param>
        public static void Populate(
            IEnumerable<object>? tags,
            Func<object, string> idSelector,
            Func<object, string> nameSelector)
        {
            if (idSelector is null)
            {
                throw new ArgumentNullException(nameof(idSelector));
            }

            if (nameSelector is null)
            {
                throw new ArgumentNullException(nameof(nameSelector));
            }

            lock (_lock)
            {
                if (_isPopulated)
                {
                    return;
                }

                _isPopulated = true;
                _isAvailable = true;

                if (tags is null)
                {
                    return;
                }

                foreach (var tag in tags)
                {
                    if (tag is null)
                    {
                        continue;
                    }

                    string id = idSelector(tag);
                    string name = nameSelector(tag);
                    if (string.IsNullOrEmpty(id) || string.IsNullOrEmpty(name))
                    {
                        continue;
                    }

                    _byId[id] = name;

                    // A display name is not unique in Intune, so a name keeps every id it covers.
                    if (!_byName.TryGetValue(name, out var ids))
                    {
                        ids = new List<string>();
                        _byName[name] = ids;
                    }
                    ids.Add(id);
                }
            }
        }

        /// <summary>
        /// Records that the tags could not be read, so the rest of the run passes values through
        /// instead of repeating a call that has already failed.
        /// </summary>
        public static void MarkUnavailable()
        {
            lock (_lock)
            {
                _isPopulated = true;
                _isAvailable = false;
                _byId.Clear();
                _byName.Clear();
            }
        }

        /// <summary>Returns the display name of a tag id.</summary>
        public static bool TryGetName(string id, out string? name)
        {
            name = null;
            if (string.IsNullOrEmpty(id))
            {
                return false;
            }

            lock (_lock)
            {
                return _byId.TryGetValue(id, out name);
            }
        }

        /// <summary>Returns every tag id carrying a display name.</summary>
        public static bool TryGetIds(string displayName, out string[]? ids)
        {
            ids = null;
            if (string.IsNullOrEmpty(displayName))
            {
                return false;
            }

            lock (_lock)
            {
                if (!_byName.TryGetValue(displayName, out var matches))
                {
                    return false;
                }

                ids = matches.ToArray();
                return true;
            }
        }

        /// <summary>Clears every cached tag and allows the next load to run.</summary>
        public static void Reset()
        {
            lock (_lock)
            {
                _byId.Clear();
                _byName.Clear();
                _isPopulated = false;
                _isAvailable = true;
            }
        }
    }
}
