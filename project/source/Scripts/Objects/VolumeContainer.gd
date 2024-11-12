@tool
extends Node2D
class_name VolumeContainer

# Each volume container has a volume and maxVolume
# volume denotes how much liquid substance it holds
# maxVolume is the container's volumetric capacity
var volume: float
var maxVolume: float

# Add this to the group VolumeContainers
func _ready() -> void:
	add_to_group("VolumeContainers", true)

# Getters and setters for volume and maxVolume
func GetVolume() -> float:
	return volume

func GetMaxVolume() -> float:
	return maxVolume

func SetVolume(newVolume: float) -> void:
	# If the newVolume is less than or equal to maxVolume, update the volume variable
	# Otherwise, set it to the maxVolume for now
	if newVolume >= 0:
		if newVolume <= maxVolume:
			volume = newVolume
		else:
			volume = maxVolume

func SetMaxVolume(newMaxVolume: float) -> void:
	if newMaxVolume >= 0:
		maxVolume = newMaxVolume

func AddSubstance(substanceVolume: float) -> bool:
	if (volume + substanceVolume) > maxVolume:
		return false
	volume += substanceVolume
	return true
	
func DumpContents() -> void:
	volume = 0
