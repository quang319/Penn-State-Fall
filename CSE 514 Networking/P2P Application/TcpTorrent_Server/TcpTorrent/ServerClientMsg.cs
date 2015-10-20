using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;
using System.Net;

namespace TcpTorrent
{
    [Serializable]
    [XmlRoot("TcpMsg")]
    public class ServerClientMsg
    {
        public enum Commands
        {
            RegisterRq, FileListRq, FileLocRq, LeaveRq, RegisterRly,FileListRly, FileLocRly, LeaveRly , DataRq, DataRly
        }
        public int Command = 0;

        // Local EP
        public string ClientIP = string.Empty;
        public int ClientPort = 0;

        // Files and files lengths
        public List<string> Files = new List<string>();
        public List<int> FilesLength = new List<int>();

        // Name of files and # of files
        public int NoOfFiles = 0;
        public string NameOfFile = string.Empty;
        public string ResultingDataSegment = string.Empty;
        public int SegmentOfFile = 0;
        public string HashOfFile = string.Empty;

        // List to let the client know if each of the files it tried to register was successful or not
        public List<bool> SuccessCount = new List<bool>();

        // Size of the file
        public int SizeOfFile = 0;

        // Remote EPs
        public int NoOfEPs = 0;
        public List<string> IPAddresses = new List<string>();
        public List<int> Ports = new List<int>();
        
        // Register Request
        public void RegisterRq(string ipAddress, int port, List<string> files, List<int> filesLength)
        {
            Command = (int) Commands.RegisterRq;
            ClientIP = ipAddress;
            ClientPort = port;
            NoOfFiles = files.Count;
            Files = files;
            FilesLength = filesLength;
        }

        // File list request
        public void FileListRq ()
        {
            Command = (int)Commands.FileListRq;
        }

        // File Location Request
        public void FileLocRq(string nameOffile)
        {
            Command = (int)Commands.FileLocRq;
            NameOfFile = nameOffile;
        }

        // Leave Request
        public void LeaveRq(string address, int port)
        {
            Command = (int)Commands.LeaveRq;
            ClientIP = address;
            ClientPort = port;
        }

        // Register Reply
        public void RegisterRly (List<bool> success)
        {
            Command = (int)Commands.RegisterRly;
            SuccessCount = success;
        }

        // File List Reply
        public void FileListRly (List<string> files, List<int> filesLength)
        {
            Command = (int)Commands.FileListRly;
            Files = files;
            NoOfFiles = files.Count;
            FilesLength = filesLength;
        }

        // File Location Reply
        public void FileLocRly(int sizeOfFile, List<string> localIPs, List<int> ports)
        {
            Command = (int)Commands.FileLocRly;
            SizeOfFile = sizeOfFile;
            NoOfEPs = localIPs.Count;
            IPAddresses = localIPs;
            Ports = ports;
        }

        // Leave Reply
        public void LeaveRly()
        {
            Command = (int)Commands.LeaveRly;
        }

        // Data Request
        public void DataRq(string nameOfFile, int segmentOfFile)
        {
            Command = (int)Commands.DataRq;
            NameOfFile = nameOfFile;
            SegmentOfFile = segmentOfFile;
        }

        // Data Reply
        public void DataRly(string sh1Hash, int segment, string Data)
        {
            Command = (int)Commands.DataRly;
            HashOfFile = sh1Hash;
            SegmentOfFile = segment;
            ResultingDataSegment = Data;
        }
    }
}
