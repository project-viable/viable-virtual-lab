tool
extends Node2D
class_name VolumeContainer

# Each volume container has a volume and maxVolume
# volume denotes how much liquid substance it holds
# maxVolume is the container's volumetric capacity
var volume
var maxVolume

# Add this to the group VolumeContainers
func _ready():
	add_to_group("VolumeContainers", true)

# Getters and setters for volume and maxVolume
func GetVolume():
	return volume

func GetMaxVolume():
	return maxVolume

func SetVolume(newVolume):
	# If the newVolume is less than or equal to maxVolume, update the volume variable
	# Otherwise, set it to the maxVolume for now
	if newVolume >= 0:
		if newVolume <= maxVolume:
			volume = newVolume
		else:
			volume = maxVolume

func SetMaxVolume(newMaxVolume):
	if newMaxVolume >= 0:
		maxVolume = newMaxVolume

func AddSubstance(substanceVolume):
	if (volume + substanceVolume) > maxVolume:
		return false
	volume += substanceVolume
	return true
	
func DumpContents():
	volume = 0
