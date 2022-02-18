public class Huely.LightDiscovery : GLib.Object
{
    public ObservableList<Huely.Light> DiscoverLights ()
    {
        ObservableList<Huely.Light> discoveredLights = new ObservableList<Huely.Light> ();

        GLib.Socket sock;

        string discoveryMessage = "HF-A11ASSISTHREAD";
        var cancel = new GLib.Cancellable ();
        string receiveBuffer = "extra long string to store data in hopefully";

        try
        {
            var addr = new InetAddress.from_string ("255.255.255.255");
            var address = new InetSocketAddress(addr, 48899);
            sock = new GLib.Socket (GLib.SocketFamily.IPV4, GLib.SocketType.DATAGRAM, GLib.SocketProtocol.UDP);
            sock.set_broadcast (true);
            sock.set_timeout (3);

            print (@"Sending message: $discoveryMessage\n");
            sock.send_to (address, discoveryMessage.data);

            print ("Starting 3 second timer...\n");

            while (true)
            {
                var numBytes = sock.receive (receiveBuffer.data, cancel);
                string recdIpAddress = receiveBuffer.split (",",0)[0];
                print (@"received $numBytes from $recdIpAddress\n");
                discoveredLights.add (new Huely.Light () { name = "DicoveredLight 1", ipAddress = recdIpAddress, color = "#FFFFFF"});
            }
        }
        catch (GLib.Error ex)
        {
            print ("times up!\n");
            print (ex.message);
        }

        return discoveredLights;
    }
}
