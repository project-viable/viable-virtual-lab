extends Node
## Interface with the lab report, shown when a module is completed.
##
## The report consists of a set of [LabReportNote]s, each uniquely identified by a name and a type.
##
## A [LabReportNote] represents a single section of the lab report, and keeps track of the data
## needed to report it. For example, look at [BasicEquipmentLabReportNote]. This note keeps track
## of mistakes made with any basic piece of equipment, including the pipette and the scale, so any
## of these objects need access to the same [BasicEquipmentLabReportNote] instance. Any object that
## wants an instance of that note can get it with
## [code]get_or_create_report_note(BasicEquipmentLabReportNote)[/code], which will also
## automatically create the instance if it doesn't exist yet.

# Maps pairs [code](name, type)[/code] to [LabReportNote]s.
var _report_note_by_name: Dictionary[Array, LabReportNote] = {}


## Return the note with name [param note_name] and type [param note_type]. If it doesn't exist yet,
## create it. If there only needs to be a single note of the given type, then the empty string will
## be used by default. If there are multiple instances of the same note type, then each one should
## be given a name using [param note_name].
func get_or_create_report_note(note_type: Script, note_name: String = "") -> LabReportNote:
	var instance: LabReportNote = _report_note_by_name.get([note_name, note_type])
	if not instance:
		var created_instance := Resource.new()
		created_instance.set_script(note_type)
		instance = created_instance

		# I'm not sure if there's a better way to check the type of the script.
		if not is_instance_of(instance, LabReportNote): return null

		_report_note_by_name.set([note_name, note_type], instance)

	return instance

## Generate the report into [param label].
func generate_report(label: RichTextLabel) -> void:
	label.clear()
	for note: LabReportNote in _report_note_by_name.values():
		note.add_to_label(label)

## Remove all notes.
func clear() -> void:
	_report_note_by_name.clear()
