public class Huely.LightDiscovery : GLib.Object
{
    public async ObservableList<Huely.Light> DiscoverLightsAsync ()
    {
        SourceFunc callback = DiscoverLightsAsync.callback;
        ObservableList<Huely.Light> discoveredLights = new ObservableList<Huely.Light> ();

        // Hold reference to closure to keep it from being freed whilst
        // thread is active.
        ThreadFunc<bool> run = () =>
        {
            GLib.Socket sock;

            string discoveryMessage = "HF-A11ASSISTHREAD";
            var cancel = new GLib.Cancellable ();
            string receiveBuffer = "                                            ";

            try
            {
                var addr = new InetAddress.from_string ("255.255.255.255");
                var address = new InetSocketAddress(addr, 48899);
                sock = new GLib.Socket (GLib.SocketFamily.IPV4, GLib.SocketType.DATAGRAM, GLib.SocketProtocol.UDP);
                sock.set_broadcast (true);
                sock.set_timeout (3);

                debug (@"Sending message: $discoveryMessage\n");
                sock.send_to (address, discoveryMessage.data);

                debug ("Starting 3 second timer...\n");

                int numLights = 1;

                while (true)
                {
                    var numBytes = sock.receive (receiveBuffer.data, cancel);
                    string recdIpAddress = receiveBuffer.split (",",0)[0];
                    debug (@"received $numBytes from $recdIpAddress\n");
                    discoveredLights.add (new Huely.Light.with_ip (recdIpAddress) { Name = @"Light $(numLights++)"});
                }
            }
            catch (GLib.Error ex)
            {
                print (@"times up: $(ex.message)\n");
            }

            Idle.add((owned) callback);
            return true;
        };
        new Thread<bool>("discover-lights-thread", (owned)run);

        // Wait for background thread to schedule our callback
        yield;
        return discoveredLights;
    }
}
