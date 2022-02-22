public class Huely.ColorChooser : Gtk.Grid
{
    public Gdk.RGBA SelectedColor;
    private Huely.ColorGridButton _previouslyClickedButton = null;

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

            Huely.ColorGridButton colorButton = new Huely.ColorGridButton ();
            colorButton.Row = y;
            colorButton.Column = x;
            colorButton.Color = parser;
            colorButton.height_request = 25;
            colorButton.width_request = 50;

            colorButton.clicked.connect ((btn) =>
            {
                SelectedColor = ((Huely.ColorGridButton)btn).Color;
                handlePreviousButtonClick();
                handleClick((Huely.ColorGridButton)btn);
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

    private void handlePreviousButtonClick ()
    {
        if (_previouslyClickedButton != null)
        {
            int tempCol;
            int tempRow;
            Gdk.RGBA tempColor;

            tempRow = _previouslyClickedButton.Row;
            tempCol = _previouslyClickedButton.Column;
            tempColor = _previouslyClickedButton.Color;

            this.remove (_previouslyClickedButton);

            _previouslyClickedButton = new Huely.ColorGridButton.without_icon ();

            _previouslyClickedButton.clicked.connect ((btn) =>
            {
                handlePreviousButtonClick();
                handleClick ((Huely.ColorGridButton)btn);
            });

            _previouslyClickedButton.height_request = 25;
            _previouslyClickedButton.width_request = 50;
            _previouslyClickedButton.Row = tempRow;
            _previouslyClickedButton.Column = tempCol;
            _previouslyClickedButton.Color = tempColor;

            this.attach (_previouslyClickedButton, _previouslyClickedButton.Column, _previouslyClickedButton.Row);
        }
    }

    private void handleClick (Huely.ColorGridButton btn)
    {
        int tempCol;
        int tempRow;
        Gdk.RGBA tempColor;

        tempCol = btn.Column;
        tempRow = btn.Row;
        tempColor = btn.Color;

        print (@"btn.Column = $(tempCol), btn.Row = $(tempRow)\n");

        this.remove (btn);

        Huely.ColorGridButton colorButton = new Huely.ColorGridButton.from_icon_name ("checkbox-checked-symbolic", Gtk.IconSize.BUTTON);
        colorButton.height_request = 25;
        colorButton.width_request = 50;
        colorButton.Row = tempRow;
        colorButton.Column = tempCol;
        colorButton.Color = tempColor;

        _previouslyClickedButton = colorButton;

        colorButton.clicked.connect ((btn) =>
        {
            handlePreviousButtonClick();
            handleClick((Huely.ColorGridButton)btn);
        });

        print (@"colorButton.Column = $(colorButton.Column), btn.Row = $(colorButton.Row)\n");
        this.attach (colorButton, colorButton.Column, colorButton.Row);

        this.show_all ();
    }
}
