public class Huely.ColorChooser : Gtk.Grid
{
    private Huely.ColorGridButton previouslyClickedButton = null;

    public ColorChooser (int numColumns, string [] paletteString)
    {
        this.row_spacing = 5;
        this.column_spacing = 5;

        Gdk.RGBA[] palette = new Gdk.RGBA[0];
        int x = 0;
        int y = 0;

        foreach (var s in paletteString)
        {
            Gdk.RGBA parser = Gdk.RGBA ();
            parser.parse (s);
            palette += parser;

            Huely.ColorGridButton colorButton = new Huely.ColorGridButton ();//.from_icon_name ("checkbox-checked-symbolic", Gtk.IconSize.BUTTON);
            colorButton.Row = y;
            colorButton.Column = x;
            colorButton.Color = parser;
            colorButton.height_request = 25;
            colorButton.width_request = 50;
            colorButton.override_background_color (Gtk.StateFlags.NORMAL, parser);

            colorButton.clicked.connect (() =>
            {
                int tempCol;
                int tempRow;
                Gdk.RGBA tempColor;

                if (previouslyClickedButton != null)
                {
                    tempRow = previouslyClickedButton.Row;
                    tempCol = previouslyClickedButton.Column;
                    tempColor = previouslyClickedButton.Color;

                    this.remove (previouslyClickedButton);

                    previouslyClickedButton = new Huely.ColorGridButton.without_icon ();

                    previouslyClickedButton.height_request = 25;
                    previouslyClickedButton.width_request = 50;
                    previouslyClickedButton.override_background_color (Gtk.StateFlags.NORMAL, tempColor);
                    previouslyClickedButton.Row = tempRow;
                    previouslyClickedButton.Column = tempCol;
                    previouslyClickedButton.Color = tempColor;

                    this.attach (previouslyClickedButton, previouslyClickedButton.Column, previouslyClickedButton.Row);
                }

                tempCol = colorButton.Column;
                tempRow = colorButton.Row;
                tempColor = colorButton.Color;

                print (@"colorButton.Column = $(tempCol), colorButton.Row = $(tempRow)\n");

                this.remove (colorButton);

                colorButton = new Huely.ColorGridButton.from_icon_name ("checkbox-checked-symbolic", Gtk.IconSize.BUTTON);
                colorButton.height_request = 25;
                colorButton.width_request = 50;
                colorButton.override_background_color (Gtk.StateFlags.NORMAL, tempColor);
                colorButton.Row = tempRow;
                colorButton.Column = tempCol;
                colorButton.Color = tempColor;

                print (@"colorButton.Column = $(colorButton.Column), colorButton.Row = $(colorButton.Row)\n");

                previouslyClickedButton = colorButton;
                this.attach (colorButton, colorButton.Column, colorButton.Row);

                this.show_all ();
            });

            this.attach (colorButton, x, y);

            if (x < numColumns)
            {
                x++;
            }
            else
            {
                x = 0;
                y++;
            }
        }
    }
}
