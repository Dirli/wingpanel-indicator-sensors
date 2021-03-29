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
}
