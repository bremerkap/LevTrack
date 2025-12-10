import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

// Custom confirmation view for reset
class ResetConfirmView extends WatchUi.View {

    var _selectedOption as Number;  // 0 = Cancel, 1 = Confirm
    
    function initialize() {
        View.initialize();
        _selectedOption = 0;  // Default to Cancel for safety
    }
    
    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Warning message
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            30,
            Graphics.FONT_SMALL,
            "Delete All?",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            55,
            Graphics.FONT_TINY,
            "This will delete all",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        dc.drawText(
            width / 2,
            70,
            Graphics.FONT_TINY,
            "schedules and data",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        // Draw options
        var cancelY = height / 2 + 20;
        var confirmY = height / 2 + 50;
        
        // Cancel option
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
        
        // Confirm option
        if (_selectedOption == 1) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_DK_GRAY);
            dc.fillRectangle(20, confirmY - 5, width - 40, 25);
        }
        dc.setColor(_selectedOption == 1 ? Graphics.COLOR_WHITE : Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            confirmY,
            Graphics.FONT_SMALL,
            "DELETE ALL",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        // Instructions
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height - 55,
            Graphics.FONT_XTINY,
            "UP/DOWN: Select",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            width / 2,
            height - 40,
            Graphics.FONT_XTINY,
            "SELECT: Confirm | BACK: Cancel",
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

class ResetConfirmDelegate extends WatchUi.BehaviorDelegate {

    var _view as ResetConfirmView;
    
    function initialize(view as ResetConfirmView) {
        BehaviorDelegate.initialize();
        _view = view;
    }
    
    // UP or DOWN button - toggle selection
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
    
    // SELECT - confirm the choice
    function onSelect() as Boolean {
        var selection = _view.getSelectedOption();
        System.println("SELECT pressed - option: " + selection);
        
        if (selection == 1) {
            // User selected DELETE ALL
            System.println("Deleting all schedules");
            var app = getApp();
            app.resetSchedules();
            
            // Show success message
            WatchUi.pushView(new SuccessMessageView("All schedules deleted!"), new MessageDelegate(), WatchUi.SLIDE_IMMEDIATE);
        } else {
            // User selected Cancel
            System.println("Cancelled reset");
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        
        return true;
    }
    
    // BACK - cancel
    function onBack() as Boolean {
        System.println("BACK pressed - cancelling reset");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

// Simple success message view
class SuccessMessageView extends WatchUi.View {

    var _message as String;
    
    function initialize(message as String) {
        View.initialize();
        _message = message;
    }
    
    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2 - 20,
            Graphics.FONT_SMALL,
            _message,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2 + 20,
            Graphics.FONT_TINY,
            "Press any button",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}

class MessageDelegate extends WatchUi.BehaviorDelegate {
    
    function initialize() {
        BehaviorDelegate.initialize();
    }
    
    // Any button press closes the message
    function onSelect() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
    
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
    
    function onPreviousPage() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
    
    function onNextPage() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}
