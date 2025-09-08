extends LabBody


func _on_electrical_component_voltage_changed() -> void:
	print("Box: voltage set to %s" % [$ElectricalComponent.voltage])
