extends Node
#This node should be autoloaded, so that it's always accessible from everywhere

#logs should generally be in one of 3 categories: "log", "warning", or "error".
#log is for general messages - not mistakes, just something you want to log.
#warning is for minor errors that you can continue on from - like putting glass in a nornmal trash can
#error is for things you can't recover from
#^but, this system is designed to support other weird things, if you want.
#logs is a dictionary like this:
#{'category1': [list of logs], 'category2': [list of logs]}
#each log is stored as dictionaries like this:
#{'message': "something", 'hidden': false, 'popup': false}
#log data will be used by other things. This node just stores them and notifies others when they change.
var logs: Dictionary = {}
signal new_message(category: String, new_log: Dictionary)
signal logs_cleared()
signal ReportShown()

func add_log_message(category: String, message: String, hidden: bool = false, popup: bool = false) -> void:
	if not logs.has(category):
		logs[category] = []
	
	var new_log: Dictionary = {'message': message, 'hidden': hidden, 'popup': popup}
	logs[category].append(new_log)
	
	emit_signal("new_message", category, new_log)

#returns the entire logs structure, defined above.
func get_logs() -> Dictionary:
	return logs.duplicate(true)

#clears all the logs
func clear_logs() -> void:
	logs = {}
	emit_signal("logs_cleared")

#This is just for convenience - instead of having to find the final report UI node, just call LabLog.show_report() and it'll make sure that everyone who needs to know about it does.
func show_report() -> void:
	emit_signal("ReportShown")

#========Convenience Functions========
#all of these are just prettier ways of calling AddLogMessage
#the intent is that you should only ever have to call these

func log(message: String, hidden: bool = false, popup: bool = true) -> void:
	add_log_message("log", message, hidden, popup)

func warn(message: String, hidden: bool = false, popup: bool = true) -> void:
	add_log_message("warning", message, hidden, popup)

#errors should generally always popup, and should not be hidden.
func error(message: String) -> void:
	add_log_message("error", message, false, true)
