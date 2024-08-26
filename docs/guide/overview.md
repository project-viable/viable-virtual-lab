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
  - [Reference](https://docs.godotengine.org/en/3.5/tutorials/io/saving_games.html)
- How to make a script execute without running the game (the `tool` keyword at the top of some scripts like `LabObject.gd`)

## Important Things

Here's the most important systems you should know about:

1. [Modules](/docs/reference/modules.md) - These are the individual labs that contain all the logic, objects, etc. to simulate a lab experiment.
2. [LabObjects](/docs/reference/labobject.md) - These are the objects that can be dragged around and interact with others.
3. [Lab Boundary](/docs/reference/labboundary.md) - This fixes the position of lab objects so they can't go outside the designated lab space.
4. [Object Groups](/docs/reference/groups/index.md) - These use Godot groups to indicate an object's purpose or properties it has.
5. [Object Slot](/docs/reference/objectslot.md) - This is like a socket where you can put a lab object inside of another.
6. [SubsceneManagers](/docs/reference/subscenemanagers.md) - These are objects that maintain a subscene, which can be zoomed in view, let a user have a more in-depth control of their interactions with objects, etc.
7. [Substances](/docs/reference/substances.md) - These are chemicals and other substances used in labs that have properties such as density.
8. [Lab Logs](/docs/reference/lablogs.md) - These indicate user actions as well as let a user know if they did something wrong via warnings and errors.
9. [Main Scene](/docs/reference/mainscene.md) - Like `main()` in C/C++, this is where global configurations are set and controls the current module scene, menu, options, etc.
10. [Game Settings](/docs/reference/gamesettings.md) - These control global settings using a Singleton design pattern, for example the popup UI timeout.
11. [Deployment](/docs/reference/deployment.md) - This is how you export the project to a web format and deploy to GitHub Pages.

See the [full reference](/docs/index.md#reference) if this doesn't tell you what you need.