### 1 - Creating a new Substance with node groups

See Scenes/Substances/GelModule/GelMixSubstance.tscn and Scenes/Substances/GelModule/GelMixSubstance.gd.

This substance can be heated, chilled and weighed, and includes the corresponding function implementations. Substances have no need to implement the `get_mass()` function for the `Weighable` group, as the base Substance class does this for them.

### 2 - Mixing two Substances

See Scenes/Substances/GelModule/GelMixSubstance.gd and Scenes/Substances/GelModule/GelMixManager.gd.

The GelMixManager extends MixManager, and only has to populate the `outcomes` dictionary and `substance_folder` filepath. All other mixing functionality is handled by the base class based on this data.

The GelMixSubstance represents a mixture that can result from mixing two substances with different attributes. Specifically, its `color` and `gel_ratio` fields are determined based on the parent substances given to it by `init_mixed()`, which is called when the substance is created by mixing two or more parent substances together.