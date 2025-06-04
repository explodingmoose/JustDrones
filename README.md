#  Just Drones

Just drones is a drone app (in the musical sense). Most tuner apps which offer drones, or random drones found on 
streaming platforms/online offer minimal control when it comes to just intonation or temperament. This app serves to
offer musicians greater control over tuning parameters and basic sound synthesis. Additionally, it offers hands-free 
intonation practice with a page-turning pedal (which functions as an external keyboard). The visual layouts of the drones 
also serve an educational purpose by showing pitch-class space (intervallic proximity). In the spirit of sharing knowledge 
and music, I've uploaded the source code to GitHub.

## Just Intonation

Just intonation is a term that is often used without complete nuisance. I recommend checking out the
 [Xenharmonic Wiki] (https://en.xen.wiki/w/Just_intonation) on Just Intonation. 
 This app offers tuning in the 3-limit and 5-limit via "Circle of Fifths" and "Tonnetz" respectively.

3-limit systems tune all pitches as they relate from the fundamental to the 3rd harmonic. In other words, they tune
pitches completely by 5ths and octaves. The circle of fifths setting demonstrates methods of tuning in a sequence of 
fifths relative to a "tonus." The app maintains the diapason at the set calibration regardless of tonus. Having multiple 
sizes of 5ths allows you to hear the differences in meantone temperaments. Pure fifths (also known as pythagorean), Equal 
Temperament, 1/4 Comma Meantone (pure major 3rds), and 1/3 Comma Meantone (pure minor 3rds) are all available.

The Tonnetz maps out just intonation in 5-limit pitch-class space. That is, all the notes are related by fifths and thirds.
You will notice this causes many repeated notenames / enharmonic spellings. However, with just fifths and thirds, these are
all distinct pitch classes. You can check the frequencies themselves under the display mode settings, or show 
pitch class integers. The tonnetz is an extremely useful way to show the mathematical issues the come with tuning in a 
visual manner.

## Acknowledgements

All of the audio components of this app use AudioKit and related packages. Please check out their various projects!

## Code Usage

I am an amateur programmer at best, so feel free to offer suggestions or feedback! You are also welcome to send questions.
Feel free to use any part of the code (without just plagiarizing).
