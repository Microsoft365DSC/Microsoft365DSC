using System;
using System.Collections;
using System.Collections.Generic;

namespace Microsoft365DSC.Connection
{
    /// <summary>
    /// Provides methods for determining the most secure authentication type
    /// supported by Microsoft365DSC resources.
    /// </summary>
    public static class ConnectionHelper
    {
        /// <summary>
        /// Determines the most secure authentication method supported by each requested resource from a
        /// map of resource name (with or without the MSFT_ prefix) to the names of its DSC properties.
        /// </summary>
        /// <param name="propertyNamesByResource">The property names declared by each resource.</param>
        /// <param name="authenticationMethods">
        /// The authentication methods to evaluate, in order of preference:
        /// ApplicationWithSecret, CertificateThumbprint, CertificatePath, Credentials,
        /// CredentialsWithTenantId, CredentialsWithApplicationId, ManagedIdentity, AccessTokens.
        /// </param>
        /// <param name="resources">The resource names to evaluate (without MSFT_ prefix).</param>
        /// <returns>A list of Hashtable objects, each containing 'Resource' (string) and 'AuthMethod' (string).</returns>
        public static List<Hashtable> GetComponentsWithMostSecureAuthenticationType(
            IDictionary propertyNamesByResource,
            string[] authenticationMethods,
            string[] resources)
        {
            if (propertyNamesByResource == null || propertyNamesByResource.Count == 0)
            {
                throw new ArgumentNullException(nameof(propertyNamesByResource));
            }

            if (authenticationMethods == null || authenticationMethods.Length == 0)
            {
                throw new ArgumentNullException(nameof(authenticationMethods));
            }

            if (resources == null || resources.Length == 0)
            {
                throw new ArgumentNullException(nameof(resources));
            }

            HashSet<string> resourceSet = new(resources, StringComparer.OrdinalIgnoreCase);
            HashSet<string> authMethodSet = new(authenticationMethods, StringComparer.OrdinalIgnoreCase);
            List<Hashtable> components = [];

            foreach (DictionaryEntry entry in propertyNamesByResource)
            {
                string resourceName = StripPrefix(entry.Key.ToString(), "MSFT_");
                if (!resourceSet.Contains(resourceName))
                {
                    continue;
                }

                HashSet<string> propertySet = ToPropertyNames(entry.Value);
                string? authMethod = DetermineMostSecureAuthMethod(authMethodSet, propertySet, resourceName);
                if (authMethod != null)
                {
                    components.Add(new Hashtable
                    {
                        { "Resource", resourceName },
                        { "AuthMethod", authMethod }
                    });
                }
            }

            return components;
        }

        /// <summary>Collects the property names of a map value, accepting any non-string enumerable.</summary>
        private static HashSet<string> ToPropertyNames(object? value)
        {
            HashSet<string> names = new(StringComparer.OrdinalIgnoreCase);
            if (value is IEnumerable enumerable && value is not string)
            {
                foreach (object? item in enumerable)
                {
                    if (item?.ToString() is { Length: > 0 } name)
                    {
                        names.Add(name);
                    }
                }
            }

            return names;
        }

        /// <summary>
        /// One authentication method a resource may support, and what it takes to qualify.
        /// </summary>
        private sealed class AuthenticationCandidate
        {
            public AuthenticationCandidate(
                string method,
                string authMethod,
                string[] requiredProperties,
                string[]? excludedResourcePrefixes = null)
            {
                Method = method;
                AuthMethod = authMethod;
                RequiredProperties = requiredProperties;
                ExcludedResourcePrefixes = excludedResourcePrefixes;
            }

            /// <summary>The method name as supplied by the caller.</summary>
            public string Method { get; }

            /// <summary>The name reported back for this method.</summary>
            public string AuthMethod { get; }

            /// <summary>Properties the resource must declare for this method to apply.</summary>
            public string[] RequiredProperties { get; }

            /// <summary>Resource name prefixes this method never applies to.</summary>
            public string[]? ExcludedResourcePrefixes { get; }
        }

        /// <summary>
        /// The authentication methods in descending order of security. The first candidate whose
        /// method was requested and whose properties the resource declares wins.
        /// </summary>
        private static readonly AuthenticationCandidate[] AuthenticationPriority =
        [
            new("CertificateThumbprint", "CertificateThumbprint", ["ApplicationId", "CertificateThumbprint", "TenantId"]),
            new("CertificatePath", "CertificatePath", ["ApplicationId", "CertificatePath", "TenantId"]),
            new("ApplicationWithSecret", "ApplicationSecret", ["ApplicationId", "ApplicationSecret", "TenantId"]),
            new("CredentialsWithTenantId", "CredentialsWithTenantId", ["Credential", "TenantId"], ["SPO", "OD", "PP"]),
            new("CredentialsWithApplicationId", "CredentialsWithApplicationId", ["Credential"]),
            new("Credentials", "Credentials", ["Credential"]),
            new("ManagedIdentity", "ManagedIdentity", ["ManagedIdentity"]),
            new("AccessTokens", "AccessTokens", ["AccessTokens"])
        ];

        /// <summary>
        /// Determines the most secure authentication method for a resource based on
        /// the authentication methods requested and the DSC properties the resource declares.
        /// </summary>
        private static string? DetermineMostSecureAuthMethod(
            HashSet<string> authMethods,
            HashSet<string> parameters,
            string resourceName)
        {
            foreach (AuthenticationCandidate candidate in AuthenticationPriority)
            {
                if (!authMethods.Contains(candidate.Method) ||
                    IsExcluded(resourceName, candidate.ExcludedResourcePrefixes) ||
                    !DeclaresAll(parameters, candidate.RequiredProperties))
                {
                    continue;
                }

                return candidate.AuthMethod;
            }

            return null;
        }

        private static bool IsExcluded(string resourceName, string[]? excludedPrefixes)
        {
            if (excludedPrefixes is null)
            {
                return false;
            }

            foreach (string prefix in excludedPrefixes)
            {
                if (resourceName.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }

            return false;
        }

        private static bool DeclaresAll(HashSet<string> parameters, string[] requiredProperties)
        {
            foreach (string required in requiredProperties)
            {
                if (!parameters.Contains(required))
                {
                    return false;
                }
            }

            return true;
        }

        private static string StripPrefix(string value, string prefix)
        {
            return value.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)
                ? value.Substring(prefix.Length)
                : value;
        }
    }
}
