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


        public int GetNoOfSegments (long SizeOfFile, int ChunkSize)
        {
            return (int)Math.Ceiling((double)SizeOfFile / (double)ChunkSize);
        }


        public void SplitFile(string inputFile, int chunkSize, string path)
        {
            const int BUFFER_SIZE = 20 * 1024;
            byte[] buffer = new byte[BUFFER_SIZE];

            using (Stream input = File.OpenRead(inputFile))
            {
                int index = 0;
                while (input.Position < input.Length)
                {
                    using (Stream output = File.Create(path + @"\" + Path.GetFileNameWithoutExtension(inputFile)
                        + "_temp"+ index + Path.GetExtension(inputFile)))
                    {
                        int remaining = chunkSize, bytesRead;
                        while (remaining > 0 && (bytesRead = input.Read(buffer, 0,
                                Math.Min(remaining, BUFFER_SIZE))) > 0)
                        {
                            output.Write(buffer, 0, bytesRead);
                            remaining -= bytesRead;
                        }
                    }
                    index++;
                }
            }
        }

        public string GetHash(string path)
        {
            using (FileStream stream = File.OpenRead(path))
            {
                SHA256Managed sha = new SHA256Managed();
                byte[] hash = sha.ComputeHash(stream);
                return BitConverter.ToString(hash).Replace("-", String.Empty);
            }
        }
        public bool getHashAndCompare(byte[] file , string expectetdHash)
        {
            SHA256Managed sha = new SHA256Managed();
            byte[] hashByte = sha.ComputeHash(file);
            string hashString = BitConverter.ToString(hashByte).Replace("-", String.Empty);
            if (hashString == expectetdHash)
                return true;
            else
                return false;
        }
    }
}
