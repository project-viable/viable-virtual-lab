tool
extends SubsceneManager

func TryInteract(others):
	AdoptNode(others[0])
	ShowSubscene()
	return true

func TryActIndependently():
	if not subsceneActive: ShowSubscene()
	return true
