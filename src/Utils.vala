namespace Sensors.Utils {
    private static string parse_temp (string temp_str) {
        if (temp_str == "") {
            return "0° C";
        }

        int temp_int = int.parse (temp_str) / 1000;
        return @"$(temp_int)° C";
    }

    private string get_content (string path) {
        string content;
        try {
            GLib.FileUtils.get_contents (HWMON_PATH + path, out content);
        } catch (GLib.Error e) {
            return "";
        }

        return content.chomp ();
    }

    private int compare_monitors (HWMonStruct? mon1, HWMonStruct? mon2) {
        if (mon1 == null) {return (mon2 == null) ? 0 : -1;}
        if (mon2 == null) {return 1;}
        if (mon1.name == AMD_CPU || mon1.name == INTEL_CPU) {return -1;}
        if (mon2.name == AMD_CPU || mon2.name == INTEL_CPU) {return 1;}
        if (mon1.name == NVIDIA_GPU || mon1.name == "radeon" || mon1.name == "nouveau") {return -1;}
        if (mon2.name == NVIDIA_GPU || mon2.name == "radeon" || mon2.name == "nouveau") {return 1;}
        if (mon1.name != "drivetemp" && mon1.name != "nvme") {return -1;}
        if (mon2.name != "drivetemp" && mon2.name != "nvme") {return 1;}

        if (mon1.name == "nvme") {return -1;}
        if (mon2.name == "nvme") {return 1;}

        return GLib.strcmp (mon1.label, mon2.label);
    }
}
