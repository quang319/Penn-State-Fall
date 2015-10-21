using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TcpTorrent
{
    public class StateObject
    {
        public string Address = string.Empty;
        public int Port = 0;
        public List<string> UploadableFilePath = new List<string>();
        public List<int> UploadableFileSize = new List<int>();
        public String TempFolderPath = string.Empty;

        public List<string> FilePathsToReg = new List<string>();
        public List<int> FilePathsToRegLength = new List<int>();
        public List<string> DownloadableFileName = new List<string>();
        public List<int> DownloadableFileSize = new List<int>();
        public int MaxChunkSize = 8000;
        public bool ClientType = true;
        public Dictionary<string, dynamic> FileDict = new Dictionary<string, dynamic>();
        public string FileNameToDownload = string.Empty;
        public int FileNameToDownloadLength = 0;

    }
}
