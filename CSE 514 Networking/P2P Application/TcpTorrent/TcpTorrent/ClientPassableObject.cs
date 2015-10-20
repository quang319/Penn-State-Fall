using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace TcpTorrent
{ 

    public class ClientPassableObject
    {
        public ClientPassableObject(StateObject state)
        {
            port = state.Port;
            address = state.Address;
            _state = state;
        }

        StateObject _state;
        public enum enCommands{
        PrintDownloadable,DownloadFile,RegFiles,Leave,FileLocation,GetFile
        };

        public enum enTarget
        {
            Server,Peer
        }
        public string address = string.Empty;
        public int port = 0;

        public int command = 0;

        public int target = 0;

        public bool DoneFlag = false;

        public List<string> FilesToReg = new List<string>();
        public List<int> FilesLength = new List<int>();

        public List<string> DownloadableFiles = new List<string>();
        public List<int> DownloadableFilesLength = new List<int>();
        public List<bool> FilesRegSuccessCount = new List<bool>();

        public string FileToDownload = string.Empty;
        public int FileSegmentToDownload = 0;

        public string ResultFileSegment = string.Empty;
        public string ResultFileHash = string.Empty;
        public int ResultFileSegmentNo = 0;

        public int FileToDownloadLength = 0;
        public List<string> AddressAtFile2Download = new List<string>();
        public List<int> PortAtFile2Download = new List<int>();

        public void PrintDownloadable()
        {
            command = (int)ClientPassableObject.enCommands.PrintDownloadable;
            target = (int)ClientPassableObject.enTarget.Server;
        }
        public void RegisterFiles()
        {
            command = (int)ClientPassableObject.enCommands.RegFiles;
            target = (int)ClientPassableObject.enTarget.Server;
            foreach ( var path in _state.FilePathsToReg)
            {
                FilesToReg.Add(Path.GetFileName(path));
            }
            FilesLength = _state.FilePathsToRegLength;
        }

        public void LeaveRequest()
        {
            command = (int)ClientPassableObject.enCommands.Leave;
            target = (int)ClientPassableObject.enTarget.Server;
        }
        public void GetFilesLocation(string FileName)
        {
            command = (int)ClientPassableObject.enCommands.FileLocation;
            target = (int)ClientPassableObject.enTarget.Server;
            FileToDownload = FileName;
        }

        public void GetFile(string ipAddress, int portNo, string fileToGet, int segment)
        {
            command = (int)ClientPassableObject.enCommands.GetFile;
            target = (int)ClientPassableObject.enTarget.Peer;
            address = ipAddress;
            port = portNo;
            FileToDownload = fileToGet;
            FileSegmentToDownload = segment;
            
        }
    }
}
