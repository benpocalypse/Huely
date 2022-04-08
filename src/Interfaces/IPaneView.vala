public interface Huely.IPaneView
{
    public abstract void Activate ();
    public abstract void Deactivate ();

    public signal void LightSelected (Huely.Light light);
}
