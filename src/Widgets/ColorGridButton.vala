public class Huely.ColorGridButton : Gtk.Button
{
    public int Column { get; set; }
    public int Row { get; set; }

    private Gdk.RGBA _color;
    public Gdk.RGBA Color //{ get; set; }
    {
        get { return this._color; }
        set
        {
            Gtk.CssProvider prov = new Gtk.CssProvider ();

            string red = ((uint8)(value.red * 255)).to_string ("%x");
            string green = ((uint8)(value.green * 255)).to_string ("%x");
            string blue = ((uint8)(value.blue * 255)).to_string ("%x");

            string cssData = @"* { background: #$red$green$blue; }";
            debug (@"cssData = $cssData\n");

            prov.load_from_data (cssData, cssData.length);

            var context = this.get_style_context ();
            context.add_provider (prov, Gtk.STYLE_PROVIDER_PRIORITY_USER);

            this._color = value;
        }
    }

    public ColorGridButton.from_icon_name (string iconName, Gtk.IconSize? size)
    {
        this.image = new Gtk.Image.from_icon_name (iconName, size);
    }

    public ColorGridButton.without_icon ()
    {
        this.image = null;
    }
}
