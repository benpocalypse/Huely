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
                height_request: 420,
                width_request: 420,
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
        private Gtk.ListBox lightListBox;

        private void create_layout () {
            // Unlike GTK, in Handy, the header bar is added to the window’s content area.
            // See https://gnome.pages.gitlab.gnome.org/libhandy/doc/1-latest/HdyHeaderBar.html

            Hdy.TitleBar titlebar = new Hdy.TitleBar();

            leaf1 = new Hdy.Leaflet();
            leaf1.set_transition_type (Hdy.LeafletTransitionType.SLIDE);
            leaf1.transition_type = Hdy.LeafletTransitionType.SLIDE;

            headrbar1 = new Hdy.HeaderBar ();
            headrbar1.set_title ("Huely");
            headrbar1.visible = true;
            headrbar1.show_close_button = true;

            Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            separator.visible = true;

            headrbar2 = new Hdy.HeaderBar ();
            headrbar2.set_title ("Content");
            headrbar2.name = "content";
            headrbar2.visible = true;
            headrbar2.hexpand = true;
            headrbar2.show_close_button = true;

            Hdy.HeaderGroup headrGroup = new Hdy.HeaderGroup ();
            headrGroup.add_header_bar (headrbar1);
            headrGroup.add_header_bar (headrbar2);
            headrGroup.set_decorate_all (false);

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

            Gtk.Button setButton = new Gtk.Button ();
            setButton.margin = 5;
            setButton.halign = Gtk.Align.END;
            setButton.label = "Set";

            contentBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            contentBox.add (nameBox);
            contentBox.add (colorChooser);
            contentBox.add (setButton);

            Gtk.Button button1 = new Gtk.Button ();
            button1.set_label ("Back");
            button1.clicked.connect (on_back_button_clicked);

            leaf2 = new Hdy.Leaflet ();
            leaf2.set_transition_type (Hdy.LeafletTransitionType.SLIDE);
            leaf2.transition_type = Hdy.LeafletTransitionType.SLIDE;
            leaf2.visible = true;

            lightListBox = new Gtk.ListBox ();
            var testButton = new Gtk.Button ();
            testButton.set_label ("Switch!");
            testButton.clicked.connect (on_switch_button_clicked);

            lightListBox.row_selected.connect ((row) =>
            {
                nameEntry.text = ((Widgets.LightListBoxRow)row).LightName.label;
            });

            lightListBox.add (new Widgets.LightListBoxRow ().with_name ("Light 1").with_color ("#FF0000"));
            lightListBox.add (new Widgets.LightListBoxRow ().with_name ("Light 2").with_color ("#00FF00"));
            lightListBox.add (new Widgets.LightListBoxRow ().with_name ("Light 3").with_color ("#0000FF"));
            lightListBox.add (testButton);

            Gtk.Label label = new Gtk.Label("Content");
            label.label = "Content";

            leaf1.add (headrbar1);
            leaf1.add (separator);

            headrbar2.add (button1);

            leaf1.add (headrbar2);

            titlebar.add(leaf1);

            leaf2.add (lightListBox);
            leaf2.add (contentBox);

            leaf1.set_visible_child (headrbar2);
            leaf2.set_visible_child (contentBox);

            // These sizegroups in combination with the leaflets are what make the adaptive magic happen.
            Gtk.SizeGroup sizegroup1 = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
            sizegroup1.add_widget (headrbar1);
            sizegroup1.add_widget (lightListBox);

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
            leaf2.set_visible_child (lightListBox);
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
