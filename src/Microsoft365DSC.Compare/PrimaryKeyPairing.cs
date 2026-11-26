using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace Microsoft365DSC.Compare
{
    /// <summary>
    /// Aligns the elements of two complex arrays by the primary keys their CIM class declares.
    /// A drift is then reported against the element that carries it, not against the element
    /// that shares its index.
    /// </summary>
    internal static class PrimaryKeyPairing
    {
        private const char KeySeparator = (char)31;
        private static readonly string NullKeyMarker = ((char)1).ToString();

        public static bool CanPair(object[] items, List<string> primaryKeyNames)
        {
            foreach (object item in items)
            {
                if (item is not Hashtable hash)
                {
                    return false;
                }

                foreach (string primaryKey in primaryKeyNames)
                {
                    if (!hash.ContainsKey(primaryKey) || hash[primaryKey] is null)
                    {
                        return false;
                    }
                }
            }

            return true;
        }

        public static (
            List<(Hashtable desired, Hashtable? matched, int desiredIndex)> pairs,
            List<(Hashtable extra, int currentIndex)> extras)
            Pair(
                object[] desired,
                object[] current,
                List<string> primaryKeyNames)
        {
            Dictionary<string, Queue<int>> currentByKey = new(StringComparer.OrdinalIgnoreCase);
            for (int j = 0; j < current.Length; j++)
            {
                if (current[j] is not Hashtable currentHash)
                {
                    continue;
                }

                string key = PrimaryKeyOf(currentHash, primaryKeyNames);
                if (!currentByKey.TryGetValue(key, out Queue<int> indexes))
                {
                    indexes = new Queue<int>();
                    currentByKey[key] = indexes;
                }

                indexes.Enqueue(j);
            }

            List<(Hashtable desired, Hashtable? matched, int desiredIndex)> pairs = [];
            bool[] consumed = new bool[current.Length];

            for (int i = 0; i < desired.Length; i++)
            {
                if (desired[i] is not Hashtable desiredHash)
                {
                    continue;
                }

                Hashtable? match = null;
                if (currentByKey.TryGetValue(PrimaryKeyOf(desiredHash, primaryKeyNames), out Queue<int> candidates) && candidates.Count > 0)
                {
                    int j = candidates.Dequeue();
                    consumed[j] = true;
                    match = (Hashtable)current[j];
                }

                pairs.Add((desiredHash, match, i));
            }

            List<(Hashtable extra, int currentIndex)> extras = [];
            for (int j = 0; j < current.Length; j++)
            {
                if (!consumed[j] && current[j] is Hashtable extraHash)
                {
                    extras.Add((extraHash, j));
                }
            }

            return (pairs, extras);
        }

        public static HashSet<string> SkippedKeys(
            List<string> primaryKeyNames,
            HashSet<string>? includedSet,
            bool isIntunePolicyAssignment)
        {
            HashSet<string> skipped = new(StringComparer.OrdinalIgnoreCase);
            foreach (string primaryKey in primaryKeyNames)
            {
                if (isIntunePolicyAssignment && string.Equals(primaryKey, "dataType", StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                if (includedSet is not null && includedSet.Contains(primaryKey))
                {
                    continue;
                }

                skipped.Add(primaryKey);
            }

            return skipped;
        }

        private static string PrimaryKeyOf(Hashtable hash, List<string> primaryKeyNames)
        {
            if (primaryKeyNames.Count == 1)
            {
                return GetStringValue(hash, primaryKeyNames[0]) ?? NullKeyMarker;
            }

            StringBuilder builder = new();
            foreach (string primaryKey in primaryKeyNames)
            {
                if (builder.Length > 0)
                {
                    builder.Append(KeySeparator);
                }

                builder.Append(GetStringValue(hash, primaryKey) ?? NullKeyMarker);
            }

            return builder.ToString();
        }

        private static string? GetStringValue(Hashtable hash, string key)
        {
            if (hash is null || !hash.ContainsKey(key))
            {
                return null;
            }

            return hash[key]?.ToString();
        }
    }
}
