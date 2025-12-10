import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

class ViewSchedulesView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // Nothing needed here
    }

    function onShow() as Void {
        System.println("View Schedules screen shown");
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        var app = getApp();
        var schedules = app.getSchedules();
        
        // Title - smaller
        dc.drawText(
            width / 2,
            5,
            Graphics.FONT_TINY,
            "My Schedules",
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
                height / 2 + 10,
                Graphics.FONT_XTINY,
                "Add one from menu",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            var yPosition = 35;
            
            for (var i = 0; i < schedules.size(); i++) {
                var schedule = schedules[i] as Dictionary;
                var scheduledTime = schedule["scheduledTime"] as String;
                var windowHours = schedule["windowHours"] as Number;
                var dosesTaken = schedule["dosesTaken"] as Array;
                var dosesMissed = schedule["dosesMissed"] as Array;
                
                // Draw schedule number - smaller
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    width / 2,
                    yPosition,
                    Graphics.FONT_TINY,
                    "Schedule " + (i + 1),
                    Graphics.TEXT_JUSTIFY_CENTER
                );
                
                // Draw time - medium size
                dc.drawText(
                    width / 2,
                    yPosition + 17,
                    Graphics.FONT_MEDIUM,
                    scheduledTime,
                    Graphics.TEXT_JUSTIFY_CENTER
                );
                
                // Draw window info - tiny
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    width / 2,
                    yPosition + 42,
                    Graphics.FONT_XTINY,
                    "Window: " + windowHours + " hrs",
                    Graphics.TEXT_JUSTIFY_CENTER
                );
                
                // Draw statistics - tiny
                dc.drawText(
                    width / 2,
                    yPosition + 55,
                    Graphics.FONT_XTINY,
                    "Taken: " + dosesTaken.size() + " | Missed: " + dosesMissed.size(),
                    Graphics.TEXT_JUSTIFY_CENTER
                );
                
                // Always increment yPosition for next schedule
                yPosition += 75;
            }
        }
        
        // Instructions at bottom
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height - 40,
            Graphics.FONT_XTINY,
            "BACK: Return",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function onHide() as Void {
        System.println("View Schedules screen hidden");
    }
}

class ViewSchedulesDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        System.println("BACK pressed - returning to main screen");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
    
    function onSelect() as Boolean {
        // Could add functionality to edit schedules here later
        return true;
    }
}
