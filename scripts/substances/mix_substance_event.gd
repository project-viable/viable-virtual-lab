class_name MixSubstanceEvent
extends Substance.Event
## Event to update whether a substance is being mixed.


## The new mix state of this substance.
var is_mixing: bool = false


func _init(p_is_mixing: bool) -> void: is_mixing = p_is_mixing
