using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace TcpTorrent
{
    class DataSegmentObject
    {
        private ClientDataObject _clientData;
        private int SegmentSize = 500000;
        public DataSegmentObject(ClientDataObject data)
        {
            _clientData = data;
        }

        static List<string> ChunksUpto(string str, int maxChunkSize)
        {
            List<string> result = new List<string>();
            for (int i = 0; i < str.Length; i += maxChunkSize)
                result.Add(str.Substring(i, Math.Min(maxChunkSize, str.Length - i)));
            return result;
        }

        // This function will 
        public List<string> BreakFile(string path)
        {
            if (File.Exists(path))
            {
                StringBuilder tempSb = new StringBuilder();
                using (var streamReader = new StreamReader(path))
                {
                    while (!streamReader.EndOfStream)
                    {
                        tempSb.Append(streamReader.ReadLine());
                    }
                }

                List<string> ResultList = (List<string>) ChunksUpto(tempSb.ToString(), SegmentSize);

                return ResultList;


            }
            else
            {
                Console.WriteLine("I'm exiting because the file does not exist!");
                return null;
            }
            

        }
    }
}
