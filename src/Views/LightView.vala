public class Huely.LightView : Gtk.ListBox
{
    public Huely.LightViewModel ViewModel
    {
        get;
        default = new Huely.LightViewModel ();
    }

    construct
    {
        this.bind_model (this.ViewModel.Lights , item =>
        {
            return_val_if_fail (item is Huely.Light, null);
            return new LightListBoxRow ((Huely.Light) item);
        });

        ViewModel.notify.connect (() =>
        {
            this.notify_property ("ViewModel");
            debug (@"Item added!");
        });
    }

    static construct
    {
        //set_css_name ("studentview");
    }

    public void clear ()
    {
        ViewModel.Lights.clear ();
    }

    public void add_light (Huely.Light light)
    {
        ViewModel.Lights.add (light);
    }

    public void add_lights (List<Huely.Light> lights)
    {
        ViewModel.Lights.add_all (lights);
    }
}

