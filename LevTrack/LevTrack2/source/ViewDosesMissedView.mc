import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time;

class ViewDosesMissedView extends WatchUi.View {

    var _scrollOffset as Number;  // For scrolling through long lists

    function initialize() {
        View.initialize();
        _scrollOffset = 0;
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // Nothing needed here
    }

    function onShow() as Void {
        System.println("View Doses Missed screen shown");
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var app = getApp();
        var schedules = app.getSchedules();

        // Title - Red for "Missed"
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            5,
            Graphics.FONT_TINY,
            "Doses Missed",
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // Check if any schedules exist
        if (schedules.size() == 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                height / 2 - 15,
                Graphics.FONT_SMALL,
                "No schedules",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                width / 2,
                height / 2 + 15,
                Graphics.FONT_XTINY,
                "Add one from menu",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            // Collect all missed doses from all schedules
            var allDoses = [];

            for (var i = 0; i < schedules.size(); i++) {
                var schedule = schedules[i] as Dictionary;
                var dosesMissed = schedule["dosesMissed"] as Array;

                // Add each dose with schedule info
                for (var j = 0; j < dosesMissed.size(); j++) {
                    allDoses.add({
                        "timestamp" => dosesMissed[j],
                        "scheduleIndex" => i,
                        "scheduledTime" => schedule["scheduledTime"]
                    });
                }
            }

            // Sort doses by timestamp (most recent first)
            allDoses = sortDoses(allDoses);

            if (allDoses.size() == 0) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    width / 2,
                    height / 2,
                    Graphics.FONT_SMALL,
                    "No doses missed",
                    Graphics.TEXT_JUSTIFY_CENTER
                );
                dc.drawText(
                    width / 2,
                    height / 2 + 25,
                    Graphics.FONT_XTINY,
                    "History will appear here",
                    Graphics.TEXT_JUSTIFY_CENTER
                );
            } else {
                // Display count
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    width / 2,
                    35,
                    Graphics.FONT_XTINY,
                    "Total: " + allDoses.size(),
                    Graphics.TEXT_JUSTIFY_CENTER
                );

                // Display doses (up to 6 on screen)
                var yPosition = 50;
                var maxVisible = 6;
                var startIndex = _scrollOffset;
                var endIndex = startIndex + maxVisible;
                if (endIndex > allDoses.size()) {
                    endIndex = allDoses.size();
                }

                for (var i = startIndex; i < endIndex; i++) {
                    var dose = allDoses[i] as Dictionary;
                    var timestamp = dose["timestamp"] as Number;
                    var scheduleIndex = dose["scheduleIndex"] as Number;
                    var scheduledTime = dose["scheduledTime"] as String;

                    // Convert timestamp to readable date/time
                    var moment = new Time.Moment(timestamp);
                    var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);

                    var dateString = Lang.format("$1$/$2$/$3$", [
                        info.month.format("%02d"),
                        info.day.format("%02d"),
                        info.year.toString().substring(2, 4)  // Just last 2 digits of year
                    ]);

                    var timeString = Lang.format("$1$:$2$", [
                        info.hour.format("%02d"),
                        info.min.format("%02d")
                    ]);

                    // Draw schedule info
                    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(
                        20,
                        yPosition,
                        Graphics.FONT_XTINY,
                        "Sch " + (scheduleIndex + 1) + " (" + scheduledTime + ")",
                        Graphics.TEXT_JUSTIFY_LEFT
                    );

                    // Draw date and time
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(
                        20,
                        yPosition + 12,
                        Graphics.FONT_TINY,
                        dateString + " " + timeString,
                        Graphics.TEXT_JUSTIFY_LEFT
                    );

                    yPosition += 30;
                }

                // Show scroll indicators if needed
                if (allDoses.size() > maxVisible) {
                    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

                    if (_scrollOffset > 0) {
                        // Can scroll up - draw up arrow
                        dc.drawText(width - 15, 40, Graphics.FONT_TINY, "▲", Graphics.TEXT_JUSTIFY_CENTER);
                    }

                    if (endIndex < allDoses.size()) {
                        // Can scroll down - draw down arrow
                        dc.drawText(width - 15, height - 50, Graphics.FONT_TINY, "▼", Graphics.TEXT_JUSTIFY_CENTER);
                    }

                    // Page indicator
                    var currentPage = (_scrollOffset / maxVisible).toNumber() + 1;
                    var totalPages = ((allDoses.size() - 1) / maxVisible).toNumber() + 1;
                    dc.drawText(
                        width / 2,
                        height - 35,
                        Graphics.FONT_XTINY,
                        currentPage + "/" + totalPages,
                        Graphics.TEXT_JUSTIFY_CENTER
                    );
                }
            }
        }

        // Instructions at bottom
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height - 45,
            Graphics.FONT_XTINY,
            "UP/DOWN: Scroll | BACK: Return",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function onHide() as Void {
        System.println("View Doses Missed screen hidden");
    }

    function scrollUp() as Void {
        if (_scrollOffset > 0) {
            _scrollOffset = _scrollOffset - 1;
            WatchUi.requestUpdate();
        }
    }

    function scrollDown() as Void {
        var app = getApp();
        var schedules = app.getSchedules();

        // Count total missed doses
        var totalDoses = 0;
        for (var i = 0; i < schedules.size(); i++) {
            var schedule = schedules[i] as Dictionary;
            var dosesMissed = schedule["dosesMissed"] as Array;
            totalDoses += dosesMissed.size();
        }

        var maxVisible = 6;
        if (_scrollOffset + maxVisible < totalDoses) {
            _scrollOffset = _scrollOffset + 1;
            WatchUi.requestUpdate();
        }
    }

    // Helper function to sort doses by timestamp (newest first)
    function sortDoses(doses as Array) as Array {
        // Simple bubble sort (good enough for small arrays)
        var n = doses.size();
        for (var i = 0; i < n - 1; i++) {
            for (var j = 0; j < n - i - 1; j++) {
                var dose1 = doses[j] as Dictionary;
                var dose2 = doses[j + 1] as Dictionary;
                var time1 = dose1["timestamp"] as Number;
                var time2 = dose2["timestamp"] as Number;

                // Sort descending (newest first)
                if (time1 < time2) {
                    var temp = doses[j];
                    doses[j] = doses[j + 1];
                    doses[j + 1] = temp;
                }
            }
        }
        return doses;
    }
}

class ViewDosesMissedDelegate extends WatchUi.BehaviorDelegate {

    var _view as ViewDosesMissedView;

    function initialize(view as ViewDosesMissedView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onPreviousPage() as Boolean {
        System.println("UP pressed - scrolling up");
        _view.scrollUp();
        return true;
    }

    function onNextPage() as Boolean {
        System.println("DOWN pressed - scrolling down");
        _view.scrollDown();
        return true;
    }

    function onBack() as Boolean {
        System.println("BACK pressed - returning to main screen");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onSelect() as Boolean {
        return true;
    }
}
