extends Node
## Manages the z-indices of objects (especially those that can move around).
##
## If an object (especially a [LabBody]) wants to manage its depth relative to other objects, then
## it should handle that using this singleton.
##
## The z-indices managed by the depth manager are divided into several [enum Layer]s, each of which
## has a range of z-indices that can be assigned (see [enum Layer] documentation for the exact
## ranges). Managed objects are always given a z-index that is a multiple of 10, and their children
## can use any z-indices in the range [-4, 5] relative to that. Negative z-indices are not managed
## by the depth manager, so they can safely be used for backgrounds.
##
## Whenever any object is added to a layer, changes layers, or changes position in a layer (through
## functions like [method move_to_front_of_layer]), all other objects in that layer will be
## automatically re-assigned their z-index to retain their relative order.


enum Layer
{
	STORAGE_BACK, ## The back side of things like cabinets and microwaves. Layer 0 only.
	STORAGE, ## The inside of things like cabinets and microwaves. Layers 10–1990.
	STORAGE_FRONT, ## The front of things like cabinets and microwaves (i.e., the door). Layer 2000 only.
	BENCH, ## Objects sitting out on the bench. Layers 1020–3990.
	HELD, ## The object currently being held, which is in front of everything else. Layer 4000 only.
}


var _layer_arranger_map: Dictionary[Layer, ZIndexArranger] = {
	Layer.STORAGE_BACK: ZIndexArranger.new(10, 10),
	Layer.STORAGE: ZIndexArranger.new(20, 1990),
	Layer.STORAGE_FRONT: ZIndexArranger.new(2000, 2000),
	Layer.BENCH: ZIndexArranger.new(2010, 3990),
	Layer.HELD: ZIndexArranger.new(4000, 4000)
}

var _object_arranger_map: Dictionary[CanvasItem, ZIndexArranger] = {}


## Moves [param object] to the front of the given layer. [param object] will now be managed by this
## depth manager, and will have its z-index automatically set when any other object is placed in
## front of it.
func move_to_front_of_layer(object: CanvasItem, layer: Layer) -> void:
	var prev_arranger: ZIndexArranger = _object_arranger_map.get(object)
	var new_arranger: ZIndexArranger = _layer_arranger_map.get(layer)

	if not new_arranger: return

	if prev_arranger and prev_arranger != new_arranger:
		prev_arranger.remove(object)

	new_arranger.put_in_front(object)
	_object_arranger_map[object] = new_arranger

## Stops [param object] from being managed by this depth manager. This might be used, for example,
## before setting an object's z-index to the same z-index as another object when they're
## interacting.
func stop_managing(object: CanvasItem) -> void:
	var arranger: ZIndexArranger = _object_arranger_map.get(object)
	if arranger:
		arranger.remove(object)
		_object_arranger_map.erase(object)

## Given the absolute z-index [param z_index] of an object, give the nearest "base" z-index (i.e.,
## multiple of 10). If this is the child of a managed object and is within the correct relative
## range of allowed z-indices, then this will be the z-index of that managed object.
func get_base_z_index(absolute_index: int) -> int:
	@warning_ignore("integer_division")
	return (absolute_index + 4) / 10 * 10


class ZIndexArranger:
	var min_index: int = 0
	var max_index: int = 0

	var _objects: Array[CanvasItem] = []

	func _init(p_min_index: int, p_max_index: int) -> void:
		min_index = p_min_index
		max_index = p_max_index

	func put_in_front(object: CanvasItem) -> void:
		object.z_as_relative = false

		_objects.erase(object)
		_objects.push_back(object)

		@warning_ignore("integer_division")
		var num_slots: int = (max_index - min_index) / 10 + 1
		if len(_objects) > num_slots:
			push_warning("While assigning layer to %s, number of z-index layers exceeded" % [object])

		_update_indices()

	func remove(object: CanvasItem) -> void:
		_objects.erase(object)
		_update_indices()

	func _update_indices() -> void:
		var cur_index := min_index
		for o in _objects:
			o.z_index = cur_index
			cur_index += 10
