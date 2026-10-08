using System;
using System.Collections;
using System.Management.Automation;

namespace Microsoft365DSC.Utilities
{
    /// <summary>
    /// Reads named members off the loosely-typed values that flow between PowerShell and C#.
    ///
    /// A single property can arrive as a <see cref="Hashtable"/>, a <see cref="PSObject"/>
    /// wrapping a PSCustomObject, a CimInstance, or a plain CLR object. Rather than
    /// branching on each of those at every call site, everything funnels through here.
    /// CimInstance is handled without referencing Microsoft.Management.Infrastructure,
    /// because PowerShell's own object adapter surfaces its properties through PSObject.
    /// </summary>
    public static class MemberAccessor
    {
        /// <summary>
        /// Unwraps a <see cref="PSObject"/> to the object it wraps, leaving anything else alone.
        /// </summary>
        /// <param name="value">The value to unwrap.</param>
        /// <returns>The underlying object, or the original value when it is not a PSObject.</returns>
        /// <remarks>
        /// A PSCustomObject is deliberately not unwrapped. Its properties live on the PSObject
        /// wrapper rather than on the base object, so unwrapping one would discard everything
        /// it carries and make every member lookup fail.
        /// </remarks>
        public static object? Unwrap(object? value)
        {
            if (value is PSObject psObject && psObject.BaseObject is not PSCustomObject)
            {
                return psObject.BaseObject;
            }

            return value;
        }

        /// <summary>
        /// Attempts to read a named member from a value.
        /// </summary>
        /// <param name="source">The object to read from. May be null.</param>
        /// <param name="name">The member name. Matching is case-insensitive.</param>
        /// <param name="value">Receives the member value, already unwrapped.</param>
        /// <returns>
        /// True when the member exists. A member that exists but is null still returns true,
        /// so callers can tell "absent" apart from "present but empty".
        /// </returns>
        public static bool TryGetMember(object? source, string name, out object? value)
        {
            value = null;
            object? target = Unwrap(source);
            if (target is null || string.IsNullOrEmpty(name))
            {
                return false;
            }

            if (target is IDictionary dictionary)
            {
                return TryGetDictionaryEntry(dictionary, name, out value);
            }

            // Covers PSCustomObject, CimInstance and ordinary CLR objects in one path:
            // PSObject's adapter exposes all three through the same property collection.
            try
            {
                PSPropertyInfo? property = PSObject.AsPSObject(target).Properties[name];
                if (property is null)
                {
                    return false;
                }

                value = Unwrap(property.Value);
                return true;
            }
            catch (ExtendedTypeSystemException)
            {
                // Property access can throw for members the adapter cannot materialize.
                return false;
            }
        }

        /// <summary>
        /// Looks a key up in a dictionary, preferring the dictionary's own comparer and
        /// falling back to a case-insensitive scan for dictionaries that are ordinal.
        /// </summary>
        /// <param name="dictionary">The dictionary to search.</param>
        /// <param name="name">The key to find.</param>
        /// <param name="value">Receives the entry value, already unwrapped.</param>
        /// <returns>True when the key exists.</returns>
        private static bool TryGetDictionaryEntry(IDictionary dictionary, string name, out object? value)
        {
            value = null;

            // PowerShell hashtables are already case-insensitive, so this hits first in
            // the common case and the scan below never runs.
            if (dictionary.Contains(name))
            {
                value = Unwrap(dictionary[name]);
                return true;
            }

            foreach (DictionaryEntry entry in dictionary)
            {
                if (entry.Key is string key && string.Equals(key, name, StringComparison.OrdinalIgnoreCase))
                {
                    value = Unwrap(entry.Value);
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Reads a member and renders it as a string, returning null when the member is
        /// absent, null, or renders empty.
        /// </summary>
        /// <param name="source">The object to read from.</param>
        /// <param name="name">The member name.</param>
        /// <returns>The member value as a string, or null.</returns>
        public static string? GetMemberAsString(object? source, string name)
        {
            if (!TryGetMember(source, name, out object? value) || value is null)
            {
                return null;
            }

            string text = value.ToString();
            return string.IsNullOrEmpty(text) ? null : text;
        }
    }
}
