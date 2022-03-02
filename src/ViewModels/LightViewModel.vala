public class Huely.LightViewModel : Object
{
    public Huely.ObservableList<Huely.Light> Lights
    {
        get;
        default = new Huely.ObservableList<Huely.Light> ();
    }

    construct
    {
        Lights.items_changed.connect((item) =>
        {
            this.notify_property ("Lights");
            debug ("LightViewModel.Lights notify()\n");
        });
    }
}
