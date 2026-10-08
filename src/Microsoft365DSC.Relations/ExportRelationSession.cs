using Microsoft365DSC.Utilities;
using System;
using System.Collections.Generic;
using System.Threading;

namespace Microsoft365DSC.Relations
{
    /// <summary>
    /// Holds the relation state for a single export: which instances were produced, which
    /// references they made, and the rewrite of the finished document.
    /// </summary>
    /// <remarks>
    /// <para>
    /// One session replaces the two global collections the export used to accumulate into.
    /// Both grew by array reallocation, so every registration cost more than the one before
    /// it and the dependency phase degraded superlinearly as an export progressed.
    /// </para>
    /// <para>
    /// The session is reached through the static <see cref="Current"/> rather than a
    /// PowerShell variable, because a parallel export runs its resources in a pool of
    /// runspaces and PowerShell variables do not cross runspace boundaries. The assemblies
    /// are loaded once per process, so static state here is visible to every runspace and to
    /// the main thread that later rewrites the document. That makes the runspaces concurrent
    /// writers, so every mutable collection below is guarded.
    /// </para>
    /// </remarks>
    public sealed class ExportRelationSession
    {
        private static ExportRelationSession? _current;

        private readonly RelationIndex _index;
        private readonly DependencyCollector _collector = new();
        private readonly RelationResolver _resolver;
        private readonly List<ExportedInstance> _instances = [];
        private readonly List<string> _warnings = [];

        /// <summary>
        /// Starts a session over a prebuilt relation index.
        /// </summary>
        /// <param name="index">The index built at module load.</param>
        /// <exception cref="ArgumentNullException">The index is null.</exception>
        public ExportRelationSession(RelationIndex index)
        {
            _index = index ?? throw new ArgumentNullException(nameof(index));
            _resolver = new RelationResolver(_index, _collector, _warnings);
        }

        /// <summary>
        /// The session the current export is accumulating into, or null when no export asked
        /// for dependency tracking.
        /// </summary>
        public static ExportRelationSession? Current => Volatile.Read(ref _current);

        /// <summary>
        /// Begins a new export session and publishes it to every runspace in the process.
        /// </summary>
        /// <param name="index">The relation index to resolve against.</param>
        /// <returns>The new session.</returns>
        /// <remarks>
        /// Any previous session is discarded unconditionally, so an export that failed part
        /// way through cannot leak its state into the next one.
        /// </remarks>
        public static ExportRelationSession Start(RelationIndex index)
        {
            ExportRelationSession session = new(index);
            Volatile.Write(ref _current, session);
            return session;
        }

        /// <summary>
        /// Ends the current session and releases the state it accumulated.
        /// </summary>
        public static void Reset()
        {
            Volatile.Write(ref _current, null);
        }

        /// <summary>The number of distinct dependencies discovered so far.</summary>
        public int DependencyCount => _collector.Count;

        /// <summary>The number of exported instances registered so far.</summary>
        public int InstanceCount
        {
            get
            {
                lock (_instances)
                {
                    return _instances.Count;
                }
            }
        }

        /// <summary>Diagnostics gathered while resolving, surfaced as verbose output.</summary>
        public IReadOnlyList<string> Warnings
        {
            get
            {
                lock (_warnings)
                {
                    return _warnings.ToArray();
                }
            }
        }

        /// <summary>
        /// Records an instance that was exported, so references to it resolve to a real
        /// DependsOn entry rather than a generated stub.
        /// </summary>
        /// <param name="resourceName">The resource type.</param>
        /// <param name="instanceName">The unique instance name.</param>
        /// <param name="primaryKey">The instance's primary key value.</param>
        /// <param name="results">
        /// The exported property bag. It is read here and not retained: only the values of
        /// properties that some relation actually references are kept.
        /// </param>
        public void RegisterInstance(string resourceName, string instanceName, string? primaryKey, object? results)
        {
            if (string.IsNullOrEmpty(resourceName) || string.IsNullOrEmpty(instanceName))
            {
                return;
            }

            Dictionary<string, string>? keyValues = null;
            string[] keyProperties = _index.GetTargetKeyProperties(resourceName);

            if (keyProperties.Length > 0 && results is not null)
            {
                foreach (string keyProperty in keyProperties)
                {
                    string? value = MemberAccessor.GetMemberAsString(results, keyProperty);
                    if (value is not null)
                    {
                        keyValues ??= new Dictionary<string, string>(keyProperties.Length, StringComparer.OrdinalIgnoreCase);
                        keyValues[keyProperty] = value;
                    }
                }
            }

            ExportedInstance instance = new(resourceName, instanceName, primaryKey ?? string.Empty, keyValues);
            lock (_instances)
            {
                _instances.Add(instance);
            }
        }

        /// <summary>
        /// Resolves the relations declared for a resource type against one exported instance.
        /// </summary>
        /// <param name="resourceName">The resource type being exported.</param>
        /// <param name="instanceName">The unique instance name.</param>
        /// <param name="results">The exported property bag to read references from.</param>
        public void ResolveRelations(string resourceName, string instanceName, object? results)
        {
            if (string.IsNullOrEmpty(resourceName) || string.IsNullOrEmpty(instanceName))
            {
                return;
            }

            _resolver.Resolve(resourceName, instanceName, results);
        }

        /// <summary>
        /// Registers a dependency directly, bypassing the relation templates.
        /// </summary>
        /// <param name="sourceInstanceName">The referencing instance name.</param>
        /// <param name="sourceResourceName">The referencing resource type.</param>
        /// <param name="targetResourceType">The referenced resource type.</param>
        /// <param name="targetKey">The value identifying the target.</param>
        public void RegisterDependency(
            string sourceInstanceName,
            string sourceResourceName,
            string targetResourceType,
            string targetKey)
        {
            _collector.Add(sourceInstanceName, sourceResourceName, targetResourceType, null, targetKey);
        }

        /// <summary>
        /// Rewrites the exported content with DependsOn declarations and dependency stubs.
        /// </summary>
        /// <param name="content">The concatenated resource blocks.</param>
        /// <param name="stubOptions">Inputs for rendering stub blocks.</param>
        /// <returns>The rewritten content.</returns>
        public string InjectDependsOn(string content, StubBlockOptions stubOptions)
        {
            // Snapshot both collections so a runspace that is still finishing cannot mutate
            // them while the document is being rebuilt.
            ExportedInstance[] instances;
            lock (_instances)
            {
                instances = _instances.ToArray();
            }

            return DependsOnInjector.Inject(content, _collector.GetRecordsSnapshot(), instances, stubOptions);
        }
    }
}
