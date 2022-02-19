public class LightListBoxRow : Gtk.ListBoxRow
{
    private Gtk.Box _verticalBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box _horizontalBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

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
                "name",
                this._lightName,
                "label",
                BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
            );
        }
    }

    public LightListBoxRow.with_light (Huely.Light light)
    {
        this.light = light;

        _lightName  = new Gtk.Label (light.name)
        {
            halign = Gtk.Align.START,
            margin_left = 12,
            margin_top = 5,
            margin_right = 12
        };

        _ipAddress  = new Gtk.Label (light.ipAddress)
        {
            halign = Gtk.Align.START,
            margin_left = 12,
            margin_top = 5,
            margin_right = 12,
            margin_bottom = 5
        };

        Gtk.StyleContext context = new Gtk.StyleContext ();
        Pango.FontDescription font = context.get_font (Gtk.StateFlags.NORMAL);
        font.set_size (7 * 1024);
        font.set_style (Pango.Style.ITALIC);
        _ipAddress.override_font (font);

        _verticalBox.add (_lightName);
        _verticalBox.add (_ipAddress);

        Huely.RoundColorButton _colorButton = new Huely.RoundColorButton(Huely.AccentColor.NO_PREFERENCE);
        _colorButton.margin = 3;
        _colorButton.halign = Gtk.Align.END;
        _colorButton.toggled.connect (() =>
        {
            light.set_on (_colorButton.get_active());
        });
        light.notify.connect (() =>
        {
            print (@"isOn = $(light.isOn)");
            _colorButton.set_active(light.isOn);
        });

        _horizontalBox.add (_verticalBox);
        _horizontalBox.add (_colorButton);
        _horizontalBox.set_child_packing (_colorButton, true, true, 0, Gtk.PackType.END );

        add (_horizontalBox);

        /*
        Object (
            light: light
        );
        */
    }

    public void set_name (string name)
    {
        _lightName.set_label (name);
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
        //return this;
    }
}
