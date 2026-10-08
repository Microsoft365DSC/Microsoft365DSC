using Microsoft.Management.Infrastructure;
using System;
using System.Collections;
using System.Text;

namespace Microsoft365DSC.Converter
{
    internal class ArrayConverter
    {
        public static string ConvertToString(Array array)
        {
            StringBuilder sb = new();
            _ = sb.Append("(");
            for (int i = 0; i < array.Length; i++)
            {
                object? item = array.GetValue(i);
                if (item is Hashtable hashtable)
                {
                    _ = sb.Append("{");
                    _ = sb.Append(HashtableConverter.ConvertToString(hashtable));
                    _ = sb.Append("}");
                }
                else if (item is CimInstance cimInstance)
                {
                    _ = sb.Append(CimInstanceConverter.ConvertToString(cimInstance));
                }
                else
                {
                    _ = sb.Append(item?.ToString());
                }

                if (i < (array.Length - 1))
                {
                    _ = sb.Append(',');
                }
            }
            _ = sb.Append(")");
            return sb.ToString();
        }
    }
}
