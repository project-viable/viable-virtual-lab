@abstract
class_name LabReportNote
extends Resource
## A section of the lab report.


## (virtual) Add the content of this note to [param label]. It is preferred that this be done via
## the [code]RichTextLabel.add_*[/code] functions rather than appending to the text directly.
@abstract
func add_to_label(label: RichTextLabel) -> void
