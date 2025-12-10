import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application.Storage;
import Toybox.Time;

class LevTrack2App extends Application.AppBase {

    var meddata as Dictionary;

    function initialize() {
        AppBase.initialize();
        meddata = {
            "schedules" => []
        };
        loadMedicationData();

        if (meddata["schedules"].size() == 0) {
            System.println("Hello I would like some schedules please");
        }
    }

    function onStart(state as Lang.Dictionary?) as Void {
        System.println("Hello I'm alive and kicking");
    }

    function onStop(state as Lang.Dictionary?) as Void {
        System.println("I'm dying but I'll save my data, for you xoxo");
        saveMedicationData();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new LevTrack2View(), new LevTrack2Delegate() ];
    }

    //Load medication data from storage
    function loadMedicationData() as Void {
        System.println("Load the data from storage!");

        var savedData = Storage.getValue("meddata");

        if (savedData != null && savedData instanceof Dictionary) {
            meddata = savedData as Dictionary;
            var schedules = meddata["schedules"] as Array;
            System.println("Loaded " + schedules.size() + " schedule(s)");
        } else {
            meddata = {
                "schedules" => []
            };
            System.println("Nothing here");
        }
    }

    // UDF #2: Save medication data to persistent storage
    function saveMedicationData() as Void {
        System.println("Saving medication data to storage...");
        
        Storage.setValue("meddata", meddata);
        
        var schedules = meddata["schedules"] as Array;
        System.println("Saved " + schedules.size() + " schedule(s)");
    }
    
    // UDF #3: Get the medication schedules (so other classes can access them)
    function getSchedules() as Array {
        return meddata["schedules"] as Array;
    }
    
    // UDF #4: Add a new dosing schedule
    function addSchedule(scheduledTime as String, windowHours as Number) as Void {
        var schedules = meddata["schedules"] as Array;
        
        System.println("Adding schedule: " + scheduledTime + " with " + windowHours + "hr window");
        
        if (schedules.size() >= 2) {
            System.println("ERROR: Already have 2 schedules. Cannot add more.");
            return;
        }
        
        var newSchedule = {
            "scheduledTime" => scheduledTime,
            "windowHours" => windowHours,
            "dosesTaken" => [],
            "dosesMissed" => []
        };
        
        schedules.add(newSchedule);
        
        saveMedicationData();
        
        System.println("Schedule added successfully. Total schedules: " + schedules.size());
    }
    
    // UDF #5: Edit an existing schedule
    function editSchedule(index as Number, scheduledTime as String, windowHours as Number) as Void {
        var schedules = meddata["schedules"] as Array;
        
        if (index < 0 || index >= schedules.size()) {
            System.println("ERROR: Invalid schedule index: " + index);
            return;
        }
        
        System.println("Editing schedule " + index);
        
        var schedule = schedules[index] as Dictionary;
        schedule["scheduledTime"] = scheduledTime;
        schedule["windowHours"] = windowHours;
        
        saveMedicationData();
        
        System.println("Schedule edited successfully");
    }
    
    // UDF #6: Delete a schedule
    function deleteSchedule(index as Number) as Void {
        var schedules = meddata["schedules"] as Array;
        
        if (index < 0 || index >= schedules.size()) {
            System.println("ERROR: Invalid schedule index: " + index);
            return;
        }
        
        System.println("Deleting schedule " + index);
        
        schedules.remove(schedules[index]);
        
        saveMedicationData();
        
        System.println("Schedule deleted successfully. Total schedules: " + schedules.size());
    }
    
    // UDF #7: Log a dose as taken
    function logDose(scheduleIndex as Number, timestamp as Number) as Void {
        var schedules = meddata["schedules"] as Array;
        
        if (scheduleIndex < 0 || scheduleIndex >= schedules.size()) {
            System.println("ERROR: Invalid schedule index: " + scheduleIndex);
            return;
        }
        
        System.println("Logging dose for schedule " + scheduleIndex);
        
        var schedule = schedules[scheduleIndex] as Dictionary;
        var dosesTaken = schedule["dosesTaken"] as Array;
        
        dosesTaken.add(timestamp);
        
        saveMedicationData();
        
        System.println("Dose logged at timestamp: " + timestamp);
    }
    
    // UDF #8: Mark a dose as missed
    function markDoseMissed(scheduleIndex as Number, timestamp as Number) as Void {
        var schedules = meddata["schedules"] as Array;
        
        if (scheduleIndex < 0 || scheduleIndex >= schedules.size()) {
            System.println("ERROR: Invalid schedule index: " + scheduleIndex);
            return;
        }
        
        System.println("Marking dose missed for schedule " + scheduleIndex);
        
        var schedule = schedules[scheduleIndex] as Dictionary;
        var dosesMissed = schedule["dosesMissed"] as Array;
        
        dosesMissed.add(timestamp);
        
        saveMedicationData();
        
        System.println("Dose marked as missed at timestamp: " + timestamp);
    }
    
    // UDF #9: Check if current time is within dosing window
    function isInWindow(scheduleIndex as Number, currentTime as Time.Moment) as Boolean {
        var schedules = meddata["schedules"] as Array;
        
        if (scheduleIndex < 0 || scheduleIndex >= schedules.size()) {
            return false;
        }
        
        var schedule = schedules[scheduleIndex] as Dictionary;
        var scheduledTime = schedule["scheduledTime"] as String;
        var windowHours = schedule["windowHours"] as Number;
        
        var timeParts = StringUtils.splitString(scheduledTime, ":");
        var scheduledHour = timeParts[0].toNumber();
        var scheduledMinute = timeParts[1].toNumber();
        
        var now = Time.Gregorian.info(currentTime, Time.FORMAT_SHORT);
        var currentHour = now.hour;
        var currentMinute = now.min;
        
        var scheduledMinutes = scheduledHour * 60 + scheduledMinute;
        var currentMinutes = currentHour * 60 + currentMinute;
        var windowMinutes = windowHours * 60;
        
        var difference = currentMinutes - scheduledMinutes;
        
        if (difference >= 0 && difference <= windowMinutes) {
            return true;
        }
        
        return false;
    }
    
    // UDF #10: Reset all schedules (delete all)
    function resetSchedules() as Void {
        System.println("Resetting all schedules");
        
        meddata = {
            "schedules" => []
        };
        
        saveMedicationData();
        
        System.println("All schedules deleted");
    }
    
}

function getApp() as LevTrack2App {
    return Application.getApp() as LevTrack2App;
}
