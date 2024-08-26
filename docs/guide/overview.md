# Project Overview

This is intended to list what different things exist, so that the rest of the documentation makes a little more sense. It may not be complete, but if you add an important system or something, try to at least link to it here.

## Things you should know about Godot before continuing
### Absolute Basics
- How the scene tree works
- What Signals are and how to use them
- What Groups are
- How to make an object, and give it a script
### Things Tutorials might not have taught you
- How to arrange UI nodes (![Layout Presets](layout_presets_image.png) in the editor)
- How Godot does [Singletons](https://docs.godotengine.org/en/3.5/tutorials/scripting/singletons_autoload.html)
- What a Z-Index is
- What [Resources](https://docs.godotengine.org/en/3.5/tutorials/scripting/resources.html) are
- How to draw a line (see Scenes/Objects/ContactWire.tscn for an example)
- How to programmatically get and set positions and the fact positions are of type `Vector2` (a two dimensional vector)
- How to read from a JSON file (for cases like reading a file of stored mixtures)
- How to make a script execute without running the game (the `tool` keyword at the top of some scripts like `LabObject.gd`)

## Important Things

Here's the most important systems you should know about:

1. [Modules](/docs/reference/modules.md)
2. [LabObjects](/docs/reference/labobject.md)
3. [Lab Boundary](/docs/reference/labboundary.md)
4. [Object Groups](/docs/reference/groups/index.md)
5. [Object Slot](/docs/reference/objectslot.md)
6. [SubsceneManagers](/docs/reference/subscenemanagers.md)
7. [Substances](/docs/reference/substances.md)
8. [Lab Logs](/docs/reference/lablogs.md)
9. [Main Scene](/docs/reference/mainscene.md)
10. [Game Settings](/docs/reference/gamesettings.md)
11. [Deployment](/docs/reference/deployment.md)

See the [full reference](/docs/index.md#reference) if this doesn't tell you what you need.