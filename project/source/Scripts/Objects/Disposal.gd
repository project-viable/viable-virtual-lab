extends LabObject

export(Array, String) var acceptedGroups = ["LabObjects"] #we will only try to interact with objects in at least one of these groups.
export(bool) var confirmDisposal = true

var target = null #used to store which object we're asking about, if the confirmation menu is used.

func _ready():
	._ready() #like super() in other languages
	$Menu.hide()

func TryInteract(others):
	for other in others:
		for group in acceptedGroups:
			if other.is_in_group(group):
				#update the text
				if len(other.DisplayName) > 0:
					$Menu/PanelContainer/VBoxContainer/Label.text = "Do you really want to dispose of this " + other.DisplayName + "?"
				else:
					$Menu/PanelContainer/VBoxContainer/Label.text = "Are you sure you want to throw this away?"
				
				if confirmDisposal:
					target = other
					$Menu.show()
				else:
					Dispose(other)
				return true
	
	return false

func Dispose(object):
	#TODO: Report this to the mistake checker
	print("Calling Disposal function of " + str(object))
	object.dispose()

func _on_YesButton_pressed():
	Dispose(target)
	$Menu.hide()
