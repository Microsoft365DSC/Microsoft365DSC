using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace Microsoft365DSC.Reporting.Configuration
{
    /// <summary>
    /// Reads a configuration file and prepares its content for the DSC parser.
    /// </summary>
    public static class ConfigurationReader
    {
        private static readonly Regex UnescapedCurlyQuote = new(
            "(?<!`)((?:``)*)([“”„‟])",
            RegexOptions.Compiled);

        /// <summary>
        /// Reads a configuration file and escapes the curly quotes it carries.
        /// </summary>
        /// <param name="path">The path of the configuration file.</param>
        /// <returns>The content of the file, ready to be parsed.</returns>
        public static string ReadContent(string path)
        {
            return EscapeCurlyQuotes(File.ReadAllText(path, Encoding.UTF8));
        }

        /// <summary>
        /// Escapes every curly quote that is not escaped yet, which the parser would otherwise
        /// read as the end of a string.
        /// </summary>
        /// <param name="content">The configuration content.</param>
        /// <returns>The content with every curly quote escaped.</returns>
        public static string EscapeCurlyQuotes(string content)
        {
            return UnescapedCurlyQuote.Replace(content, "$1`$2");
        }
    }
}
