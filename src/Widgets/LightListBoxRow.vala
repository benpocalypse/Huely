public class LightListBoxRow : Gtk.ListBoxRow
{
    private Gtk.Box _verticalBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box _horizontalBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    public Gtk.Label LightName;
    private Gtk.Label _ipAddress;
    private Gtk.ColorButton _lightColor = new Gtk.ColorButton ();

    public Huely.Light? light { get; set; }//construct; }

    construct
    {
        if (this.light != null)
        {
            this.light.bind_property (
                "name",
                this.LightName,
                "label",
                BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
            );
        }
    }

/*
    public LightListBoxRow copy ()
    {
        return new LightListBoxRow ()
        {
            name = this.name,
            ipAddress = this.ipAddress,
            color = this.color,
            isOn = this.isOn
        };
    }
*/

    public LightListBoxRow.with_light (Huely.Light light)
    {
        this.light = light;

        LightName  = new Gtk.Label (light.name)
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

        _verticalBox.add (LightName);
        _verticalBox.add (_ipAddress);

        var rgba = new Gdk.RGBA ();
        rgba.parse (light.color);
        _lightColor.set_rgba (rgba);
        _lightColor.halign = Gtk.Align.END;
        _lightColor.margin = 5;

        _lightColor.color_set.connect (() =>
        {
            light.color = _lightColor.get_rgba ().to_string();
        });

        _horizontalBox.add (_verticalBox);
        _horizontalBox.add (_lightColor);

        add (_horizontalBox);

        /*
        Object (
            light: light
        );
        */
    }

    public void set_name (string name)
    {
        LightName.set_label (name);
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

    public LightListBoxRow.with_color (string rgba)
    {
        var rgbaColor = new Gdk.RGBA();
        rgbaColor.parse (rgba);
        _lightColor.set_rgba (rgbaColor);

        //return this;
    }
}
