## HTML5 Export and Deployment
Since this project aims to help provide research experience, we have opted for the most accessible option for deployment, a web-based export.

### HTML5 Export
Prior to merging branch `dev` into `main`, it is important to create a new HTML5 export in Godot.

The process of creating a new export is straightforward. First, go to the Project tab in the top right corner and click `Export...`

If you do not have the HTML5 preset, it is a simple download. Click on `Add...` next to `Presets` and select the `HTML5` option.

While having the HTML5 preset selected, click `Export Project` and click save. If it asks to overwrite, click yes.

#### Important HTML5 Export Notes
In our current state, we need to include some extra resources in our export. For example, `Mixtures.json` needs to be exported.

To do this, we fill out a field in the `Resources` tab of the export window.

![image](./images/deployment/HTML5%20Export%20Extras.png)

### For more information about exporting to the web, check out the official Godot documentation [here](https://docs.godotengine.org/en/3.5/tutorials/export/exporting_for_web.html)

### Deployment
Currently, we are using GitHub Pages to deploy our build.

It is a straightforward process to build and deploy. Based off the settings set to deploy from branch `main`, you just need to merge `dev` into `main`.

### Future
In the future, this process can be streamlined using GitHub Actions.

A possible action that we can use is [this](https://github.com/firebelley/godot-export).

The reason for switching to GitHub Actions is that it would allow us to skip the step of manually creating an HTML5 export before merging `dev` into `main`.