public class Huely.LightListPane : Gtk.ScrolledWindow, Huely.IPaneView
{
    private Huely.LightViewModel _viewModel
    {
        get;
        set;
        default = new Huely.LightViewModel ();
    }

    private Huely.LightViewListBox _lightViewList;
    private Gtk.Box _spinnerBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box _lightViewBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Button _deleteLightButton = new Gtk.Button.from_icon_name ("user-trash-symbolic", Gtk.IconSize.LARGE_TOOLBAR) {margin = 3, sensitive = false};
    private Gtk.Button _groupLightButton = new Gtk.Button.from_icon_name ("path-combine-symbolic", Gtk.IconSize.LARGE_TOOLBAR) {margin = 3, sensitive = false};

    construct
    {
        this.valign = Gtk.Align.FILL;
        this.set_shadow_type (Gtk.ShadowType.IN);
        this.width_request = 250;
    }

    public LightListPane (Huely.LightViewModel viewModel)
    {
        _lightViewList = new Huely.LightViewListBox (viewModel);
        _lightViewList.row_selected.connect ((row) =>
        {
            // FIXME - This is what causes the light row to be selected after
            //         the long press happens. Maybe add a bool here to check
            //         to see what the source of selection is?

            if (_lightViewList.FromLongPress == false)
            {
                LightSelected (((Huely.LightListBoxRow)row).Light);
            }
            else
            {
                _lightViewList.unselect_all ();
            }

            if (_lightViewList.NumberOfLightsSelected >= 1)
            {
                _deleteLightButton.set_sensitive (true);
            }
            else
            {
                _deleteLightButton.set_sensitive (false);
            }

            if (_lightViewList.NumberOfLightsSelected > 1)
            {
                _groupLightButton.set_sensitive (true);
            }
            else
            {
                _groupLightButton.set_sensitive (false);
            }
        });

        Gtk.Box buttonBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        buttonBox.pack_start (_deleteLightButton, false, false, 0);
        buttonBox.pack_start (_groupLightButton, false, false, 0);

        _lightViewBox.pack_start (_lightViewList, true, true, 0);
        _lightViewBox.pack_end (buttonBox, false, false, 0);

        this.add (_lightViewBox);

        // TODO - If the ViewModel doesn't contain lights, perhaps
        // show a nice "onboarding" display explaining how to search
        // for lights. Or should that be handled by the main Window
        // and the left pane should be replaced with a different view,
        // outside of this one? Not sure yet.
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
                ((LightListBoxRow)_lightViewList.get_selected_row ()).Light;
    }

    public void DisplaySearchingForLights ()
    {
        _spinnerBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        _spinnerBox.valign = Gtk.Align.CENTER;
        Gtk.Label spinnerLabel = new Gtk.Label ("Searching for lights...");

        Gtk.Spinner spinner = new Gtk.Spinner ();
        spinner.margin = 10;
        spinner.width_request = 32;
        spinner.height_request = 32;

        _spinnerBox.add (spinner);
        _spinnerBox.add (spinnerLabel);

        this.remove (_lightViewBox);
        this.add (_spinnerBox);
        this.show_all ();
        spinner.start ();
    }

    public void DisplayLightList ()
    {
        this.remove (_spinnerBox);
        this.add (_lightViewBox);
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

