public class Huely.LightListPane : Gtk.ScrolledWindow, Huely.IPaneView
{
    private Huely.LightViewModel view_model
    {
        get;
        set;
        default = new Huely.LightViewModel ();
    }

    private Huely.LightViewListBox _lightViewList;
    private Gtk.Box _spinnerBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box _lightViewBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Label _textLabel = new Gtk.Label ("Press search button to discover lights.") { margin = 10 };

    private Gtk.Revealer _actionBoxRevealer = new Gtk.Revealer ();
    private Gtk.Button _deleteLightButton = new Gtk.Button.from_icon_name ("user-trash-symbolic", Gtk.IconSize.LARGE_TOOLBAR) {margin = 3, sensitive = false};

    // TODO - implement Grouping.
    //private Gtk.Button _groupLightButton = new Gtk.Button.from_icon_name ("path-combine-symbolic", Gtk.IconSize.LARGE_TOOLBAR) {margin = 3, sensitive = false};

    construct
    {
        this.valign = Gtk.Align.FILL;
        this.set_shadow_type (Gtk.ShadowType.IN);
        this.width_request = 250;
    }

    public LightListPane (Huely.LightViewModel viewModel)
    {
        view_model = viewModel;
        _lightViewList = new Huely.LightViewListBox (viewModel);
        _lightViewList.row_selected.connect ((row) =>
        {
            // TODO - This is what causes the light row to be selected after
            //         the long press happens. Maybe add a bool here to check
            //         to see what the source of selection is?

            _actionBoxRevealer.set_transition_type (
                _actionBoxRevealer.get_reveal_child () == false ?
                    Gtk.RevealerTransitionType.SLIDE_DOWN :
                    Gtk.RevealerTransitionType.SLIDE_UP);

            if (_lightViewList.FromLongPress == false)
            {
                if (_lightViewList.NumberOfLightsSelected == 0)
                {
                    _actionBoxRevealer.set_reveal_child (false);
                }

                LightSelected (((Huely.LightListBoxRow)row).Light);
            }
            else
            {
                _actionBoxRevealer.set_reveal_child (true);
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

            /*
            if (_lightViewList.NumberOfLightsSelected > 1)
            {
                _groupLightButton.set_sensitive (true);
            }
            else
            {
                _groupLightButton.set_sensitive (false);
            }
            */
        });

        Gtk.Box buttonBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        buttonBox.pack_start (_deleteLightButton, true, true, 0);
        //buttonBox.pack_start (_groupLightButton, false, false, 0);

        _actionBoxRevealer.add (buttonBox);
        _actionBoxRevealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_UP);
        _actionBoxRevealer.set_reveal_child (false);

        _deleteLightButton.clicked.connect (() =>
        {
            print ("Light deleted!\r\n");

            _lightViewList.@foreach ((row) =>
            {
                var lightRow = (LightListBoxRow)row;
                if (lightRow.IsChecked)
                {
                    view_model.Lights.remove (lightRow.Light);
                }
            });

            _actionBoxRevealer.set_reveal_child (false);
        });

        _lightViewBox.pack_start (_lightViewList, true, true, 0);
        _lightViewBox.pack_end (_actionBoxRevealer, false, false, 0);

        _spinnerBox.valign = Gtk.Align.CENTER;
        Gtk.Label spinnerLabel = new Gtk.Label ("Searching for lights...");

        Gtk.Spinner spinner = new Gtk.Spinner ();
        spinner.margin = 10;
        spinner.width_request = 32;
        spinner.height_request = 32;
        spinner.start ();

        _spinnerBox.add (spinner);
        _spinnerBox.add (spinnerLabel);

        if (viewModel.Lights.length () == 0)
        {
            DisplayText ();
        }
        else
        {
            DisplayLightList ();
        }
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

    public void DisplayText (string displayText = "Press search button to discover lights.")
    {
        if (_lightViewBox.get_visible ())
        {
            _lightViewBox.set_visible (false);
            this.remove (_lightViewBox);
        }

        if (_spinnerBox.get_visible ())
        {
            _spinnerBox.set_visible (false);
            this.remove (_spinnerBox);
        }

        if (this.get_children ().index (_textLabel) != -1)
        {
            _textLabel.set_visible (true);
        }
        else
        {
            this.add (_textLabel);
        }

        this.show_all ();
    }

    public void DisplaySearchingForLights ()
    {
        if (_textLabel.get_visible ())
        {
            _textLabel.set_visible (false);
            this.remove (_textLabel);
        }

        if (_lightViewBox.get_visible ())
        {
            _lightViewBox.set_visible (false);
            this.remove (_lightViewBox);
        }

        if (this.get_children ().index (_spinnerBox) != -1)
        {
            _spinnerBox.set_visible (true);
        }
        else
        {
            this.add (_spinnerBox);
        }

        this.show_all ();
    }

    public void DisplayLightList ()
    {
        if (_textLabel.get_visible ())
        {
            _textLabel.set_visible (false);
            this.remove (_textLabel);
        }

        if (_spinnerBox.get_visible ())
        {
            _spinnerBox.set_visible (false);
            this.remove (_spinnerBox);
        }

        if (this.get_children ().index (_lightViewBox) != -1)
        {
            _lightViewBox.set_visible (true);
        }
        else
        {
            this.add (_lightViewBox);
        }

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

