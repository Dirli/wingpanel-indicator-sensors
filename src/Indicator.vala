/*
* Copyright (c) 2018-2020 Dirli <litandrej85@gmail.com>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*/

namespace Sensors {
    public class Indicator : Wingpanel.Indicator {
        private HWMonitor hw_monitor;
        private Gtk.Grid? main_widget = null;
        private Gtk.Label panel_label;
        private Gtk.Box panel_widget;

        public Indicator () {
            Object (code_name: "sensors-indicator");

            Gtk.IconTheme.get_default ().add_resource_path ("/io/elementary/desktop/wingpanel/sensors");

            this.visible = true;
        }

        public override Gtk.Widget get_display_widget () {
            if (panel_widget == null) {
                panel_widget = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                panel_label = new Gtk.Label ("");

                hw_monitor = new HWMonitor (panel_label);

                panel_widget.add (new Gtk.Image.from_icon_name ("temp-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
                panel_widget.add (panel_label);
            }

            return panel_widget;
        }

        public override Gtk.Widget? get_widget () {
            if (main_widget == null) {
                main_widget = new Gtk.Grid ();
                main_widget.margin_top = main_widget.margin_bottom = 10;
                main_widget.halign = Gtk.Align.CENTER;
                main_widget.orientation = Gtk.Orientation.HORIZONTAL;
                main_widget.hexpand = true;
                main_widget.row_spacing = 5;

                Wingpanel.Widgets.Switch watch_switch = new Wingpanel.Widgets.Switch (_("Show on panel"), hw_monitor.watcher);
                main_widget.attach (watch_switch, 0, 0, 2, 1);
                watch_switch.set_sensitive (hw_monitor.watcher);
                var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
                separator.hexpand = true;
                main_widget.attach (separator, 0, 1, 2, 1);
                watch_switch.notify["active"].connect (() => {
                    if (watch_switch.active) {
                        hw_monitor.watcher = true;
                    } else {
                        hw_monitor.watcher = false;
                        panel_label.label = "";
                    }
                });

                hw_monitor.init_widget (main_widget);
            }

            return main_widget;
        }

        public override void opened () {
            hw_monitor.extended = true;
            if (!hw_monitor.watcher) {
                hw_monitor.hwm_start (false);
            }
        }

        public override void closed () {
            hw_monitor.extended = false;
            if (!hw_monitor.watcher) {
                hw_monitor.hwm_stop ();
            }
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
