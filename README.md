# VIABLE Virtual Lab

To try out our current demo, click [here](https://project-viable.github.io/viable-virtual-lab/export/VirtualLabExport.html). You can also follow the Setup instructions below to try it out locally.

This is very much an early demo, and it is actively being improved.

# Getting Started

This project is made using Godot 3.5 (the LTS version). You don't need to download that yourself because we include its exectuable here, to make sure everyone is using the right version and everything.

This Documentation assumes some basic familiarity with Godot. It has links to the Godot docs for things you might not have been exposed to before, but if you've never used it before you'll probably want to follow at least one basic tutorial.

Here's a link to the Godot 3.5 documentation (and if you google something related to Godot, *make sure you're on the documentation for **this version***):<br>
https://docs.godotengine.org/en/3.5/

## Setup

To start, you need to clone or download the repo from GitHub.

To try the game once you've got the project files, you'll need to go to Project/Tools and run the Godot Engine executable there. Once that pops up you'll have to import the project itself, which is in Project/Source. You should only need to import it once on the computer you're using. Once you've imported it, you can open the project. From there, you can run the game by hitting the play button in the upper right.
![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/47f6327b-9051-4bbf-96ea-3f7009dcd14e)

# Documentation

TODO: The rest of this README page is documentation that should be moved to the `docs` folder, and there should be a link to it here.

