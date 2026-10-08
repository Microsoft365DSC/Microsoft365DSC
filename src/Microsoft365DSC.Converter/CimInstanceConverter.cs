using Microsoft.Management.Infrastructure;
using System.Text;

namespace Microsoft365DSC.Converter
{
    internal static class CimInstanceConverter
    {
        public static string ConvertToString(CimInstance cimInstance)
        {
            StringBuilder sb = new();
            _ = sb.Append("{");
            bool isFirst = true;
            foreach (var property in cimInstance.CimInstanceProperties)
            {
                if (!isFirst)
                {
                    _ = sb.Append(", ");
                }
                _ = sb.Append($"{property.Name}={property.Value}");
                isFirst = false;
            }
            _ = sb.Append("}");
            return sb.ToString();
        }
    }
}
