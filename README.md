TwoFlyTracker
======================


## Examples

![Example](resources/example.gif "Original video (left) and analyzed result(right)")

## Description
TwoFlyTracker is an automated program written in MATLAB for behavior analysis of fruit flies.  It can track two flies and charactorize their behaviors.  TwoFlyTracker can generate the following infomation for each frame of the input videos:
* Tracking: 
    * position
    * speed
    * orientation
    * size
* Behavior analysis:
    * wing extension (courtship assay)
    * copulation (courtship assay)
    * aggression (aggression assay, under development)
    * collision (both)

## Dependencies
TwoFlyTracker is tested under Windows 7, 8 and 10 using MATLAB R2015a. 

## Installation
    1. git clone https://github.com/he-zhe/TwoFlyTracker.git
    2. Add file location and subfolders to MATLAB path

## Usage
    General workflow:
    1. Annotation: In MATLAB go to folders with input videos. Type "annotate_video" in MATLAB console and select all input videos.
    2. Tracking: Type "run" or "run_multicore" in MATLAB console and select all annotated videos.
    3. Inspection: Type "manual_correction" in MATLAB console and select all annotated videos. If there is any mistakes in tracking procedure, correct them.
    4. Type "get_speed" and "get_agg" (if in agression assay) to calculate speed and mark aggression behaviors.
    5. Type "get_statistics" to get a Excel sheet that summarize the data.
    6. (optional) Type "get_movie_agg" or "get_movie_WE" to get the annotated videos.(See example folder or github page for examples)
    
    A more detailed recording and analysis protocol will be available soon.
## Caveats & to-do
    1. Only MP4 format is supported and tested currectly. More formats will be supported before 9/1/2016.
    2. Only support 640X480 resolution. More resolutions will be supported before 9/1/2016.
    3. The sensitivity of aggression behaviors detection is only ~95%.
    4. stdout needs to be cleaned.
## Credit
This project was originally based on [Fly Voyeur](http://sg-s.github.io/fly-voyeur/) ([Published in *Neuron*](http://www.sciencedirect.com/science/article/pii/S0896627314006230)).  Most of the code has been re-written to fit the recording protocol.  But the GUI is still heavily inspired by [Fly Voyeur](http://sg-s.github.io/fly-voyeur/).  Please see the beginning comments of each sorce file for details.
