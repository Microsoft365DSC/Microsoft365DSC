using System;

namespace Microsoft365DSC.Relations
{
    /// <summary>
    /// One relation from the relation templates, pre-processed for repeated evaluation:
    /// the dotted property path is already split and the condition is already parsed.
    /// </summary>
    public sealed class RelationDefinition
    {
        /// <summary>The property path, already split on '.'.</summary>
        public string[] PropertyPath { get; }

        /// <summary>The property read off each resolved item to obtain the target key, or null.</summary>
        public string? ChildProperty { get; }

        /// <summary>The resource type this relation points at.</summary>
        public string TargetResource { get; }

        /// <summary>
        /// The property on the target resource that the key matches against, or null to fall
        /// back to the target instance's primary key.
        /// </summary>
        public string? TargetKeyProperty { get; }

        /// <summary>The parsed condition an item must satisfy, or null when unconditional.</summary>
        public IRelationCondition? Condition { get; }

        /// <summary>
        /// Creates a relation definition.
        /// </summary>
        /// <param name="propertyPath">The dotted property path, for example <c>Assignments.Assignment</c>.</param>
        /// <param name="childProperty">The property read off each resolved item to obtain the target key, if any.</param>
        /// <param name="targetResource">The resource type this relation points at.</param>
        /// <param name="targetKeyProperty">The property on the target resource that the key matches against.</param>
        /// <param name="condition">An expression that an item must satisfy, or null.</param>
        /// <exception cref="ArgumentException">The property path or target resource is missing.</exception>
        /// <exception cref="FormatException">The condition uses an unsupported syntax.</exception>
        public RelationDefinition(
            string propertyPath,
            string? childProperty,
            string targetResource,
            string? targetKeyProperty,
            string? condition)
        {
            if (string.IsNullOrWhiteSpace(propertyPath))
            {
                throw new ArgumentException("A relation requires a property path.", nameof(propertyPath));
            }

            if (string.IsNullOrWhiteSpace(targetResource))
            {
                throw new ArgumentException("A relation requires a target resource.", nameof(targetResource));
            }

            PropertyPath = propertyPath.Split('.');
            ChildProperty = string.IsNullOrWhiteSpace(childProperty) ? null : childProperty;
            TargetResource = targetResource;
            TargetKeyProperty = string.IsNullOrWhiteSpace(targetKeyProperty) ? null : targetKeyProperty;
            Condition = ConditionParser.Parse(condition);
        }
    }
}
