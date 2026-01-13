@abstract class_name Substance
extends Resource


## (virtual) Make a deep copy of this substance. This needs to be here because `Resource::duplicate`
## doesn't behave super nicely with arrays and stuff.
func clone() -> Substance: return duplicate(true)

## (virtual) Get the density, in grams per milliliter.
func get_density() -> float: return 1.0

## (virtual) Get the volume, in millileters.
func get_volume() -> float: return 0.0

## (virtual) Get the color to be displayed.
func get_color() -> Color: return Color.WHITE

## (virtual) Get the "viscosity" of this substance. This should be a value between 0 and 1,
## inclusive. If the viscosity is 0, the substance will very quickly flow with gravity when
## displayed by a [SubstanceDisplayPolygon] and it will be poured very quickly. If the viscosity is
## 1, the substance cannot be poured and will not move when a container is rotated.
func get_viscosity() -> float: return 0.0

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
func try_incorporate(_s: Substance) -> bool: return false

## (virtual) Do a single tick worth of processing. `container` is the container node that this
## substance is in. `delta` is the length of the tick in seconds, measured in lab time.
##
## It is okay to modify `container.substances` in this function. Note that `container.substances`
## will contain this substance, so it's a good idea when doing any reactions to ensure that the
## other reagent is not this one.
##
## This function should be used for any mixing or reactions.
func process(_container: ContainerComponent, _delta: float) -> void: pass

## (virtual) Send an event that this substance can react to. This is used for things like mixing,
## microwaving, and applying voltage.
func handle_event(_event: Event) -> void: pass

## (virtual) Take *up to* `v` milliliters of this substance and return a new `Substance`
## from what was taken. If `v` is greater than the current volume, then the full volume will be
## taken.
@abstract func take_volume(_v: float) -> Substance


## Generic event that a [Substance] can handle by overriding [method Substance.handle_event].
@abstract
class Event: pass
