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
        public List<long> UploadableFileSize = new List<long>();
        public String TempFolderPath = string.Empty;

        public List<string> FilePathsToReg = new List<string>();
        public List<long> FilePathsToRegLength = new List<long>();
        public List<string> DownloadableFileName = new List<string>();
        public List<long> DownloadableFileSize = new List<long>();
        public int MaxChunkSize = 8000;
        public bool ClientType = true;
        public Dictionary<string, dynamic> FileDict = new Dictionary<string, dynamic>();
        public string FileNameToDownload = string.Empty;
        public long FileNameToDownloadLength = 0;

    }
}
