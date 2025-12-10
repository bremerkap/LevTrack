import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time;

class LevTrack2View extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // We'll draw everything manually in onUpdate
    }

    function onShow() as Void {
        System.println("View is now visible");
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        var app = getApp();
        var schedules = app.getSchedules();
        
        var now = Time.now();
        var timeInfo = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var currentTimeString = Lang.format("$1$:$2$", [
            timeInfo.hour.format("%02d"),
            timeInfo.min.format("%02d")
        ]);
        
        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            15,
            Graphics.FONT_MEDIUM,
            "LevTrack",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        // Current time (large and prominent)
        dc.drawText(
            width / 2,
            45,
            Graphics.FONT_NUMBER_HOT,
            currentTimeString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        
        // Check if any schedules exist
        if (schedules.size() == 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                height / 2,
                Graphics.FONT_TINY,
                "No schedules configured",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                width / 2,
                height / 2 + 30,
                Graphics.FONT_TINY,
                "Press MENU to add",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            // Just show a simple status summary
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                110,
                Graphics.FONT_SMALL,
                schedules.size() + " schedule(s) active",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            
            // Check if any are due now
            var anyDue = false;
            for (var i = 0; i < schedules.size(); i++) {
                if (app.isInWindow(i, now)) {
                    anyDue = true;
                    break;
                }
            }
            
            if (anyDue) {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    width / 2,
                    height / 2 + 10,
                    Graphics.FONT_LARGE,
                    "TAKE NOW",
                    Graphics.TEXT_JUSTIFY_CENTER
                );
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    width / 2,
                    height / 2 + 40,
                    Graphics.FONT_SMALL,
                    "Press SELECT to log",
                    Graphics.TEXT_JUSTIFY_CENTER
                );
            } else {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    width / 2,
                    height / 2,
                    Graphics.FONT_MEDIUM,
                    "No dose due",
                    Graphics.TEXT_JUSTIFY_CENTER
                );
            }
        }
        
        // Instructions at bottom
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height - 30,
            Graphics.FONT_XTINY,
            "MENU: Options",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function onHide() as Void {
        System.println("View is now hidden");
    }
}
