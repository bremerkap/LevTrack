import Toybox.Lang;

module StringUtils {
    // Split string by delimiter
    function splitString(str as String, delimiter as String) as Array {
        var result = [];
        var startIndex = 0;

        for (var i = 0; i < str.length(); i++) {
            if (str.substring(i, i + 1).equals(delimiter)) {
                result.add(str.substring(startIndex, i));
                startIndex = i + 1;
            }
        }

        if (startIndex < str.length()) {
            result.add(str.substring(startIndex, str.length()));
        }

        return result;
    }
}
