/*
 * Copyright (c) 2021 Dirli <litandrej85@gmail.com>
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
 *
 */

namespace Sensors {
    public class Widgets.MainGrid : Gtk.Grid {
        public signal void show_on_paanel (bool s);

        private int top = 0;

        private Gee.HashMap<string, Gtk.Label> sensors_hash;

        public MainGrid () {
            Object (margin_top: 10,
                    margin_bottom: 10,
                    halign: Gtk.Align.FILL,
                    orientation: Gtk.Orientation.HORIZONTAL,
                    hexpand: true,
                    row_spacing: 5);
        }

        construct {
            sensors_hash = new Gee.HashMap<string, Gtk.Label> ();

            Gtk.Label watch_label = new Gtk.Label (_("Show on panel"));
            watch_label.halign = Gtk.Align.START;
            watch_label.margin_start = 20;

            Gtk.Switch watch_switch = new Gtk.Switch ();
            watch_switch.halign = Gtk.Align.END;
            watch_switch.active = true;
            watch_switch.margin_end = 20;

            attach (watch_label, 0, top);
            attach (watch_switch, 1, top++);

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator.hexpand = true;
            attach (separator, 0, top++, 2, 1);
            watch_switch.notify["active"].connect (() => {
                show_on_paanel (watch_switch.active);
            });
        }

        public void add_hwmon_label (string monitor_label) {
            Gtk.Label hwm_label = new Gtk.Label (monitor_label);
            hwm_label.ellipsize = Pango.EllipsizeMode.END;
            hwm_label.margin_start = hwm_label.margin_end = 5;
            hwm_label.margin_top = 5;
            hwm_label.get_style_context ().add_class ("h3");

            attach (hwm_label, 0, top++, 2, 1);
        }

        public bool add_sensor (SensorStruct sens) {
            Gtk.Label sens_iter_label = new Gtk.Label (sens.label);
            sens_iter_label.halign = Gtk.Align.START;
            sens_iter_label.margin_start = 20;

            if (sens.tooltip != null && sens.tooltip != "") {
                sens_iter_label.tooltip_text = "max " + Utils.parse_temp (sens.tooltip);
            }

            Gtk.Label sens_iter_val = new Gtk.Label ("-");
            sens_iter_val.halign = Gtk.Align.END;
            sens_iter_val.margin_end = 20;

            attach (sens_iter_label, 0, top, 1, 1);
            attach (sens_iter_val, 1, top++, 1, 1);

            sensors_hash[sens.key] = sens_iter_val;

            return true;
        }

        public void update_label (string key, string temp_str) {
            if (sensors_hash.has_key (key)) {
                sensors_hash[key].label = Utils.parse_temp (temp_str);
            }
        }

    }
}
