# Documentation Home

This is an index of our documentation for the project.

If you're here for the first time, go \[here](TODO). Do make sure to look at the class reference, not just the guides.

## Guides
1. \[Installation/Getting Started](TODO: probably keep this in the readme?)
2. \[Project Overview](TODO. Also include things to make sure you know about Godot.)
3. \[Creating a new Module](TODO: Separate out the section from the Modules reference)
4. \[Adding a new object to the game](TODO: Separate out the section from the LabObject reference)
5. \[Using Subscenes](TODO: Separate out of the SubsceneManager reference)

## Reference
1. [Modules](/docs/reference/modules.md)
2. [LabObjects](/docs/reference/labobject.md)
3. [LabBoundaries](/docs/reference/labboundary.md)
4. [SubsceneManagers](/docs/reference/subscenemanagers.md)
5. [Substances](/docs/reference/substances.md)
6. [Lab Logs](/docs/reference/lablogs.md)
7. [Main Scene](/docs/reference/mainscene.md)
8. [DimensionSprites](/docs/reference/dimensionsprite.md)

## Examples
1. TODO

## Examples

TODO: Put these in their own files? Group them by what class they're related to?

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

At the time of writing, this project has no license, which means that, while you can see it, you currently can't actually use any of the code on your own, because it belongs to its individual authors.

Soom, there will be a real license. When there is, Github will show it to you in the sidebar.
