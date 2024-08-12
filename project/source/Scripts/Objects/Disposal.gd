extends LabObject

export(Array, String) var acceptedGroups = ["LabObjects"] #we will only try to dispose of objects in at least one of these groups.
export(bool) var confirmDisposal = true

var target = null #used to store which object we're asking about, if the confirmation menu is used.

func _ready():
	._ready() #like super() in other languages
	$Menu.hide()

func TryInteract(others):
	#In general, we should only interact with one thing at once
	#every LabObject is equally trashable, so we just pick the first one.
	
	#update the text
	if len(others[0].DisplayName) > 0:
		$Menu/PanelContainer/VBoxContainer/Label.text = "Do you really want to dispose of this " + others[0].DisplayName + "?"
	else:
		$Menu/PanelContainer/VBoxContainer/Label.text = "Are you sure you want to throw this away?"
	
	if confirmDisposal:
		target = others[0]
		$Menu.show()
	else:
		Dispose(others[0])
	return true

func Dispose(object):
	#TODO: Report this to the mistake checker
	print("Calling Disposal function of " + str(object))
	object.dispose()

func _on_YesButton_pressed():
	Dispose(target)
	$Menu.hide()
