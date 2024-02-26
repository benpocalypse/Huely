namespace Huely {
    public class MainWindow : Hdy.ApplicationWindow
    {
        public weak Huely.Application app { get; construct; }

        // Widgets
        public const string ACTION_PREFIX = "win.";
        public const string ACTION_FULLSCREEN = "action_fullscreen";
        public const string ACTION_QUIT = "action_quit";

        public SimpleActionGroup actions { get; set; }
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        public enum WindowState
        {
            NORMAL = 0,
            MAXIMIZED = 1,
            FULLSCREEN = 2
        }

        private const ActionEntry[] ACTION_ENTRIES =
        {
            { ACTION_FULLSCREEN, action_fullscreen },
            { ACTION_QUIT, action_quit },
        };

        private static void define_action_accelerators ()
        {
            // Define action accelerators (keyboard shortcuts).
            action_accelerators.set (ACTION_FULLSCREEN, "F11");
            action_accelerators.set (ACTION_QUIT, "<Control>q");
        }

        public MainWindow (Huely.Application application)
        {
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
                height_request: 500,
                width_request: 380,
                hide_titlebar_when_maximized: true,
                icon_name: "com.github.benpocalypse.Huely"
            );
        }

        // This constructor is guaranteed to be run only once during the lifetime of the application.
        static construct
        {
            // Initialise the Handy library.
            // https://gnome.pages.gitlab.gnome.org/libhandy/
            Hdy.init();

            // Define acclerators (keyboard shortcuts) for actions.
            MainWindow.define_action_accelerators ();
        }

        // This constructor will be called every time an instance of this class is created.
        construct
        {
            // State preservation: save window dimensions and location on window close.
            // See: https://docs.elementary.io/hig/user-workflow/closing
            set_up_state_preservation ();

            // State preservation: restore window dimensions and location from last run.
            // See https://docs.elementary.io/hig/user-workflow/normal-launch#state
            restore_window_state ();

            // Create window layout.
            CreateInitialLayout ();

            // Set up actions (with accelerators) for full screen, quit, etc.
            set_up_actions ();

            // Make all widgets (the interface) visible.
            show_all ();
        }

        // Layout.
        private Gtk.ScrolledWindow aboutScrolledWindow = new Gtk.ScrolledWindow (null, null);
        private Huely.LightViewModel _lightViewModel = new Huely.LightViewModel ();

        private void CreateInitialLayout ()
        {
            var createLayoutLoop = new MainLoop();
            CreateRealLayoutAsync.begin((obj, res) =>
            {
                CreateRealLayoutAsync.end (res);
                createLayoutLoop.quit();
            });
            createLayoutLoop.run();
        }

        private Hdy.Deck deck1 = new Hdy.Deck ();
        private async void CreateRealLayoutAsync ()
        {
            SourceFunc callback = CreateRealLayoutAsync.callback;
            ThreadFunc<bool> run = () =>
            {
                Hdy.TitleBar titlebar = new Hdy.TitleBar();
                Gtk.Box aboutBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
                Gtk.Box mainBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

                Hdy.Leaflet leaf1 = new Hdy.Leaflet();
                leaf1.set_transition_type (Hdy.LeafletTransitionType.SLIDE);
                leaf1.transition_type = Hdy.LeafletTransitionType.SLIDE;
                leaf1.visible = true;

                Hdy.HeaderBar headrbar1 = new Hdy.HeaderBar ();
                headrbar1.set_title ("Huely");
                headrbar1.visible = true;
                headrbar1.show_close_button = true;

                Hdy.HeaderBar headrbar2 = new Hdy.HeaderBar ();
                headrbar2.set_title ("Details");
                headrbar2.visible = true;
                headrbar2.hexpand = true;
                headrbar2.show_close_button = true;

                Hdy.Leaflet leaf2 = new Hdy.Leaflet();

                Huely.LightListPane lightPane = new Huely.LightListPane (_lightViewModel);
                Huely.LightDetailsPane detailsPane = new Huely.LightDetailsPane ();

                Gtk.Button backButton = new Gtk.Button.from_icon_name ("go-previous-symbolic");
                backButton.clicked.connect (() =>
                {
                    leaf1.set_visible_child (headrbar1);
                    leaf2.set_visible_child (lightPane);
                    lightPane.UnselectAll ();
                });

                Gtk.Button settingsButtonRight = new Gtk.Button.from_icon_name ("emblem-system-symbolic");
                Gtk.Button settingsButtonLeft = new Gtk.Button.from_icon_name ("emblem-system-symbolic");
                settingsButtonLeft.visible = false;

                settingsButtonRight.clicked.connect ((btn) =>
                {
                    GenerateSettingsMenuForDeck (deck1, btn);
                });

                settingsButtonLeft.clicked.connect ((btn) =>
                {
                    GenerateSettingsMenuForDeck (deck1, btn);
                });

                Hdy.HeaderGroup headrGroup = new Hdy.HeaderGroup ();
                headrGroup.add_header_bar (headrbar1);
                headrGroup.add_header_bar (headrbar2);
                headrGroup.set_decorate_all (false);

                // This 'ugliness' is responsible for hiding/showing the back button
                // on the Details pane, and the settings gear on both when size permits.
                headrGroup.update_decoration_layouts.connect (() =>
                {
                    if (leaf2.get_visible_child () is LightListPane)
                    {
                        backButton.visible = false;
                    }
                    else
                    {
                        if (leaf2.get_visible_child () is LightDetailsPane && backButton.visible == true)
                        {
                            backButton.visible = false;
                        }
                        else
                        {
                            backButton.visible = true;
                        }
                    }

                    if (leaf1.get_folded () == true)
                    {
                        settingsButtonLeft.visible = true;
                    }
                    else
                    {
                        settingsButtonLeft.visible = false;
                    }
                });

                leaf2 = new Hdy.Leaflet ();
                leaf2.set_transition_type (Hdy.LeafletTransitionType.SLIDE);
                leaf2.transition_type = Hdy.LeafletTransitionType.SLIDE;

                leaf1.add (headrbar1);
                headrbar2.pack_start (backButton);
                headrbar2.pack_end (settingsButtonRight);
                leaf1.add (headrbar2);

                titlebar.add(leaf1);

                var searchButton = new Gtk.Button.from_icon_name ("view-refresh-symbolic");
                searchButton.margin = 5;

                searchButton.clicked.connect (() =>
                {
                    lightPane.DisplaySearchingForLights ();

                    debug ("Searching for lights...\n");

                    LightDiscovery dl = new LightDiscovery ();
                    ObservableList<Huely.Light> lights = new ObservableList<Huely.Light> ();

                    var loop = new MainLoop();
                    dl.DiscoverLightsAsync.begin((obj, res) =>
                    {
                        lights = dl.DiscoverLightsAsync.end (res);
                        loop.quit();
                    });
                    loop.run();

                    debug ("finished searching.\n");

                    // TODO - We might not want to just clear the list. Maybe
                    // in the future only add newly discovered lights to the
                    // existing list?
                    _lightViewModel.Lights.clear ();

                    _lightViewModel.Lights.add_all (lights.data);

                    if (_lightViewModel.Lights.length () > 0)
                    {
                        debug ("Displaying lights list.\n");
                        lightPane.DisplayLightList ();
                    }
                    else
                    {
                        lightPane.DisplayText ("No compatible lights found.");
                    }
                });

                lightPane.LightSelected.connect ((light) =>
                {
                    detailsPane.LightSelected (light);
                    leaf1.set_visible_child (headrbar2);
                    leaf2.set_visible_child (detailsPane);
                });

                headrbar1.pack_start (searchButton);
                headrbar1.pack_end (settingsButtonLeft);

                leaf2.add (lightPane);
                leaf2.add (detailsPane);
                leaf2.valign = Gtk.Align.FILL;

                // About Deck
                Hdy.HeaderBar aboutHeader = new Hdy.HeaderBar ();
                Gtk.Button aboutBackButton = new Gtk.Button.from_icon_name ("go-previous-symbolic");

                aboutBackButton.clicked.connect (() =>
                {
                    deck1.set_visible_child (mainBox);
                });

                aboutHeader.set_title ("About");
                aboutHeader.show_close_button = true;
                aboutHeader.pack_start (aboutBackButton);

                var aboutImage = new Gtk.Image.from_icon_name ("com.github.benpocalypse.Huely", Gtk.IconSize.DIALOG);
                aboutImage.pixel_size = 128;

                aboutBox.pack_start (aboutHeader, false, false);
                aboutBox.pack_start (aboutImage, false, false, 10);

                var aboutNameLabel = new Gtk.Label ("");
                aboutNameLabel.set_markup ("<b>Huely</b>");

                var aboutWebsiteLabel = new Gtk.Label("");
                aboutWebsiteLabel.set_markup ("<a href='https://github.com/benpocalypse/Huely'>Website</a>");
                aboutBox.pack_start (aboutNameLabel, false, false);
                aboutBox.pack_start (new Gtk.Label (@"v$(Constants.Config.VERSION)"), false, false);
                aboutBox.pack_start (aboutWebsiteLabel, false, false, 10);
                aboutBox.pack_start (new Gtk.Label (@"Color your space."), false, false);
                aboutBox.pack_start (new Gtk.Label (@"© Ben Foote"), false, false);
                aboutBox.pack_end (new Gtk.Label (""), true, true);

                // These sizegroups in combination with the leaflets are what make the adaptive magic happen.
                Gtk.SizeGroup sizegroup1 = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
                sizegroup1.add_widget (headrbar1);
                sizegroup1.add_widget (lightPane);

                Gtk.SizeGroup sizegroup3 = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
                sizegroup3.add_widget (headrbar2);
                sizegroup3.add_widget (detailsPane);

                mainBox.pack_start (titlebar, false, false);
                mainBox.pack_start (leaf2, true, true);

                aboutScrolledWindow.add (aboutBox);
                aboutScrolledWindow.valign = Gtk.Align.FILL;
                aboutScrolledWindow.set_shadow_type (Gtk.ShadowType.IN);

                deck1.prepend (aboutScrolledWindow);
                deck1.prepend (mainBox);

                Idle.add((owned) callback);
                return true;
            };

            new Thread<bool>("create-layout-thread", (owned)run);

            yield;

            add (deck1);
        }

        private void GenerateSettingsMenuForDeck (Hdy.Deck deck, Gtk.Button button)
        {
            Gtk.Box menuBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            var helpButton = new Gtk.ModelButton ();
            helpButton.text = "Help";
            helpButton.margin = 5;
            helpButton.clicked.connect (() =>  GLib.AppInfo.launch_default_for_uri ("https://github.com/benpocalypse/Huely", new GLib.AppLaunchContext ()));

            var aboutButton = new Gtk.ModelButton ();
            aboutButton.text = "About";
            aboutButton.margin = 5;
            aboutButton.clicked.connect (() => deck.set_visible_child (aboutScrolledWindow));

            menuBox.pack_start (helpButton);
            menuBox.pack_start (aboutButton);

            Gtk.Popover popover = new Gtk.Popover (button);
            popover.add (menuBox);
            popover.show_all ();
        }

        // State preservation.
        private void set_up_state_preservation ()
        {
            // Before the window is deleted, preserve its state.
            delete_event.connect (() =>
            {
                preserve_window_state ();
                return false;
            });

            // Quit gracefully (ensuring state is preserved) when SIGINT or SIGTERM is received
            // (e.g., when run from terminal and terminated using Ctrl+C).
            Unix.signal_add (Posix.Signal.INT, quit_gracefully, Priority.HIGH);
            Unix.signal_add (Posix.Signal.TERM, quit_gracefully, Priority.HIGH);
        }

        private void restore_window_state ()
        {
            var rect = Gdk.Rectangle ();
            Huely.saved_state.get ("window-size", "(ii)", out rect.width, out rect.height);

            var lightStringArray = Huely.saved_state.get_strv ("lights");

            try
            {
                foreach (var lightString in lightStringArray)
                {
                    _lightViewModel.Lights.add (new Huely.Light.from_string (lightString));
                }
            }
            catch (GLib.Error error)
            {
                // TODO - log? or something?
            }

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

        private void preserve_window_state ()
        {
            // Persist window dimensions and location.
            var state = get_window ().get_state ();

            if (Gdk.WindowState.MAXIMIZED in state)
            {
                Huely.saved_state.set_enum ("window-state", WindowState.MAXIMIZED);
            }
            else if (Gdk.WindowState.FULLSCREEN in state)
            {
                Huely.saved_state.set_enum ("window-state", WindowState.FULLSCREEN);
            }
            else
            {
                Huely.saved_state.set_enum ("window-state", WindowState.NORMAL);
                // Save window size
                int width, height;
                get_size (out width, out height);
                Huely.saved_state.set ("window-size", "(ii)", width, height);
            }

            int x, y;
            get_position (out x, out y);
            Huely.saved_state.set ("window-position", "(ii)", x, y);

            Huely.saved_state.set_strv ("lights", _lightViewModel.Lights.to_string_array () );
        }

        // Actions.
        private void set_up_actions ()
        {
            // Setup actions and their accelerators.
            actions = new SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("win", actions);

            foreach (var action in action_accelerators.get_keys ())
            {
                var accels_array = action_accelerators[action].to_array ();
                accels_array += null;

                app.set_accels_for_action (ACTION_PREFIX + action, accels_array);
            }
        }

        // Action handlers.
        private void action_fullscreen ()
        {
            if (Gdk.WindowState.FULLSCREEN in get_window ().get_state ())
            {
                unfullscreen ();
            }
            else
            {
                fullscreen ();
            }
        }

        private void action_quit ()
        {
            preserve_window_state ();
            destroy ();
        }

        // Graceful shutdown.
        public bool quit_gracefully ()
        {
            action_quit ();
            return false;
        }
    }
}
