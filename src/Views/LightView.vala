public class Huely.LightView : Gtk.ListBox
{
    private Huely.LightViewModel _view_model = new Huely.LightViewModel ();

    protected override void dispose ()
    {
        //this._scrolled_window.unparent ();
        base.dispose ();
    }

/*
    [GtkCallback (name = "load-more-students")]
    private void load_more_students ()
    {
        this._view_model.load_more_students ();
    }
*/

    construct
    {
        this.bind_model (this._view_model.lights , item =>
        {
            return_val_if_fail (item is Huely.Light, null);
            return new LightListBoxRow ((Huely.Light) item);
        });
    }

    static construct
    {
        //set_css_name ("studentview");
    }
}
