extends Node
## Singleton that provides access to stuff connected to "lab time". Lab time affects the speed of
## the simulation, but it does *not* affect the speed of physics or animations, since speeding up
## physics or animations would be annoying.


## Multiplier on the rate that time passes in the simulation.
var time_scale: float
