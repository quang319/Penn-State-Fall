using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TcpTorrent
{ 

    public class ClientPassableObject
    {
        public ClientPassableObject(StateObject state)
        {
            port = state.Port;
            address = state.Address;
        }

        public enum enCommands{
        PrintDownloadable,DownloadFile,RegFiles
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

        public void PrintDownloadable()
        {
            command = (int)ClientPassableObject.enCommands.PrintDownloadable;
            target = (int)ClientPassableObject.enTarget.Server;
        }
        public void RegisterFiles(List<string> files,List<int> filesLength)
        {
            command = (int)ClientPassableObject.enCommands.RegFiles;
            target = (int)ClientPassableObject.enTarget.Server;
            FilesToReg = files;
            FilesLength = filesLength;
        }
    }
}
