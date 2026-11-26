using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Globalization;
using System.Text;

namespace Microsoft365DSC.Reporting.Configuration
{
    internal static class JsonReader
    {
        private const int MaximumDepth = 64;

        public static object? Parse(string text)
        {
            int position = 0;
            object? value = ReadValue(text, ref position, 0);
            SkipWhitespace(text, ref position);
            return position == text.Length ? value : throw Error(text, position, "unexpected trailing content");
        }

        private static object? ReadValue(string text, ref int position, int depth)
        {
            SkipWhitespace(text, ref position);
            if (position >= text.Length)
            {
                throw Error(text, position, "unexpected end of content");
            }

            if (depth > MaximumDepth)
            {
                throw Error(text, position, $"more than {MaximumDepth} nested values");
            }

            return text[position] switch
            {
                '{' => ReadObject(text, ref position, depth + 1),
                '[' => ReadArray(text, ref position, depth + 1),
                '"' => ReadString(text, ref position),
                't' => ReadLiteral(text, ref position, "true", true),
                'f' => ReadLiteral(text, ref position, "false", false),
                'n' => ReadLiteral(text, ref position, "null", null),
                _ => ReadNumber(text, ref position)
            };
        }

        private static OrderedDictionary ReadObject(string text, ref int position, int depth)
        {
            OrderedDictionary members = new(StringComparer.OrdinalIgnoreCase);
            position++;
            SkipWhitespace(text, ref position);
            if (Peek(text, position) == '}')
            {
                position++;
                return members;
            }

            while (true)
            {
                SkipWhitespace(text, ref position);
                string name = ReadString(text, ref position);
                SkipWhitespace(text, ref position);
                Expect(text, ref position, ':');
                members[name] = ReadValue(text, ref position, depth);
                SkipWhitespace(text, ref position);
                char separator = Peek(text, position);
                position++;
                if (separator == '}')
                {
                    return members;
                }

                if (separator != ',')
                {
                    throw Error(text, position - 1, "expected ',' or '}'");
                }
            }
        }

        private static List<object?> ReadArray(string text, ref int position, int depth)
        {
            List<object?> items = [];
            position++;
            SkipWhitespace(text, ref position);
            if (Peek(text, position) == ']')
            {
                position++;
                return items;
            }

            while (true)
            {
                items.Add(ReadValue(text, ref position, depth));
                SkipWhitespace(text, ref position);
                char separator = Peek(text, position);
                position++;
                if (separator == ']')
                {
                    return items;
                }

                if (separator != ',')
                {
                    throw Error(text, position - 1, "expected ',' or ']'");
                }
            }
        }

        private static string ReadString(string text, ref int position)
        {
            Expect(text, ref position, '"');
            StringBuilder value = new();
            while (true)
            {
                char character = Peek(text, position);
                position++;
                if (character == '"')
                {
                    return value.ToString();
                }

                if (character != '\\')
                {
                    value.Append(character);
                    continue;
                }

                char escape = Peek(text, position);
                position++;
                switch (escape)
                {
                    case 'b': value.Append('\b'); break;
                    case 'f': value.Append('\f'); break;
                    case 'n': value.Append('\n'); break;
                    case 'r': value.Append('\r'); break;
                    case 't': value.Append('\t'); break;
                    case 'u':
                        if (position + 4 > text.Length)
                        {
                            throw Error(text, position, "incomplete escape sequence");
                        }

                        value.Append((char)int.Parse(
                            text.Substring(position, 4),
                            NumberStyles.HexNumber,
                            CultureInfo.InvariantCulture));
                        position += 4;
                        break;
                    default: value.Append(escape); break;
                }
            }
        }

        private static object ReadNumber(string text, ref int position)
        {
            int start = position;
            while (position < text.Length && "+-.eE0123456789".IndexOf(text[position]) >= 0)
            {
                position++;
            }

            string number = text.Substring(start, position - start);
            return double.Parse(number, NumberStyles.Float, CultureInfo.InvariantCulture);
        }

        private static object? ReadLiteral(string text, ref int position, string literal, object? value)
        {
            if (string.CompareOrdinal(text, position, literal, 0, literal.Length) != 0)
            {
                throw Error(text, position, $"expected '{literal}'");
            }

            position += literal.Length;
            return value;
        }

        private static void SkipWhitespace(string text, ref int position)
        {
            while (position < text.Length && char.IsWhiteSpace(text[position]))
            {
                position++;
            }
        }

        private static void Expect(string text, ref int position, char expected)
        {
            if (Peek(text, position) != expected)
            {
                throw Error(text, position, $"expected '{expected}'");
            }

            position++;
        }

        private static char Peek(string text, int position)
        {
            return position < text.Length ? text[position] : throw Error(text, position, "unexpected end of content");
        }

        private static FormatException Error(string text, int position, string reason)
        {
            return new($"Invalid JSON at position {position} of {text.Length}: {reason}.");
        }
    }
}
