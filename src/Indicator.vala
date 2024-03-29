/*
 * Copyright (c) 2018-2021 Dirli <litandrej85@gmail.com>
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
    public const string HWMON_PATH = "/sys/class/hwmon/";
    public const string AMD_CPU = "k10temp";
    public const string INTEL_CPU = "coretemp";
    public const string NVIDIA_GPU = "nvidia";

    public struct HWMonStruct {
        public string label;
        public string path;
        public string name;
    }

    public struct SensorStruct {
        public string key;
        public string label;
        public string tooltip;
    }

    public class Indicator : Wingpanel.Indicator {
        private HWMonitor hw_monitor;
        private Widgets.MainGrid? main_widget = null;
        private Gtk.Label panel_label;
        private Gtk.Box panel_widget;

        private uint timeout_id;

        private bool extended = false;
        private bool on_panel = true;

        public Indicator () {
            Object (code_name: "sensors-indicator");

            hw_monitor = new HWMonitor ();

            Gtk.IconTheme.get_default ().add_resource_path ("/io/elementary/desktop/wingpanel/sensors");

            this.visible = true;
        }

        public override Gtk.Widget get_display_widget () {
            if (panel_widget == null) {
                panel_widget = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                panel_label = new Gtk.Label (null);

                hw_monitor.fetch_sensor.connect ((key, val) => {
                    if (key == "") {
                        panel_label.label = @"$(val)°";
                    } else {
                        if (main_widget != null) {
                            main_widget.update_label (key, val);
                        }
                    }
                });

                panel_widget.add (new Gtk.Image.from_icon_name ("temp-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
                panel_widget.add (panel_label);

                if (hw_monitor.update_sensors (extended)) {
                    timeout_id = GLib.Timeout.add (1500, update);
                }
            }

            return panel_widget;
        }

        private bool update () {
            if ((!extended && !on_panel) || (!hw_monitor.update_sensors (extended))) {
                timeout_id = 0;

                return false;
            }

            return true;
        }

        public override Gtk.Widget? get_widget () {
            if (main_widget == null) {
                main_widget = new Widgets.MainGrid ();
                main_widget.show_on_paanel.connect ((s) => {
                    on_panel = s;
                    if (!s) {
                        panel_label.label = "";
                    }
                });

                hw_monitor.get_hwmonitors ().foreach ((mon) => {
                    main_widget.add_hwmon_label (mon.label);

                    hw_monitor.get_hwmon_sensors (mon.path).foreach ((sen) => {
                        main_widget.add_sensor (sen);
                        return true;
                    });

                    return true;
                });
            }

            return main_widget;
        }

        public override void opened () {
            extended = true;

            if (timeout_id == 0 && hw_monitor.update_sensors (extended)) {
                timeout_id = GLib.Timeout.add (1500, update);
            }
        }

        public override void closed () {
            extended = false;
        }
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Sensors Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new Sensors.Indicator ();
    return indicator;
}
