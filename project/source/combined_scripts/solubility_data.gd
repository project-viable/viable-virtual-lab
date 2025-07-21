class_name SolubilityData
extends Resource


## Speed that a substance will dissolve into another substance assuming conditions are met.
@export var base_solubility: float = 0.0

## If the container's temperature is below this, then it won't dissolve.
@export var min_temp: float = -300.0
