## Main Scene

The Main scene is kind of like the `main()` function in a language like C++. It is the scene that is loaded when the game starts, and it loads all the other scenes (like your Modules) beneath it.

There are 2 common ways of structuring a game at a high level in Godot:

One (which we do not use) is to use Godot's built in functions to fully change scenes. If you use the `SceneTree.change_scene()` function, the scene you're currently in is removed, and the scene you change to becomes the only scene that exists. The reason that we do not use this method is that *nothing* from the previous scene's tree sticks around, *including the UI, etc*. Our game is dependent on the Main scene to handle input (see below), and we want the UI to be easily accessible at any time, so we don't want that to happen.

The alternative (what we do) is to have a Main scene that just contains the things that the game needs to run - the Main script that handles input events (see below), the Camera, etc, and when we want to load a new scene, add it as a child of the Main scene. For our particular project, this makes the structure of the game a little simpler. It does have one small downside, which is that, without the Main scene, any other scenes you might make (like a module or an individual LabObject's scene) *will not be able to function alone*, so you have to run the entire game every time you want to test something, as opposed to using Godot's "Play Scene" button. We think this tradeoff is worth it, because it's very easy to create a simple little test module to put any objects you're working on in.

![image](./images/mainscene/Main%20scene.png)

The above is the structure of the main scene. It contains the following higher-level nodes:
- `Menu`
  - The main UI the user itneracts with to perform actions like updating options and changing modules.
- `Scene`
  - The current scene the user is on. As of now, since there is just one module, it just sets itself to the GelElectrophoresis module scene. In the future, when this needs to be changed as another module is added, refer to the `_ready()` function within the `Scripts/UI/Menu.gd` script.
- `Mixtures`
  - This tracks all known mixtures relevant to the lab. It is meant to check for mistakes when a user makes a mixture.

### Input Handling

TODO: talk about how for subscenes we have to manually handle input events in a different order than Godot does by default.

### Utility Functions

TODO: talk about the `SetScene` and `GetDeepestSubsceneAt` functions and why (if?) you might use them. Probably also warn that it's really unlikely you need them unless `Main.gd` is broken or something, so make sure you're not overcomplicating something.