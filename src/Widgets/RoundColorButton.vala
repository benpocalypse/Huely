public enum Huely.AccentColor
{
    NO_PREFERENCE,
    RED,
    ORANGE,
    YELLOW,
    GREEN,
    MINT,
    BLUE,
    PURPLE,
    PINK,
    BROWN,
    GRAY;

    public string to_string () {
        switch (this) {
            case RED:
                return "strawberry";
            case ORANGE:
                return "orange";
            case YELLOW:
                return "banana";
            case GREEN:
                return "lime";
            case MINT:
                return "mint";
            case BLUE:
                return "blueberry";
            case PURPLE:
                return "grape";
            case PINK:
                return "bubblegum";
            case BROWN:
                return "cocoa";
            case GRAY:
                return "slate";
        }

        return "auto";
    }
}

public class Huely.RoundColorButton: Gtk.CheckButton
{

    private const string INTERFACE_SCHEMA = "org.gnome.desktop.interface";
    private const string STYLESHEET_KEY = "gtk-theme";
    private const string STYLESHEET_PREFIX = "io.elementary.stylesheet.";

    public AccentColor color { get; construct; }

    private static GLib.Settings interface_settings;

    public RoundColorButton (AccentColor color)
    {
        Object (
            color: color
        );
    }

    static construct
    {
        interface_settings = new GLib.Settings (INTERFACE_SCHEMA);
    }

    construct
    {
        Gtk.StyleContext context = get_style_context ();
        context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
        context.add_class (color.to_string ());

        /*
        realize.connect (() =>
        {
            active = false;// color == AccentColor.NO_PREFERENCE;// == pantheon_act.prefers_accent_color;

            toggled.connect (() =>
            {
                if (color != AccentColor.NO_PREFERENCE)
                {
                    interface_settings.set_string (
                        STYLESHEET_KEY,
                        STYLESHEET_PREFIX + color.to_string ()
                    );
                }
            });
        });
        */
    }
}

