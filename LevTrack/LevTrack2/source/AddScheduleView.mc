import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

class AddScheduleView extends WatchUi.View {

    var _hour as Number;
    var _minute as Number;
    var _windowHours as Number;
    var _editingField as Number;
    
    function initialize() {
        View.initialize();
        
        _hour = 9;
        _minute = 0;
        _windowHours = 3;
        _editingField = 0;
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // Nothing needed here
    }

    function onShow() as Void {
        System.println("Add Schedule view shown");
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        dc.drawText(
            width / 2,
            15,
            Graphics.FONT_SMALL,
            "Add Schedule",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        dc.drawLine(10, 40, width - 10, 40);
        
        drawField(dc, "Hour:", _hour.format("%02d"), 60, (_editingField == 0));
        drawField(dc, "Minute:", _minute.format("%02d"), 85, (_editingField == 1));
        drawField(dc, "Window (hrs):", _windowHours.toString(), 110, (_editingField == 2));
        
        var timeString = Lang.format("$1$:$2$", [
            _hour.format("%02d"),
            _minute.format("%02d")
        ]);
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height - 85,
            Graphics.FONT_SMALL,
            "Time: " + timeString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        dc.drawText(
            width / 2,
            height - 35,
            Graphics.FONT_TINY,
            "Hold Menu to Save",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
    
    function drawField(dc as Graphics.Dc, label as String, value as String, yPos as Number, isSelected as Boolean) as Void {
        var width = dc.getWidth();
        
        if (isSelected) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
            dc.fillRectangle(10, yPos - 5, width - 20, 30);
        }
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            20,
            yPos,
            Graphics.FONT_SMALL,
            label,
            Graphics.TEXT_JUSTIFY_LEFT
        );
        
        dc.setColor(isSelected ? Graphics.COLOR_YELLOW : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width - 20,
            yPos,
            Graphics.FONT_MEDIUM,
            value,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    function onHide() as Void {
        System.println("Add Schedule view hidden");
    }
    
    function getHour() as Number {
        return _hour;
    }
    
    function getMinute() as Number {
        return _minute;
    }
    
    function getWindowHours() as Number {
        return _windowHours;
    }
    
    function getEditingField() as Number {
        return _editingField;
    }
    
    function incrementValue() as Void {
        if (_editingField == 0) {
            _hour = (_hour + 1) % 24;
        } else if (_editingField == 1) {
            _minute = (_minute + 1) % 60;
        } else if (_editingField == 2) {
            _windowHours = _windowHours + 1;
            if (_windowHours > 12) {
                _windowHours = 1;
            }
        }
        WatchUi.requestUpdate();
    }
    
    function decrementValue() as Void {
        if (_editingField == 0) {
            _hour = _hour - 1;
            if (_hour < 0) {
                _hour = 23;
            }
        } else if (_editingField == 1) {
            _minute = _minute - 1;
            if (_minute < 0) {
                _minute = 59;
            }
        } else if (_editingField == 2) {
            _windowHours = _windowHours - 1;
            if (_windowHours < 1) {
                _windowHours = 12;
            }
        }
        WatchUi.requestUpdate();
    }
    
    function nextField() as Void {
        _editingField = (_editingField + 1) % 3;
        WatchUi.requestUpdate();
    }
}

class AddScheduleDelegate extends WatchUi.BehaviorDelegate {

    var _view as AddScheduleView;
    
    function initialize(view as AddScheduleView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onPreviousPage() as Boolean {
        System.println("UP pressed - incrementing");
        _view.incrementValue();
        return true;
    }
    
    function onNextPage() as Boolean {
        System.println("DOWN pressed - decrementing");
        _view.decrementValue();
        return true;
    }
    
    function onSelect() as Boolean {
        System.println("SELECT pressed - next field");
        _view.nextField();
        return true;
    }
    
    function onMenu() as Boolean {
        System.println("MENU pressed - saving schedule");
        
        var hour = _view.getHour();
        var minute = _view.getMinute();
        var windowHours = _view.getWindowHours();
        
        var timeString = Lang.format("$1$:$2$", [
            hour.format("%02d"),
            minute.format("%02d")
        ]);
        
        var app = getApp();
        app.addSchedule(timeString, windowHours);
        
        System.println("Schedule added: " + timeString + " with " + windowHours + "hr window");
        
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        
        return true;
    }
    
    function onBack() as Boolean {
        System.println("BACK pressed - canceling");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}