## Table of Contents
   [Administrative/Logistical Stuff](#non-code-documentation)
1. [Modules](#modules)
2. [LabObjects](#labobjects)
3. [SubsceneManagers](#subscenemanagers)
4. [Substances](#substances)
5. [Lab Logs](#lab-logs)
6. [Main Scene](#main-scene)
7. [DimensionSprites](#dimension-sprites)
8. [Examples](#examples)

## Modules

A Module is basically a Level. The game is able to load them automatically, and each one basically consists of a `ModuleData` resource, and a Scene that gets loaded when the module is selected.

### ModuleData Resource

Each ModuleData stores metadata about a module. They're [resources](https://docs.godotengine.org/en/3.5/classes/class_resource.html), and the game automatically loads them if you save them in the proper place (see Making a new Module below). Right now, the ModuleData script has no functionality of its own, so they basically function like a struct.

ModuleData has the following properties:
- `Show`: should be used to control whether the module is visible in the module selection screen. This way you could have testing module files in the game, but make them invisible for some kind of actual release.
- `Name`: the title of the module
- `Tooltip`: the description text shown in the module select menu
- `Thumbnail`: the icon for the module
- `InstructionsBBCode`: a string (formatted with [bbcode](https://docs.godotengine.org/en/3.5/tutorials/ui/bbcode_in_richtextlabel.html)) for the instructions. This will be shown in the instructions tab after the scene is loaded.
- `Scene`: This is the most important property - it tells the game what scene to load when this module is selected.

### Making a new Module

In order to make a module, you need to do a couple things:
1. Make the scene that contains all of the LabObjects, backgrounds, etc, that make up your new module. Don't worry about adding the Menu or a Camera or anything, because that's handled for you by the [Main Scene](#main-scene). For an example, you can look at the Gel electrophoresis scene. The location of this .tscn file in the project folder doesn't technically matter.
2. Make a new ModuleData resource in the `"res://Modules"` folder. Simple Godot tutorials might not cover this - right click in the folder, hit "new resource", and find `ModuleData`. It needs to be in that folder so that the game can find it on its own.
3. Once you've made your new `ModuleData` resource, fill in its properties (listed above) - you can leave most of them blank if you need to, or use a placeholder. Just make sure you've set the `Scene` property to point to the scene you made in step 1 (you don't need to make a new packed scene or anything, hit "Load" and point it directly to the .tscn file).

Now, the game should see the ModuleData you made, and automatically populate the Module Select manu for you. When you click the button for your new module, it will load your new scene. For details on how that works, see [Main Scene](#main-scene).

## LabObjects

`LabObject` is the base class for any objects that need to interact with others or be moved around the scene. For example, pipettes, containers, and anything else that exists in the lab should inherit from `LabObject`.

**Inherited By:** SubsceneManager

### Properties

- `draggable` tells a `LabObject` whether it should be possible to drag it around the screen.
- `canChangeSubscenes` controls whether this object can be dragged from one subscene (see SubsceneManagers) to another. If false, this object will stop dragging when the mouse leaves the subscene that it is a child of (they will not act independently or interact when this happens, i.e. `OnUserAction()` is not called).
- `DisplayName` should contain the name of the object that should be shown to the user. If this is not empty, the base class will automatically create and manage a tooltip with this as its text.
- `mode` (listed under `RigidBody2D` in the editor) tells the object what kind of physics object it should act like. If you want the object to be affected by gravity, this should be `Rigid`. Non draggable `LabObject`s don't need to be `Static`, but probably should be.

If a `LabObject` is `draggable`, it will try to interact with any objects it's overlapping with when it is released. If it is not draggable, it will try to interact when it is clicked.

All `LabObject`s are part of the `LabObjects` group. They take care of that on their own. You should add them to other groups depending on what they are capable of, so that other objects know how to interact with them. See Example 1 below for a basic example.

### Functions

#### Simulation Functionality
- `TryInteract(others)`: `others` is a list of other `LabObject`s. This function checks if this object would like to interact with any of them, and if so, does that interaction. Returns whether it chose to interact (`true`/`false`). This is a virtual function, and it is called automatically by the child class (in `OnUserAction()`, see below). Override this function in your child classes if they need to interact with others. See Example 1 below for how you can do that.
- `TryActIndependently()`: This function checks if this object would like to do anything that does not require another object, and if so, does that thing. Returns whether it chose to do something (`true`/`false`). This is a virtual function, and it is called automatically by the child class (in `OnUserAction()`, see below). Override this function in your child classes if they need to, for example, open a menu when clicked. See Example 2 or Example 3 below for how you can do that.
- `OnUserAction()`: This function is called for you when the user releases a `draggable` LabObject, or when they click a non draggable one. It decides which of the above functions to call in what order, and it is NOT virtual. In the base class, it does this: ![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/30cb9ea9-5828-46f0-bbcf-03ba1ca9e13d) You can override this function in a child class if you have a reason for needing different behavior. **Note:** The base class keeps track of how far a LabObject has been dragged from where it started, and only calls TryActIndependently() if it has not been dragged very far. This way, objects generally won't try to do things without the user explicitly wanting them to do so by either clicking them, or dragging them onto another object.
- `dispose()`: Called when the LabObject is disposed of, for example by putting it in a trashcan. This exists (and you can override it) because some objects need to decide what to do in that situation based on things that only they know. For example, when put over a trashcan, a pipette might want to throw its tip away, instead of itself.

#### Convenience Functions
These functions do the same things as the corresponding Godot functions. The base LabObject class uses some of these functions, and it needs them to work, and we've had issues with people forgetting to call `super()` (that's not the syntax in Godot, but you know what I mean).

*Please* use these instead of the built in functions like `_ready()` and `_process()`. If you're just doing a basic object, they'll work exactly the same, and it'll prevent mistakes and keep everything nicely organized.
- `LabObjectReady()`: called by the base class in Godot's built in `_ready()` function.
- `LabObjectProcess(delta)`: called by the base class in Godot's built in `_process(delta)` function.
- `LabObjectPhysicsProcess(delta)`: called by the base class in Godot's built in `_physics_process(delta)` function.
- `LabObjectEnterTree()`: called by the base class in Godot's built in `_enter_tree()` function.
- `LabObjectExitTree()`: called by the base class in Godot's built in `_exit_tree()` function.

### Creating a new type of LabObject

You need to create a new Scene, whose type is Godot's RigidBody2D class (or something that extends it), and give it a new script for your child class.

When you create a new script, tell it to inherit from LabObject.
![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/95bddad7-39d7-4213-a819-c23bc622adf6)

Your object is going to need some child nodes in order to do anything:

- Something visible on the screen (like a `Sprite2D`)
- A collision (like a `CollisionShape2D`).

![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/f572f008-abc1-4d43-8ef2-ecaa9f698e8a)

You can add multiple of each if you'd like. The collision is necessary so that the game knows when your object has been clicked, when other objects are touching it, etc. In the editor, you'll need to edit the `shape` property of your collision. You probably want to make it cover the entire area that the visible area does, something like this:

![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/ed83b2ba-db12-4ffd-95b0-8dd0f691db73)


If your object needs to initiate any kind of interaction (so, if it needs to do something when clicked or when dragged onto another object), it should override `TryInteract(others)`. The base class calls that function for you. `others` is a list of all the other objects that your object has the option to interact with. It does not need to interact with any of them (for example, a pipette shouldn't interact with another pipette if it's the only option). It should probably only ever interact with one other object at once, and then stop. For how this can go you can look at Example 1 below, and the LabObjects section above.

***Note:*** The base LabObject class uses Godot's `_ready()` and `_process()` functions to do its job, so if you override those, its functionality will break. To prevent this, use the corresponding Convenience Functions listed above. In most cases, they'll work exactly the same.

If for some reason you do need to give your custom LabObject a `_ready()` or `_process(delta)` function, make sure to call the base class function so it continues to work. In Godot 3.5, you do that like this:

![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/a1d9942b-00b7-461b-81b6-87efb72497b4)

## SubsceneManagers

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

## Substances

### 1 - Purpose and Node Groups

Substances are meant to represent the various chemical and/or biological substances the modules may need to deal with, and are structured such that their interactions are similar to that of LabObjects. They can be interacted with using the same node group system, and are intended to handle reacting to those interactions in an encapsulated manner, including all of the information needed to inform those interactions.

A substance is represented as a standard Node2D with a set of node groups based on what phenomena it interacts with and a script dictating how it reacts to those phenomena, including when it is created by a Source Container and as a result of mixing other substances together. Substances have a color, volume and density by default, with color influencing the color of associated UI elements or containers and volume being the default measure of quantity rather than mass, to keep consistency between solid and liquid substances. A substance's mass is determined by multiplying the volume and density variables together.

Membership of a node group is treated as similar to implementing an interface (I.E. a substance in the `Heatable` group must implement the `heat()` function), and a substance's groups can be added either via code or from the Godot editor under the Node > Groups section of the inspector window.

For use in duplicating or modifying a substance, the `get_properties()` function returns a `properties` dictionary containing key-value pairs for each of its instance variables, which can then be used to port a substance's internal data to another instance of that substance.

- **NOTE:** When creating a substance with a non-default density and color, you'll need to implement the `_init()` function that passes the custom values in dictionary format to the `init_created()` function in order to properly initialize them. (Refer to Scenes/Substances/GelModule/AgarPowderSubstance.gd for an example of this)

### 2 - Mixing substances

Mixing substances together requires both substances to be part of the `Mixable` group, in addition to the presence of a MixManager object in the module scene. The MixManager handles taking in a set of substances to mix, creating an instance of the resulting substance and offering the new substance a chance to set its properties according to the properties of the substances being mixed.

The MixManager exists as a central touchpoint for all reactions that happen in a given module, and should extend the base class to implement a custom version for each module, filling in pairs for which reactants produce which new substances (I.E. Substances [A, B, C] produce Substance D).

To mix two substances together, simply pass them as an array argument to the MixManager's mix() function. This will look through the list of input arrays (with the order of inputs not mattering) and, if a matching array is found, the output substance will be created and its `init_mixed()` function will be called with the reactant substances as an array argument. Following this, the created substance will be returned from `mix()`, and this new substance should be put in place of the substances that created it, which should be deleted after mixing finishes.

### 3 - Custom MixManagers

 In addition to a dictionary of pairs representing mix outcomes, a custom MixManager also needs a dedicated folder to hold the substances for its specific module (specifically, their `.tscn` files), which will be used for loading and creating them on-the-fly during the mixing process, and all substance names entered into the manager's `outcomes` dictionary must be **identical** to the scene names for each substance involved, otherwise the manager will be unable to find them.
 
 Typically, the substance folder for a module will be placed under Scenes/Substances in the same way that the GelModule folder has been, and the filepath specified in the manager's `substance_folder` variable should start at 'res://'. (Refer to Scenes/Substances/GelModule/GelMixManager.gd for an example of this)

## Lab Logs

This refers to any message that you need to show to the user (for example, telling them that they heated something too long). In order to do this, you need to use the `LabLog` object, which you can access from any script.

Logs should fall into 3 categories:

- Log: this is for messages that the user should be able to see, but are purely informational, not mistakes. For example, you might create a log when they reach a certain milestone or checkpoint in the lab.
- Warning: this is for warning the user of small mistakes, but ones which they can continue from. For example, in Gel Electrophoresis, if they microwave it too long, the viscosity will be different than expected, which may impact the final result.
- Error: this is for larger mistakes, whose results we cannot simulate. Use these to notify the user of critical errors.

Logs also have 2 properties:

- `hidden`: true/false, specifies whether the log should be shown in the log menu in the upper right of the screen. Hidden logs are intended for things that should only be visible at the end of the experiment, in the final report (see `ShowReport()` below).`
- `popup`: true/false, specifies whether the user should immediately be notified with a popup dialog. It does not affect or matter whether the log is hidden. Errors should probably always have this true.

### `LabLog` Functions

###### Common Functions:
- `Log(message, hidden = false, popup = false)`: creates a new log with the given message. `hidden` and `popup` are optional. The category of this log will be `"log"`.
- `Warn(message, hidden = false, popup = false)`: creates a new Warning type log with the given message. `hidden` and `popup` are optional. The category of this log will be `"warning"`.
- `Error(message)`: creates a new Error type log with the given message. `hidden` is always set to false and `popup` is always set as true. The category of this log will be `"error"`.
- `ShowReport()`: Tells the system to show the final report for the module - a popup window that shows warning and errors, and lets them restart, return to the menu, or continue in freeform mode. Call this function when the user has completed an experiment.
###### Other Functions:
- `GetLogs()`: returns all the logs that have been created, in a dictionary like this: `{"log": [list of logs], "error": [list of logs], "category": [list of logs in that category]}` See below for the log data structure.
- `ClearLogs()`: Clears all the logs, and notifies anything that cares that it has done so. This is only used internally when switching scenes, etc.
- `AddLogMessage(category, message, hidden, popup)`: You shouldn't need to call this, but it's documented here for completeness. This function is used by Log, Warn, and Error (see above). This way the system technically supports other types of logs, and errors that do not have popups. Currently, `category` is always "log", "warning", or "error", but you could use others. If you need to add another category of log at some point, and there's going to be multiple logs of that category, I think you should consider adding a convenience function like the above for it. That way you can decide whether it should always have popups, always be hidden, etc, and the code for adding a new one is more readable.

### `LabLog` Signals
You probably don't need to use any of these, but you can if you need. They are used by the UI nodes to update themselves with the new logs that interest them. You can use them yourself by calling `LabLog.connect("the name of the signal", [yourObject (probably 'self')], "theFunctionToCallOnYourObject")`.

- `NewMessage(category, newLog)`: Emitted when a new log is created, of any type. See below for the log data structure.
- `PopupLog(category, newLog)`: Emitted when a new `popup` log of any type is created. See below for the log data structure.
- `ReportShown`: Emitted when something calls `ShowReport()` (see above). Used internally, but you can connect to it too if you need to.
- `ClearLogs`: Emitted when logs are cleared with `CleaLogs()` (see above). Used internally to tell UI nodes to update themselves.

### Log data structure

`GetLogs()` and the signals `NewMessage` and `PopupLog` give you logs as dictionaries like this:

```
{
   "message": "Some string",
   "hidden": true/false,
   "popup": true/false
}
```

### Using LabLog

`LabLog` is a singleton (an [autoloaded](https://docs.godotengine.org/en/3.5/tutorials/scripting/singletons_autoload.html) instance of the `LabLogSingleton.gd` script), which you can access from any script by its name. To log something, just do something like this:

```
LabLog.Log("Hello World!")
LabLog.Warn("You didn't heat [something] for long enough! This may affect the final result.", true, false)
LabLog.Error(You messed up really bad.)
```

## Main Scene

The Main scene is kind of like the `main()` function in a language like C++. It is the scene that is loaded when the game starts, and it loads all the other scenes (like your Modules) beneath it.

There are 2 common ways of structuring a game at a high level in Godot:

One (which we do not use) is to use Godot's built in functions to fully change scenes. If you use the `SceneTree.change_scene()` function, the scene you're currently in is removed, and the scene you change to becomes the only scene that exists. The reason that we do not use this method is that *nothing* from the previous scene's tree sticks around, *including the UI, etc*. Our game is dependent on the Main scene to handle input (see below), and we want the UI to be easily accessible at any time, so we don't want that to happen.

The alternative (what we do) is to have a Main scene that just contains the things that the game needs to run - the Main script that handles input events (see below), the Camera, etc, and when we want to load a new scene, add it as a child of the Main scene. For our particular project, this makes the structure of the game a little simpler. It does have one small downside, which is that, without the Main scene, any other scenes you might make (like a module or an individual LabObject's scene) *will not be able to function alone*, so you have to run the entire game every time you want to test something, as opposed to using Godot's "Play Scene" button. We think this tradeoff is worth it, because it's very easy to create a simple little test module to put any objects you're working on in.

TODO: show a screenshot of the structure of the Main scene, including the $Scene node where things are added.

### Input Handling

TODO: talk about how for subscenes we have to manually handle input events in a different order than Godot does by default.

### Utility Functions

TODO: talk about the `SetScene` and `GetDeepestSubsceneAt` functions and why (if?) you might use them. Probably also warn that it's really unlikely you need them unless `Main.gd` is broken or something, so make sure you're not overcomplicating something.

## Dimension Sprites

Godot's `Sprite` nodes don't let you specify exact dimensions, although you can scale them. At times this can make it hard to get things precisely the size you want without spending a lot fo effort or doing the scale factor math yourself.

We've made a `DimensionSprite` class that hopefully makes this a little easier, if you want it. It functions exactly the same as a normal `Sprite`, but it lets you set the dimensions directly in the editor. You could also theoretically use its functionality at run time if you really wanted to.

**NOTE:** You never have to use DimensionSprites. They're there if you want them, but it's purely for convenience. They function in the game identically to a standard `Sprite` node.

**Inherits:** [Sprite](https://docs.godotengine.org/en/3.5/classes/class_sprite.html)

### Properties
- `OverrideDimensions`: boolean, toggles whether the script will automatically set the scale.
- `SpriteDimensions`: the dimensions, in pixels, that the sprite should have. Only works if `OverrideDimensions` is true.

### Functions
- SetDimensions(newDimensions): sets the dimensions, only if `OverrideDimensions` is true. This is [called automatically](https://docs.godotengine.org/en/3.5/tutorials/plugins/running_code_in_the_editor.html#editing-variables) when you change the `SpriteDimensions` property in the editor. Works by changing the `scale` for you.

## Examples

### 1 - Basic LabObject that interacts with others

See Scenes/Objects/TestLabObject1.tscn and TestLabObject2.tscn for how you can do this.

Object1 has a script that implements `TryInteract()` and Object2 is in a group called `Test LabObject Group`, that tells Object1 that it is able to interact with it. To try it, drag an instance of Object1 onto an instance of Object2.

### 2 - LabObject that opens a Menu

Sometimes you might want to prompt the user for something that a `LabObject` needs to do its job (for example, how long a microwave should heat something for). You can see an example of how you might structure this in Scenes/Objects/ExampleMenuLabobject.tscn.

This object has a child called `Menu`.
![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/3305eb0e-5164-48e4-8546-a1a65ef3243f)
All of the menu components are children of that node, and it's accessed in the script as `$Menu`.

`Menu` is a type of node called [CanvasLayer](https://docs.godotengine.org/en/3.5/classes/class_canvaslayer.html). It makes sure that its children are drawn as UI, relative to the screen (as opposed to relative to the LabObject itself). If you wanted to, for example, have a button that followed its object around, you would remove the `CanvasLayer` and parent that UI node to the LabObject directly.

ExampleMenuLabobject also responds to input in its menu. When you select a color in the ColorPicker, it changes the color of the square below the object's sprite. To try it, drag this object onto any other `LabObject`.

To do things like this, you don't need to follow any particular design (ie. the base class doesn't do it for you). Just connect a signal on the UI element to a function that does what you want to do. <br>
![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/7124fc4b-43fe-43e6-89ad-baa995c23c0e)
![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/bde57384-c265-4949-9305-25a13ca967d3)

### 3 - LabObject that does something independently

See Scenes/Objects/Spawner.tscn.

This object creates a new instance of a specified object when clicked. It implements `TryActIndependently()`. To try it, just click an instance of the spawner.

### 4 - Basic Subscene

See Scenes/Objects/SubsceneManagerTest.tscn.

This object does not extend the SubsceneManager script, because it needs only the basic functionality. It has several children to demonstrate where they should be put in the scene tree. While this particular SubsceneManager is `draggable`, most probably will not be.

### 5 - Creating a new Substance with node groups

See Scenes/Substances/GelModule/GelMixSubstance.tscn and Scenes/Substances/GelModule/GelMixSubstance.gd.

This substance can be heated, chilled and weighed, and includes the corresponding function implementations. Substances have no need to implement the `get_mass()` function for the `Weighable` group, as the base Substance class does this for them.

### 6 - Mixing two Substances

See Scenes/Substances/GelModule/GelMixSubstance.gd and Scenes/Substances/GelModule/GelMixManager.gd.

The GelMixManager extends MixManager, and only has to populate the `outcomes` dictionary and `substance_folder` filepath. All other mixing functionality is handled by the base class based on this data.

The GelMixSubstance represents a mixture that can result from mixing two substances with different attributes. Specifically, its `color` and `gel_ratio` fields are determined based on the parent substances given to it by `init_mixed()`, which is called when the substance is created by mixing two or more parent substances together.

## Non Code Documentation

### Licensing

<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/project-viable/viable-virtual-lab">VIABLE Framework</a> by <span property="cc:attributionName">VIABLE team</span> is licensed under <a href="https://creativecommons.org/licenses/by-nc/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" alt=""></a></p>

The contents of this repository are under the above license unless otherwise noted (for example, we include the Godot Engine, which uses its own, somewhat similar, open-source license).
