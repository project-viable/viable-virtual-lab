## Dimension Sprites

Godot's `Sprite` nodes don't let you specify exact dimensions, although you can scale them. At times this can make it hard to get things precisely the size you want without spending a lot of effort or doing the scale factor math yourself.

We've made a `DimensionSprite` class that hopefully makes this a little easier, if you want it. It functions exactly the same as a normal `Sprite`, but it lets you set the dimensions directly in the editor. You could also theoretically use its functionality at run time if you really wanted to.

**NOTE:** You never have to use DimensionSprites. They're there if you want them, but it's purely for convenience. They function in the game identically to a standard `Sprite` node.

**Inherits:** [Sprite](https://docs.godotengine.org/en/4.3/classes/class_sprite.html)

### Properties
- `override_dimensions`: boolean, toggles whether the script will automatically set the scale.
- `sprite_dimensions`: the dimensions, in pixels, that the sprite should have. Only works if `override_dimensions` is true.

### Functions
- `set_dimensions(new_dimensions: Vector2)`: sets the dimensions, only if `override_dimensions` is true. This is [called automatically](https://docs.godotengine.org/en/4.3/tutorials/plugins/running_code_in_the_editor.html#editing-variables) when you change the `sprite_dimensions` property in the editor. Works by changing the `scale` for you.
