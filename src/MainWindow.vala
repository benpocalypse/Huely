namespace Huely {
    public class MainWindow : Hdy.ApplicationWindow {
        public weak Huely.Application app { get; construct; }

        // Widgets
        public const string ACTION_PREFIX = "win.";
        public const string ACTION_FULLSCREEN = "action_fullscreen";
        public const string ACTION_QUIT = "action_quit";

        public SimpleActionGroup actions { get; set; }
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        public enum WindowState {
            NORMAL = 0,
            MAXIMIZED = 1,
            FULLSCREEN = 2
        }

        private const ActionEntry[] ACTION_ENTRIES = {
            { ACTION_FULLSCREEN, action_fullscreen },
            { ACTION_QUIT, action_quit },
        };

        private static void define_action_accelerators () {
            // Define action accelerators (keyboard shortcuts).
            action_accelerators.set (ACTION_FULLSCREEN, "F11");
            action_accelerators.set (ACTION_QUIT, "<Control>q");
        }

        public MainWindow (Huely.Application application) {
            Object (
                // We must set the inherited application property for Hdy.ApplicationWindow
                // to initialise properly. However, this is not a set-type property (get; set;)
                // so the assignment is made after construction, which means that we cannot
                // reference the application during the construct method. This is why we also
                // declare a property called app that is construct-type (get; construct;) which
                // is assigned before the constructors are run.
                //
                // So use the app property when referencing the application instance from
                // the constructors. Anywhere else, they can be used interchangeably.
                app: application,
                application: application,                    // DON’T use in constructors; won’t have been assigned yet.
                height_request: 200,
                width_request: 200,
                hide_titlebar_when_maximized: true,          // FIXME: This does not seem to have an effect. Why not?
                icon_name: "com.github.benpocalypse.Huely"
            );
        }

        // This constructor is guaranteed to be run only once during the lifetime of the application.
        static construct {
            // Initialise the Handy library.
            // https://gnome.pages.gitlab.gnome.org/libhandy/
            // (Apps in elementary OS 6 use the Handy library extensions
            // instead of GTKApplicationWindow, etc., directly.)
            Hdy.init();

            // Define acclerators (keyboard shortcuts) for actions.
            MainWindow.define_action_accelerators ();
        }

        // This constructor will be called every time an instance of this class is created.
        construct {
            // State preservation: save window dimensions and location on window close.
            // See: https://docs.elementary.io/hig/user-workflow/closing
            set_up_state_preservation ();

            // State preservation: restore window dimensions and location from last run.
            // See https://docs.elementary.io/hig/user-workflow/normal-launch#state
            restore_window_state ();

            // Create window layout.
            create_layout ();

            // Set up actions (with accelerators) for full screen, quit, etc.
            set_up_actions ();

            // Make all widgets (the interface) visible.
            show_all ();
        }

        // Layout.
        private Hdy.Leaflet leaf1;
        private Hdy.HeaderBar headrbar2;
        private Hdy.HeaderBar headrbar1;
        private Gtk.Box contentBox;
        private Hdy.Leaflet leaf2;
        private Gtk.ScrolledWindow scrolledWindow;

        private void create_layout () {
            // Unlike GTK, in Handy, the header bar is added to the window’s content area.
            // See https://gnome.pages.gitlab.gnome.org/libhandy/doc/1-latest/HdyHeaderBar.html

            Hdy.TitleBar titlebar = new Hdy.TitleBar();

            leaf1 = new Hdy.Leaflet();
            leaf1.set_transition_type (Hdy.LeafletTransitionType.SLIDE);
            leaf1.transition_type = Hdy.LeafletTransitionType.SLIDE;
            leaf1.visible = true;

            headrbar1 = new Hdy.HeaderBar ();
            headrbar1.set_title ("Huely");
            headrbar1.visible = true;
            headrbar1.show_close_button = true;

            headrbar2 = new Hdy.HeaderBar ();
            headrbar2.set_title ("Details");
            headrbar2.visible = true;
            headrbar2.hexpand = true;
            headrbar2.show_close_button = true;

            Gtk.Button button1 = new Gtk.Button.from_icon_name ("go-previous-symbolic");
            button1.clicked.connect (on_back_button_clicked);

            Hdy.HeaderGroup headrGroup = new Hdy.HeaderGroup ();
            headrGroup.add_header_bar (headrbar1);
            headrGroup.add_header_bar (headrbar2);
            headrGroup.set_decorate_all (false);

            // This 'ugliness' is responsible for hiding/showing the back button
            // on the Details pane when size permits.
            headrGroup.update_decoration_layouts.connect (() =>
            {
                var childName = leaf2.get_visible_child ().name;

                if (childName == "GtkScrolledWindow")
                {
                    button1.visible = false;
                }
                else
                {
                    if (childName == "GtkBox" && button1.visible == true)
                    {
                        button1.visible = false;
                    }
                    else
                    {
                        button1.visible = true;
                    }
                }
            });

            Gtk.Label nameLabel = new Gtk.Label ("Name:");
            nameLabel.margin = 12;
            Gtk.Entry nameEntry = new Gtk.Entry ();
            nameEntry.margin = 5;
            nameEntry.margin_top = 10;
            Gtk.Box nameBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            nameBox.add (nameLabel);
            nameBox.add (nameEntry);

            Gtk.ColorChooserWidget colorChooser = new Gtk.ColorChooserWidget ();
            colorChooser.margin = 12;

            // TODO - Make a proper palette parser or something. This is ugly.
            Gdk.RGBA parser1 = Gdk.RGBA ();
            parser1.parse ("#a0ddd3");
            Gdk.RGBA parser2 = Gdk.RGBA();
            parser2.parse ("#6fb0b7");
            Gdk.RGBA parser3 = Gdk.RGBA();
            parser3.parse ("#577f9d");
            Gdk.RGBA parser4 = Gdk.RGBA();
            parser4.parse ("#4a5786");
            Gdk.RGBA parser5 = Gdk.RGBA();
            parser5.parse ("#3e3b66");
            Gdk.RGBA parser6 = Gdk.RGBA();
            parser6.parse ("#392945");
            Gdk.RGBA parser7 = Gdk.RGBA();
            parser7.parse ("#2d1e2f");
            Gdk.RGBA parser8 = Gdk.RGBA();
            parser8.parse ("#452e3f");
            Gdk.RGBA parser9 = Gdk.RGBA();
            parser9.parse ("#5d4550");
            Gdk.RGBA parser10 = Gdk.RGBA();
            parser10.parse ("#d8725e");
            Gdk.RGBA parser11 = Gdk.RGBA();
            parser11.parse ("#f09f71");
            Gdk.RGBA parser12 = Gdk.RGBA();
            parser12.parse ("#f7cf91");
            Gdk.RGBA[] palette = {parser1,parser2,parser3,parser4,parser5,parser6,parser7,parser8, parser9,parser10,parser11,parser12};
            colorChooser.add_palette (Gtk.Orientation.VERTICAL, 3, palette);

            contentBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            contentBox.add (nameBox);
            contentBox.add (colorChooser);

            leaf2 = new Hdy.Leaflet ();
            leaf2.set_transition_type (Hdy.LeafletTransitionType.SLIDE);
            leaf2.transition_type = Hdy.LeafletTransitionType.SLIDE;

            leaf1.add (headrbar1);
            headrbar2.add (button1);
            leaf1.add (headrbar2);

            titlebar.add(leaf1);

            LightView lightView = new LightView ();

            Gtk.Button setButton = new Gtk.Button ();
            setButton.margin = 5;
            setButton.halign = Gtk.Align.END;
            setButton.label = "Set";
            setButton.clicked.connect (() =>
            {
                if (lightView.get_selected_row () != null)
                {
                    var row = ((LightListBoxRow)lightView.get_selected_row ());

                    var rgba = colorChooser.get_rgba ();
                    uint8 red = ((uint8)(rgba.red * 255));
                    uint8 green = ((uint8)(rgba.green * 255));
                    uint8 blue = ((uint8)(rgba.blue * 255));

                    row.set_name (nameEntry.text);
                    row.light.Connect ();
                    row.light.SetColor (red, green, blue);
                }
            });

            setButton.set_sensitive (false);

            lightView.row_selected.connect ((row) =>
            {
                var lightRow = ((LightListBoxRow)row);
                nameEntry.text = lightRow.LightName;
                leaf1.set_visible_child (headrbar2);
                leaf2.set_visible_child (contentBox);
                setButton.set_sensitive (true);
            });

            lightView.notify.connect (() =>
            {
               print ("lightView updated!\n");
            });

            contentBox.add (setButton);

            var searchButton = new Gtk.Button.from_icon_name ("system-search-symbolic");
            searchButton.margin = 5;

            searchButton.clicked.connect (() =>
            {
                print ("Disconvering lights...\n");
                LightDiscovery dl = new LightDiscovery ();
                lightView.clear ();
                lightView.add_lights (dl.DiscoverLights ().data);
                lightView.show_all();
            });

            headrbar1.add (searchButton);

            scrolledWindow = new Gtk.ScrolledWindow (null, null);
            scrolledWindow.set_shadow_type (Gtk.ShadowType.IN);
            scrolledWindow.add (lightView);
            leaf2.add (scrolledWindow);
            leaf2.add (contentBox);

            // These sizegroups in combination with the leaflets are what make the adaptive magic happen.
            Gtk.SizeGroup sizegroup1 = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
            sizegroup1.add_widget (headrbar1);
            sizegroup1.add_widget (scrolledWindow);

            Gtk.SizeGroup sizegroup3 = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
            sizegroup3.add_widget (headrbar2);
            sizegroup3.add_widget (contentBox);

            Gtk.Grid grid = new Gtk.Grid();
            grid.attach (titlebar, 0, 0);
            grid.attach (leaf2, 0, 1);

            add (grid);
        }

        [GtkCallback]
        public void on_switch_button_clicked ()
        {
            leaf1.set_visible_child (headrbar2);
            leaf2.set_visible_child (contentBox);
        }

        [GtkCallback]
        public void on_back_button_clicked ()
        {
            leaf1.set_visible_child (headrbar1);
            leaf2.set_visible_child (scrolledWindow);
        }

        // State preservation.

        private void set_up_state_preservation () {
            // Before the window is deleted, preserve its state.
            delete_event.connect (() => {
                preserve_window_state ();
                return false;
            });

            // Quit gracefully (ensuring state is preserved) when SIGINT or SIGTERM is received
            // (e.g., when run from terminal and terminated using Ctrl+C).
            Unix.signal_add (Posix.Signal.INT, quit_gracefully, Priority.HIGH);
            Unix.signal_add (Posix.Signal.TERM, quit_gracefully, Priority.HIGH);
        }

        private void restore_window_state () {
            var rect = Gdk.Rectangle ();
            Huely.saved_state.get ("window-size", "(ii)", out rect.width, out rect.height);

            default_width = rect.width;
            default_height = rect.height;

            var window_state = Huely.saved_state.get_enum ("window-state");
            switch (window_state) {
                case WindowState.MAXIMIZED:
                    maximize ();
                    break;
                case WindowState.FULLSCREEN:
                    fullscreen ();
                    break;
                default:
                    Huely.saved_state.get ("window-position", "(ii)", out rect.x, out rect.y);
                    if (rect.x != -1 && rect.y != -1) {
                        move (rect.x, rect.y);
                    }
                    break;
            }
        }

        private void preserve_window_state () {
            // Persist window dimensions and location.
            var state = get_window ().get_state ();
            if (Gdk.WindowState.MAXIMIZED in state) {
                Huely.saved_state.set_enum ("window-state", WindowState.MAXIMIZED);
            } else if (Gdk.WindowState.FULLSCREEN in state) {
                Huely.saved_state.set_enum ("window-state", WindowState.FULLSCREEN);
            } else {
                Huely.saved_state.set_enum ("window-state", WindowState.NORMAL);
                // Save window size
                int width, height;
                get_size (out width, out height);
                Huely.saved_state.set ("window-size", "(ii)", width, height);
            }

            int x, y;
            get_position (out x, out y);
            Huely.saved_state.set ("window-position", "(ii)", x, y);
        }

        // Actions.

        private void set_up_actions () {
            // Setup actions and their accelerators.
            actions = new SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("win", actions);

            foreach (var action in action_accelerators.get_keys ()) {
                var accels_array = action_accelerators[action].to_array ();
                accels_array += null;

                app.set_accels_for_action (ACTION_PREFIX + action, accels_array);
            }
        }

        // Action handlers.

        private void action_fullscreen () {
            if (Gdk.WindowState.FULLSCREEN in get_window ().get_state ()) {
                unfullscreen ();
            } else {
                fullscreen ();
            }
        }

        private void action_quit () {
            preserve_window_state ();
            destroy ();
        }

        // Graceful shutdown.

        public bool quit_gracefully () {
            action_quit ();
            return false;
        }
    }
}
