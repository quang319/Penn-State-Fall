using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

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
        public String Message = string.Empty;
    }
}
