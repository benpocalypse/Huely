public class Huely.Light : Object
{
    public string name { get; set; }
    public string ipAddress { get; set; }
    public string color { get; set; }
    public bool isOn { get; set; }

    public Light copy ()
    {
        return new Light ()
        {
            name = this.name,
            ipAddress = this.ipAddress,
            color = this.color,
            isOn = this.isOn
        };
    }
}
