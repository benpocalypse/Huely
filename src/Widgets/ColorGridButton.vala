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
            this.override_background_color (Gtk.StateFlags.NORMAL, value);
            //this.override_color (Gtk.StateFlags.NORMAL, value);
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
