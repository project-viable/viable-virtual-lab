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