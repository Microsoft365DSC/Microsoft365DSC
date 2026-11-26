using System;
using System.Collections.Generic;

namespace Microsoft365DSC.Relations
{
    /// <summary>
    /// Relations keyed by the resource type they apply to.
    /// </summary>
    /// <remarks>
    /// The templates are authored the other way round - each template lists the resources it
    /// covers - so resolving a resource previously meant scanning every template and doing a
    /// linear search of its resource list, once per exported instance. Inverting that once at
    /// module load turns the per-instance cost into a single dictionary lookup.
    /// </remarks>
    public sealed class RelationIndex
    {
        private static readonly RelationDefinition[] NoRelations = [];

        private readonly Dictionary<string, RelationDefinition[]> _relationsByResource;
        private readonly Dictionary<string, string[]> _targetKeyPropertiesByResource;

        internal RelationIndex(
            Dictionary<string, RelationDefinition[]> relationsByResource,
            Dictionary<string, string[]> targetKeyPropertiesByResource)
        {
            _relationsByResource = relationsByResource;
            _targetKeyPropertiesByResource = targetKeyPropertiesByResource;
        }

        /// <summary>The number of resource types that have at least one relation.</summary>
        public int ResourceCount => _relationsByResource.Count;

        /// <summary>
        /// Returns the relations declared for a resource type.
        /// </summary>
        /// <param name="resourceName">The resource type name.</param>
        /// <returns>The relations, or an empty array when the resource has none.</returns>
        public RelationDefinition[] GetRelations(string resourceName)
        {
            if (resourceName is not null && _relationsByResource.TryGetValue(resourceName, out RelationDefinition[]? relations))
            {
                return relations;
            }

            return NoRelations;
        }

        /// <summary>
        /// Returns the property names that other resources use to reference this one.
        /// </summary>
        /// <remarks>
        /// Used to keep the instance registry small: instead of retaining every exported
        /// property bag so a target can be matched later, only the handful of properties that
        /// some relation actually points at are captured.
        /// </remarks>
        /// <param name="resourceName">The resource type name.</param>
        /// <returns>The referenced key property names, or an empty array.</returns>
        public string[] GetTargetKeyProperties(string resourceName)
        {
            if (resourceName is not null && _targetKeyPropertiesByResource.TryGetValue(resourceName, out string[]? properties))
            {
                return properties;
            }

            return [];
        }
    }

    /// <summary>
    /// Accumulates relations and produces a <see cref="RelationIndex"/>.
    /// </summary>
    /// <remarks>
    /// The ingestion surface is deliberately flat strings rather than a parsed document.
    /// PowerShell owns parsing of M365DSCRelationTemplates.json and drives this builder, which
    /// keeps this assembly free of any JSON dependency and therefore free of assembly version
    /// conflicts with other modules loaded in the same session.
    /// </remarks>
    public sealed class RelationIndexBuilder
    {
        private readonly Dictionary<string, List<RelationDefinition>> _relationsByResource =
            new(StringComparer.OrdinalIgnoreCase);

        private readonly Dictionary<string, HashSet<string>> _targetKeyPropertiesByResource =
            new(StringComparer.OrdinalIgnoreCase);

        /// <summary>
        /// Registers one relation for one resource type.
        /// </summary>
        /// <param name="resourceName">The resource type the relation applies to.</param>
        /// <param name="propertyPath">The dotted property path to read.</param>
        /// <param name="childProperty">The property holding the target key on each item, if any.</param>
        /// <param name="targetResource">The resource type being referenced.</param>
        /// <param name="targetKeyProperty">The property on the target that the key matches.</param>
        /// <param name="condition">An expression each item must satisfy, or null.</param>
        /// <exception cref="ArgumentException">The resource name is missing, or the relation is malformed.</exception>
        /// <exception cref="FormatException">The condition uses an unsupported syntax.</exception>
        public void AddRelation(
            string resourceName,
            string propertyPath,
            string? childProperty,
            string targetResource,
            string? targetKeyProperty,
            string? condition)
        {
            if (string.IsNullOrWhiteSpace(resourceName))
            {
                throw new ArgumentException("A relation requires a resource name.", nameof(resourceName));
            }

            RelationDefinition definition = new(propertyPath, childProperty, targetResource, targetKeyProperty, condition);

            if (!_relationsByResource.TryGetValue(resourceName, out List<RelationDefinition>? relations))
            {
                relations = [];
                _relationsByResource[resourceName] = relations;
            }

            relations.Add(definition);

            if (definition.TargetKeyProperty is not null)
            {
                if (!_targetKeyPropertiesByResource.TryGetValue(definition.TargetResource, out HashSet<string>? properties))
                {
                    properties = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                    _targetKeyPropertiesByResource[definition.TargetResource] = properties;
                }

                properties.Add(definition.TargetKeyProperty);
            }
        }

        /// <summary>
        /// Freezes the accumulated relations into an index.
        /// </summary>
        /// <returns>The built index.</returns>
        public RelationIndex Build()
        {
            Dictionary<string, RelationDefinition[]> relations = new(_relationsByResource.Count, StringComparer.OrdinalIgnoreCase);
            foreach (KeyValuePair<string, List<RelationDefinition>> entry in _relationsByResource)
            {
                relations[entry.Key] = entry.Value.ToArray();
            }

            Dictionary<string, string[]> keyProperties = new(_targetKeyPropertiesByResource.Count, StringComparer.OrdinalIgnoreCase);
            foreach (KeyValuePair<string, HashSet<string>> entry in _targetKeyPropertiesByResource)
            {
                string[] names = new string[entry.Value.Count];
                entry.Value.CopyTo(names);
                keyProperties[entry.Key] = names;
            }

            return new RelationIndex(relations, keyProperties);
        }
    }
}
