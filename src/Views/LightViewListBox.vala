public class Huely.LightViewListBox : Gtk.ListBox
{
    private Huely.LightViewModel _viewModel
    {
        get;
        set;
        default = new Huely.LightViewModel ();
    }

    private Gtk.GestureLongPress glp;

    public LightViewListBox (Huely.LightViewModel viewModel)
    {
        _viewModel= viewModel;

        this.bind_model (this._viewModel.Lights , item =>
        {
            return_val_if_fail (item is Huely.Light, null);
            return new LightListBoxRow.with_light ((Huely.Light) item);
        });

        _viewModel.notify.connect (() =>
        {
            this.notify_property ("ViewModel");
        });

        glp = new Gtk.GestureLongPress (this);

        glp.propagation_phase = Gtk.PropagationPhase.TARGET;
        //glp.delay_factor = 1.0d;
        glp.pressed.connect ((x, y) =>
        {
            var row = ((Huely.LightListBoxRow)this.get_row_at_y ((int)y));

            print (@"Long pressed!!\n");

            if (row != null)
            {
                print (@"Clicked!\n");
                row.LongPressed ();
            }
        });

        glp.cancelled.connect (() =>
        {
            print (@"Long press cancelled!!\n");
        });
    }
}

