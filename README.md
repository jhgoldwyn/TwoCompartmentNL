# TwoCompartmentNL

Code and data files that accompany
Structure and dynamics that specialize neurons for high-frequency coincidence detection in the barn owl nucleus laminaris
by Ben Drucker and Joshua H. Goldwyn (Swarthmore College)

Manuscript available on bioRxiv

### Repository contains:

*twoCptNL_figs.m [matlab]*
* run to reproduce figures in the manuscript

*twoCptNL_run.py [python and c]*
* run the NL model described in the manuscript
* inputs types can be varied (synaptic conductance, sinusoidal conductance, or sinusoidal current)
* coupling configuration and Na inactivation can be varied (see manuscript for details)
* ITD can be varied

integrateFire_run.m [matlab]
* runs the nonlinear integrate-and-fire model described in the manuscript

### supporting files are:
* twoCptNL.c: c code that executes the NL model
* makefile: make file for NL program
* plot_traces.py: python wrapper to set up and run NL model simulations
* graphing_utils.py: python function used in plot_traces
* 1_ITD_0.XX.nmlib: example synaptic files to use as inputs to NL model.  XX is IPD, which takes values from 00 (in phase) to 50 (out of phase)
* figureData.mat: data used in twoCptNL_figs to recreate figures in paper
* gNaData.csv: database of gNa values for various coupling configurations and Na inactivation curves


## Instructions for running NL model using plot_traces program:

To plot using synaptic input, run:
> python3 plot_traces.py --mode syn -L

To plot using sinusoidal input using no pre-run initial values, run
> python3 plot_traces.py --mode sin --init-values no-input -L

To plot using sinusoidal input using initial values obtained by an initial run, run
> python3 plot_traces.py --mode sin --init-values run-before -L

*To modify parameter values:*
* Make changes to parameter values in the "args_dict" structures at the bottom of plot_traces.py.  Modify the correct dictionary, depending on whether you are using synaptic or sinusoidal inputs. 

*Notes:* 
* Can only run coupling configurations for which there is a gNa value stored in the database gNaData.csv
* For reasons having to do with earlier versions of our code, we indicate the steepness of the Na inactivation function by "hDenom" in this code
* Two subdirectories will be created by this code and figures will be stored there (Figures, C_Intermediate_Output)
