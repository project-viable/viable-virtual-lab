### 1 - Basic Subscene

See Scenes/Objects/SubsceneManager.tscn.

This object is the base class for the SubsceneManager. It implements the basic functionality required for a Subscene.

#### Member Functions
The following defines the base behavior for `SubsceneManagers`. However, nodes that extend this class can override them if necessary.
- `_ready()`: Called when the object is initialized. Calls its parent `_ready()` function. It then sets the subscene variable to be the child `$Subscene`, adds itself to the `SubsceneManagers` group, sets the `z_index` to make the subscene draw in front of the one above it in the tree.
- `CountSubsceneDepth()`: Returns the depth of the subscene. It is used by main when picking which object should receive a user input action (e.g. mouse click).
- `set_dimensions(new_dim: Vector2)`: Updates the dimensions of the subscene to the dimensions defined by a `Vector2`.
- `try_interact_independently()`: By default, if `subscene_active` is false, it calls `show_subscene()`.
- `show_subscene()`: Shows the subscene.
- `hide_subscene()`: Hides the subscene.
- `adopt_node()`: Remove node from parent's children and adds as child of subscene.
- `adjust_subscene_to_visible_height()`: Adjusts the subscene window height to fit objects within it. 

### 2 - Complex, Real World Subscene

See Scenes/Objects/GelMoldSubsceneManager.tscn.

This is the Gel Mold in the Gel Electrophoresis module.
