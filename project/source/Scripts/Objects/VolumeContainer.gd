@tool
extends Node2D
class_name VolumeContainer

# Each volume container has a volume and max_volume
# volume denotes how much liquid substance it holds
# max_volume is the container's volumetric capacity
var volume: float
var max_volume: float

# Add this to the group VolumeContainers
func _ready() -> void:
	add_to_group("VolumeContainers", true)

# Getters and setters for volume and max_volume
func GetVolume() -> float:
	return volume

func GetMaxVolume() -> float:
	return max_volume

func SetVolume(new_volume: float) -> void:
	# If the new_volume is less than or equal to max_volume, update the volume variable
	# Otherwise, set it to the max_volume for now
	if new_volume >= 0:
		if new_volume <= max_volume:
			volume = new_volume
		else:
			volume = max_volume

func SetMaxVolume(new_max_volume: float) -> void:
	if new_max_volume >= 0:
		max_volume = new_max_volume

func AddSubstance(substance_volume: float) -> bool:
	if (volume + substance_volume) > max_volume:
		return false
	volume += substance_volume
	return true
	
func DumpContents() -> void:
	volume = 0
