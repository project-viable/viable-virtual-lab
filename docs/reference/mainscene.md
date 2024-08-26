## Main Scene

The Main scene is kind of like the `main()` function in a language like C++. It is the scene that is loaded when the game starts, and it loads all the other scenes (like your Modules) beneath it.

There are 2 common ways of structuring a game at a high level in Godot:

One (which we do not use) is to use Godot's built in functions to fully change scenes. If you use the `SceneTree.change_scene()` function, the scene you're currently in is removed, and the scene you change to becomes the only scene that exists. The reason that we do not use this method is that *nothing* from the previous scene's tree sticks around, *including the UI, etc*. Our game is dependent on the Main scene to handle input (see below), and we want the UI to be easily accessible at any time, so we don't want that to happen.

The alternative (what we do) is to have a Main scene that just contains the things that the game needs to run - the Main script that handles input events (see below), the Camera, etc, and when we want to load a new scene, add it as a child of the Main scene. For our particular project, this makes the structure of the game a little simpler. It does have one small downside, which is that, without the Main scene, any other scenes you might make (like a module or an individual LabObject's scene) *will not be able to function alone*, so you have to run the entire game every time you want to test something, as opposed to using Godot's "Play Scene" button. We think this tradeoff is worth it, because it's very easy to create a simple little test module to put any objects you're working on in.

![image](./images/mainscene/Main%20scene.png)

The above is the structure of the main scene. It contains the following higher-level nodes:
- `Menu`
  - The main UI the user interacts with to perform actions like updating options and changing modules. It has its own script that controls it.
- `Scene`
  - The current scene the user is on. As of now, since there is just one module, it just sets itself to the GelElectrophoresis module scene. In the future, when this needs to be changed as another module is added, refer to the `_ready()` function within the `Scripts/UI/Menu.gd` script.
- `Mixtures`
  - This tracks all known mixtures relevant to the lab. It is meant to check for mistakes when a user makes a mixture.

### Input Handling

For subscenes, we have to manually handle input events in a different order than Godot does by default. Relying on the normal object picking does not give us the control we need.

The problem is that, when the user clicks the mouse, we need to figure out which LabObject (if any) they might be clicking on. But, LabObjects can overlap, and when they do, Godot would, by default, pick the wrong one. When we have Subscenes, possibly nested, and objects within those subscenes, we should always pick the one *deepest* in the scene tree, because it is in the deepest nested subscene. This is the opposite of what Godot would do by default - unhandled input is given to the root node first, so LabObjects can not be responsible for deciding whether they have been clicked.

Given that, the Main scene watches for, and delegates responses to mouse input to the appropriate LabObject (see "Current Click Behavior" below). If this is broken or needs to be modified,  look at the `_unhandled_input` function, consult the Godot documentation guides on how input is dealt with, and please please *please* test your changes thouroughly before merging them.

*NOTE:* Why not use sub viewports to impliment subscenes, you may ask? Godot still gives the unhandled input events to the root viewport first, so the main scene would need to decide whether the click should be handled by it, or a child, and every child viewport would need to be doing the same work to decide whether that input is its problem. This would be even more complicated than the current solution. It is a somewhat gross, unstatisfying solution, but I (Jonas Courtney) was not able to come up with anything better, at least not in Godot 3.5.

If you've got better ideas for how to do this, feel free to try them out! Just make very sure they're going to work before merging them.

#### Current Click Behavior

To find the best pick, it iterates over the options. Draggables are preferrable to non-draggables and high z indices are tie breakers.

If a best pick is found, and if it's draggable, it will start dragging. Otherwise, it calls `OnUserAction()` for that object.

### Utility Functions

Within the Main scene, there are two utility functions to be aware of: `SetScene()` and `GetDeepestSubsceneAt()`. You probably do not actually need to use use or modify them, but you can. Just make sure you're not overcomplicating things. For most objects, the base class will take of everything related to this for you.

- `SetScene(scene: PackedScene)`: This first clears the currently loaded scene within `$Scene`. Then, it instantiates the scene from the parameter. It then adds the scene as a child of `$Scene`, and set the `currentModuleScene` to this scene.
- `GetDeepestSubsceneAt(pos: Vector2)`: This finds the deepest `Subscene` at position `pos`. This is primarily used for dealing with `LabObjects` and determining its behavior if its within a subscene.
