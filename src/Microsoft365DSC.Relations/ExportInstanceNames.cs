using System;
using System.Collections.Generic;
using System.Globalization;

namespace Microsoft365DSC.Relations
{
    /// <summary>
    /// Hands out unique DSC instance names for the duration of an export.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Two resources can produce the same natural instance name, so the second and later ones
    /// get a numeric suffix. This used to live in PowerShell global variables, which are
    /// per-runspace: during a parallel export each runspace kept its own set of claimed names
    /// and could not see the others'. Static state on the assembly is shared across the whole
    /// process, so every runspace draws from one registry.
    /// </para>
    /// <para>
    /// Reservation is a single locked operation rather than a separate "is it taken" test
    /// followed by a claim, because the two-step form lets two callers agree that a name is
    /// free and then both take it.
    /// </para>
    /// <para>
    /// This is not relation-specific, but it is export-scoped shared state used from the same
    /// code path as the relation session, and it did not warrant an assembly of its own.
    /// </para>
    /// </remarks>
    public static class ExportInstanceNames
    {
        private static readonly object Gate = new();

        private static readonly HashSet<string> Claimed = new(StringComparer.OrdinalIgnoreCase);

        /// <summary>
        /// The next suffix to try for a base name, so a name claimed many times does not
        /// re-probe from the start on every occurrence.
        /// </summary>
        private static readonly Dictionary<string, int> NextSuffix = new(StringComparer.OrdinalIgnoreCase);

        /// <summary>
        /// Claims a unique instance name, appending a numeric suffix when the name is taken.
        /// </summary>
        /// <param name="baseName">The natural instance name.</param>
        /// <returns>
        /// <paramref name="baseName"/> when it was still free, otherwise the name with the
        /// lowest free suffix appended.
        /// </returns>
        public static string Reserve(string baseName)
        {
            if (string.IsNullOrEmpty(baseName))
            {
                return baseName;
            }

            lock (Gate)
            {
                if (Claimed.Add(baseName))
                {
                    return baseName;
                }

                int suffix = NextSuffix.TryGetValue(baseName, out int last) ? last : 2;

                string candidate;
                do
                {
                    candidate = baseName + "-" + suffix.ToString(CultureInfo.InvariantCulture);
                    suffix++;
                }
                while (!Claimed.Add(candidate));

                NextSuffix[baseName] = suffix;
                return candidate;
            }
        }

        /// <summary>
        /// Forgets every claimed name, so a new export starts from a clean registry.
        /// </summary>
        public static void Reset()
        {
            lock (Gate)
            {
                Claimed.Clear();
                NextSuffix.Clear();
            }
        }

        /// <summary>The number of names claimed so far. Intended for diagnostics and tests.</summary>
        public static int Count
        {
            get
            {
                lock (Gate)
                {
                    return Claimed.Count;
                }
            }
        }
    }
}
