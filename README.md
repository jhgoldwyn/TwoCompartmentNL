# TwoCompartmentNL

Matlab files that accompany "Dynamics of the continuity illusion" by Bennett Drucker and Joshua H. Goldwyn (Swarthmore College)

Manuscript available on bioRxiv at

twoCptNL_figs.m
* can be run in sections to reproduce figures in the manuscript

twoCptNL_run.py
* run the NL model described in the manuscript
* inputs types can be varied (synaptic conductance, sinusoidal conductance, or sinusoidal current)
* coupling configuration and Na inactivation can be varied (see manuscript for details)
* ITD can be varied

supporting files are:
* twoCptODE.c: c code that executes the NL model
* figureData.mat: data used in twoCptNL_figs to recreate figures in paper
* gNaData.csv: database of gNa values for various coupling configurations and Na inactivation curves
