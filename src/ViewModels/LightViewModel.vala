public class Huely.LightViewModel : Object
{
    public Huely.ObservableList<Huely.Light> lights
    {
        get;
        default = new Huely.ObservableList<Huely.Light> ();
    }

    construct
    {
        lights.add (new Huely.Light () { name = "Light 1", color = "#FF0000", isOn = true });
            //new Huely.Light () { name = "Light 2", color = "#00FF00", isOn = false },
            //new Huely.Light () { name = "Light 3", color = "#0000FF", isOn = true }
    }

    // FIXME - Remove this.
    public void load_more_lights ()
    {
        this.lights.add (this.lights[0].copy ());
        this.lights.add (this.lights[1].copy ());
        this.lights.add (this.lights[2].copy ());
    }
}
