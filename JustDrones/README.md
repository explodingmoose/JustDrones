#  Just Drones Code

This Folder contains everything in the app:
* Assets - Colors, App Icon, and Symbols Used on the waveform knobs
* Bravura Text - The font used for accidentals
* Launch Screen
* Preview Content - Space for preview versions

* JustDronesApp - The actual app
* ContentView - The main body of the app
* Models - Connects UI to Data
    * Default Parameters - These are loaded before content view via AppDelegate
    * Drone Manager - Controls the tuning of drones according to the diapason, stop, and size of fifth.
    * Recording Manager - Houses the preset drone lists
    * Synth Manager - Controls all of the synth parameters, and responds to turning on and off drones. In AudioKit terms, this acts as the conductor.
* Menus - All of the menus used to control variabls
* Drone Layouts - Views for the drones
    * Buttons - The actual button of the drone, which handles the display of the drone information and telling the synth to turn on and off drones
    * CircleOfFifths
    * Tonnetz
    * Recorded Drones - Shows recorded drones
        * Save Menu - Allow saving of the recorded drones as a preset
        * Pedal Drone - The drone button which can be used to switch between drones with a page-turning pedal (any keyboard)
    
    

