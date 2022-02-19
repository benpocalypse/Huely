public class Huely.Light : Object
{
    public string name { get; set; }
    public string ipAddress { get; set; }
    public string color { get; set; }
    public bool isOn { get; set; }
    public bool isConnected { get; set; }
    public bool useChecksum { get; set; }
    public uint8 brightness { get; private set; }
    public LedProtocol protocol { get; private set; }
    public DateTime time { get; private set; }

    public enum TransitionType { Gradual = 0x3a, Strobe = 0x3c, Jump = 0x3b }
    public enum LedProtocol { LEDENET, LEDENET_ORIGINAL, UNKNOWN }
    public enum LightMode { Color, WarmWhite, Preset, Custom, Unknown }
    public enum PresetPattern
    {
        SevenColorsCrossFade = 0x25,
        RedGradualChange = 0x26,
        GreenGradualChange = 0x27,
        BlueGradualChange = 0x28,
        YellowGradualChange = 0x29,
        CyanGradualChange = 0x2a,
        PurpleGradualChange = 0x2b,
        WhiteGradualChange = 0x2c,
        RedGreenCrossFade = 0x2d,
        RedBlueCrossFade = 0x2e,
        GreenBlueCrossFade = 0x2f,
        SevenColorStrobeFlash = 0x30,
        RedStrobeFlash = 0x31,
        GreenStrobeFlash = 0x32,
        BlueStrobeFlash = 0x33,
        YellowStrobeFlash = 0x34,
        CyanStrobeFlash = 0x35,
        PurpleStrobeFlash = 0x36,
        WhiteStrobeFlash = 0x37,
        SevenColorsJumping = 0x38
    }

    // TODO - Decide if I want to keep/implement these.
    public uint8 WarmWhite { get; private set; }
    public LightMode Mode { get; private set; }

    private GLib.Socket _socket;
    private const uint16 PORT = 5577;

    public Light()
    {
        isConnected = false;
        useChecksum = true;
        protocol = LedProtocol.UNKNOWN;

        _socket = new GLib.Socket (GLib.SocketFamily.IPV4, GLib.SocketType.STREAM, GLib.SocketProtocol.TCP);
    }

    public Light.with_ip (string ip)
    {
        isConnected = false;
        useChecksum = true;
        protocol = LedProtocol.UNKNOWN;
        ipAddress = ip;

        _socket = new GLib.Socket (GLib.SocketFamily.IPV4, GLib.SocketType.STREAM, GLib.SocketProtocol.TCP);
        this.Connect ();
    }

    public Light copy ()
    {
        return new Light ()
        {
            name = this.name,
            ipAddress = this.ipAddress,
            color = this.color,
            isOn = this.isOn
        };
    }

    // Communications functions
    public void Connect ()
    {
        var addr = new InetAddress.from_string (ipAddress);
        var address = new InetSocketAddress(addr, PORT);

        try
        {
            _socket.set_timeout (1);
            isConnected = _socket.connect (address);
            print (@"Connected = $isConnected\n");
            GetProtocol ();
            Refresh ();
        }
        catch (GLib.Error error)
        {
            var msg = error.message;
            print (@"Failed to connect to light: $msg\n");
        }
    }


    private LedProtocol GetProtocol ()
    {
        LedProtocol result = LedProtocol.UNKNOWN;
        uint8[] args = {0x81, 0x8a, 0x8b};
        send_data (args);
        try
        {
            uint8[] buffer_ledenet = new uint8[14];
            GLib.Cancellable cancel = new GLib.Cancellable ();
            _socket.receive (buffer_ledenet, cancel);
            result = LedProtocol.LEDENET;
        }
        catch (GLib.Error error)
        {
            var msg = error.message;
            print (@"Error, not LEDENET due to: $msg\n");
            args = {0xef, 0x01, 0x77};
            send_data(args);
            try
            {
                uint8[] buffer_original = new uint8[14];
                _socket.receive (buffer_original);
                result = LedProtocol.LEDENET_ORIGINAL;
            }
            catch (GLib.Error error)
            {
                msg = error.message;
                print (@"Error, not LEDENET_ORIGINAL due to: $msg\n");
                result = LedProtocol.UNKNOWN;
            }
        }

        protocol = result;

        return result;
    }

    public void Refresh ()
    {
        //Send request for status.
        if (protocol == LedProtocol.LEDENET)
        {
            uint8[] args = {0x81, 0x8a, 0x8b};
            send_data (args);
        }
        else
        {
            if (protocol == LedProtocol.LEDENET_ORIGINAL)
            {
                uint8[] args = {0xef, 0x01, 0x77};
                send_data (args);
            }
        }

        var dataRaw = read_data ();
        string[] dataHex = new string[14];
        for (int i = 0; i < dataHex.length; i++)
            dataHex[i] = dataRaw[i].to_string ("X");

        if (protocol == LedProtocol.LEDENET_ORIGINAL && dataHex[1] == "01")
        {
            useChecksum = false;
        }

        //Check power state.
        if (dataHex[2] == "23")
        {
            print ("Light.isOn = true\n");
            isOn = true;
        }
        else if (dataHex[2] == "24")
        {
            print ("Light.isOn = false\n");
            isOn = false;
        }

        /*
        //Check light mode.
        Mode = Utilis.DetermineMode(dataHex[3], dataHex[9]);

        //Handle color property.
        switch (Mode)
        {
            case LightMode.Color:
                Color = new Color(dataRaw[6], dataRaw[7], dataRaw[8]);
                WarmWhite = 0;
                break;
            case LightMode.WarmWhite:
                Color = Colors.Empty;
                WarmWhite = dataRaw[9];
                break;
            case LightMode.Preset:
            case LightMode.Unknown:
            case LightMode.Custom:
                Color = Colors.Empty;
                WarmWhite = 0;
                break;
        }

        UpdateBrightness();

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
        if (protocol == LedProtocol.LEDENET)
        {
            uint8[] args = {0x71, 0x23, 0x0f};
            send_data (args);
        }
        else
        {
            uint8[] args = {0xcc, 0x23, 0x33};
            send_data (args);
        }

        isOn = true;
    }

    private void turn_off ()
    {
        if (protocol == LedProtocol.LEDENET)
        {
            uint8[] args = {0x71, 0x24, 0x0f};
            send_data (args);
        }
        else
        {
            uint8[] args = {0xcc, 0x24, 0x33};
            send_data (args);
        }

        isOn = false;
    }

    public void set_color (uint8 red, uint8 green, uint8 blue)
    {
        if (protocol == LedProtocol.LEDENET)
        {
            uint8[] args = {0x41, red, green, blue, 0x00, 0x00, 0x0F};
            print (@"args.length = $(args.length)\n");
            send_data (args);
        }
        else
        {
            uint8[] args = {0x56, red, green, blue, 0xAA};
            send_data (args);
        }

        //Populate fields
        //Color = color;
        //WarmWhite = 0;
        //UpdateBrightness();
    }


    public DateTime get_time ()
    {
        uint8[] args = {0x11, 0x1a, 0x1b, 0x0f};
        send_data (args);
        uint8[] data = read_data ();
        var time = new GLib.DateTime.local(
            data[3] + 2000,
            data[4],
            data[5],
            data[6],
            data[7],
            data[8]
        );

        print (@"Time = $time\n");

        return time;
    }

    private void send_data (uint8[] _data)
    {
        uint8 csum = 0;
        if (useChecksum == true)
        {
            for (int i = 0; i < _data.length; i++)
            {
                csum += _data[i];
            }
            csum = csum & 0xFF;
        }

        try
        {
            if (useChecksum == true)
            {
                uint8[] finalData = _data;
                finalData += csum;

                string test = "";
                foreach (uint8 d in finalData)
                {
                    test += d.to_string() + ", ";
                }
                print (@"Sending: $test\n");

                _socket.send (finalData);
            }
            else
            {
                string test = "";
                foreach (uint8 d in _data)
                {
                    test += d.to_string() + ", ";
                }
                print (@"Sending: $test\n");

                _socket.send (_data);
            }
        }
        catch (GLib.Error error)
        {
            print (@"Failed to send data: $(error.message)\n");
        }
    }

    private uint8[] read_data ()
    {
        uint8[] buffer = new uint8[14];
        GLib.Cancellable cancel = new GLib.Cancellable ();

        try
        {
            _socket.receive (buffer, cancel);
        }
        catch (GLib.Error error)
        {
            print (@"Failed to receive data: $(error.message)\n");
        }

        return buffer;
    }
}

