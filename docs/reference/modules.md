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