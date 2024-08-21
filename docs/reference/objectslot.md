# Object Slot
`ObjectSlot` is a node that extends `LabObject` that acts as a socket for another node such as a `LabObject` or `LabContainer`. It allows a user to place an object within another. 

For examples, refer to `ElectrolysisSetup` or `GelImager`.

## Properties
- `allowed_groups`, which is an exported variable, is an array of groups the `ObjectSlot` can hold. The default allowed are `Container` and `Liquid Container`.
- `held_object` stores the object is is holding. The default value is `null`. When an object is added successfully, it is set to that object. Once removed, it is restored to `null`.

## Functions
- `TryInteract()`: extended from `LabObject`, this overridden function modifies the object if it's allowed to be inserted into the slot before updating the parent of the object to be the `ObjectSlot`. It sets the object's active state to false, so that it cannot have unexpected behavior while it is in the slot.
- `filled()`: returns whether or not the `ObjectSlot` is filled.
- `get_object()`: returns the `held_object`.
- `_on_GelBoatSlot_input_event(viewport, event, shape_idx)`: removes the object from the `ObjectSlot`, sets the `active` state to true, restores its original parent, and sets `held_object` to null. It is called when it is clicked on by the user.

## Dependencies
The `ObjectSlot` has a couple dependencies: `slot_filled()` and `slot_emptied()`.

The parent node of the `ObjectSlot` needs to implement these functions. This behavior is specific to the parent node.

For examples, see `ElectrolysisSetup.gd` and `GelImager.gd`.

Like other `LabObject`s, it requires to have a `CollisionShape2D`. To fulfill this dependency, just add the node as a child of `ObjectSlot` with the size and shape the parent node requires. 