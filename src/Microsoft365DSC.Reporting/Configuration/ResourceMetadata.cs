using System.Collections;
using System.Collections.Generic;

namespace Microsoft365DSC.Reporting.Configuration
{
    /// <summary>A property of a resource class or of one of its embedded classes.</summary>
    public sealed class ResourceParameter
    {
        /// <summary>The property name.</summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>The DSC attribute of the property, such as Key, Required or Write.</summary>
        public string Option { get; set; } = string.Empty;

        /// <summary>The CIM type of the property, such as String or MSFT_Example[].</summary>
        public string CimType { get; set; } = string.Empty;

        /// <summary>The description of the property.</summary>
        public string Description { get; set; } = string.Empty;

        /// <summary>The values the property accepts, when it is restricted to a set of them.</summary>
        public IReadOnlyList<string>? ValueMap { get; set; }
    }

    /// <summary>A resource class or one of the complex types it embeds.</summary>
    public sealed class ResourceClass
    {
        /// <summary>The class name, including the MSFT_ prefix.</summary>
        public string ClassName { get; set; } = string.Empty;

        /// <summary>The properties of the class, in schema order.</summary>
        public IReadOnlyList<ResourceParameter> Parameters { get; set; } = new List<ResourceParameter>();
    }

    /// <summary>
    /// Supplies the resource metadata a converter needs to describe properties beyond their value.
    /// </summary>
    public interface IResourceMetadataSource
    {
        /// <summary>
        /// Returns the class of the given name, or null when the schema does not define it.
        /// </summary>
        /// <param name="className">The class name, including the MSFT_ prefix.</param>
        /// <returns>The class, or null.</returns>
        ResourceClass? GetClass(string className);

        /// <summary>
        /// Returns the documentation of a resource type as Markdown, or null when there is none.
        /// </summary>
        /// <param name="resourceType">The resource type name, without the MSFT_ prefix.</param>
        /// <returns>The documentation, or null.</returns>
        string? GetDocumentation(string resourceType);

        /// <summary>
        /// Returns the permissions of a resource type, keyed by API name, or null when the type
        /// carries no permission information.
        /// </summary>
        /// <param name="resourceType">The resource type name, without the MSFT_ prefix.</param>
        /// <returns>The permissions, or null.</returns>
        IDictionary? GetPermissions(string resourceType);
    }
}
