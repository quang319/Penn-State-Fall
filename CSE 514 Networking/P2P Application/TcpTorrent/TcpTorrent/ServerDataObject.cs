using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TcpTorrent
{
    class ServerDataObject
    {
        public long Length = 0;
        public List<string> Addresses = new List<string>();
        public List<int> Ports = new List<int>();
        public List<string> Hashes = new List<string>();

        public bool AddEndPoint(string address, int port)
        {
            if (Addresses.IndexOf(address) == -1)
            {
                Addresses.Add(address);
                Ports.Add(port);
                return true;
            }
            return false;
        }

        public void RemoveEndPoint(string address)
        {
            int index = Addresses.IndexOf(address);
            if (index > -1)
            {
                Addresses.RemoveAt(index);
                Ports.RemoveAt(index);
            }
           
        }

    }
}
