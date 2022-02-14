public class Huely.LightDiscovery : GLib.Object
{
    public List<Huely.Light> DiscoverLights ()
    {
        List<Huely.Light> discoveredLights = new List<Huely.Light> ();

        GLib.Socket sock;
        GLib.SocketClient client = new GLib.SocketClient () { protocol = SocketProtocol.UDP, type = SocketType.DATAGRAM };
        GLib.SocketConnection connection;

        string discoveryMessage = "HF-A11ASSISTHREAD";
        var cancel = new GLib.Cancellable ();
        string receiveBuffer = "";

        try
        {
            var addr = new InetAddress.from_string ("255.255.255.255");
            var address = new InetSocketAddress(addr, 48899);

            //sock.bind (address, true);
            sock = new GLib.Socket (GLib.SocketFamily.IPV4, GLib.SocketType.DATAGRAM, GLib.SocketProtocol.UDP);
            sock.set_broadcast (true);
            sock.send_to (address, discoveryMessage.data);

            //connection = client.connect (address);
            //connection.socket.set_broadcast (true);

            try
            {
                //connection.output_stream.write (discoveryMessage.data, cancel);

                try
                {
                    while (!cancel.is_cancelled ())
                    {
                        //connection.input_stream.read (receiveBuffer.data, cancel);
                        sock.receive (receiveBuffer.data, cancel);

                        debug ("received: " + receiveBuffer);
                    }
                }
                catch (GLib.IOError ex)
                {
                    debug (ex.message);
                }
            }
            catch (GLib.IOError ex)
            {
                debug (ex.message);
            }
        }
        catch (GLib.Error ex)
        {
            debug (ex.message);
        }

        return discoveredLights;
    }
}
