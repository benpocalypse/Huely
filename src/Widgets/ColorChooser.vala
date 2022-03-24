public class Huely.ColorChooser : Gtk.Grid
{
    public Gdk.RGBA SelectedColor;
    private Huely.ColorGridButton _previouslyClickedButton = null;
    private int NumberOfColumns = 0;
    private int NumberOfRows = 0;

    public ColorChooser (int numColumns, string [] paletteString)
    {
        this.row_spacing = 5;
        this.column_spacing = 5;

        Gdk.RGBA[] palette = new Gdk.RGBA[0];
        int x = 0;
        int y = 0;

        bool firstButton = true;

        foreach (var s in paletteString)
        {
            Gdk.RGBA parser = Gdk.RGBA ();
            parser.parse (s);
            palette += parser;

            Huely.ColorGridButton colorButton = new Huely.ColorGridButton ();

            if (firstButton)
            {
                colorButton = new Huely.ColorGridButton.from_icon_name ("checkbox-checked-symbolic", Gtk.IconSize.BUTTON);
                SelectedColor = parser;
                _previouslyClickedButton = colorButton;
                firstButton = false;
            }

            colorButton.Row = y;
            colorButton.Column = x;
            colorButton.Color = parser;
            colorButton.height_request = 25;
            colorButton.width_request = 50;

            colorButton.clicked.connect ((btn) =>
            {
                var huelyButton = ((Huely.ColorGridButton)btn);

                if (SelectedColor != huelyButton.Color)
                {
                    SelectedColor = huelyButton.Color;
                    HandlePreviousButtonClick ();
                    HandleClick ((Huely.ColorGridButton)btn);
                }
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

        NumberOfColumns = numColumns + 1;
        NumberOfRows = y;
    }

    public void ChooseColor (Gdk.RGBA color)
    {
        for (int i = 0; i < NumberOfColumns; i++)
        {
            for (int j = 0; j < NumberOfRows; j++)
            {
                var btn = (Huely.ColorGridButton)this.get_child_at (i,j);
                if (btn.Color == color)
                {
                    HandlePreviousButtonClick ();
                    HandleClick (btn);
                }
            }
        }
    }

    private void HandlePreviousButtonClick ()
    {
        if (_previouslyClickedButton != null)
        {
            var tempRow = _previouslyClickedButton.Row;
            var tempCol = _previouslyClickedButton.Column;
            var tempColor = _previouslyClickedButton.Color;

            this.remove (_previouslyClickedButton);

            _previouslyClickedButton = new Huely.ColorGridButton.without_icon ();

            _previouslyClickedButton.clicked.connect ((btn) =>
            {
                var huelyButton = ((Huely.ColorGridButton)btn);

                if (huelyButton.Color != SelectedColor)
                {
                    HandlePreviousButtonClick ();
                    HandleClick ((Huely.ColorGridButton)btn);
                }
            });

            _previouslyClickedButton.height_request = 25;
            _previouslyClickedButton.width_request = 50;
            _previouslyClickedButton.Row = tempRow;
            _previouslyClickedButton.Column = tempCol;
            _previouslyClickedButton.Color = tempColor;

            this.attach (_previouslyClickedButton, _previouslyClickedButton.Column, _previouslyClickedButton.Row);
        }
    }

    private void HandleClick (Huely.ColorGridButton btn)
    {
        var tempCol = btn.Column;
        var tempRow = btn.Row;
        var tempColor = btn.Color;

        debug (@"btn.Column = $(tempCol), btn.Row = $(tempRow)\n");

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
            var huelyButton = ((Huely.ColorGridButton)btn);

            if (huelyButton.Color != SelectedColor)
            {
                HandlePreviousButtonClick ();
                HandleClick ((Huely.ColorGridButton)btn);
            }
        });

        debug (@"colorButton.Column = $(colorButton.Column), btn.Row = $(colorButton.Row)\n");

        this.attach (colorButton, colorButton.Column, colorButton.Row);
        this.show_all ();
    }
}
