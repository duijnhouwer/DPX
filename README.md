![DPX](https://github.com/duijnhouwer/dpx/blob/master/dpxDocs/dpxLogo.png)

---

### Introduction

DPX is a Matlab toolbox for creating and analyzing psychophysical experiments for vision research. It is a fully object-oriented extension of Psychtoolbox (PTB) which needs to be installed on your system for DPX to function. DPX provides a simple way to create and manage experiments owing to it's object-oriented design. Stimuli and responses measures are programmed as modules that can be plugged into the tried and tested core of DPX. Data output is an integral part of the core as well. DPX automatically saves all aspects of the experiments as an easy to work-with structure called DPXD. Functions to create analyses based on DPXD-structs are included. DPX stands for Duijnhouwer-Psychtoolbox-Experiments.

I like to think that DPX relates to PTB as LaTeX to TeX. All the hard work---low-level graphics processing, keeping track of timing, etc.---is done by PTB, and DPX provides a convenient, structured yet flexible environment to create and manage experiments. If you publish work for which DPX was used you should [cite](http://psychtoolbox.org/credits) the creators of PTB.

### Requirements

To use DPX you need the following:

 * A Linux, Mac OS X, or Windows computer. I've tested DPX on Ubuntu 12.04 and 14.04, Mac OS X 10.6.8 and 10.9.5, and Windows 7 SP1.
 * Matlab. DPX was tested with 2012b, 2014a and 2014b. I expect that any version since the introduction object-oriented syntax (in 2008b) will work.
 * Psychtoolbox-3. [Installation instructions](http://psychtoolbox.org/PsychtoolboxDownload). Try and test PTB before installing installing DPX, have a look at help Psychdemos. If this is the first time you run PTB, there will likely be some steps to take, most notably restarting Matlab. Carefully read the instructions PTB spews onto the command window.

### Installation

To obtain the DPX files and give Matlab access to them:

* Change the current working directory of Matlab to the location where you wish to install the DPX toolbox. For example, to move to the default location for Matlab toolboxes on Windows you could type
  cd('C:\Users\YOURUSERNAME\Documents\MATLAB')
* Download DPX from Google Code to your system by Copy/Pasting the following to the Matlab command window
  `!svn checkout https://github.com/duijnhouwer/dpx DPX`
* Place DPX on the Matlab path.
The easiest way to do this is by right clicking the "DPX"-folder in the "Current Folder"-panel (on the left in Matlab's default layout) > select "Add to Path/Selected folders and subfolders". Then enter savepath in the command window.
Alternatively you could use the pathtool command but you'll have to manually remove all folders containing ".svn" (Subversion uses these normally hidden folders for internal housekeeping.)

### Test

If everything is installed properly, running dpxExampleExperiment should present you with a basic 2AFC left-right motion discrimination experiment. Use dpxExampleExperimentAnalysis to plot the psychometric curve.

### Troubleshooting

If you encounter any problems have look in the DPX-wiki. Also make sure to search the PTB website. If the problem persists, please send a description of the problem to j.duijnhouwer+DPX (at) gmail (dot) com.
