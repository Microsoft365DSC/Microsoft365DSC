using System;
using System.Collections;
using System.Linq;
using System.Text;

namespace Microsoft365DSC.Converter
{
    internal static class SimpleObjectConverter
    {
        /// <summary>
        /// Converts a simple object type to its string representation in DSC format.
        /// </summary>
        /// <param name="key">The property key/name</param>
        /// <param name="value">The value to convert</param>
        /// <param name="space">The indentation spacing (default: 16 spaces)</param>
        /// <returns>A formatted string representation of the key-value pair</returns>
        public static string ToDscString(string key, object value, string space = "                ")
        {
            if (value is null)
            {
                return string.Empty;
            }

            var returnValue = new StringBuilder();
            var valueType = value.GetType();
            var fullTypeName = valueType.FullName ?? valueType.Name;

            // Boolean type
            if (valueType == typeof(bool))
            {
                _ = returnValue.Append($"{space}{key} = ${value}\r\n");
            }
            // String type
            else if (valueType == typeof(string))
            {
                var stringValue = (string)value;

                // Handle special @odata.type key
                if (key.Equals("@odata.type", StringComparison.OrdinalIgnoreCase))
                {
                    key = "odataType";
                }

                // Escape special characters
                var newString = stringValue
                    .Replace("`", "``")
                    .Replace("$", "`$");

                newString = Utilities.Utilities.UpdateSpecialCharacters(newString);
                newString = newString.Replace("\"", "`\"");

                _ = returnValue.Append($"{space}{key} = \"{newString}\"\r\n");
            }
            // DateTime type
            else if (valueType == typeof(DateTime))
            {
                _ = returnValue.Append($"{space}{key} = \"{value}\"\r\n");
            }
            // Array/Collection types
            else if (value is IEnumerable enumerable and not string)
            {
                var items = enumerable.Cast<object>().Where(item => item is not null).ToList();
                _ = returnValue.Append($"{space}{key} = @(");

                string whitespace = string.Empty;
                string newline = string.Empty;

                if (items.Count > 1)
                {
                    _ = returnValue.Append("\r\n");
                    whitespace = space + "    ";
                    newline = "\r\n";
                }

                foreach (var item in items)
                {
                    if (item is null) continue;

                    var itemType = item.GetType();

                    if (itemType == typeof(string))
                    {
                        var itemString = ((string)item)
                            .Replace("`", "``")
                            .Replace("$", "`$")
                            .Replace("\"", "`\"");
                        _ = returnValue.Append($"{whitespace}\"{itemString}\"{newline}");
                    }
                    else if (itemType == typeof(DateTime))
                    {
                        _ = returnValue.Append($"{whitespace}\"{item}\"{newline}");
                    }
                    else
                    {
                        _ = returnValue.Append($"{whitespace}{item}{newline}");
                    }
                }

                if (items.Count > 1)
                {
                    _ = returnValue.Append($"{space})\r\n");
                }
                else
                {
                    _ = returnValue.Append(")\r\n");
                }
            }
            // Default case for other types
            else
            {
                _ = returnValue.Append($"{space}{key} = {value}\r\n");
            }

            return returnValue.ToString();
        }
    }
}
