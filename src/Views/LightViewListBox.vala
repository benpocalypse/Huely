public class Huely.LightViewListBox : Gtk.ListBox
{
    private Huely.LightViewModel view_model
    {
        get;
        set;
        default = new Huely.LightViewModel ();
    }

    private Gtk.GestureLongPress glp;

    public bool FromLongPress = false;
    public int NumberOfLightsSelected = 0;

    public LightViewListBox (Huely.LightViewModel viewModel)
    {
        view_model= viewModel;

        this.bind_model (this.view_model.Lights , item =>
        {
            return_val_if_fail (item is Huely.Light, null);
            return new LightListBoxRow.with_light ((Huely.Light) item);
        });

        set_activate_on_single_click (false);
        glp = new Gtk.GestureLongPress (this);

        glp.propagation_phase = Gtk.PropagationPhase.TARGET;
        glp.pressed.connect ((x, y) =>
        {
            var row = ((Huely.LightListBoxRow)this.get_row_at_y ((int)y));

            print (@"Long pressed!!\n");

            if (row != null)
            {
                print (@"Clicked!\n");
                FromLongPress = true;
                row.LongPressed ();

                if (row.IsChecked == true)
                {
                    NumberOfLightsSelected++;
                }
                else
                {
                    NumberOfLightsSelected--;
                }

                this.unselect_all ();
            }
        });

        glp.cancelled.connect (() =>
        {
            print (@"Long press cancelled!!\n");
        });
    }

    public override void row_selected (Gtk.ListBoxRow? row)
    {
        print ("row_selected!!\n");
        FromLongPress = false;
    }
}

