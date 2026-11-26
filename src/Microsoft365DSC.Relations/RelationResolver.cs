using Microsoft365DSC.Utilities;
using System;
using System.Collections;
using System.Collections.Generic;

namespace Microsoft365DSC.Relations
{
    /// <summary>
    /// Walks an exported resource's property bag along each relation's property path and
    /// records the references it finds.
    /// </summary>
    internal sealed class RelationResolver
    {
        private readonly RelationIndex _index;
        private readonly DependencyCollector _collector;
        private readonly List<string> _warnings;

        internal RelationResolver(RelationIndex index, DependencyCollector collector, List<string> warnings)
        {
            _index = index;
            _collector = collector;
            _warnings = warnings;
        }

        /// <summary>
        /// Resolves every relation declared for a resource type against one exported instance.
        /// </summary>
        /// <param name="resourceName">The resource type being exported.</param>
        /// <param name="instanceName">The unique instance name assigned to it.</param>
        /// <param name="results">The exported property bag.</param>
        internal void Resolve(string resourceName, string instanceName, object? results)
        {
            RelationDefinition[] relations = _index.GetRelations(resourceName);
            if (relations.Length == 0 || results is null)
            {
                return;
            }

            foreach (RelationDefinition relation in relations)
            {
                if (TryResolvePath(results, relation.PropertyPath, out object? value))
                {
                    RegisterValue(resourceName, instanceName, relation, value);
                }
            }
        }

        /// <summary>
        /// Follows a dotted property path, fanning out across collections along the way.
        /// </summary>
        /// <param name="root">The property bag to start from.</param>
        /// <param name="path">The path segments.</param>
        /// <param name="value">Receives the resolved value.</param>
        /// <returns>False when any segment is missing or resolves to nothing.</returns>
        private static bool TryResolvePath(object? root, string[] path, out object? value)
        {
            object? current = root;

            foreach (string segment in path)
            {
                if (current is null)
                {
                    value = null;
                    return false;
                }

                object? unwrapped = MemberAccessor.Unwrap(current);

                // A dictionary is itself enumerable, so it has to be tested first or a
                // hashtable-valued property would be walked as a sequence of DictionaryEntry
                // objects and no member would ever be found on it.
                if (unwrapped is IDictionary || unwrapped is string || unwrapped is not IEnumerable)
                {
                    if (!MemberAccessor.TryGetMember(unwrapped, segment, out current))
                    {
                        value = null;
                        return false;
                    }

                    continue;
                }

                // Mirrors PowerShell member enumeration: reading a property off a collection
                // yields that property from each element, flattened one level. The flattening
                // matters for nested paths such as Assignments.Assignment, where each element
                // holds a collection of its own.
                List<object?> collected = [];
                foreach (object? item in (IEnumerable)unwrapped)
                {
                    if (!MemberAccessor.TryGetMember(item, segment, out object? itemValue) || itemValue is null)
                    {
                        continue;
                    }

                    if (itemValue is not string && itemValue is not IDictionary && itemValue is IEnumerable nested)
                    {
                        foreach (object? element in nested)
                        {
                            object? unwrappedElement = MemberAccessor.Unwrap(element);
                            if (unwrappedElement is not null)
                            {
                                collected.Add(unwrappedElement);
                            }
                        }
                    }
                    else
                    {
                        collected.Add(itemValue);
                    }
                }

                if (collected.Count == 0)
                {
                    value = null;
                    return false;
                }

                current = collected;
            }

            value = current;
            return current is not null;
        }

        /// <summary>
        /// Records dependencies for a resolved property value, dispatching on its shape.
        /// </summary>
        /// <param name="resourceName">The source resource type.</param>
        /// <param name="instanceName">The source instance name.</param>
        /// <param name="relation">The relation being applied.</param>
        /// <param name="value">The resolved value.</param>
        private void RegisterValue(string resourceName, string instanceName, RelationDefinition relation, object? value)
        {
            object? unwrapped = MemberAccessor.Unwrap(value);
            if (unwrapped is null)
            {
                return;
            }

            // A scalar names the target key directly.
            if (unwrapped is string || unwrapped is ValueType)
            {
                RegisterScalar(resourceName, instanceName, relation, unwrapped);
                return;
            }

            // Ordered before IEnumerable: see the note in TryResolvePath.
            if (unwrapped is IDictionary)
            {
                RegisterComplexItem(resourceName, instanceName, relation, unwrapped);
                return;
            }

            if (unwrapped is IEnumerable enumerable)
            {
                foreach (object? item in enumerable)
                {
                    object? element = MemberAccessor.Unwrap(item);
                    if (element is null)
                    {
                        continue;
                    }

                    if (element is string || element is ValueType)
                    {
                        RegisterScalar(resourceName, instanceName, relation, element);
                    }
                    else
                    {
                        RegisterComplexItem(resourceName, instanceName, relation, element);
                    }
                }

                return;
            }

            // CimInstance and PSCustomObject land here; both expose their properties through
            // the member accessor.
            RegisterComplexItem(resourceName, instanceName, relation, unwrapped);
        }

        /// <summary>
        /// Records a scalar value as a target key, subject to the relation's condition.
        /// </summary>
        /// <param name="resourceName">The source resource type.</param>
        /// <param name="instanceName">The source instance name.</param>
        /// <param name="relation">The relation being applied.</param>
        /// <param name="value">The scalar value.</param>
        /// <remarks>
        /// A condition written against <c>$_</c> tests the value itself, which is how a plain
        /// string array is split between target types, for example owners that are user
        /// principal names versus owners that are application ids.
        /// </remarks>
        private void RegisterScalar(string resourceName, string instanceName, RelationDefinition relation, object value)
        {
            if (relation.Condition is not null && !relation.Condition.Evaluate(value))
            {
                return;
            }

            Register(resourceName, instanceName, relation, value.ToString());
        }

        /// <summary>
        /// Applies the relation's condition and child property to a single complex item.
        /// </summary>
        /// <param name="resourceName">The source resource type.</param>
        /// <param name="instanceName">The source instance name.</param>
        /// <param name="relation">The relation being applied.</param>
        /// <param name="item">The item to read the target key from.</param>
        private void RegisterComplexItem(string resourceName, string instanceName, RelationDefinition relation, object item)
        {
            if (relation.Condition is not null && !relation.Condition.Evaluate(item))
            {
                return;
            }

            if (relation.ChildProperty is null)
            {
                // Nothing on the relation says which property carries the key, so there is no
                // way to derive one from a complex value.
                // Locked because a parallel export resolves several resources at once, each on
                // its own runspace, all sharing this list.
                lock (_warnings)
                {
                    _warnings.Add(
                        $"Relation on '{resourceName}' targeting '{relation.TargetResource}' resolved to a complex " +
                        "value but declares no childProperty; skipping.");
                }

                return;
            }

            string? targetKey = MemberAccessor.GetMemberAsString(item, relation.ChildProperty);
            if (targetKey is not null)
            {
                Register(resourceName, instanceName, relation, targetKey);
            }
        }

        /// <summary>
        /// Hands one resolved reference to the collector.
        /// </summary>
        /// <param name="resourceName">The source resource type.</param>
        /// <param name="instanceName">The source instance name.</param>
        /// <param name="relation">The relation being applied.</param>
        /// <param name="targetKey">The value identifying the target instance.</param>
        private void Register(string resourceName, string instanceName, RelationDefinition relation, string? targetKey)
        {
            if (string.IsNullOrEmpty(targetKey))
            {
                return;
            }

            _collector.Add(instanceName, resourceName, relation.TargetResource, relation.TargetKeyProperty, targetKey!);
        }
    }
}
