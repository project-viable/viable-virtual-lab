# Groups Home

## Introduction

The simulation has many objects that can all interact with each other in many ways. In order for an Object A to decide whether it should interact with Object B, it needs to know some information about what it is capable of. For example, a Pipette needs to check whether another can have liquids dispensed into it.

The obvious solution here is to have a class for each thing (like "Container" or "Heatable"), which provides some set of functions, and have the acting object check if the other object `is` that class. The problem with this is that **GDScript does not support multiple inheritance**, so we fake it using Godot's Object Groups.

Each of the groups we've defined (see below) is essentially an Interface. They allow us to ensure `LabObject`s and `Substance`s implement certain functions or have certain properties necessary for checking.

To continue with the example above:
- A Pipette has been dragged onto another object, and has the option to interact with it.
- The Pipette wants to dispense some liquid into the other object, if it can.
- The Pipette uses [is_in_group()](https://docs.godotengine.org/en/3.5/classes/class_node.html#class-node-method-is-in-group) to see if the other object is in the `Container` group.
- If the other object is in the group `Container`, the Pipette knows that it can accept liquids, and that it has an `AddContents()` function.
-Knowing this, the Pipette can safely call that function to actually do the interaction.

See the pages below for a list of groups that exist, and ***please add any new groups you create to these pages***.

## Reference
1. [Lab Objects](/docs/reference/groups/labobject.md)
2. [Substances](./substance.md)