public class Huely.ObservableList<T> : Object, ListModel
{
    public List<T> data = new List<T> ();

    public void add (T item)
    {
        var position = data.length ();
        data.append (item);
        items_changed (position, 0, 1);
    }

    public void add_all (List<T> items)
    {
        var position = data.length ();

        foreach (var item in items)
        {
            data.append (item);
        }

        items_changed (position, 0, items.length ());
    }

    public new T @get (uint index)
    {
        return data.nth_data (index);
    }

    public bool remove (T item)
    {
        var position = data.index (item);

        if (position == -1)
            return false;

        data.remove (item);
        items_changed (position, 1, 0);

        return true;
    }

    public void clear ()
    {
        var total = data.length ();

        foreach (var item in data)
            data.remove (item);

        items_changed (0,total,0);
    }

    public uint length ()
    {
        return data.length ();
    }

    Object? get_item (uint position)
    {
        return this[position] as Object;
    }

    Type get_item_type ()
    {
            return typeof (T);
    }

    uint get_n_items ()
    {
        return data.length ();
    }
}

