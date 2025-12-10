import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time;

class LogDoseConfirmView extends WatchUi.View {

    var _scheduleIndex as Number;
    var _selectedOption as Number;
    
    function initialize(scheduleIndex as Number) {
        View.initialize();
        _scheduleIndex = scheduleIndex;
        _selectedOption = 1;
    }
    
    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        var app = getApp();
        var schedules = app.getSchedules();
        var schedule = schedules[_scheduleIndex] as Dictionary;
        var scheduledTime = schedule["scheduledTime"] as String;
        
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            20,
            Graphics.FONT_SMALL,
            "Confirm Dose",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            50,
            Graphics.FONT_TINY,
            "Schedule " + (_scheduleIndex + 1),
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        dc.drawText(
            width / 2,
            65,
            Graphics.FONT_MEDIUM,
            scheduledTime,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        var now = Time.now();
        var timeInfo = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var currentTimeString = Lang.format("$1$:$2$", [
            timeInfo.hour.format("%02d"),
            timeInfo.min.format("%02d")
        ]);
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            95,
            Graphics.FONT_TINY,
            "Taken at: " + currentTimeString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        var cancelY = height / 2 + 20;
        var confirmY = height / 2 + 50;
        
        if (_selectedOption == 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_DK_GRAY);
            dc.fillRectangle(20, cancelY - 5, width - 40, 25);
        }
        dc.setColor(_selectedOption == 0 ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            cancelY,
            Graphics.FONT_SMALL,
            "Cancel",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        if (_selectedOption == 1) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_DK_GRAY);
            dc.fillRectangle(20, confirmY - 10, width - 40, 25);
        }
        dc.setColor(_selectedOption == 1 ? Graphics.COLOR_BLACK : Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            confirmY,
            Graphics.FONT_SMALL,
            "LOG DOSE",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height - 30,
            Graphics.FONT_XTINY,
            "UP/DOWN: Select",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
    
    function getSelectedOption() as Number {
        return _selectedOption;
    }
    
    function toggleSelection() as Void {
        _selectedOption = (_selectedOption == 0) ? 1 : 0;
        WatchUi.requestUpdate();
    }
}

class LogDoseConfirmDelegate extends WatchUi.BehaviorDelegate {

    var _scheduleIndex as Number;
    var _view as LogDoseConfirmView;
    
    function initialize(scheduleIndex as Number, view as LogDoseConfirmView) {
        BehaviorDelegate.initialize();
        _scheduleIndex = scheduleIndex;
        _view = view;
    }
    
    function onPreviousPage() as Boolean {
        System.println("UP pressed - toggling selection");
        _view.toggleSelection();
        return true;
    }
    
    function onNextPage() as Boolean {
        System.println("DOWN pressed - toggling selection");
        _view.toggleSelection();
        return true;
    }
    
    function onSelect() as Boolean {
        var selection = _view.getSelectedOption();
        System.println("SELECT pressed - option: " + selection);
        
        if (selection == 1) {
            System.println("Logging dose for schedule " + _scheduleIndex);
            
            var app = getApp();
            var now = Time.now();
            var timestamp = now.value();
            
            app.logDose(_scheduleIndex, timestamp);
            
            var successView = new DoseLoggedSuccessView(_scheduleIndex);
            WatchUi.pushView(successView, new DoseLoggedSuccessDelegate(), WatchUi.SLIDE_IMMEDIATE);
        } else {
            System.println("Cancelled dose log");
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        
        return true;
    }
    
    function onBack() as Boolean {
        System.println("BACK pressed - canceling");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class DoseLoggedSuccessView extends WatchUi.View {

    var _scheduleIndex as Number;
    
    function initialize(scheduleIndex as Number) {
        View.initialize();
        _scheduleIndex = scheduleIndex;
    }
    
    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2 - 40,
            Graphics.FONT_LARGE,
            "Yay!",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_SMALL,
            "Dose Logged!",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2 + 25,
            Graphics.FONT_TINY,
            "Schedule " + (_scheduleIndex + 1),
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}

class DoseLoggedSuccessDelegate extends WatchUi.BehaviorDelegate {
    
    function initialize() {
        BehaviorDelegate.initialize();
    }
    
    function onSelect() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
    
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
    
    function onPreviousPage() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
    
    function onNextPage() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}
