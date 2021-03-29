namespace Sensors {
    public class Widgets.MainGrid : Gtk.Grid {
        public signal void show_on_paanel (bool s);

        private int top;

        private Gee.HashMap<string, Gtk.Label> sensors_hash;

        public MainGrid () {
            Object (margin_top: 10,
                    margin_bottom: 10,
                    halign: Gtk.Align.CENTER,
                    orientation: Gtk.Orientation.HORIZONTAL,
                    hexpand: true,
                    row_spacing: 5);
        }

        construct {
            sensors_hash = new Gee.HashMap<string, Gtk.Label> ();

            Wingpanel.Widgets.Switch watch_switch = new Wingpanel.Widgets.Switch (_("Show on panel"), true);
            attach (watch_switch, 0, top++, 2, 1);

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
