## Lab Boundaries

`LabBoundary` is a node that extends an `Area2D` that is necessary to define the bounds of every LabObject within a module scene. It acts as a convenience instead of overriding physics to prevent LabObjects from getting stuck or colliding with objects or areas it should not.

### Properties

- `CollisionShape2D`, which is defined as a `RectangleShape2D`, determines the min and max bounds for a LabObject's position within a module.
- `xBounds` is a Vector2 that is defined as the `CollisionShape2D`'s position ± the extents of the `CollisionShape` in the X dimension
- `yBounds` is a Vector2 that is defined as the `CollisionShape2D`'s position ± the extents of the `CollisionShape` in the Y dimension