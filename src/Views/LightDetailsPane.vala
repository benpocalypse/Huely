public class Huely.LightDetailsPane : Gtk.ScrolledWindow, Huely.IPaneView
{
    private Huely.Light? _light;
    private Gtk.Box contentBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Button setButton = new Gtk.Button ();
    private Gtk.Entry nameEntry = new Gtk.Entry ();
    private Huely.ColorChooser chooser;

    private Gtk.Label doSomething = new Gtk.Label ("Select a light from the list on the left.") {margin = 20};
    private bool _noSelection = true;

    construct
    {
        Gtk.Label nameLabel = new Gtk.Label ("Name:");
        nameLabel.vexpand = false;
        nameLabel.margin = 12;

        nameEntry.set_sensitive (false);
        nameEntry.vexpand = false;
        nameEntry.margin = 5;
        nameEntry.margin_top = 10;
        Gtk.Box nameBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        nameBox.vexpand = false;
        nameBox.add (nameLabel);
        nameBox.add (nameEntry);

        contentBox.valign = Gtk.Align.FILL;

        // TODO - Make a proper palette parser or something. This is ugly.
        string [] paletteStrings =
        {
            "#6074ab",
            "#6b9acf",
            "#8bbde6",
            "#aae0f3",
            "#c8eded",
            "#faffe0",
            "#dde6e0",
            "#b4bec2",
            "#949da8",
            "#7a7a99",
            "#5b5280",
            "#4e3161",
            "#421e42",
            "#612447",
            "#7a3757",
            "#96485b",
            "#bd6868",
            "#d18b79",
            "#dbac8c",
            "#e6cfa1",
            "#e7ebbc",
            "#b2dba0",
            "#87c293",
            "#70a18f",
            "#637c8f",
            "#b56e75",
            "#c98f8f",
            "#dfb6ae",
            "#edd5ca",
            "#bd7182",
            "#9e5476",
            "#753c6a"
        };

        chooser = new Huely.ColorChooser (3, paletteStrings);
        chooser.margin = 10;

        setButton.margin_right = 10;
        setButton.margin_bottom = 10;
        setButton.halign = Gtk.Align.END;
        setButton.label = "Set";
        setButton.clicked.connect (() =>
        {
            var rgba = chooser.SelectedColor;
            uint8 red = ((uint8)(rgba.red * 255));
            uint8 green = ((uint8)(rgba.green * 255));
            uint8 blue = ((uint8)(rgba.blue * 255));

            var loop = new MainLoop();
            _light.ConnectAsync.begin((obj, res) =>
            {
                _light.ConnectAsync.end (res);
                loop.quit();
            });
            loop.run();

            _light.Name = nameEntry.text;
            _light.SetColor (red, green, blue);
            _light.SetBrightness (_light.Brightness);
        });

        setButton.set_sensitive (false);

        contentBox.pack_start (nameBox, false, false);
        contentBox.pack_start (chooser, false, false);
        contentBox.pack_start (setButton, false, false);

        this.width_request = 250;
        this.add(doSomething);
    }

    public void Activate ()
    {

    }

    public void Deactivate ()
    {

    }

    public void LightSelected (Huely.Light? light)
    {
        if (_noSelection == true)
        {
            this.remove (doSomething);
            this.add (contentBox);
            _noSelection = false;
        }

        print ("Light selected!!\n");
        _light = light;

        _light.notify.connect ((sender, property) =>
        {
            print (@"Something happened: $(_light.Name)!!!\n");

            setButton.set_sensitive (true);
            nameEntry.set_sensitive (true);
            nameEntry.text = _light.Name;
            chooser.ChooseColor (light.Color);
        });

        _light.notify_property ("Name");

        this.show_all ();
    }
}
