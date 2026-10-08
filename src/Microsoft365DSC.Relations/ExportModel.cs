using System;
using System.Collections.Generic;

namespace Microsoft365DSC.Relations
{
    /// <summary>
    /// One discovered reference from an exported instance to a target resource.
    /// </summary>
    public sealed class DependencyRecord
    {
        internal DependencyRecord(
            string sourceInstanceName,
            string sourceResourceName,
            string targetResourceType,
            string? targetKeyProperty,
            string targetKey)
        {
            SourceInstanceName = sourceInstanceName;
            SourceResourceName = sourceResourceName;
            TargetResourceType = targetResourceType;
            TargetKeyProperty = targetKeyProperty;
            TargetKey = targetKey;
        }

        /// <summary>The instance name of the resource that holds the reference.</summary>
        public string SourceInstanceName { get; }

        /// <summary>The resource type that holds the reference.</summary>
        public string SourceResourceName { get; }

        /// <summary>The resource type being referenced.</summary>
        public string TargetResourceType { get; }

        /// <summary>The property on the target that <see cref="TargetKey"/> should match, or null.</summary>
        public string? TargetKeyProperty { get; }

        /// <summary>The value identifying the target instance.</summary>
        public string TargetKey { get; }

        /// <summary>The DSC reference for the source, in <c>[ResourceName]InstanceName</c> form.</summary>
        public string SourceReference => $"[{SourceResourceName}]{SourceInstanceName}";
    }

    /// <summary>
    /// A resource instance that was actually exported, recorded so references to it can be
    /// resolved to a real DependsOn entry instead of a generated stub.
    /// </summary>
    /// <remarks>
    /// Only the fields needed for dependency resolution are kept. The full property bag used
    /// to be retained for every instance for the lifetime of the export, which cost a great
    /// deal of memory on large tenants and was never read.
    /// </remarks>
    public sealed class ExportedInstance
    {
        internal ExportedInstance(
            string resourceName,
            string instanceName,
            string primaryKey,
            Dictionary<string, string>? keyValues)
        {
            ResourceName = resourceName;
            InstanceName = instanceName;
            PrimaryKey = primaryKey;
            KeyValues = keyValues;
        }

        /// <summary>The resource type.</summary>
        public string ResourceName { get; }

        /// <summary>The generated, unique instance name.</summary>
        public string InstanceName { get; }

        /// <summary>The instance's primary key value.</summary>
        public string PrimaryKey { get; }

        /// <summary>
        /// Values of the properties that other resources reference this one by, captured at
        /// registration so the property bag itself need not be retained.
        /// </summary>
        /// <remarks>
        /// Null when no relation targets this resource type by a named property. Populated from
        /// <see cref="RelationIndex.GetTargetKeyProperties"/>, so it holds at most a couple of
        /// entries rather than the whole export result.
        /// </remarks>
        public Dictionary<string, string>? KeyValues { get; }

        /// <summary>The DSC reference for this instance, in <c>[ResourceName]InstanceName</c> form.</summary>
        public string Reference => $"[{ResourceName}]{InstanceName}";
    }

    /// <summary>
    /// Accumulates dependency records, discarding duplicates as they arrive.
    /// </summary>
    /// <remarks>
    /// Deduplicating at registration matters as much as the storage change: a value such as a
    /// shared role scope tag is referenced by nearly every policy, so the same record was
    /// previously appended thousands of times and only collapsed much later.
    /// </remarks>
    internal sealed class DependencyCollector
    {
        /// <summary>
        /// Joins the parts of a composite key. A control character is used so that values
        /// containing the more obvious delimiters cannot collide, for example a display name
        /// that itself contains a pipe.
        /// </summary>
        internal const string KeySeparator = "\u001F";

        private readonly List<DependencyRecord> _records = [];
        private readonly HashSet<string> _seen = new(StringComparer.OrdinalIgnoreCase);
        private readonly object _gate = new();

        /// <summary>The number of distinct dependencies recorded.</summary>
        internal int Count
        {
            get
            {
                lock (_gate)
                {
                    return _records.Count;
                }
            }
        }

        /// <summary>
        /// Takes a copy of the recorded dependencies.
        /// </summary>
        /// <returns>A snapshot, safe to enumerate while other threads keep recording.</returns>
        internal IReadOnlyList<DependencyRecord> GetRecordsSnapshot()
        {
            lock (_gate)
            {
                return _records.ToArray();
            }
        }

        /// <summary>
        /// Records a dependency unless an identical one was already recorded.
        /// </summary>
        /// <param name="sourceInstanceName">The referencing instance name.</param>
        /// <param name="sourceResourceName">The referencing resource type.</param>
        /// <param name="targetResourceType">The referenced resource type.</param>
        /// <param name="targetKeyProperty">The property the key matches on the target, or null.</param>
        /// <param name="targetKey">The value identifying the target.</param>
        internal void Add(
            string sourceInstanceName,
            string sourceResourceName,
            string targetResourceType,
            string? targetKeyProperty,
            string targetKey)
        {
            if (string.IsNullOrEmpty(targetKey))
            {
                return;
            }

            string identity = string.Join(
                KeySeparator,
                sourceResourceName,
                sourceInstanceName,
                targetResourceType,
                targetKeyProperty ?? string.Empty,
                targetKey);

            // A parallel export has one runspace per resource writing here concurrently. The
            // de-duplication test and the append have to be one atomic step, otherwise two
            // threads can both observe "not seen" and record the same dependency twice.
            lock (_gate)
            {
                if (_seen.Add(identity))
                {
                    _records.Add(new DependencyRecord(
                        sourceInstanceName, sourceResourceName, targetResourceType, targetKeyProperty, targetKey));
                }
            }
        }
    }
}
