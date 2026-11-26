using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;

namespace Microsoft365DSC.Reporting.Configuration
{
    internal sealed class ValueEncoder
    {
        public const string NullToken = "%NULL%";
        private const string PipeToken = "%PIPE%";
        private const string CommaToken = "%COMMA%";
        private const string NullLiteral = "$null";
        private const string EscapedLineBreak = "`r`n";
        private const string ConfigurationDataPrefix = "ConfigurationData.NonNodeData.";

        private static readonly Regex LineBreak = new("\r\n|\n|\r", RegexOptions.Compiled);

        private readonly Regex _tenantPattern;
        private readonly string[] _tenantTokens;

        public ValueEncoder(string? organizationName, string? tenantGuid)
        {
            string? domainShortName = string.IsNullOrEmpty(organizationName) ? null : organizationName!.Split('.')[0];
            (string Variable, string? Value, string Token)[] tenantValues =
            [
                ("OrganizationName", organizationName, "%ORGANIZATIONNAME%"),
                ("TenantGuid", tenantGuid, "%TENANTGUID%"),
                ("DomainShortName", domainShortName, "%DOMAINSHORTNAME%")
            ];

            _tenantTokens = tenantValues.Select(tenantValue => tenantValue.Token).ToArray();
            IEnumerable<string> groups = tenantValues
                .Select(tenantValue => $"({BuildAlternatives(tenantValue.Variable, tenantValue.Value)})");
            _tenantPattern = new(
                string.Join("|", groups),
                RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
        }

        public string ReplaceTenantTokens(string text)
        {
            return _tenantPattern.Replace(text, ResolveTenantToken);
        }

        public string EncodeScalar(object? value, bool escapeLineBreaks)
        {
            return value switch
            {
                null => NullToken,
                bool boolean => boolean ? "True" : "False",
                DateTime date => EncodeString(date.ToString("o", CultureInfo.InvariantCulture), escapeLineBreaks),
                DateTimeOffset date => EncodeString(date.ToString("o", CultureInfo.InvariantCulture), escapeLineBreaks),
                string text => EncodeString(text, escapeLineBreaks),
                IFormattable formattable => EncodeString(
                    formattable.ToString(null, CultureInfo.InvariantCulture),
                    escapeLineBreaks),
                _ => EncodeString(value.ToString() ?? string.Empty, escapeLineBreaks)
            };
        }

        public string EncodeArray(IEnumerable<object?> items, bool escapeLineBreaks)
        {
            string[] encoded = items
                .Select(item => IsBlankItem(item) ? NullToken : EncodeScalar(item, escapeLineBreaks))
                .Select(item => item.Replace(",", CommaToken))
                .ToArray();

            return encoded.Length == 0 ? NullToken : string.Join(",", encoded);
        }

        private string EncodeString(string text, bool escapeLineBreaks)
        {
            if (text.Length == 0 || string.Equals(text, NullLiteral, StringComparison.OrdinalIgnoreCase))
            {
                return NullToken;
            }

            if (bool.TryParse(text, out bool boolean))
            {
                return boolean ? "True" : "False";
            }

            string encoded = ReplaceTenantTokens(text).Replace("|", PipeToken);
            return escapeLineBreaks ? LineBreak.Replace(encoded, EscapedLineBreak) : encoded;
        }

        private string ResolveTenantToken(Match match)
        {
            for (int index = 0; index < _tenantTokens.Length; index++)
            {
                if (match.Groups[index + 1].Success)
                {
                    return _tenantTokens[index];
                }
            }

            return match.Value;
        }

        private static bool IsBlankItem(object? item)
        {
            return item is null || (item is string text && text.Trim('\r', '\n').Length == 0);
        }

        private static string BuildAlternatives(string variableName, string? value)
        {
            string[] names = [ConfigurationDataPrefix + variableName, variableName];
            List<string> alternatives = names
                .SelectMany(name => new[]
                {
                    Regex.Escape("$($" + name + ")"),
                    Regex.Escape("$" + name) + "(?![A-Za-z0-9_])"
                })
                .ToList();

            if (!string.IsNullOrEmpty(value))
            {
                alternatives.Add(Regex.Escape(value));
            }

            return string.Join("|", alternatives);
        }
    }
}
