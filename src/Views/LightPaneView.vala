public class Huely.LightPaneView : Gtk.ScrolledWindow, Huely.IPaneView
{
    private Huely.LightViewModel _viewModel
    {
        get;
        set;
        default = new Huely.LightViewModel ();
    }

    private Huely.LightViewListBox _lightViewList;
    private Gtk.Box _spinnerBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

    construct
    {
        this.valign = Gtk.Align.FILL;
        this.set_shadow_type (Gtk.ShadowType.IN);
        this.width_request = 250;
    }

    public LightPaneView(Huely.LightViewModel viewModel)
    {
        _lightViewList = new Huely.LightViewListBox (viewModel);
        this.add (_lightViewList);

        // TODO - If the ViewModel doesn't contain lights, perhaps
        // show a nice "onboarding" display explaining how to search
        // for lights.
    }

    public void UnselectAll ()
    {
        _lightViewList.unselect_all ();
    }

    public Huely.Light GetSelectedLight ()
    {
        return
            ((LightListBoxRow)_lightViewList.get_selected_row ()) == null ?
                null :
                ((LightListBoxRow)_lightViewList.get_selected_row ()).light;
    }

    public void DisplaySearchingForLights ()
    {
        this.remove (_lightViewList);

        _spinnerBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        _spinnerBox.valign = Gtk.Align.CENTER;
        Gtk.Label spinnerLabel = new Gtk.Label ("Searching for lights...");

        Gtk.Spinner spinner = new Gtk.Spinner ();
        spinner.margin = 10;
        spinner.width_request = 32;
        spinner.height_request = 32;

        _spinnerBox.add (spinner);
        _spinnerBox.add (spinnerLabel);

        this.remove (_lightViewList);
        this.add (_spinnerBox);
        this.show_all ();
        spinner.start ();
    }

    public void DisplayLightList ()
    {
        this.remove (_spinnerBox);
        this.add (_lightViewList);
        this.show_all ();
    }

    public void Activate ()
    {
        UnselectAll ();
    }

    public void Deactivate ()
    {

    }
}

