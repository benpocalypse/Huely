namespace Huely.Widgets {
    public class HeaderBar : Hdy.HeaderBar {
        public HeaderBar () {
            Object (
                title: _("Huely"),
                has_subtitle: false,
                show_close_button: true,
                hexpand: true
            );
        }
    }
}
