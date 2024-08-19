### 1 - Basic LabObject that interacts with others

See Scenes/Objects/TestLabObject1.tscn and TestLabObject2.tscn for how you can do this.

Object1 has a script that implements `TryInteract()` and Object2 is in a group called `Test LabObject Group`, that tells Object1 that it is able to interact with it. To try it, drag an instance of Object1 onto an instance of Object2.

### 2 - LabObject that opens a Menu

Sometimes you might want to prompt the user for something that a `LabObject` needs to do its job (for example, how long a microwave should heat something for). You can see an example of how you might structure this in Scenes/Objects/DummyHeater.tscn.

This object has a child called `Menu`.
![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/3305eb0e-5164-48e4-8546-a1a65ef3243f)
All of the menu components are children of that node, and it's accessed in the script as `$Menu`.

`Menu` is a type of node called [CanvasLayer](https://docs.godotengine.org/en/3.5/classes/class_canvaslayer.html). It makes sure that its children are drawn as UI, relative to the screen (as opposed to relative to the LabObject itself). If you wanted to, for example, have a button that followed its object around, you would remove the `CanvasLayer` and parent that UI node to the LabObject directly.

DummyHeater also responds to input in its menu. When you select a button, it can change the time it will heat an object for or start the heating process. To try it, drag a `LabObject` that has the `Heatable` property into this object.

To do things like this, you don't need to follow any particular design (ie. the base class doesn't do it for you). Just connect a signal on the UI element to a function that does what you want to do. <br>
![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/7124fc4b-43fe-43e6-89ad-baa995c23c0e)
![image](https://github.com/jcourt325/BiofrontiersCapstone/assets/65268611/bde57384-c265-4949-9305-25a13ca967d3)

### 3 - LabObject that does something independently

See Scenes/Objects/Spawner.tscn.

This object creates a new instance of a specified object when clicked. It implements `TryActIndependently()`. To try it, just click an instance of the spawner.