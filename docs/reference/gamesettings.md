## Game Settings

This refers to settings controlled in the Options menu.

![screenshot alt text](/docs/reference/images/options_menu.png)

These settings need to be available at all times, so they're stored in a [Singleton](https://docs.godotengine.org/en/4.3/tutorials/scripting/singletons_autoload.html) instance of the `GameSettingsSingleton.gd` script.

### GameSettingsSingleton

This object has no functions. It is essentially a Struct to which anything has access.

It has a property for every setting.

#### Using Game Settings

You can access the Settings object as `GameSettings` at any time, from any script. You can just do something like this:
```gdscript
if GameSettings.mouse_camera_drag:
	drag_camera()
```

#### Adding a new Setting

You need to do 2 things:
- Add a property to `GameSettingsSingleton.gd` to store its value **initialized to a sensible default value**
- Add a UI element to the Menu scene, that sets that value.
