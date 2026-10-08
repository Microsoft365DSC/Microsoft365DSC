using Microsoft.Management.Infrastructure;
using System;
using System.Collections;
using System.Collections.Generic;

namespace Microsoft365DSC.Converter
{
    public class HashtableConverter
    {
        private static readonly HashSet<string> ParametersToObfuscate = new(
            ["ApplicationSecret", "CertificateThumbprint", "CertificatePath", "CertificatePassword", "Credential", "Password"],
            StringComparer.Ordinal);

        /// <summary>
        /// Converts the specified hashtable to its string representation.
        /// </summary>
        /// <param name="hashtable">The hashtable to convert to a string.</param>
        /// <returns>A string that represents the specified hashtable.</returns>
        public static string ConvertToString(Hashtable hashtable)
        {
            List<string> propertyStrings = [];
            foreach (DictionaryEntry entry in hashtable)
            {
                string propertyString;
                if (entry.Value is Array array)
                {
                    propertyString = $"{entry.Key}={ArrayConverter.ConvertToString(array)}";
                }
                else if (entry.Value is Hashtable ht)
                {
                    propertyString = $"{entry.Key}={{{ConvertToString(ht)}}}";
                }
                else if (entry.Value is CimInstance cimInstance)
                {
                    propertyString = $"{entry.Key}={CimInstanceConverter.ConvertToString(cimInstance)}";
                }
                else
                {
                    if (entry.Value is null)
                    {
                        propertyString = $"{entry.Key}=$null";
                    }
                    else
                    {
                        if (ParametersToObfuscate.Contains(entry.Key.ToString()))
                        {
                            propertyString = $"{entry.Key}=***";
                        }
                        else
                        {
                            propertyString = $"{entry.Key}={entry.Value}";
                        }
                    }
                }
                propertyStrings.Add(propertyString);
            }

            propertyStrings.Sort();
            return string.Join(Environment.NewLine, propertyStrings);
        }
    }
}
