# TwoCompartmentNL

Code and data files that accompany
Structure and dynamics that specialize neurons for high-frequency coincidence detection in the barn owl nucleus laminaris
by Bennett Drucker and Joshua H. Goldwyn (Swarthmore College)

Manuscript available on bioRxiv

Repository contains:

twoCptNL_figs.m
* run to reproduce figures in the manuscript

twoCptNL_run.py
* run the NL model described in the manuscript
* inputs types can be varied (synaptic conductance, sinusoidal conductance, or sinusoidal current)
* coupling configuration and Na inactivation can be varied (see manuscript for details)
* ITD can be varied

integrateFire_run.py
* runs the nonlinear integrate-and-fire model described in the manuscript

supporting files are:
* twoCptNL.c: c code that executes the NL model
* figureData.mat: data used in twoCptNL_figs to recreate figures in paper
* gNaData.csv: database of gNa values for various coupling configurations and Na inactivation curves
