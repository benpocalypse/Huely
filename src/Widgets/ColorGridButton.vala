public class Huely.ColorGridButton : Gtk.Button
{
    public int Column { get; set; }
    public int Row { get; set; }
    public Gdk.RGBA Color { get; set; }

    public ColorGridButton.from_icon_name (string iconName, Gtk.IconSize? size)
    {
        this.image = new Gtk.Image.from_icon_name (iconName, size);
    }

    public ColorGridButton.without_icon ()
    {
        this.image = null;
    }
}
