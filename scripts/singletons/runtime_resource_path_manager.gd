extends Node


var _next_path_num := 0



## Set the [member Resource.resource_path] of [param resource] to a unique name. This is not
## actually saved to disk, but the resource can be loaded through that path.
func register(resource: Resource) -> void:
	resource.take_over_path("res://_gen/%s" % [_next_path_num])
	_next_path_num += 1
