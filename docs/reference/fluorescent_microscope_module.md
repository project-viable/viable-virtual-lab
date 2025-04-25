# Fluorescent Microscope Module
This part assumes you have already looked through the [Project Overview](/docs/guide/overview.md) and have familiarized yourself with Godot and other parts of the documentation. 

This is for documenting the structure of the module, and how things generally work to help future developers. 

This is the 2nd module that was developed after the Gel Electrophoresis module. In this module a user is able to open the `Fridge` and select a `Slide`, and then drag it to the `Microscope`. Afterwards, the user is then able to view the contents of the slide and configure different properties of the `Microscope` via the `Computer`. Consider looking at the [Procedure](/docs/procedures/fluorescence_microscopy.md) for this module for more details and a better understanding. 



## Node Structure

The`FluorosceneceMicroscopy` scene consists of these important nodes:

- `Computer` - Responsible for displaying contents of the slide and configurations.
- `Fridge` - Holds the `Slides` and can also have its temperature configured.
- `MicroscopeControls` - Consists of the `Joystick` and `Focus Control` for moving and focusing the slide image on the `Computer Screen`
- `Microscope` - Responsible for physical configurations like opening and closing the trays, toggling the light, and for mounting a slide. 


## Slides
This section will explain how different slide images are loaded, and how to add additional slides to the module.


Right now, for each slide there are 4 channels to choose from in the `Computer`:
1) Dapi
2) FITC
3) TRITC
4) Cy5

and 4 zoom levels:
1) 10x
2) 20x
3) 40x
4) 100x

For every combination of a channel and zoom, there is an image representing that combination. This is done for each slide and can be seen in `/project/source/Images/ImageCells/BPAE/A1`. BPAE is the type of cell and has variations labeled A1, B1, and C1. These images are the ones that could be displayed on the `Computer`. 

Accounting for numerous images, we decided that the best way to load images for display on the `Computer` would be to use `String interpolation` for the image path as such: 

`var image_path: String = "res://Images/ImageCells/BPAE/%s/%s/%s.jpg" %[current_slide, current_channel, zoom_level]`

Here, `current_slide` is the variation like A1, `current_channel` like Dapi, and `zoom_level` would be something like 40x.

Overall, the image path should look something like this:

`"res://Images/ImageCells/BPAE/A1/Dapi/40x.jpg"`

As you can see, correctly naming the folders and files is **very** important, at least for the channel and zoom level since these are set in stone. 

So, when adding new slides, make sure to create the necessary folders and place the correctly named image files into their respective folders.

Adding an actual `Slide` node inside Godot is much more straightforward and you can for the most part, duplicate the already existing slide nodes inside the `Fridge` scene. They should all use the same script and be added to the `Slides` group. Afterwards you can freely change the textures directly via the editor. The `Slide Name` is the most important property of a slide as this is the value used for the `current_slide` for the image path.
