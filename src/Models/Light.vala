public class Huely.Light : Object
{
    // TODO - Evaluate get/set public/private concerns.
    public string Name { get; set; }
    public string IpAddress { get; set; }
    public bool IsOn { get; set; }
    public bool IsConnected { get; set; }
    public uint8 Red { get; set; }
    public uint8 Green { get; set; }
    public uint8 Blue { get; set; }
    public uint8 Brightness { get; private set; }
    public Gdk.RGBA Color
    {
        get
        {
            var tempParser = Gdk.RGBA ();
            tempParser.parse ("#" + Red.to_string ("%x") + Green.to_string ("%x") + Blue.to_string ("%x"));
            return tempParser;
        }

        private set {}
    }

    private bool _useChecksum;
    private LedProtocol _protocol;

    private DateTime time { get; private set; }
    private enum LedProtocol { LEDENET, LEDENET_ORIGINAL, UNKNOWN }

    private GLib.Socket _socket;
    private const uint16 PORT = 5577;

    public Light.from_string (string lightString) throws GLib.Error
    {
        var lightTokens = lightString.split (",", 0);

        // TODO - Add more validation. Lots more.
        if (lightTokens.length < 6)
        {
            throw new GLib.Error (Quark.from_string ("invalid-format"), 1, "Invalid light string format specified.");
        }

        var ip = lightTokens[0];
        var name = lightTokens[1];
        var red = uint.parse (lightTokens[2]);
        var green = uint.parse (lightTokens[3]);
        var blue = uint.parse (lightTokens[4]);
        var brightness = uint.parse (lightTokens[5]);

        IsConnected = false;
        _useChecksum = true;
        _protocol = LedProtocol.UNKNOWN;
        IpAddress = ip;
        Name = name;
        Red = (uint8)red;
        Green = (uint8)green;
        Blue = (uint8)blue;
        Brightness = (uint8)brightness;

        try
        {
            _socket = new GLib.Socket (GLib.SocketFamily.IPV4, GLib.SocketType.STREAM, GLib.SocketProtocol.TCP);
            _socket.set_timeout (1);

            var loop = new MainLoop();
            this.ConnectAsync.begin((obj, res) =>
            {
                this.ConnectAsync.end (res);
                loop.quit();
            });
            loop.run();
        }
        catch (GLib.Error ex)
        {
            print (@"Encountered error constrtucting new Light: $(ex.message)\n");
        }
    }

    public string to_string ()
    {
        return IpAddress.to_string () + "," +
            Name + "," +
            Red.to_string () + "," +
            Green.to_string () + "," +
            Blue.to_string () + "," +
            Brightness.to_string ();
    }

    public Light.with_ip (string ip)
    {
        IsConnected = false;
        _useChecksum = true;
        _protocol = LedProtocol.UNKNOWN;
        IpAddress = ip;

        try
        {
            _socket = new GLib.Socket (GLib.SocketFamily.IPV4, GLib.SocketType.STREAM, GLib.SocketProtocol.TCP);
            _socket.set_timeout (1);

            var loop = new MainLoop();
            this.ConnectAsync.begin((obj, res) =>
            {
                this.ConnectAsync.end (res);
                loop.quit();
            });
            loop.run();
        }
        catch (GLib.Error ex)
        {
            print (@"Encountered error constrtucting new Light: $(ex.message)\n");
        }
    }

    public Light.with_ip_and_name_and_color_and_brightness (string ip, string name, uint8 red, uint8 green, uint8 blue, uint8 brightness)
    {
        IsConnected = false;
        _useChecksum = true;
        _protocol = LedProtocol.UNKNOWN;
        IpAddress = ip;
        Name = name;
        Red = red;
        Green = green;
        Blue = blue;
        Brightness = brightness;

/*
        try
        {
            _socket = new GLib.Socket (GLib.SocketFamily.IPV4, GLib.SocketType.STREAM, GLib.SocketProtocol.TCP);
            _socket.set_timeout (1);

            var loop = new MainLoop();
            this.ConnectAsync.begin((obj, res) =>
            {
                this.ConnectAsync.end (res);
                loop.quit();
            });
            loop.run();

            this.SetColor (Red, Green, Blue);
        }
        catch (GLib.Error ex)
        {
            print (@"Encountered error constrtucting new Light: $(ex.message)\n");
        }
*/
    }

    // Communication functions
    public async void ConnectAsync ()
    {
        debug ("ConnectAsync ()\n");
        SourceFunc callback = ConnectAsync.callback;

        var addr = new InetAddress.from_string (IpAddress);
        var address = new InetSocketAddress(addr, PORT);

        ThreadFunc<bool> run = () =>
        {
            try
            {
                if (IsConnected == false)
                {
                    IsConnected = _socket.connect (address);
                }
                else
                {
                    IsConnected = false;
                }

                debug (@"Connected = $IsConnected\n");

                var getProtcolLoop = new MainLoop();
                GetProtocolAsync.begin((obj, res) =>
                {
                    GetProtocolAsync.end (res);
                    getProtcolLoop.quit();
                });
                getProtcolLoop.run();

                var refreshLoop = new MainLoop();
                RefreshAsync.begin((obj, res) =>
                {
                    RefreshAsync.end (res);
                    refreshLoop.quit();
                });
                refreshLoop.run();
            }
            catch (GLib.Error error)
            {
                var msg = error.message;
                print (@"Failed to connect to Light: $msg\n");
            }

            Idle.add((owned) callback);
            return true;
        };
        new Thread<bool>("light-connect-thread", (owned)run);

        yield;

        this.notify_property("IsConnected");
    }

    private async LedProtocol GetProtocolAsync ()
    {
        SourceFunc callback = GetProtocolAsync.callback;
        LedProtocol result = LedProtocol.UNKNOWN;

        ThreadFunc<bool> run = () =>
        {
            debug ("GetProtocolAsync ()");
            uint8[] args = {0x81, 0x8a, 0x8b};
            send_data (args);
            try
            {
                uint8[] buffer_ledenet = new uint8[14];
                GLib.Cancellable cancel = new GLib.Cancellable ();
                _socket.receive (buffer_ledenet, cancel);
                result = LedProtocol.LEDENET;
            }
            catch (GLib.Error ex1)
            {
                print (@"Error, not LEDENET due to: $(ex1.message)\n");
                args = {0xef, 0x01, 0x77};
                send_data(args);
                try
                {
                    uint8[] buffer_original = new uint8[14];
                    _socket.receive (buffer_original);
                    result = LedProtocol.LEDENET_ORIGINAL;
                }
                catch (GLib.Error ex2)
                {
                    print (@"Error, not LEDENET_ORIGINAL due to: $(ex2.message)\n");
                    result = LedProtocol.UNKNOWN;
                }
            }

            _protocol = result;

            Idle.add((owned) callback);
            return true;
        };
        new Thread<bool>("light-get-protocol-thread", (owned)run);

        yield;
        return result;
    }

    public async void RefreshAsync ()
    {
        SourceFunc callback = RefreshAsync.callback;
        debug ("RefreshAsync ()\n");

        ThreadFunc<bool> run = () =>
        {
            //Send request for status.
            if (_protocol == LedProtocol.LEDENET)
            {
                uint8[] args = {0x81, 0x8a, 0x8b};
                send_data (args);
            }
            else
            {
                if (_protocol == LedProtocol.LEDENET_ORIGINAL)
                {
                    uint8[] args = {0xef, 0x01, 0x77};
                    send_data (args);
                }
            }

            var dataRaw = read_data ();
            string[] dataHex = new string[14];

            // TODO - Why even bother to convert it to hex strings?
            debug ("dataHex = ");
            for (int i = 0; i < dataHex.length; i++)
            {
                dataHex[i] = dataRaw[i].to_string ("%x");
                debug (dataHex[i] +", ");
            }
            debug ("\n");

            // TODO - convert this to not use string hex
            if (_protocol == LedProtocol.LEDENET_ORIGINAL && dataHex[1] == "01")
            {
                _useChecksum = false;
            }

            //Check power state.
            if (dataRaw[2] == 35)
            {
                debug (@"Light.isOn = $IsOn\n");
                IsOn = true;
                debug (@"Light.isOn = $IsOn\n");
            }
            else if (dataRaw[2] == 36)
            {
                debug (@"Light.isOn = $IsOn\n");
                IsOn = false;
                debug (@"Light.isOn = $IsOn\n");
            }

            Idle.add((owned) callback);
            return true;
        };
        new Thread<bool>("light-refresh-thread", (owned)run);

        yield;

        /*
        //Send request to get the time of the light.
        Time = await GetTimeAsync();
        */
    }

    public void set_state (bool turnOn)
    {
        if (turnOn == true)
        {
            turn_on ();
        }
        else
        {
            turn_off ();
        }
    }

    private void turn_on ()
    {
        if (_protocol == LedProtocol.LEDENET)
        {
            send_data ({0x71, 0x23, 0x0f});
        }
        else
        {
            send_data ({0xcc, 0x23, 0x33});
        }

        IsOn = true;
    }

    private void turn_off ()
    {
        if (_protocol == LedProtocol.LEDENET)
        {
            uint8[] args = {0x71, 0x24, 0x0f};
            send_data (args);
        }
        else
        {
            uint8[] args = {0xcc, 0x24, 0x33};
            send_data (args);
        }

        IsOn = false;
    }

    public void SetColor (uint8 red, uint8 green, uint8 blue)
    {
        Red = red;
        Green = green;
        Blue = blue;

        var redBrightnessFactor = ((uint8) ( (((double)Brightness) / 100) * ((double)Red) ) );
        var greenBrightnessFactor = ((uint8) ( (((double)Brightness) / 100) * ((double)Green) ) );
        var blueBrightnessFactor = ((uint8) ( (((double)Brightness) / 100) * ((double)Blue) ) );

        if (IsConnected == false)
        {
            var loop = new MainLoop();
            this.ConnectAsync.begin((obj, res) =>
            {
                this.ConnectAsync.end (res);
                loop.quit();
            });
            loop.run();
        }

        if (_protocol == LedProtocol.LEDENET)
        {
            uint8[] args = {0x41, redBrightnessFactor, greenBrightnessFactor, blueBrightnessFactor, 0x00, 0x00, 0x0F};
            send_data (args);
        }
        else
        {
            uint8[] args = {0x56, redBrightnessFactor, greenBrightnessFactor, blueBrightnessFactor, 0xAA};
            send_data (args);
        }

        this.notify_property ("Red");
        this.notify_property ("Green");
        this.notify_property ("Blue");
    }

    public void SetBrightness (double brightness)
    {
        if (brightness > 100)
        {
            brightness = 100;
        }

        Brightness = (uint8)brightness;

        var redBrightnessFactor = ((uint8) ( (((double)Brightness) / 100) * ((double)Red) ) );
        var greenBrightnessFactor = ((uint8) ( (((double)Brightness) / 100) * ((double)Green) ) );
        var blueBrightnessFactor = ((uint8) ( (((double)Brightness) / 100) * ((double)Blue) ) );

        if (IsConnected == false)
        {
            var loop = new MainLoop();
            this.ConnectAsync.begin((obj, res) =>
            {
                this.ConnectAsync.end (res);
                loop.quit();
            });
            loop.run();
        }

        if (_protocol == LedProtocol.LEDENET)
        {
            uint8[] args = {0x41, redBrightnessFactor, greenBrightnessFactor, blueBrightnessFactor, 0x00, 0x00, 0x0F};
            send_data (args);
        }
        else
        {
            uint8[] args = {0x56, redBrightnessFactor, greenBrightnessFactor, blueBrightnessFactor, 0xAA};
            send_data (args);
        }

        this.notify_property ("Brightness");
    }

    public DateTime get_time2 ()
    {
        send_data (new uint8[] {0x11, 0x1a, 0x1b, 0x0f});
        uint8[] data = read_data ();
        var time = new GLib.DateTime.local(
            data[3] + 2000,
            data[4],
            data[5],
            data[6],
            data[7],
            data[8]
        );

        debug (@"Time = $time\n");

        return time;
    }

    private void send_data (uint8[] _data)
    {
        uint8 csum = 0;
        if (_useChecksum == true)
        {
            for (int i = 0; i < _data.length; i++)
            {
                csum += _data[i];
            }
            csum = csum & 0xFF;
        }

        try
        {
            if (_useChecksum == true)
            {
                uint8[] finalData = _data;
                finalData += csum;

                string test = "";
                foreach (uint8 d in finalData)
                {
                    test += d.to_string() + ", ";
                }
                debug (@"Sending: $test\n");

                _socket.send (finalData);
            }
            else
            {
                string test = "";
                foreach (uint8 d in _data)
                {
                    test += d.to_string() + ", ";
                }
                debug (@"Sending: $test\n");

                _socket.send (_data);
            }
        }
        catch (GLib.Error ex)
        {
            print (@"Failed to send data: $(ex.message)\n");
        }
    }

    private uint8[] read_data ()
    {
        uint8[] buffer = new uint8[14];
        GLib.Cancellable cancel = new GLib.Cancellable ();

        try
        {
            _socket.receive (buffer, cancel);

            debug ("Received: ");
            foreach (var i in buffer)
            {
                debug (@"$(i), ");
            }

            debug ("\n");
        }
        catch (GLib.Error ex)
        {
            print (@"Failed to receive data: $(ex.message)\n");
        }

        return buffer;
    }
}

