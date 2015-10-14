using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace AsyncAwayClient
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("hit Ctrl-C to exit.");
            var task = new Program().ClientStart();
            Console.ReadKey();
        }

        object _lock = new object();
        List<Task> _connections = new List<Task>();

        private async Task ClientStart()
        {
            IPEndPoint localEP = new IPEndPoint(IPAddress.Parse("127.0.0.1"), 1002);
            var tcpclient = new TcpClient(localEP);
            await tcpclient.ConnectAsync(IPAddress.Parse("127.0.0.1"), 1000);
            Console.WriteLine("Connected to the server");
            var task = OnConnectAsync(tcpclient);
            if (task.IsFaulted)
                task.Wait();

            
        }

        private async Task OnConnectAsync(TcpClient tcpclient)
        {
            var TransferTask = OnTransferAsync(tcpclient);

            lock(_lock)
                _connections.Add(TransferTask);
            try
            {
                await TransferTask;
            }
            catch (Exception ex)
            {

                Console.WriteLine(ex.ToString());
            }
            finally
            {
                lock(_lock)
                    _connections.Remove(TransferTask);
            }
        }

        private async Task OnTransferAsync(TcpClient tcpclient)
        {
            await Task.Yield();

            using (var networkStream = tcpclient.GetStream())
            {
                var SendBytes = Encoding.UTF8.GetBytes("Hello this is the Client");
                await networkStream.WriteAsync(SendBytes, 0, SendBytes.Length);
                var ReceivedBytes = new byte[1024];
                await networkStream.ReadAsync(ReceivedBytes, 0, ReceivedBytes.Length);
                Console.WriteLine(Encoding.UTF8.GetString(ReceivedBytes));
            }
        }
    }
}
