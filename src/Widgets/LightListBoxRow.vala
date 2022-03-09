public class LightListBoxRow : Gtk.ListBoxRow
{
    public string LightName
    {
        get { return _lightName.label; }
        set { _lightName.label = value; }
    }
    public Gtk.Label _lightName;
    private Gtk.Label _ipAddress;

    public Huely.Light? light { get; set; }//construct; }

    construct
    {
        if (this.light != null)
        {
            this.light.bind_property (
                "Name",
                this._lightName,
                "label",
                BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
            );
        }
    }

    public LightListBoxRow.with_light (Huely.Light light)
    {
        this.light = light;

        _lightName  = new Gtk.Label (light.Name)
        {
            halign = Gtk.Align.START,
            margin_left = 12,
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

        Gtk.Box _verticalBoxInner = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        Gtk.Box _verticalBoxOuter = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        Gtk.Box _horizontalBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        Gtk.StyleContext context = new Gtk.StyleContext ();
        Pango.FontDescription font = context.get_font (Gtk.StateFlags.NORMAL);
        font.set_size (7 * 1024);
        font.set_style (Pango.Style.ITALIC);
        _ipAddress.override_font (font);

        _verticalBoxInner.add (_lightName);
        _verticalBoxInner.add (_ipAddress);

        Gtk.Scale brightnessScale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 100, 1);
        brightnessScale.margin_left = 10;
        brightnessScale.margin_right = 10;
        brightnessScale.set_draw_value (false);

        brightnessScale.value_changed.connect ((val) =>
        {
            light.SetBrightness (val.get_value ());
        });

        var colorButton = new Gtk.CheckButton ();
        var colorButtonStyle = colorButton.get_style_context ();
        colorButtonStyle.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
        colorButton.margin = 3;
        colorButton.halign = Gtk.Align.END;
        colorButton.set_active(light.IsOn);

        colorButton.toggled.connect (() =>
        {
            light.set_state (colorButton.get_active());
        });

        light.notify.connect (() =>
        {
            debug (@"LightListBoxRow.IsOn = $(light.IsOn)\n");
            colorButton.set_active(light.IsOn);
        });

        _horizontalBox.add (_verticalBoxInner);
        _horizontalBox.add (colorButton);
        _horizontalBox.set_child_packing (colorButton, true, true, 0, Gtk.PackType.END );

        _verticalBoxOuter.add (_horizontalBox);
        _verticalBoxOuter.add (brightnessScale);

        add (_verticalBoxOuter);
    }

    public void set_name (string name)
    {
        _lightName.set_label (name);
        light.Name = name;
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
