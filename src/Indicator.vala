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
            panel_label = new Gtk.Label("-");
            hw_monitor = new Sensors.Widgets.HWMonitor (panel_label);
        }

        return panel_label;
    }

    public override Gtk.Widget? get_widget () {
        if (main_widget == null) {
            main_widget = new Gtk.Grid ();
            main_widget.margin_top = main_widget.margin_bottom = 10;
            main_widget.margin_start = main_widget.margin_end = 10;
            main_widget.valign = Gtk.Align.CENTER;
            main_widget.halign = Gtk.Align.CENTER;
            main_widget.orientation = Gtk.Orientation.HORIZONTAL;
            main_widget.hexpand = true;
            main_widget.column_spacing = 20;
            main_widget.row_spacing = 5;

            hw_monitor.init_widget (main_widget);
        }

        return main_widget;
    }

    public override void opened () {
        hw_monitor.extended = true;
        
    }

    public override void closed () {
        hw_monitor.extended = false;
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
