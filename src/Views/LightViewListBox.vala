public class Huely.LightViewListBox : Gtk.ListBox
{
    private Huely.LightViewModel _viewModel
    {
        get;
        set;
        default = new Huely.LightViewModel ();
    }

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
    }
}

