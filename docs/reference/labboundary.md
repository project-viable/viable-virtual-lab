## Lab Boundaries

`LabBoundary` is a node that extends an `Area2D` that is necessary to define the bounds of every LabObject within a module scene. It acts as a convenience instead of overriding physics to prevent LabObjects from getting stuck or colliding with objects or areas it should not.

It requires a `CollisionShape2D` child to work. Ensure that the `disabled` option is checked, since it does not need to detect collisions. We are just using it to define the bounds `LabObjects` should be able to be in.

Refer to Scenes/Modules/GelElectrophoresis as an example of this implementation.

### Properties

- `CollisionShape2D`, which is defined as a `RectangleShape2D`, determines the min and max bounds for a LabObject's position within a module.
- `xBounds` is a Vector2 that is defined as the `CollisionShape2D`'s position ± the extents of the `CollisionShape` in the X dimension
- `yBounds` is a Vector2 that is defined as the `CollisionShape2D`'s position ± the extents of the `CollisionShape` in the Y dimension