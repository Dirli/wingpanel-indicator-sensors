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

public class Sensors.Widgets.HWMonitor : GLib.Object {
    private Gee.HashSet<string> hw_monitors;
    private Gee.HashMap<string, string> sens_hash;
    private uint timeout_id;
    private Gee.HashMap<string, Gtk.Label> sens_position_hash;
    private Gtk.Label panel_label;
    private string hwm_cpu;

    public bool watcher = false;
    public bool extended = false;

    public HWMonitor (Gtk.Label panel_lab) {
        panel_label = panel_lab;
        sens_hash = new Gee.HashMap<string, string> ();

        if (FileUtils.test("/sys/class/hwmon/", FileTest.IS_DIR)) {
            string hwm_name, sensors_str;
            hw_monitors = get_hw_monitors ();

            foreach (string hwm in hw_monitors) {
                hwm_name = get_content (@"/sys/class/hwmon/$hwm/name");

                if (hwm_name. chomp() == "coretemp" || hwm_name. chomp() == "k10temp") {
                    hwm_cpu = hwm;
                    watcher = true;
                }

                sensors_str = get_hwm_sensors (@"/sys/class/hwmon/$hwm");
                if (sensors_str != "") {
                    sens_hash[hwm] = sensors_str;
                }
            }
            hwm_start (true);
        }
    }

    public void hwm_start (bool panel_start) {
        if (panel_start && !watcher) {
            return;
        }

        if (!panel_start && sens_hash.size == 0) {
            return;
        }

        update ();
        timeout_id = GLib.Timeout.add (2000, update);
    }

    public void hwm_stop () {
        if (timeout_id > 0) {
            Source.remove (timeout_id);
        }
    }

    private string get_hwm_sensors (string hwm_path) {
        string name, sens_string = "";
        Gee.TreeSet<string> sens_set = new Gee.TreeSet<string> ();
        try {
            Regex regex = new Regex ("^temp[0-9]_input");
            Dir dir = GLib.Dir.open (hwm_path, 0);
            while ((name = dir.read_name ()) != null) {
                if (regex.match (name)) {
                    sens_set.add (name.split("_")[0]);
                }
            }
        } catch (Error e) {
            warning (e.message);
        }

        foreach (string str in sens_set) {
            if (sens_string != "") {
                sens_string += ",";
            }
            sens_string += str;
        }

        return sens_string;
    }

    private Gee.HashSet<string> get_hw_monitors () {
        string? name = null;
        Gee.HashSet<string> hwm_set = new Gee.HashSet<string> ();
        try {
            Dir dir = GLib.Dir.open ("/sys/class/hwmon", 0);
            while ((name = dir.read_name ()) != null) {
                hwm_set.add (name);
            }
        } catch (Error e) {
            warning (e.message);
        }
        return hwm_set;
    }

    public void init_widget (Gtk.Grid view) {
        if (sens_hash.size == 0) {
            Gtk.Label no_hwm_message = new Gtk.Label ("Unfortunately it was not\npossible to determine the\nsensors on your device");
            view.add (no_hwm_message);
            return;
        }

        sens_position_hash = new Gee.HashMap<string, Gtk.Label> ();
        string sensor_label, monitor_label, path;
        int top_index = 2;

        foreach (var entry in sens_hash.entries) {
            path = @"/sys/class/hwmon/" + entry.key;
            monitor_label = get_content (path + "/name");
            Gtk.Label hwm_label = new Gtk.Label (monitor_label);
            hwm_label.margin_start = hwm_label.margin_end = 5;
            hwm_label.get_style_context ().add_class ("h3");
            view.attach (hwm_label, 0, top_index, 2, 1);
            top_index += 1;

            foreach (string sensor in entry.value.split(",")) {
                sensor_label = get_content (path + "/" + sensor + "_label");
                if (sensor_label == "") {
                    sensor_label = sensor;
                }
                Gtk.Label sens_iter_label = new Gtk.Label (sensor_label);
                sens_iter_label.halign = Gtk.Align.START;
                Gtk.Label sens_iter_val = new Gtk.Label ("-");
                sens_iter_val.halign = Gtk.Align.END;
                sens_iter_label.margin_start = sens_iter_val.margin_end = 20;
                view.attach (sens_iter_label, 0, top_index, 1, 1);
                view.attach (sens_iter_val, 1, top_index, 1, 1);
                top_index += 1;
                sens_position_hash[entry.key + ":" + sensor] = sens_iter_val;
            }
        }
    }

    private string get_content (string path) {
        string content;
        try {
            FileUtils.get_contents (path, out content);
        } catch (Error e) {
            return "";
        }
        return content.chomp ();
    }

    private string parse_temp (string temp_str) {
        if (temp_str == "") {
            return "0° C";
        }
        int temp_int = int.parse(temp_str) / 1000;
        return "%d° C".printf(temp_int);
    }

    private unowned bool update () {
        if (!extended) {
            int temp_val, temp_max = 0;
            string temp_cur;
            string sens_str = sens_hash[hwm_cpu];

            foreach (string sensor in sens_str.split(",")) {
                temp_cur = get_content (@"/sys/class/hwmon/$hwm_cpu/$sensor" + "_input");
                temp_val = int.parse(temp_cur) / 1000;
                if (temp_val > temp_max) {temp_max = temp_val;}
            }
            panel_label.label = "%d°".printf(temp_max);
        } else {
            string temp_str, path;
            foreach (var entry in sens_hash.entries) {
                path = "/sys/class/hwmon/" + entry.key;
                foreach (string sensor in entry.value.split(",")) {
                    temp_str = get_content (path + @"/$sensor" + "_input");
                    sens_position_hash[entry.key + ":" + sensor].label = parse_temp (temp_str);
                }
            }
        }
        return true;
    }
}
