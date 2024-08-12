## SubsceneManagers ([see examples](../examples/examples-subscenes.md))

`SubsceneManager` is a subclass of LabObject that handles a subscene (a popup that contains other LabObjects, like a zoomed in view, or maybe a fancy menu). Any time you need to create a subscene, you should make a new `SubsceneManager`. You can also `extend` it, but you often won't have to.

![CapstoneSubsceneExample-ezgif com-crop](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/1291a389-f63c-43bb-9573-9291757cbe00)

**Inherits:** LabObject

LabObjects in a subscene can only interact with others in their same subscene, and if the player clicks inside of a subscene, only objects within that subscene can recieve that click.

While a Subscene is open:
- The SubsceneManager object will not recieve mouse clicks.
- `draggable` LabObjects can be dragged in and out of the subscene. When this happens, their parent is changed.

### Properties

- `dimensions` tells a `SubsceneManager` how large its popup should be, in pixels.
- `subscene` is a reference to this SubsceneManager's `$Subscene` node. This is mainly used internally, but you must use it if you want to access to the subscene while it is hidden. See Using SubsceneManagers below for why you can't use `get_node()` (`$`).

Note: when you change `dimensions` in the editor, it will update all the appropriate child nodes' values for you. This happens because it is a [tool script](https://docs.godotengine.org/en/3.5/tutorials/plugins/running_code_in_the_editor.html).

All `SubsceneManager`s are part of the `SubsceneManagers` group. They take care of that on their own. You should add them to other groups depending on what they are capable of, so that other objects know how to interact with them. See Example 1 below for a basic example.

### Functions

- `ShowSubscene()`: Shows the subscene belonging to this object. By default, SubsceneManager overrides `TryActIndependently()`, so this happens when the object is clicked. If you don't want that to happen, override `TryActIndependently()` and then call this function yourself somewhere.
- `HideSubscene()`: Hides the subscene belonging to this object. This is called when the close button is pressed (see below), but you can also call it yourself if you need to. Note: Internally, this function *removes the entire subscene from the scene tree while it is hidden*. While it's in that state, its data still exists (we don't call `queue_free()` or anything), but it doesn't simulate at all, so it's effectively paused. This affects a lot of things - see Using SubsceneManagers below.

### Child Nodes

If you open `res://Scenes/Objects/SubsceneManager.tscn`, you'll see that SubsceneManager needs several child nodes in order to function. When you create a new SubsceneManager for your custom objects, those nodes need to exist, but you do not have to manually create them all. See below for how to create an inherited scene.

![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/5c2cef69-5fb4-4eb7-8fa2-f66011328653)

- `Subscene` is an [Area2D](https://docs.godotengine.org/en/3.5/classes/class_area2d.html) that contains the entire subscene. When you create a new subscene, add all the LabObjects in it as children of this node. When the game is started, it is removed from the tree (see `HideSubscene()` above), and readded as needed.
- `Border` is a UI node that has children for the background and close button. These UI nodes have their mouse filter set to Ignore so that they don't stop mouse clicks from being recieved by the LabObjects in the subscene.

### Using SubsceneManagers

Some general notes:
- SubsceneManager inherits LabObject, it just adds some extra functionality. Unlike LabObject, you don't *have* to extend the SubsceneManager script to make an object that does something useful. In fact, a lot of the time you probably shouldn't (see Example 4 below, and Creating A New Type of SubsceneManager).
- You can add special UI to your subscenes (similar to the close button) if you want - add your UI nodes as children of the `Border` or `Background` nodes, and you can use Godot's Layout presents (in the upper toolbar in the scene editor) to have them scale themselves and such.
- SubsceneManagers always want to position their subscene so that the entire thing is within the area that the camera can reach (currently, the camera will only move left and right, not up and down, because it'll be easier to eventually make the scene look good that way). They will adjust its position relative to themselves on the y axis only.
- Internally, SubsceneManager *removes the `Subscene` node from the tree entirely while it is hidden*, and *re adds it to the scene when it is shown*. This means:
  - While the Subscene is hidden, nodes in it will not update - `_process()` functions will not be called, they will not be part of the physics sim, etc. It's as if they don't exist (though, obviously, the data for them is preserved and they will be returned exactly as they were before).
  - Since the `$Subscene`node and its children may not exist at any given time, you cannot necessarily access them using `get_node()` (shorthand `$`) as normal. If you need to directly get a node that might be in a subscene from a script, use the `subscene` property.
    - **NOTE:** It's possible to override a node's `get_node()` function, (and doing so also affects the usage of the shorthand `$`). It should be possible, if necessary, to override it such that `get_node()` can also get nodes that are `subscene` and its children. The reason this is not currently done is that that's a really funky thing to do, because we'd be making our `get_node()` function behave differently than how it's defined by Godot, which might cause weird, difficult to diagnose errors later on. Also, I'm worried that it may affect some internal usage of `get_node()` of Godot's. A useful middle ground might be to add a `GetNodeInSubscene()` function to SubsceneManager. We can explore these things if accessing nodes in the subscene becomes a problem. For now, if your special subscene object needs to talk to an individual object within the subscene, call `get_node()` on *`subscene`* (see Properties), instead of the manager object.
  - The subscene can be removed from and added back into the tree multiple times, so any objects in the subscene may need to be able to tolerate their `_ready()` and `_enter_tree()` functions being called multiple times.

### Creating a new type of SubsceneManager

Since SubsceneManager depends on its predefined, special child nodes (see above), the process for creating a new one is a bit more complicated than a normal LabObject. To do this, find the SubsceneManager base scene (`res://Scenes/Objects/SubsceneManager.tscn`) in the file system tab, right click it, and select ![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/9b2347a9-7fd6-43ec-8281-3187f13bd8ff).

Now, you should have a new scene something like this:

![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/e1b90f5e-17b6-4a4d-bc0d-51086a0ed813)

The grayed out nodes are nodes inherited from the SubsceneManager scene. If a change is made to the base scene in the future, these nodes will reflect that change. In order to give your object special functionality (remember, it's still a LabObject, so you can `TryInteract()` or `TryActIndependently()` if you'd like), you'll need to remove the SubsceneManager script from the root of your new scene, and add a new one that extends it.

Like any other LabObject, you also need to add some other children. You need something visible on the screen, and a collider to tell the object where it can be clicked (see how to create a new LabObject for examples). For your subscene, you need to add any objects that exist in the subscene as children of the `Subscene` node. If you'd like an example of this, you can look at Example 4 below.

You should also read the Using SubsceneManagers section above. The way that they work internally has some implications for how you need to use them.