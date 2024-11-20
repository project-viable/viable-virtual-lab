extends LabObject

@export var accepted_groups: Array[String] = ["LabObjects"] #we will only try to interact with objects in at least one of these groups. # (Array, String)
@export var confirm_disposal: bool = true

var target: LabObject = null #used to store which object we're asking about, if the confirmation menu is used.

func _ready() -> void:
	super()
	$Menu.hide()

func TryInteract(others: Array[LabObject]) -> bool:
	for other in others:
		for group in accepted_groups:
			if other.is_in_group(group):
				#update the text
				if len(other.display_name) > 0:
					if (other.display_name.find("Pipette") and ("hasTip" in other) and other.hasTip):
						$Menu/PanelContainer/VBoxContainer/Label.text = "Do you really want to dispose of this " + other.display_name + " tip?"
					else:
						$Menu/PanelContainer/VBoxContainer/Label.text = "Do you really want to dispose of this " + other.display_name + "?"
				else:
					$Menu/PanelContainer/VBoxContainer/Label.text = "Are you sure you want to throw this away?"
				
				if confirm_disposal:
					target = other
					$Menu.show()
				else:
					Dispose(other)
				return true
	
	return false

func Dispose(object: LabObject) -> void:
	#TODO: Report this to the mistake checker
	print("Calling Disposal function of " + str(object))
	object.dispose()

func _on_YesButton_pressed() -> void:
	Dispose(target)
	$Menu.hide()
