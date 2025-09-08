class_name ElectricalComponent
extends Node2D


signal voltage_changed()


## Should be negative if the contacts are plugged in backwards.
@export var voltage: float = 0.0:
	set(v):
		voltage = v
		voltage_changed.emit()
