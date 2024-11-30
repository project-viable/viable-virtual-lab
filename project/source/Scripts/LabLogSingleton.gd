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
signal NewMessage(category: String, newLog: Dictionary)
signal LogsCleared()
signal ReportShown()

func AddLogMessage(category: String, message: String, hidden: bool = false, popup: bool = false) -> void:
	if not logs.has(category):
		logs[category] = []
	
	var newLog: Dictionary = {'message': message, 'hidden': hidden, 'popup': popup}
	logs[category].append(newLog)
	
	emit_signal("NewMessage", category, newLog)

#returns the entire logs structure, defined above.
func GetLogs() -> Dictionary:
	return logs.duplicate(true)

#clears all the logs
func ClearLogs() -> void:
	logs = {}
	emit_signal("LogsCleared")

#This is just for convenience - instead of having to find the final report UI node, just call LabLog.ShowReport() and it'll make sure that everyone who needs to know about it does.
func ShowReport() -> void:
	emit_signal("ReportShown")

#========Convenience Functions========
#all of these are just prettier ways of calling AddLogMessage
#the intent is that you should only ever have to call these

func Log(message: String, hidden: bool = false, popup: bool = true) -> void:
	AddLogMessage("log", message, hidden, popup)

func Warn(message: String, hidden: bool = false, popup: bool = true) -> void:
	AddLogMessage("warning", message, hidden, popup)

#errors should generally always popup, and should not be hidden.
func Error(message: String) -> void:
	AddLogMessage("error", message, false, true)
