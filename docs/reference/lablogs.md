## Lab Logs

This refers to any message that you need to show to the user (for example, telling them that they heated something too long). In order to do this, you need to use the `LabLog` object, which you can access from any script.

Logs should fall into 3 categories:

- Log: this is for messages that the user should be able to see, but are purely informational, not mistakes. For example, you might create a log when they reach a certain milestone or checkpoint in the lab. You may also use this to give the user an indication their interaction actually happened.
- Warning: this is for warning the user of small mistakes, but ones which they can continue from. For example, in Gel Electrophoresis, if they microwave it too long, the viscosity will be different than expected, which may impact the final result.
- Error: this is for larger mistakes, whose results we cannot simulate. Use these to notify the user of critical errors.

Logs also have 2 properties:

- `hidden`: true/false, specifies whether the log should be shown in the log menu in the upper right of the screen. Hidden logs are intended for things that should only be visible at the end of the experiment, in the final report (see `ShowReport()` below).`
- `popup`: true/false, specifies whether the user should immediately be notified with a popup dialog. It does not affect or matter whether the log is hidden. Errors should probably always have this true.

### `LabLog` Functions

###### Common Functions:
- `log(message, hidden = false, popup = true)`: creates a new log with the given message. `hidden` and `popup` are optional. The category of this log will be `"log"`.
- `warn(message, hidden = false, popup = true)`: creates a new Warning type log with the given message. `hidden` and `popup` are optional. The category of this log will be `"warning"`.
- `error(message)`: creates a new Error type log with the given message. `hidden` is always set to false and `popup` is always set as true. The category of this log will be `"error"`.
- `show_report()`: Tells the system to show the final report for the module - a popup window that shows warning and errors, and lets them restart, return to the menu, or continue in freeform mode. Call this function when the user has completed an experiment.
###### Other Functions:
- `get_logs()`: returns all the logs that have been created, in a dictionary like this: `{"log": [list of logs], "error": [list of logs], "category": [list of logs in that category]}` See below for the log data structure.
- `clear_logs()`: Clears all the logs, and notifies anything that cares that it has done so. This is only used internally when switching scenes, etc.
- `add_log_message(category, message, hidden, popup)`: You shouldn't need to call this, but it's documented here for completeness. This function is used by Log, Warn, and Error (see above). This way the system technically supports other types of logs, and errors that do not have popups. Currently, `category` is always "log", "warning", or "error", but you could use others. If you need to add another category of log at some point, and there's going to be multiple logs of that category, I think you should consider adding a convenience function like the above for it. That way you can decide whether it should always have popups, always be hidden, etc, and the code for adding a new one is more readable.

### `LabLog` Signals
You probably don't need to use any of these, but you can if you need. They are used by the UI nodes to update themselves with the new logs that interest them. You can use them yourself by calling `LabLog.connect("the name of the signal", [yourObject (probably 'self')], "theFunctionToCallOnYourObject")`.

- `new_message(category: String, new_log: Dictionary)`: Emitted when a new log is created, of any type. See below for the log data structure.
- `report_shown`: Emitted when something calls `show_report()` (see above). Used internally, but you can connect to it too if you need to.
- `clear_logs`: Emitted when logs are cleared with `clear_logs()` (see above). Used internally to tell UI nodes to update themselves.

### Log data structure

`get_logs()` and the `new_message` signal give you logs as dictionaries like this:

```gdscript
{
   "message": "Some string",
   "hidden": true/false,
   "popup": true/false
}
```

### Using LabLog

`LabLog` is a singleton (an [autoloaded](https://docs.godotengine.org/en/3.5/tutorials/scripting/singletons_autoload.html) instance of the `LabLogSingleton.gd` script), which you can access from any script by its name. To log something, just do something like this:

```gdscript
LabLog.log("Hello World!")
LabLog.warn("You didn't heat [something] for long enough! This may affect the final result.", true, false)
LabLog.error(You messed up really bad.)
```
