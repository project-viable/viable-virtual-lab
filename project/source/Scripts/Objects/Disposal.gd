extends LabObject

export(bool) var confirmDisposal = true

var target = null #used to store which object we're asking about, if the confirmation menu is used.

func _ready():
	._ready() #like super() in other languages
	$Menu.hide()

func TryInteract(others):
	#In general, we should only interact with one thing at once
	#every LabObject is equally trashable, so we just pick the first one.
	if confirmDisposal:
		target = others[0]
		$Menu.show()
	else:
		Dispose(others[0])
	return true

func Dispose(object):
	#TODO: once we have guided modules, check and give feedback on whether they put it in the correct bin (eg. sharps go in the sharps disposal)
	print("Calling Disposal function of " + str(object))
	object.dispose()

func _on_YesButton_pressed():
	Dispose(target)
	$Menu.hide()
