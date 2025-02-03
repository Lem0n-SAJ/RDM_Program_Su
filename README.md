# rdm_experiment

A new Flutter project.

## Getting Started

Random Dot Motion (RDM) Experiment
This is a Flutter-based program that simulates a Random Dot Motion (RDM) experiment. The application displays a fixed 1920×1080 window with a circular aperture (diameter 1000 pixels) in which 200 dots move upward at a variable speed. The program includes a central fixation cross and various keyboard shortcuts to control motion speed and display options.

Program Functionality
Random Dot Motion:

200 dots are generated outside the circular aperture (located at the bottom) and move upward.
Dots become visible only when they enter the circular region.
Once a dot has entered the circle and then leaves, it is respawned below the aperture.

Central Fixation Cross:

A small, central white cross (2 pixels thick and 4 pixels in total length) is drawn on top of all dots to serve as a fixation point.

Frame Rate Lock:

The program updates at a fixed rate of 60 frames per second to ensure consistent motion speed regardless of the display's refresh rate.

Keyboard Shortcuts:

Left Arrow: Decrease dot motion speed by 50 pixels per second.
Right Arrow: Increase dot motion speed by 50 pixels per second.
F1: Toggle display of the current speed (shown in the top-left corner).
Enter: Save the current speed as a data group.
L: Export all saved speed data to a TXT file.
A: Set the speed to 0.
D: Set the speed to the maximum (1000 pixels per second).
F10: Toggle full-screen mode.

Runtime Environment
Flutter Version: Tested with Flutter stable (e.g., version 3.27.3)
(Ensure you have a compatible version installed from flutter.dev)
Dart: Bundled with Flutter.
Dependencies:
flutter (SDK dependency)
cupertino_icons (for iOS-style icons; optional)
window_manager (^0.2.9) – used for managing the application window (full-screen control and fixed window sizing)

License
This project is licensed under the MIT License.