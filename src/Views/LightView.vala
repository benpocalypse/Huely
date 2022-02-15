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

    public void add_light (Huely.Light light)
    {
        _view_model.lights.add (light);
    }

    public void add_lights (ObservableList<Huely.Light> lights)
    {
        //_view_model.lights.add_all (lights);
    }

    public void add_fake_light (string name)
    {
        _view_model.lights.add (new Light () { name = name, color = "#FF0000", isOn = true });
    }
}

