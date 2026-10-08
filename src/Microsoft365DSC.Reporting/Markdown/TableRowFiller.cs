namespace Microsoft365DSC.Reporting.Markdown
{
    internal static class TableRowFiller
    {
        private const char CellSeparator = '|';

        public static string SetValue(string row, string? value)
        {
            int lastSeparator = row.LastIndexOf(CellSeparator);
            int valueSeparator = lastSeparator > 0 ? row.LastIndexOf(CellSeparator, lastSeparator - 1) : -1;
            if (valueSeparator < 0)
            {
                return row;
            }

            string cell = string.IsNullOrEmpty(value) ? " |" : $" {value} |";
            return row.Substring(0, valueSeparator + 1) + cell;
        }

        public static string GetParameterName(string row)
        {
            string[] cells = row.Split(CellSeparator);
            return cells.Length > 1 ? cells[1].Trim().Trim('*').Trim() : string.Empty;
        }
    }
}
