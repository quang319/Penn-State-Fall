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
            RegisterRq, FileListRq, FileLocRq, LeaveRq, RegisterRly,FileListRly, FileLocRly, LeaveRly 
        }
        public int Command = 0;

        // Local EP
        public string ClientIP = string.Empty;
        public int ClientPort = 0;

        // Files and files lengths
        List<string> Files = new List<string>();
        List<int> FilesLength = new List<int>();

        // Name of files and # of files
        int NoOfFiles = 0;
        string NameOfFile = string.Empty;

        // List to let the client know if each of the files it tried to register was successful or not
        List<bool> SuccessCount = new List<bool>();

        // Size of the file
        int SizeOfFile = 0;

        // Remote EPs
        int NoOfEPs = 0;
        List<string> IPAddresses = new List<string>();
        List<int> Ports = new List<int>();

        // Register Request
        public void RegisterRq(IPEndPoint LocalEP, List<string> files, List<int> filesLength)
        {
            Command = (int) Commands.RegisterRq;
            ClientIP = LocalEP.Address.ToString();
            ClientPort = LocalEP.Port;
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
        public void LeaveRq()
        {
            Command = (int)Commands.LeaveRq;
        }

        // File List Replay
        public void FileListRly (List<bool> success)
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
    }
}
