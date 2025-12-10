import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time;

class LogDoseView extends WatchUi.View {

    var _dueSchedules as Array;
    var _selectedIndex as Number;

    function initialize() {
        View.initialize();

        var app = getApp();
        var schedules = app.getSchedules();
        var now = Time.now();

        _dueSchedules = [];

        for (var i = 0; i < schedules.size(); i++) {
            if (app.isInWindow(i, now)) {
                _dueSchedules.add(i);
            }
        }

        _selectedIndex = 0;

        System.println("LogDoseView: Found " + _dueSchedules.size() + " due schedule(s)");
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            15,
            Graphics.FONT_SMALL,
            "Log Dose",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawLine(10, 40, width - 10, 40);

        if (_dueSchedules.size() == 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                height / 2 - 20,
                Graphics.FONT_SMALL,
                "No dose due",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.drawText(
                width / 2,
                height / 2 + 10,
                Graphics.FONT_TINY,
                "Press BACK to return",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            var app = getApp();
            var schedules = app.getSchedules();

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                50,
                Graphics.FONT_TINY,
                "Select schedule:",
                Graphics.TEXT_JUSTIFY_CENTER
            );

            var yPosition = 75;

            for (var i = 0; i < _dueSchedules.size(); i++) {
                var scheduleIndex = _dueSchedules[i];
                var schedule = schedules[scheduleIndex] as Dictionary;
                var scheduledTime = schedule["scheduledTime"] as String;
                var windowHours = schedule["windowHours"] as Number;

                if (i == _selectedIndex) {
                    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_DK_GRAY);
                    dc.fillRectangle(10, yPosition + 5, width - 20, 45);
                }

                dc.setColor(i == _selectedIndex ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    width / 2,
                    yPosition,
                    Graphics.FONT_MEDIUM,
                    "Schedule " + (scheduleIndex + 1),
                    Graphics.TEXT_JUSTIFY_CENTER
                );

                dc.drawText(
                    width / 2,
                    yPosition + 25,
                    Graphics.FONT_SMALL,
                    scheduledTime + " (" + windowHours + "hr)",
                    Graphics.TEXT_JUSTIFY_CENTER
                );

                yPosition += 55;
            }

            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

            if (_dueSchedules.size() > 1) {
                dc.drawText(
                    width / 2,
                    height - 35,
                    Graphics.FONT_XTINY,
                    "UP/DOWN: Select",
                    Graphics.TEXT_JUSTIFY_CENTER
                );
            }
        }
    }

    function getDueSchedules() as Array {
        return _dueSchedules;
    }

    function getSelectedIndex() as Number {
        return _selectedIndex;
    }

    function getSelectedScheduleIndex() as Number {
        if (_selectedIndex >= 0 && _selectedIndex < _dueSchedules.size()) {
            return _dueSchedules[_selectedIndex];
        }
        return -1;
    }

    function selectNext() as Void {
        if (_dueSchedules.size() > 0) {
            _selectedIndex = (_selectedIndex + 1) % _dueSchedules.size();
            WatchUi.requestUpdate();
        }
    }

    function selectPrevious() as Void {
        if (_dueSchedules.size() > 0) {
            _selectedIndex = _selectedIndex - 1;
            if (_selectedIndex < 0) {
                _selectedIndex = _dueSchedules.size() - 1;
            }
            WatchUi.requestUpdate();
        }
    }
}

class LogDoseDelegate extends WatchUi.BehaviorDelegate {

    var _view as LogDoseView;

    function initialize(view as LogDoseView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onPreviousPage() as Boolean {
        System.println("UP pressed - previous schedule");
        _view.selectPrevious();
        return true;
    }

    function onNextPage() as Boolean {
        System.println("DOWN pressed - next schedule");
        _view.selectNext();
        return true;
    }

    function onSelect() as Boolean {
        var dueSchedules = _view.getDueSchedules();

        if (dueSchedules.size() == 0) {
            System.println("No schedules due - cannot log");
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }

        var scheduleIndex = _view.getSelectedScheduleIndex();
        System.println("SELECT pressed - confirming dose for schedule " + scheduleIndex);

        var confirmView = new LogDoseConfirmView(scheduleIndex);
        var confirmDelegate = new LogDoseConfirmDelegate(scheduleIndex, confirmView);
        WatchUi.pushView(confirmView, confirmDelegate, WatchUi.SLIDE_IMMEDIATE);

        return true;
    }

    function onBack() as Boolean {
        System.println("BACK pressed - canceling dose log");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}
