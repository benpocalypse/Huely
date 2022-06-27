/* window.vala
 *
 * Copyright 2022 Ben Foote
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Huely
{
    [GtkTemplate (ui = "/com/github/benpocalypse/Huely/window.ui")]
    public class Window : Gtk.ApplicationWindow
    {
        [GtkChild]
        private unowned Gtk.Label label;

        public Window (Gtk.Application app)
        {
            Object (application: app);
        }
    }
}
