/*
* Copyright (c) 2018 Dirli <litandrej85@gmail.com>
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

public class Sensors.Indicator : Wingpanel.Indicator {
    private Sensors.Widgets.HWMonitor hw_monitor;
    private Gtk.Grid? main_widget = null;
    private Gtk.Label panel_label;

    public Indicator () {
        Object (code_name : "sensors-indicator",
                display_name : "Sensors Indicator",
                description: "Monitors and displays the temperature on the Wingpanel");

        this.visible = true;
    }

    public override Gtk.Widget get_display_widget () {
        if (panel_label == null) {
            panel_label = new Gtk.Label("off");
            hw_monitor = new Sensors.Widgets.HWMonitor (panel_label);
        }

        return panel_label;
    }

    public override Gtk.Widget? get_widget () {
        if (main_widget == null) {
            main_widget = new Gtk.Grid ();
            main_widget.margin_top = main_widget.margin_bottom = 5;
            /* main_widget.margin_start = main_widget.margin_end = 5; */
            main_widget.valign = Gtk.Align.CENTER;
            main_widget.halign = Gtk.Align.CENTER;
            main_widget.orientation = Gtk.Orientation.HORIZONTAL;
            main_widget.hexpand = true;
            main_widget.row_spacing = 5;

            Wingpanel.Widgets.Switch watch_switch = new Wingpanel.Widgets.Switch ("Show on panel", hw_monitor.watcher);
            main_widget.attach (watch_switch, 0, 0, 2, 1);
            watch_switch.set_sensitive (hw_monitor.watcher);
            var separator = new Wingpanel.Widgets.Separator ();
            separator.hexpand = true;
            main_widget.attach (separator, 0, 1, 2, 1);
            watch_switch.notify["active"].connect(() => {
                if (watch_switch.active) {
                    hw_monitor.watcher = true;
                } else {
                    hw_monitor.watcher = false;
                    panel_label.label = "off";
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

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Sensors Indicator");
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new Sensors.Indicator ();
    return indicator;
}
