extends LabObject

func ScaleUp():
	scale = scale * 1.1
	LabLog.Log("You scaled up a test object!")
	LabLog.Log("You scaled up a test object (hidden)!", true)
	LabLog.Warn("You scaled up a test object!")
	LabLog.Warn("You scaled up a test object!")
	LabLog.Warn("You scaled up a test object (hidden)!", true)
	LabLog.Warn("You scaled up a test object (hidden)!", true)
	LabLog.Error("Added a bunch or logs and errors for testing!")
	LabLog.ShowReport()
