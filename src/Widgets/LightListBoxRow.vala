public class Huely.LightListBoxRow : Gtk.ListBoxRow
{
    public string LightName
    {
        get { return _lightName.label; }
        set { _lightName.label = value; }
    }
    public Gtk.Label _lightName;
    private Gtk.Label _ipAddress;
    private Gtk.Revealer _checkboxRevealer = new Gtk.Revealer ();
    private Gtk.CheckButton _checkButton = new Gtk.CheckButton ();
    public bool IsChecked { get; set; }
    public Huely.Light? Light { get; set; }

    construct
    {
        if (this.Light != null)
        {
            this.Light.bind_property (
                "Name",
                this._lightName,
                "label",
                BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
            );
        }

        IsChecked = false;
    }

    public LightListBoxRow.with_light (Huely.Light light)
    {
        this.Light = light;

        _lightName  = new Gtk.Label (light.Name)
        {
            halign = Gtk.Align.START,
            margin_left = 5,
            margin_top = 5,
            margin_right = 12
        };

        _ipAddress  = new Gtk.Label (light.IpAddress)
        {
            halign = Gtk.Align.START,
            margin_left = 12,
            margin_top = 5,
            margin_right = 12,
            margin_bottom = 3
        };

        Gtk.Box verticalBoxInner = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        verticalBoxInner.halign = Gtk.Align.START;
        Gtk.Box verticalBoxOuter = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        Gtk.Box horizontalBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        Gtk.Box horizontalBoxOuter = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        Gtk.StyleContext context = new Gtk.StyleContext ();
        Pango.FontDescription font = context.get_font (Gtk.StateFlags.NORMAL);
        font.set_size (7 * 1024);
        font.set_style (Pango.Style.ITALIC);
        _ipAddress.override_font (font);

        verticalBoxInner.add (_lightName);
        verticalBoxInner.add (_ipAddress);

        Gtk.Scale brightnessScale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 100, 1);
        brightnessScale.margin_left = 10;
        brightnessScale.margin_right = 10;
        brightnessScale.set_draw_value (false);
        brightnessScale.set_value (Light.Brightness);

        brightnessScale.button_release_event.connect ((val) =>
        {
            Light.SetBrightness (brightnessScale.get_value());
            return base.button_release_event (val);
        });

        var colorButton = new Gtk.CheckButton ();
        var colorButtonStyle = colorButton.get_style_context ();

        // FIXME - Re-implement this outside of Granite
        //colorButtonStyle.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
        colorButton.margin = 10;
        colorButton.halign = Gtk.Align.END;
        colorButton.set_active(Light.IsOn);

        colorButton.toggled.connect (() =>
        {
            Light.set_state (colorButton.get_active());
        });

        var connectedIcon = new Gtk.Image.from_icon_name ("network-cellular-offline-symbolic", Gtk.IconSize.BUTTON);
        if (Light.IsConnected == true)
        {
            connectedIcon = new Gtk.Image.from_icon_name ("network-wireless-signal-excellent-symbolic", Gtk.IconSize.BUTTON);
        }
        else
        {
            connectedIcon = new Gtk.Image.from_icon_name ("network-cellular-offline-symbolic", Gtk.IconSize.BUTTON);
        }

        Gdk.RGBA parser = Gdk.RGBA ();
        parser.parse ("#" + Light.Red.to_string ("%x") + Light.Green.to_string ("%x") + Light.Blue.to_string ("%x"));

        Huely.ColorGridButton lightColorButton = new Huely.ColorGridButton.without_icon ();
        lightColorButton.Color = parser;
        lightColorButton.margin_top = 10;
        lightColorButton.margin_right = 5;
        lightColorButton.margin_left = 10;
        lightColorButton.margin_bottom = 10;
        lightColorButton.sensitive = false;
        lightColorButton.Color = parser;

        light.notify.connect (() =>
        {
            colorButton.set_active(Light.IsOn);

            parser.parse ("#" + Light.Red.to_string ("%x") + Light.Green.to_string ("%x") + Light.Blue.to_string ("%x"));
            lightColorButton.Color = parser;

            brightnessScale.set_value (Light.Brightness);

            if (Light.IsConnected == true)
            {
                connectedIcon = new Gtk.Image.from_icon_name ("network-wireless-signal-excellent-symbolic", Gtk.IconSize.BUTTON);
            }
            else
            {
                connectedIcon = new Gtk.Image.from_icon_name ("network-cellular-offline-symbolic", Gtk.IconSize.BUTTON);
            }
        });

        _checkButton.sensitive = false;
        _checkButton.margin_left = 10;
        _checkButton.set_active (false);

        _checkboxRevealer.add (_checkButton);
        _checkboxRevealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_LEFT);
        _checkboxRevealer.set_reveal_child (false);

        horizontalBox.pack_start (lightColorButton, false, false, 0);
        horizontalBox.pack_start (verticalBoxInner, false, false, 0);
        horizontalBox.pack_start (new Gtk.Label (""), true, true, 0); // Filler to pad out the row horizontally.
        horizontalBox.pack_start (connectedIcon, false, false, 0);

        var onOffSwitch = new Gtk.Switch ();
        onOffSwitch.margin = 5;

        onOffSwitch.set_state (Light.IsOn);

        onOffSwitch.state_set.connect ((val) =>
        {
            Light.set_state (val);
            onOffSwitch.active = val;

            return val;
        });

        horizontalBox.pack_end (onOffSwitch, false, false, 0);

        verticalBoxOuter.add (horizontalBox);
        verticalBoxOuter.add (brightnessScale);

        horizontalBoxOuter.pack_start (_checkboxRevealer, false, false, 0);
        horizontalBoxOuter.pack_start (verticalBoxOuter, true, true, 0);

        add (horizontalBoxOuter);
        this.show_all ();
    }

    public void LongPressed ()
    {
        _checkboxRevealer.set_transition_type (
            _checkboxRevealer.get_reveal_child () == false ?
                Gtk.RevealerTransitionType.SLIDE_RIGHT :
                Gtk.RevealerTransitionType.SLIDE_LEFT);

        _checkButton.set_active (!_checkButton.get_active ());
        _checkboxRevealer.set_reveal_child (!_checkboxRevealer.get_reveal_child ());
        IsChecked = _checkButton.active;
    }

    public void set_name (string name)
    {
        _lightName.set_label (name);
        Light.Name = name;
    }

    public void set_ip_address (string ipAddress)
    {
        _ipAddress.set_label (ipAddress);
    }

    public LightListBoxRow with_name(string name)
    {
        set_name (name);
        return this;
    }

    public LightListBoxRow.with_ip_address (string ipAddress)
    {
        set_ip_address (ipAddress);
    }
}
