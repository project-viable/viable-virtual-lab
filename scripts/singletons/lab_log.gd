extends Node
#This node should be autoloaded, so that it's always accessible from everywhere

#log data will be used by other things. This node just stores them and notifies others when they change.
var logs: Array[LogMessage] = []

signal new_message(new_log: LogMessage)
signal logs_cleared()

func add_log_message(category: LogMessage.Category, message: String, hidden: bool = false, popup: bool = false) -> void:
	var new_log := LogMessage.new(category, message, hidden, popup)
	logs.append(new_log)
	emit_signal("new_message", new_log)

# Get logs with the category `category`.
func get_logs(category: LogMessage.Category) -> Array[LogMessage]:
	return logs.filter(func (l: LogMessage) -> bool: return l.category == category)

#clears all the logs
func clear_logs() -> void:
	logs.clear()
	emit_signal("logs_cleared")

#========Convenience Functions========
#all of these are just prettier ways of calling AddLogMessage
#the intent is that you should only ever have to call these

func log(message: String, hidden: bool = false, popup: bool = true) -> void:
	add_log_message(LogMessage.Category.LOG, message, hidden, popup)

func warn(message: String, hidden: bool = false, popup: bool = true) -> void:
	add_log_message(LogMessage.Category.WARNING, message, hidden, popup)

#errors should generally always popup, and should not be hidden.
func error(message: String) -> void:
	add_log_message(LogMessage.Category.ERROR, message, false, true)
