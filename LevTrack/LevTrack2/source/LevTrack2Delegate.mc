import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

class LevTrack2Delegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
        System.println("LevTrack2Delegate initialized");
    }

    function onMenu() as Boolean {
        System.println("MENU BUTTON PRESSED!");
        
        var menu = new WatchUi.Menu2({:title=>"Options"});
        menu.addItem(new WatchUi.MenuItem("Add Schedule", null, :addSchedule, {}));
        menu.addItem(new WatchUi.MenuItem("View Schedules", null, :viewSchedules, {}));
        menu.addItem(new WatchUi.MenuItem("View Taken", null, :viewTaken, {}));
        menu.addItem(new WatchUi.MenuItem("View Missed", null, :viewMissed, {}));
        menu.addItem(new WatchUi.MenuItem("Reset All", null, :resetSchedules, {}));
        
        WatchUi.pushView(menu, new MainMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        
        return true;
    }

    function onSelect() as Boolean {
        System.println("Select button pressed - opening log dose screen");
        
        // Open the log dose screen
        var view = new LogDoseView();
        var delegate = new LogDoseDelegate(view);
        WatchUi.pushView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
        
        return true;
    }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
        System.println("MainMenuDelegate initialized");
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        System.println("Menu item selected: " + id);
        
        if (id == :addSchedule) {
            System.println("Opening Add Schedule screen");
            var view = new AddScheduleView();
            var delegate = new AddScheduleDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
            
        } else if (id == :viewSchedules) {
            System.println("Opening View Schedules screen");
            WatchUi.pushView(new ViewSchedulesView(), new ViewSchedulesDelegate(), WatchUi.SLIDE_IMMEDIATE);
            
        } else if (id == :viewTaken) {
            System.println("Opening View Taken Doses screen");
            var view = new ViewDosesTakenView();
            WatchUi.pushView(view, new ViewDosesTakenDelegate(view), WatchUi.SLIDE_IMMEDIATE);
            
        } else if (id == :viewMissed) {
            System.println("Opening View Missed Doses screen");
            var view = new ViewDosesMissedView();
            WatchUi.pushView(view, new ViewDosesMissedDelegate(view), WatchUi.SLIDE_IMMEDIATE);
            
        } else if (id == :resetSchedules) {
            System.println("Reset schedules requested - showing confirmation");
            var view = new ResetConfirmView();
            var delegate = new ResetConfirmDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
