using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Security.Cryptography;

namespace TcpTorrent
{
    class DataSegmentObject
    {

        public Tuple<string, List<string>> ChunksUpto(string str, int ChunkSize)
        {
            // Get the hash of the string
            var fileDictObject = new ObjectForFiledict();
            StringBuilder sb = new StringBuilder();
            byte[] fileBytes = Encoding.UTF8.GetBytes(str);
            using (var cryptoProvider = new SHA1CryptoServiceProvider())
            {
                sb.Append(BitConverter.ToString(cryptoProvider.ComputeHash(fileBytes)));
            }
            
                List<string> result = new List<string>();
            for (int i = 0; i < str.Length; i += ChunkSize)
                result.Add(str.Substring(i, Math.Min(ChunkSize, str.Length - i)));
            return new Tuple<string, List<string>>(sb.ToString(),result);
        }

        public int GetNoOfSegments (int SizeOfString, int ChunkSize)
        {
            return (int)Math.Ceiling((double)SizeOfString / (double)ChunkSize);
        }
    }
}
