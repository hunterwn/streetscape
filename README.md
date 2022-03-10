
<div  id="top"></div>

<h2  align="center">StreetScape</h3>

<p  align="center">

A mobile game where you get to design the perfect street and vote on the designs of other players.

</p>

</div>

### Built With
*  [Flutter](https://flutter.dev/)
*  [Firebase](https://firebase.google.com/)
### Software
*  An IDE that supports Flutter such as VSCode or Android Studio.
*  [Blender 2.9](https://flutter.dev/)
*  [GIMP](https://www.gimp.org/downloads/) or Photoshop.
* [7-Zip](https://www.7-zip.org/download.html) or [WinRAR](https://www.win-rar.com/start.html?&L=0)
* (Optional) [SketchUp](https://www.sketchup.com/try-sketchup)

## Getting Started

The project can be compiled to an Android Emulator or and Android phone connected to a PC via USB cable.
[Here](https://www.youtube.com/watch?v=Z6KZ3cTGBWw) is a tutorial that goes over the basics of building a Flutter app.

The FireBase database will need to be setup again to host the user data and service API calls. This process is relatively straightforward, [here](https://www.youtube.com/watch?v=Z6KZ3cTGBWw) you will find a tutorial from Google going over how to connect the app to a new Firebase Firestore database.

## Roadmap

-  [x] Setup Layer Rendering System

-  [x] Create and Add content for first scenario.
-  [x] Partial database integration.
-  [x] Partial menu completion.
- [ ] Generate images for the remaining scenarios.
- [ ] Add player progression.
- [ ] Full database integration.
- [ ] Full menu and GUI completion.
- [ ] UI and UX polish (animations, etc...).

## Code Details

The class hierarchy is as follows:
Each "lane" represented by the 5 buttons has a LaneManager class. This class contains the ChoiceManager for a specific choice that currently occupies that lane. The ChoiceManager has a list of features represented by the Feature class. These features contain unique logic and a list of options within the feature represented by the Options class. 

For example: The on-street-parking lane type has the parking spot feature which contains the options of parallel or diagonal parking.

Each option has a list of images represented by the OptionImage class which contains the URL of the image to fetch and the layer for the image to be inserted. When an option is enabled, all of it's images are sent to the ImageLayerManager to be rendered on screen, and the reverse happens when an option is disabled.

The majority of this code can be found in the choice_manager.dart file. The code was previously more organized in separate files but needed to be added to one file for debugging purposes. Feel free to re-organize any way you choose.

Each scenario's various features and options are declared in the get_scenario_options.dart file. You will find the getScenarioOptions function which provides variables representing each scenario declared in the file, as well as the getStaticOptions which provides the options which cannot be interacted with by the player.
## Resources

Due to their size, the files for asset generation have been placed in a the SD_assets.7z file which can be opened with 7zip or WinRAR. Inside you will find 3D models and files used to generate renders with various software listed above in the software section. The renders.7z file contains raw renders from Blender while the SD_exportedimages.7z file contains processed images.

## Asset Generation

Assets are generated in Blender using the rendering function with the Cycles rendering engine. For a tutorial on how to render in Blender look [here](https://www.youtube.com/watch?v=ZTxBrjN1ugA). 

When opening the render_scene.blend file, you will immediately see the Camera's POV at which renders are made. This camera represents the view of the player of the street and should never be moved. Pressing 0 on the numpad will reset your view to match the camera. From here 3D models can be toggled on and off to be visible on invisible in the project outline and rendered individually.

Once you have made your renders, I have provided a composite.psd file which you can import your renders into to preview them and make small edits as necessary using Photoshop. If you do not have photoshop I have also provided the .xcf file which can be edited using GIMP, a free Photoshop alternative.

After you are satisfied with the images they will need to be added to the /assets folder in the repository before they can be obtained by filename in code.

Sketchup was used as a source for various 3D architectural models. In SketchUp there is a feature called the 3D Warehouse which allows you to search and download 3D models. These can be exported as .dae files and imported to Blender with some effort. 


