## Contains information about the conditions inside a container (like temperature) and is passed to
## substances when doing context-dependent actions like mixing.
class_name SubstanceEnvironment
extends Resource

## Temperature in °C. For simplicity, it is assumed that an entire container is always in thermal
## equilibrium.
@export var temperature: float = 20.0

## The amount of "mixiness" of the stuff in the container. This approximately corresponds with mass
## diffusivity, but is not given in any particular units. Substances can use this to determine how
## quickly to mix or perform reactions. Like temperature, this is *also* considered to be
## homogeneous throughout the container.
@export var mix_amount: float = 0.0
