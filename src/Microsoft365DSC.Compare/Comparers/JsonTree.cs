using System;
using System.Collections;
using System.Linq;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Xml;
using System.Xml.Linq;

namespace Microsoft365DSC.Compare.Comparers
{
    internal static class JsonTree
    {
        private const int MaxEncodingDepth = 3;

        private static readonly XmlDictionaryReaderQuotas Quotas = new()
        {
            MaxDepth = 64,
            MaxStringContentLength = int.MaxValue,
            MaxArrayLength = int.MaxValue,
            MaxBytesPerRead = int.MaxValue,
            MaxNameTableCharCount = int.MaxValue
        };

        // Text that parses to a JSON string is parsed again, up to MaxEncodingDepth times.
        public static bool TryParse(string text, out object? tree)
        {
            tree = text;
            for (int depth = 0; depth < MaxEncodingDepth && tree is string encoded; depth++)
            {
                if (!TryParseOnce(encoded, out object? parsed))
                {
                    break;
                }

                tree = parsed;
            }

            return tree is Hashtable or object[];
        }

        public static bool IsEqual(object? left, object? right) =>
            (left, right) switch
            {
                (null, null) => true,
                (Hashtable leftObject, Hashtable rightObject) => leftObject.Count == rightObject.Count &&
                    leftObject.Keys.Cast<object>().All(key => rightObject.ContainsKey(key) && IsEqual(leftObject[key], rightObject[key])),
                (object[] leftItems, object[] rightItems) => leftItems.Length == rightItems.Length &&
                    leftItems.Zip(rightItems, IsEqual).All(isEqual => isEqual),
                (string leftText, string rightText) => string.Equals(leftText, rightText, StringComparison.OrdinalIgnoreCase),
                (bool leftFlag, bool rightFlag) => leftFlag == rightFlag,
                _ => false
            };

        private static bool TryParseOnce(string text, out object? tree)
        {
            tree = null;
            if (string.IsNullOrWhiteSpace(text))
            {
                return false;
            }

            try
            {
                using XmlDictionaryReader reader = JsonReaderWriterFactory.CreateJsonReader(Encoding.UTF8.GetBytes(text), Quotas);
                tree = ReadElement(XElement.Load(reader));
                return true;
            }
            catch (Exception exception) when (exception is XmlException or ArgumentException or FormatException)
            {
                return false;
            }
        }

        // Numbers keep their text.
        private static object? ReadElement(XElement element) =>
            (string?)element.Attribute("type") switch
            {
                "object" => ReadObject(element),
                "array" => element.Elements().Select(ReadElement).ToArray(),
                "boolean" => string.Equals(element.Value, "true", StringComparison.Ordinal),
                "null" => null,
                _ => element.Value
            };

        // A key that is not a valid XML name arrives in the item attribute.
        private static Hashtable ReadObject(XElement element)
        {
            Hashtable result = new(StringComparer.OrdinalIgnoreCase);
            foreach (XElement child in element.Elements())
            {
                result[(string?)child.Attribute("item") ?? child.Name.LocalName] = ReadElement(child);
            }

            return result;
        }
    }
}
