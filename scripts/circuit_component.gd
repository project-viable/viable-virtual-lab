class_name CircuitComponent
extends Node
## Acts as a component in an electrical circuit, which has a positive and negative end.
##
## For the time being, a circuit only counts as a circuit if it consists of exactly two components
## connected together at both terminals. Circuits of three or more components don't work.


## Emitted the connected component ([param component]) is fully disconnected from this component.
## This is not emitted when the connected component changes the value of [member closed].
signal disconnected(component: CircuitComponent)
## Emitted when this circuit component is connected to [param component].
signal connected(component: CircuitComponent)


## A side of a component that can be connected to.
enum TerminalSide
{
	POSITIVE = 0,
	NEGATIVE = 1,
}


## If set to [code]false[/code], then this component cannot form a full circuit.
@export var closed: bool = true

## The resistance of this component. This is used to calculate the displayed current on a power
## supply, and is not set by the power supply.
@export_custom(PROPERTY_HINT_NONE, "suffix:Ω") var resistance: float = 1

## Voltage running through this component. This is typically set by a power supply on the other end.
@export_custom(PROPERTY_HINT_NONE, "suffix:V") var voltage: float = 0


# Indexed by `TerminalSide`.
var _connections: Array[Connection] = [Connection.new(), Connection.new()]


## Get the [CircuitComponent] on the other end of this, as long as both terminals of this component
## are connected to the same component. If no component is fully connected, return [code]null[/code]
## To determine whether the connection is backwards or forwards, use
## [method get_connected_component_direction].
func get_connected_component() -> CircuitComponent:
	if _connections[0].component != _connections[1].component:
		return null
	else:
		return _connections[0].component

## Get the direction of the connection to the component on the other end. If no component is
## connected, return [code]0.0[/code]. If the connection is forward (i.e., the negative terminal of
## this component is connected to the negative terminal of the other end and the positive terminal
## of this component is connected to the positive terminal of the other end), then return
## [code]1.0[/code]. If the terminal connections are reversed, then return [code]-1.0[/code].
func get_connected_component_direction() -> float:
	if not get_connected_component(): return 0.0
	elif _connections[0].side == TerminalSide.POSITIVE: return 1.0
	else: return -1.0

## Connect the terminal [param our_side] on this component to the terminal [param their_side] on
## [param component]. If [param component] is [code]null[/code], then the terminal will be
## disconnected. One terminal on one circuit component can only be connected to at most one other
## terminal on another circuit component. This function will ensure that all connections are
## consistent and 1:1. [signal connection_changed] will be emitted for all involved circuit
## components, even if the connections didn't actually change.
func connect_to(component: CircuitComponent, our_side: TerminalSide, their_side: TerminalSide) -> void:
	# Keep track of circuit components that might have had their full connections (i.e., those
	# obtained via `get_connected_component`) changed. We only want to emit the signals for these
	# once, so we use a dictionary to ensure uniqueness.
	var components_to_old_connected: Dictionary[CircuitComponent, CircuitComponent] = {}
	components_to_old_connected[self] = get_connected_component()

	var our_connection := _connections[our_side]
	# If we were already connected to something else on that terminal, disconnect it.
	if our_connection.component:
		components_to_old_connected[our_connection.component] = our_connection.component.get_connected_component()
		our_connection.component._connections[our_connection.side].component = null
	our_connection.component = component
	our_connection.side = their_side

	if component:
		components_to_old_connected[component] = component.get_connected_component()
		var their_connection := component._connections[their_side]
		# Disconnect whatever might have been connected to the other component at its terminal.
		if their_connection.component:
			components_to_old_connected[their_connection.component] = their_connection.component.get_connected_component()
			their_connection.component._connections[their_connection.side].component = null
		their_connection.component = self
		their_connection.side = our_side

	for c: CircuitComponent in components_to_old_connected.keys():
		var old_connected := components_to_old_connected[c]
		var new_connected := c.get_connected_component()
		if old_connected != new_connected:
			if old_connected: c.disconnected.emit(old_connected)
			if new_connected: c.connected.emit(new_connected)


class Connection extends Resource:
	## Will be [code]null[/code] if there is no connection.
	var component: CircuitComponent
	## The side of the terminal on the connected component.
	var side: TerminalSide
