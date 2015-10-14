using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;

namespace AsyncAwaitServer
{
    class TCPTorrent
    {
        object _lock = new object(); // sync lock
        List<Task> _connections = new List<Task>();
        public async Task StartListener()
        {
            var TcpServer = TcpListener.Create(1000);
            TcpServer.Start(3);
            while (true)
            {
                var TcpClient = await TcpServer.AcceptTcpClientAsync();
                Console.WriteLine("[Server] Connect to a client");
                var task = OnConnectAsync(TcpClient);
                if (task.IsFaulted)
                    task.Wait();
            }

        }

        private async Task OnConnectAsync(TcpClient tcpClient)
        {
            // Start a transfer task
            var transferTask = OnTransferAsync(tcpClient);

            // lock it as this is critial path
            lock (_lock)
                _connections.Add(transferTask);

            try
            {
                await transferTask;

            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            finally
            {
                lock (_lock)
                    _connections.Remove(transferTask);
            }

        }

        private async Task OnTransferAsync(TcpClient tcpClient)
        {
            await Task.Yield();

            using (var networkStream = tcpClient.GetStream())
            {
                var buffer = new byte[1024];
                Console.WriteLine("[Server] Reading from client");
                var byteCount = await networkStream.ReadAsync(buffer, 0, buffer.Length);
                var ClientMsg = Encoding.UTF8.GetString(buffer, 0, byteCount);
                Console.WriteLine("The client wrote: {0}", ClientMsg);
                var ReturnBytes = Encoding.UTF8.GetBytes("This is the server");
                await networkStream.WriteAsync(ReturnBytes, 0, ReturnBytes.Length);
                Console.WriteLine("[Server] Response has been given");
            }
        }
    }
}
