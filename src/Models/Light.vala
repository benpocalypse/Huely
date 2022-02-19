public class Huely.Light : Object
{
    public string name { get; set; }
    public string ipAddress { get; set; }
    public string color { get; set; }
    public bool isOn { get; set; }
    public bool isConnected { get; set; }
    public bool useChecksum { get; set; }

    public enum TransitionType { Gradual = 0x3a, Strobe = 0x3c, Jump = 0x3b }
    public enum LedProtocol { LEDENET, LEDENET_ORIGINAL, Unknown }
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

    /// <summary> The date and time of the light. </summary>
    public DateTime Time { get; private set; }
    /// <summary> The protocol of the light. </summary>
    public LedProtocol Protocol { get; private set; }
    /// <summary> The color of the light. </summary>
    /// <summary> The warm white value of the light. </summary>
    public uint8 WarmWhite { get; private set; }
    /// <summary> The brightness of the light, from 0 to 100. </summary>
    public uint8 Brightness { get; private set; }
    /// <summary> Specifies whether the light is on or off. </summary>
    /// <summary> Specifies the mode of the light (Color, Preset, White, Custom). </summary>
    public LightMode Mode { get; private set; }

    private GLib.Socket _socket;
    private const uint16 PORT = 5577;

    public Light()
    {
        isConnected = false;
        useChecksum = true;
        Protocol = LedProtocol.Unknown;

        _socket = new GLib.Socket (GLib.SocketFamily.IPV4, GLib.SocketType.STREAM, GLib.SocketProtocol.TCP);
    }

    public Light.with_ip (string ip)
    {
        isConnected = false;
        useChecksum = true;
        Protocol = LedProtocol.Unknown;
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
        LedProtocol result = LedProtocol.Unknown;
        uint8[] args = {0x81, 0x8a, 0x8b};
        SendData(args);
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
            SendData(args);
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
                result = LedProtocol.Unknown;
            }
        }

        Protocol = result;

        return result;
    }

    public void Refresh ()
    {
        //Send request for status.
        if (Protocol == LedProtocol.LEDENET)
        {
            uint8[] args = {0x81, 0x8a, 0x8b};
            SendData (args);
        }
        else
        {
            if (Protocol == LedProtocol.LEDENET_ORIGINAL)
            {
                uint8[] args = {0xef, 0x01, 0x77};
                SendData (args);
            }
        }

        var dataRaw = ReadData ();
        string[] dataHex = new string[14];
        for (int i = 0; i < dataHex.length; i++)
            dataHex[i] = dataRaw[i].to_string ("X");

        if (Protocol == LedProtocol.LEDENET_ORIGINAL)
        if (dataHex[1] == "01")
            useChecksum = false;

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
        //Read and process the response.
        var dataRaw = await ReadDataAsync();
        string[] dataHex = new string[14];
        for (int i = 0; i < dataHex.Length; i++)
            dataHex[i] = dataRaw[i].ToString("X");

        //Check if it uses checksum.
        if (Protocol == LedProtocol.LEDENET_ORIGINAL)
            if (dataHex[1] == "01")
                UseCsum = false;

        //Check power state.
        if (dataHex[2] == "23")
            Power = true;
        else if (dataHex[2] == "24")
            Power = false;

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

    public void set_on (bool on)
    {
        if (on == true)
        {
            TurnOn ();
        }
        else
        {
            TurnOff ();
        }
    }

    public void TurnOn ()
    {
        if (Protocol == LedProtocol.LEDENET)
        {
            uint8[] args = {0x71, 0x23, 0x0f};
            SendData (args);
        }
        else
        {
            uint8[] args = {0xcc, 0x23, 0x33};
            SendData (args);
        }

        isOn = true;
    }

    public void TurnOff ()
    {
        if (Protocol == LedProtocol.LEDENET)
        {
            uint8[] args = {0x71, 0x24, 0x0f};
            SendData (args);
        }
        else
        {
            uint8[] args = {0xcc, 0x24, 0x33};
            SendData (args);
        }

        isOn = false;
    }

    public void SetColor (uint8 red, uint8 green, uint8 blue)
    {
        if (Protocol == LedProtocol.LEDENET)
        {
            uint8[] args = {0x41, red, green, blue, 0x00, 0x00, 0x0F};
            print (@"args.length = $(args.length)\n");
            SendData (args);
        }
        else
        {
            uint8[] args = {0x56, red, green, blue, 0xAA};
            SendData (args);
        }

        //Populate fields
        //Color = color;
        //WarmWhite = 0;
        //UpdateBrightness();
    }


    public DateTime GetTime ()
    {
        uint8[] args = {0x11, 0x1a, 0x1b, 0x0f};
        SendData (args);
        uint8[] data = ReadData ();
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

    private void SendData (uint8[] _data)
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

    private uint8[] ReadData ()
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

