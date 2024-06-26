import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class DSPSYSSTSView extends WatchUi.WatchFace {
    var showSteps = false;
    var showHr = false;
    var showMessages = false;
    var height = 416;
    var width = 416;
    var displayEntries;
    var is24Hour = false;

    function initialize() {
        showSteps = (Toybox has :ActivityMonitor);
        showHr = (ActivityMonitor has :getHeartRateHistory);
        showMessages = (DeviceSettings has :notificationCount);
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        height = dc.getHeight();
        width = dc.getWidth();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        is24Hour = System.getDeviceSettings().is24Hour;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var clockTime = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var hours = clockTime.hour;
        if (!is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        var timeString = Lang.format("$1$/$2$/$3$ $4$:$5$:$6$ ", 
            [clockTime.month.format("%02u"), 
            clockTime.day.format("%02u"), 
            (clockTime.year % 100).format("%02u"),
            hours.format("%02u"), 
            clockTime.min.format("%02u"), 
            clockTime.sec.format("%02u")]);

        var systemStats = System.getSystemStats();
        var batteryFormatted = leftPadString(systemStats.battery.format("%1.1f"), 5);
        var batteryString = Lang.format("% Battery . : $1$", [batteryFormatted]);

        var body =  batteryString;

        if(showSteps) {
            var actInfo = ActivityMonitor.getInfo();
            var stepsString = leftPadString(Lang.format("$1$", [actInfo.steps]), 5);
            body += "\nSteps . . . : "+stepsString;
        }

        if(showHr) {
            var pulse = getHeartRate();
            var pulseString = leftPadString(Lang.format("$1$", [pulse]), 5);
            body += "\nPulse . . . : "+pulseString;
        }

        if(showMessages) {
            var messages = System.getDeviceSettings().notificationCount;
            var messageString = leftPadString(Lang.format("$1$", [messages]), 5);
            body += "\nMessages  . : "+messageString;
        }

        var dateTime = View.findDrawableById("DateTime") as Text;
        var view = View.findDrawableById("Content") as Text;

        // Update the view
        dateTime.setText(timeString);
        view.setText(body);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    function leftPadString(str as String, len as Number) as String {
        var padding = "       ";
        var fullPadded = padding+str;
        var e = fullPadded.length();
        return fullPadded.substring(e - len, e);
    }

    function getHeartRate() as String {
    	var hr="NaN";
        var newHr=Activity.getActivityInfo().currentHeartRate;
        if(newHr==null) {
            var hrh=ActivityMonitor.getHeartRateHistory(1,true);
            if(hrh!=null) {
                var hrs=hrh.next();
                if(hrs!=null && hrs.heartRate!=null && hrs.heartRate!=ActivityMonitor.INVALID_HR_SAMPLE) {
                    newHr=hrs.heartRate;
                }
            }    	
        }
    	if(newHr!=null) {hr=newHr.toNumber();} 
        return hr;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
