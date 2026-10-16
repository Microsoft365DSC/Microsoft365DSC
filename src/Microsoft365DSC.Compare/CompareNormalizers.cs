using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;

namespace Microsoft365DSC.Compare
{
    internal static class CompareNormalizers
    {
        private const string FullDayText = "1.00:00";

        private static readonly Regex LogicalOperatorPattern = new(
            @"\G(?:-or|-and)\s",
            RegexOptions.IgnoreCase | RegexOptions.CultureInvariant,
            TimeSpan.FromSeconds(1));

        private static readonly Regex SizePattern = new(
            @"^\s*(?<value>\d+(?:\.\d+)?)\s*(?<unit>[KMGT]?B)\b",
            RegexOptions.IgnoreCase | RegexOptions.CultureInvariant,
            TimeSpan.FromSeconds(1));

        public static object? FormatDuration(object? value) =>
            value is null ? null : RuleValues.TryReadIsoDuration(value, out TimeSpan duration) ? XmlConvert.ToString(duration) : RuleValues.ConvertToText(value);

        public static object? FormatDateTime(object? value) =>
            string.IsNullOrEmpty(RuleValues.ConvertToText(value))
                ? null
                : RuleValues.TryReadInstant(value, out DateTimeOffset instant)
                    ? instant.UtcDateTime.ToString("o", CultureInfo.InvariantCulture)
                    : RuleValues.ConvertToText(value);

        public static object? FormatTimeOfDay(object? value)
        {
            if (value is null)
            {
                return null;
            }

            if (value is not TimeSpan time && !TimeSpan.TryParse(RuleValues.ConvertToText(value), CultureInfo.InvariantCulture, out time))
            {
                return RuleValues.ConvertToText(value);
            }

            return time.Days >= 1 ? FullDayText : time.ToString(@"hh\:mm", CultureInfo.InvariantCulture);
        }

        public static object? FormatSize(object? value)
        {
            if (value is null)
            {
                return null;
            }

            string text = RuleValues.ConvertToText(value) ?? string.Empty;
            Match match = SizePattern.Match(text);
            return match.Success ? match.Groups["value"].Value + match.Groups["unit"].Value.ToUpperInvariant() : text;
        }

        public static object? FormatExchangeFilter(object? value) =>
            value is string { Length: > 0 } filter && IsWellFormedFilter(filter) ? "(" + NormalizeFilterExpression(filter) + ")" : value;

        private static bool IsWellFormedFilter(string filter)
        {
            List<string> tokens = SplitTopLevel(TrimOuterParentheses(filter.Trim()));
            if (tokens.Count <= 1)
            {
                return tokens.Count == 1 && tokens[0].Length > 0;
            }

            return tokens.Count % 2 == 1 &&
                tokens.Select((token, index) => IsLogicalOperator(token) == (index % 2 == 1)).All(isValid => isValid) &&
                tokens.Where((token, index) => index % 2 == 0).All(IsWellFormedFilter);
        }

        private static bool IsLogicalOperator(string token) =>
            string.Equals(token, "-and", StringComparison.OrdinalIgnoreCase) || string.Equals(token, "-or", StringComparison.OrdinalIgnoreCase);

        public static Func<object?, object?> CreateDateTimeReformat(object declaration)
        {
            string[] inputFormats = [.. RuleValues.ReadStrings(declaration, "InputFormats")];
            string format = RuleValues.ReadRequiredString(declaration, "Format");

            return value => value switch
            {
                null => null,
                DateTime date => date.ToString(format, CultureInfo.InvariantCulture),
                _ when DateTime.TryParseExact(RuleValues.ConvertToText(value), inputFormats, CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime parsed)
                    => parsed.ToString(format, CultureInfo.InvariantCulture),
                _ => RuleValues.ConvertToText(value)
            };
        }

        // Groups -and before -or, wrapping every operand in parentheses.
        private static string NormalizeFilterExpression(string expression)
        {
            string trimmed = TrimOuterParentheses(expression.Trim());
            List<string> tokens = SplitTopLevel(trimmed);
            if (tokens.Count == 1)
            {
                return tokens[0];
            }

            CombineOperands(tokens, "-and");
            CombineOperands(tokens, "-or");
            return tokens[0];
        }

        private static string TrimOuterParentheses(string expression)
        {
            while (expression.StartsWith("(", StringComparison.Ordinal) && expression.EndsWith(")", StringComparison.Ordinal))
            {
                string inner = expression.Substring(1, expression.Length - 2).Trim();
                if (!IsBalanced(inner))
                {
                    break;
                }

                expression = inner;
            }

            return expression;
        }

        private static bool IsBalanced(string expression)
        {
            int balance = 0;
            foreach (char character in expression)
            {
                balance += character == '(' ? 1 : character == ')' ? -1 : 0;
                if (balance < 0)
                {
                    return false;
                }
            }

            return balance == 0;
        }

        private static List<string> SplitTopLevel(string expression)
        {
            List<string> tokens = [];
            StringBuilder current = new();
            int depth = 0;
            for (int index = 0; index < expression.Length; index++)
            {
                char character = expression[index];
                Match match = depth == 0 ? LogicalOperatorPattern.Match(expression, index) : Match.Empty;
                if (character is not '(' and not ')' && match.Success && match.Index == index)
                {
                    tokens.Add(current.ToString().Trim());
                    tokens.Add(match.Value.Trim());
                    current.Clear();
                    index += match.Value.Trim().Length - 1;
                    continue;
                }

                depth += character == '(' ? 1 : character == ')' ? -1 : 0;
                current.Append(character);
            }

            if (current.ToString().Trim().Length > 0)
            {
                tokens.Add(current.ToString().Trim());
            }

            return tokens;
        }

        private static void CombineOperands(List<string> tokens, string logicalOperator)
        {
            for (int index = 0; index < tokens.Count; index++)
            {
                if (string.Equals(tokens[index], logicalOperator, StringComparison.OrdinalIgnoreCase))
                {
                    string left = NormalizeFilterExpression(tokens[index - 1]);
                    string right = NormalizeFilterExpression(tokens[index + 1]);
                    tokens[index - 1] = $"(({left}) {logicalOperator} ({right}))";
                    tokens.RemoveRange(index, 2);
                    index--;
                }
            }
        }
    }
}
