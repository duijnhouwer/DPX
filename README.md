![DPX](https://github.com/duijnhouwer/dpx/blob/master/dpxDocs/dpxLogo.png)

### Introduction

DPX is a Matlab toolbox for creating and analyzing psychophysical experiments for vision research. It is a fully object-oriented extension of Psychtoolbox (PTB) which needs to be installed on your system for DPX to function. DPX is designed to create and manage experiments in a way that promotes simplicity and code-reuse. Stimuli and responses measures are modules that can be plugged into the tried and tested core of DPX. The core takes care of all the bookkeeping that is common to any experiment, including data output. DPX automatically saves all aspects of the experiments as an easy to work-with format called DPXD. Functions to create analyses based on DPXD-structs are included. 

I like to think that DPX relates to PTB as LaTeX to TeX. All the hard work---low-level graphics processing, keeping track of timing, etc.---is done by PTB, and DPX provides a convenient, structured yet flexible environment to run experiments. If you publish work for which DPX was used you should [cite](http://psychtoolbox.org/credits) the creators of PTB.

DPX stands for Duijnhouwer-Psychtoolbox-Experiments.

### Requirements

To use DPX you need the following:

 * A Linux, Mac OS X, or Windows computer. I've tested DPX on Ubuntu 12.04 and 14.04, Mac OS X 10.6.8 and 10.9.5, and Windows 7 SP1.
 * Matlab. DPX was tested with 2012b, 2014a and 2014b. I expect that any version since the introduction object-oriented syntax (in 2008b) will work.
 * Psychtoolbox-3. [Installation instructions](http://psychtoolbox.org/PsychtoolboxDownload). Try and test PTB before installing installing DPX, have a look at help Psychdemos. If this is the first time you run PTB, there will likely be some steps to take, most notably restarting Matlab. Carefully read the instructions PTB spews onto the command window.

### Installation

To obtain the DPX files and give Matlab access to them:

* Change the current working directory of Matlab to the location where you wish to install the DPX toolbox. For example, to move to the default location for Matlab toolboxes on Windows you could type
  `cd('C:\Users\YOURUSERNAME\Documents\MATLAB')`
* Download DPX from Google Code to your system by Copy/Pasting the following to the Matlab command window
  `!svn checkout https://github.com/duijnhouwer/dpx/trunk DPX`
* Add the newly created folder "DPX" and its subfolders to the path using Matlab's `pathtool`.

### Test

If everything is installed properly, running [dpxExampleExperiment](https://github.com/duijnhouwer/dpx/blob/master/dpxExperiments/Examples/dpxExampleExperiment.m) should present you with a basic 2AFC left-right motion discrimination experiment. Use [dpxExampleExperimentAnalysis](https://github.com/duijnhouwer/dpx/blob/master/dpxExperiments/Examples/dpxExampleExperimentAnalysis.m) to plot a psychometric curve of the data. I have heavily commented these examples so that they can serve as DPX tuturials.

### Troubleshooting

If you encounter any problems please look in the issues section (exclamation point in toolbar to the right) whether your problem has been encountered (and hopefully) solved before. If the problem persists, please raise a new issue, and I will promptly ignore it until I have time to solve it.
