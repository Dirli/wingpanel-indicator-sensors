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

namespace Sensors {
    public class HWMonitor : GLib.Object {
        public signal void fetch_sensor (string key, string val);

        private Gee.HashMap<string, string> sens_hash;
        private string default_monitor = "";

        public HWMonitor () {
            sens_hash = new Gee.HashMap<string, string> ();

            if (GLib.FileUtils.test (HWMON_PATH, GLib.FileTest.IS_DIR)) {
                init_hwmons ();
            }
        }

        private void init_hwmons () {
            find_hw_monitors ().foreach ((hwm) => {
                var hwm_name = Utils.get_content (@"$hwm/name");
                var sensors_str = find_hwm_sensors (HWMON_PATH + hwm);

                if (sensors_str != "") {
                    if (hwm_name.chomp () == INTEL_CPU || hwm_name.chomp () == AMD_CPU) {
                        default_monitor = hwm;
                    }

                    sens_hash[hwm] = sensors_str;
                }

                return true;
            });
        }

        private Gee.HashSet<string> find_hw_monitors () {
            string? name = null;
            Gee.HashSet<string> hwm_set = new Gee.HashSet<string> ();
            try {
                GLib.Dir dir = GLib.Dir.open (HWMON_PATH, 0);
                while ((name = dir.read_name ()) != null) {
                    hwm_set.add (name);
                }

            } catch (GLib.Error e) {
                warning (e.message);
            }

            return hwm_set;
        }

        private string find_hwm_sensors (string hwm_path) {
            string name, sens_string = "";

            try {
                GLib.Regex regex = new GLib.Regex ("^temp[0-9]_input");
                GLib.Dir dir = GLib.Dir.open (hwm_path, 0);
                while ((name = dir.read_name ()) != null) {
                    if (regex.match (name)) {
                        if (sens_string != "") {
                            sens_string += ",";
                        }

                        sens_string += name.split ("_")[0];
                    }
                }
            } catch (GLib.Error e) {
                warning (e.message);
            }

            return sens_string;
        }

        public Gee.ArrayList<HWMonStruct?> get_hwmonitors () {
            var hwmons_arr = new Gee.ArrayList<HWMonStruct?> ();

            sens_hash.@foreach ((entry) => {
                HWMonStruct hwmon_struct = {};
                var monitor_name = Utils.get_content (@"$(entry.key)/name");
                hwmon_struct.name = monitor_name;
                hwmon_struct.label = monitor_name;
                hwmon_struct.path = entry.key;

                if (monitor_name == "drivetemp") {
                    if (GLib.FileUtils.test (HWMON_PATH + @"$(entry.key)/device/model", GLib.FileTest.IS_REGULAR)) {
                        var new_label = Utils.get_content (@"$(entry.key)/device/model").chomp ();
                        if (new_label != "") {
                            hwmon_struct.label = new_label;
                        }
                    }
                }

                hwmons_arr.add (hwmon_struct);

                return true;
            });

            hwmons_arr.sort (Utils.compare_monitors);

            return hwmons_arr;
        }

        public Gee.ArrayList<SensorStruct?> get_hwmon_sensors (string path) {
            var sensors_arr = new Gee.ArrayList<SensorStruct?> ();

            if (!sens_hash.has_key (path)) {
                return sensors_arr;
            }

            foreach (string sensor in sens_hash[path].split (",")) {
                SensorStruct sens_struct = {};

                var sensor_label = Utils.get_content (@"$(path)/$(sensor)_label");
                if (sensor_label == "") {
                    sensor_label = sensor;
                }

                sens_struct.label = sensor_label;

                var sensor_tooltip = Utils.get_content (@"$(path)/$(sensor)_max");
                if (sensor_tooltip != "") {
                    sens_struct.tooltip = sensor_tooltip;
                }

                sens_struct.key = @"$(path):$(sensor)";

                sensors_arr.add (sens_struct);
            }

            return sensors_arr;
        }

        public bool update_sensors (bool extended) {
            if (!extended) {
                if (default_monitor == "") {
                    return false;
                }

                int temp_val, temp_max = 0;
                string temp_cur;
                string sens_str = sens_hash[default_monitor];

                foreach (string sensor in sens_str.split(",")) {
                    temp_cur = Utils.get_content (@"$(default_monitor)/$(sensor)_input");
                    temp_val = int.parse (temp_cur) / 1000;
                    if (temp_val > temp_max) {
                        temp_max = temp_val;
                    }
                }

                fetch_sensor ("", @"$(temp_max)");
            } else {
                if (sens_hash.size == 0) {
                    return false;
                }

                foreach (var entry in sens_hash.entries) {
                    foreach (string sensor in entry.value.split(",")) {
                        fetch_sensor (@"$(entry.key):$(sensor)", Utils.get_content (@"$(entry.key)/$(sensor)_input"));
                    }
                }
            }

            return true;
        }
    }
}
