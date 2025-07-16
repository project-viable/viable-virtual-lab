# TODO: rename this to just `Substance` when the other `Substance` class is removed.
class_name SubstanceInstance
extends Resource


enum State
{
	SOLID,
	LIQUID,
}


## (virtual) Make a deep copy of this substance. This needs to be here because `Resource::duplicate`
## doesn't behave super nicely with arrays and stuff.
func clone() -> SubstanceInstance: return duplicate(true)

## (virtual) Get the density, in grams per milliliter.
func get_density() -> float: return 1.0

## (virtual) Get the volume, in millileters.
func get_volume() -> float: return 0.0

## (virtual) Get the color to be displayed.
func get_color() -> Color: return Color.WHITE

## (virtual) Attempt to incorporate the substance `s`; return true if it was incorporated. If a
## substance `s` is added to a container, the container will first try to incorporate it into all
## existing substances in the container with `e.try_incorporate(s)`, where `e` is the existing
## substance in the container.
##
## This should only be used for cases where incorporating `s` involves *no mixing at all*; e.g., if
## `s` is the exact same substance type as this, then it should be immediately incorporated to avoid
## cluttering the container with many instances of the same substance. Note that unlike mixing,
## `try_incorporate` should never partially incorporate the new substance.
##
## `s` will always be a copy, and will be discarded if this function returns true, so it's okay to
## store the reference `s`.
func try_incorporate(_s: SubstanceInstance) -> bool: return false

## (virtual) Attempt to mix `s` into this substance by `mix_amount`. `mix_amount` does not
## correspond with any physical unit, but the amount of substance mixed in should, generally
## speaking, scale linearly with `mix_amount` multiplied by some other constants (like the
## solubility of `s` if this is a solution).
##
## In this case, `s` should be assumed *not* to be a copy, and its state after calling this function
## should reflect any substance taken, which will usually not be all of `s`.
func mix_from(_s: SubstanceInstance) -> void: pass

## (virtual) Take *up to* `v` milliliters of this substance and return a new `SubstanceInstance`
## from what was taken. If `v` is greater than the current volume, then the full volume will be
## taken.
func take_volume(_v: float) -> SubstanceInstance: return SubstanceInstance.new()
