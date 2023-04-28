from matplotlib import pyplot as plt
from matplotlib.pyplot import plot
from numpy import arange, savetxt, array
from scipy.integrate import solve_ivp
from datetime import datetime
from math import exp, pi, sin
from argparse import ArgumentParser
from os import name, system, getpid, listdir, chdir, mkdir
from os.path import abspath, exists
from pandas import read_csv
from atexit import register
from graphing_utils import txt_to_list
#Graphic parameters
plt.rcParams['font.family'] = "serif"
plt.rcParams['figure.figsize'] = [15, 5]

# OS check
if name == 'nt':
	print("This program is designed for UNIX-like systems (including mac). Windows is not supported.")

### Exit handler to clean up intermediate output after exiting for whatever reason
def clean_up():
    system("rm -f ../C/C_Intermediate_Output/*.txt")

#register(clean_up)
###



def get_gNa_value(c12, c21, hDenom):
    """Function get_gNa_value: obtain gNa value for desired configuration from Data/gNa_values.csv

    Args:
        c12 (float): forward coupling parameter
        c21 (float): reverse copuling parameter
        hDenom (float): hDenom parameter

    Returns:
        float: relevant gNa value
    """
    try:
        res = gNa_vals[(gNa_vals['couple12'] == c12) & (
            gNa_vals['couple21'] == c21) & (gNa_vals['hDenom'] == hDenom)]['gNa']
        if len(res) == 0:
            print("Error! The gNa value could not be obtained. The gNa value for (c12, c21, hDenom) == (%s, %s, %s) does not exist." % (
                c12, c21, hDenom))
            return None
        else:
            return res.iloc[0]
    except Exception as e:
        print("Error! An error occured when trying to obtain gNa value for (c12, c21, hDenom) == (%s, %s, %s) [Error message: %s]" % (
            c12, c21, hDenom, e))
        return None




def main_syn(iteration, param_dict):
    """Function main_syn: plot and save voltage traces for the "synaptic" method

    Args:
        param_dict (dict): dictionary of parameters needed to run simulation

    Returns:
        None
    """
    couple12 = param_dict['couple12']
    couple21 = param_dict['couple21']
    f = param_dict['freq']
    gNa = param_dict['gNa']
    if 'ipd' in param_dict:
        ipd = param_dict['ipd']
    else:
        ipd = 0  # Default IPD of 0
    lin_interp_fact = param_dict['lin_interp_fact']
    hDenom = param_dict['hDenom']

    # Print summary about this run
    print("Generating plot for mode = syn | Iteration=%2d | c12=%.2f | c21=%.2f | gNa=%4.2f | lin_interp_fact=%s | hdenom=%2.1f | ipd = %3.2f " % (
        iteration, couple12, couple21, gNa, str(lin_interp_fact), hDenom, ipd))

    lin_interp_fact += int(max(1, (gNa//600)) - 1)

    # data parameters
    # [0 for keep spikes, 1 for keep voltage, 2 for keep all variables]
    writeData = 1

    # neural parameters
    KLTfrac = [0., 0.]

    # stimulus parameters
    ITD = ipd*(1000./f)  # IPD takes values 0 to .5 for out phase

    # simulation time, including Euler Time Step
    tStart = 0
    tEnd = 25.
    dt = 0.1e-3/lin_interp_fact

    # parameterize twoCpt model
    areaRatio = 20./2400.  # Funabiki Table 3
    vRest = -62.  # [units:mV] 
    R1 = 5.  # [units: MegaOhms] 
    tauExp = 0.1 # [units:ms]

    # Passive conductance [units: nS] #
    gAx = (1000./R1) * couple21 / (1.-couple12*couple21)  # axial conductance #
    gTot1 = gAx * (1./couple21 - 1.)  # cpt1 total conductance
    gTot2 = gAx * (1./couple12 - 1.)  # cpt2 total conductance

    # capacitance using separation of time scales argument [units: pF] #
    cap1 = tauExp * (1-couple12*couple21) * (gTot1 + gAx)  # cpt1 capacitance
    cap2 = areaRatio * cap1  # cpt2 capacitance

    # KLT gating # Funabiki Table 2 #
    def alphad(v): return 0.20 * exp((v+60.)/21.8)
    def betad(v): return 0.17 * exp(-(v+60.)/14.)
    def dinf(v): return alphad(v) / (alphad(v) + betad(v))
    def taud(v): return 1. / (alphad(v) + betad(v))
    EK = -75.  # K reversal potential [mV]

    # KHT gating # Funabiki Table 2 #
    def alphan(v): return 0.110 * exp((v+19.)/9.1)
    def betan(v): return 0.103 * exp(-(v+19.)/20.)
    def ninf(v): return alphan(v) / (alphan(v) + betan(v))
    def taun(v): return 1. / (alphan(v) + betan(v))

    # Na gating # Funabiki Table 2 #
    def alpham(v): return 3.6 * exp((v+34)/7.5)
    def betam(v): return 3.6 * exp(-(v+34)/10.0)
    def minf(v): return alpham(v) / (alpham(v) + betam(v))
    def taum(v): return 1. / (alpham(v) + betam(v))
    def alphah(v): return 0.6 * exp(-(v+57)/18.0)
    def betah(v): return 0.6 * exp((v+57)/13.5)
    #hinf   = lambda v: alphah(v) / (alphah(v) + betah(v))
    def hinf(v): return 1./(1+exp((v+57)/hDenom))
    def tauh(v): return 1. / (alphah(v) + betah(v))
    ENa = 35.  # Na reversal potential [mV]

    # conductance values [units: nS]
    gKLT1 = KLTfrac[0]*gTot1/dinf(vRest)
    gKLT2 = KLTfrac[1]*gTot2/dinf(vRest)
    gKHT = 0.3*gNa  # using same ratio as Funabiki (450/1500)
    glk1 = gTot1 - gKLT1*dinf(vRest)
    glk2 = gTot2 - (gKLT2*dinf(vRest) + gNa*minf(vRest)
                    * hinf(vRest) + gKHT*ninf(vRest))

    # leak reversal potentials [so compartments are isopotential at rest]
    Elk1 = vRest+(1./glk1)*(gKLT1*dinf(vRest)*(vRest-EK))
    Elk2 = vRest+(1./glk2)*(gKLT2*dinf(vRest)*(vRest-EK) + gKHT *
                            ninf(vRest)*(vRest-EK) + gNa*minf(vRest)*hinf(vRest)*(vRest-ENa))

    # create synaptic input
    t = arange(tStart, tEnd, 1.e-4)
    gSyn = txt_to_list(1, ipd, lin_interp_fact)
    # save to txt file
    try:
        savetxt("C_Intermediate_Output/NMfile-%s.txt" %
               (str(getpid())), gSyn, fmt="%f")
    except Exception as e:
        print(e)
        exit(1)

    # create command line string (c code already compiled in main)
    executable = './twoCptODE'

    # run c code
    runIt = executable
    runIt += ' ' + str(writeData)
    runIt += ' ' + str(tEnd)
    runIt += ' ' + str(dt)
    runIt += ' ' + str(cap1) + ' ' + str(cap2)
    runIt += ' ' + str(glk1) + ' ' + str(glk2)
    runIt += ' ' + str(0.) + ' ' + str(gNa)   # Na only in cpt2
    runIt += ' ' + str(0.) + ' ' + str(gKHT)  # KHT only in cpt2
    runIt += ' ' + str(gKLT1) + ' ' + str(gKLT2)
    runIt += ' ' + str(Elk1) + ' ' + str(Elk2)
    runIt += ' ' + str(gAx)
    runIt += ' ' + str(hDenom)
    runIt += ' ' + str(getpid())

    system(runIt)
    
    # load data and plot
    try:
        file = open("C_Intermediate_Output/Voltages-gNa=%.3f-%s.txt" %
                (gNa, str(getpid())), "r")
    except Exception as e:
        print(e)
        exit(1)
    voltage_file = file

    # Try to read in NM file. [Occasionally, there have been issues with this which is why there is a lot of code here.]
    valid = False
    tries = 0
    while not valid and tries < 10:
        try:
            x = [[float(item) for item in line.split(" ")] for line in file]
            valid = True
        except Exception as e:
            print("Error:", e)
            pass
    if not valid:
        print("problem with file I/O. Skipping this parameter set.")
        return -1

    x = array(x)
    file.close()
    t = x[:, 0]
    v1 = x[:, 1]
    v2 = x[:, 2]

    make_plot(t, v1, v2, couple12, couple21, hDenom, Iteration=iteration,IPD=ipd)


def twoCptODE(t, x, couple12, couple21, DC, AC, f, gna, hDenom_):
    """Function twoCptODE: Definition of the two compartment differential equation 

    Args:
        t (list[float]): List of time values (not currently used)
        x (list[float]): List of initial values
        couple12 (float): forward coupling parameter
        couple21 (float): reverse coupling parameter
        DC (float): input DC value
        AC (float): input AC value
        f (_type_): frequency value
        gna (_type_): sodium conductance parameter
        hDenom_ (_type_): hDenom parameter

    Returns:
        list[float]] list of delta values
    """

    # inputs:
    # t = time [units: ms]
    # x = voltage and gating variables
    v1 = x[0]  # cpt1 voltage
    v2 = x[1]  # cpt2 voltage
    d1 = x[2]  # cpt1 KLT activation
    d2 = x[3]  # cpt2 KLT activation
    n = x[4]  # cpt2 KHT activation
    m = x[5]  # cpt2 Na activation
    h = x[6]  # cpt2 Na inactivation

    # parameters that we will want to vary at some point
    # forward and backward coupling constants #
    #couple12 = couple[0]
    #couple21 = couple[1]

    # Na maximal conductance [nS]
    gNa = gna  # 1500.

    # KLT fraction
    KLTfrac = [0, 0]  # [.55 , .5]
    # NEW v v v
    hDenom = hDenom_

    # fixed parameter values #
    areaRatio = 20./2400.  # Funabiki Table 3
    vRest = -62.  # [units:mV] 
    R1 = 5  # [units: MegaOhms]
    tauExp = 0.1 # [units:ms] 

    # Passive conductance [units: nS] #
    gAx = (1000./R1) * couple21 / (1.-couple12*couple21)  # axial conductance #
    gTot1 = gAx * (1./couple21 - 1.)  # cpt1 total conductance
    gTot2 = gAx * (1./couple12 - 1.)  # cpt2 total conductance

    # capacitance using separation of time scales argument [units: pF] #
    cap1 = tauExp * (1-couple12*couple21) * (gTot1 + gAx)  # cpt1 capacitance
    cap2 = areaRatio * cap1  # cpt2 capacitance

    # KLT gating # Funabiki Table 2 #
    def alphad(v): return 0.20 * exp((v+60.)/21.8)
    def betad(v): return 0.17 * exp(-(v+60.)/14.)
    def dinf(v): return alphad(v) / (alphad(v) + betad(v))
    def taud(v): return 1. / (alphad(v) + betad(v))
    EK = -75.  # K reversal potential [mV]

    # KHT gating # Funabiki Table 2 #
    def alphan(v): return 0.110 * exp((v+19.)/9.1)
    def betan(v): return 0.103 * exp(-(v+19.)/20.)
    def ninf(v): return alphan(v) / (alphan(v) + betan(v))
    def taun(v): return 1. / (alphan(v) + betan(v))

    # Na gating # Funabiki Table 2 #
    def alpham(v): return 3.6 * exp((v+34)/7.5)
    def betam(v): return 3.6 * exp(-(v+34)/10.0)
    def minf(v): return alpham(v) / (alpham(v) + betam(v))
    def taum(v): return 1. / (alpham(v) + betam(v))
    def alphah(v): return 0.6 * exp(-(v+57)/18.0)
    def betah(v): return 0.6 * exp((v+57)/13.5)
    # OLD hinf   = lambda v: alphah(v) / (alphah(v) + betah(v))
    # NEW hinf v v v
    def hinf(v): return 1./(1+exp(+(v+57)/hDenom))
    def tauh(v): return 1. / (alphah(v) + betah(v))
    ENa = 35.  # Na reversal potential [mV]

    # conductance values [units: nS]
    gKLT1 = KLTfrac[0]*gTot1/dinf(vRest)
    gKLT2 = KLTfrac[1]*gTot2/dinf(vRest)
    # gNa defined above #
    gKHT = 0.3*gNa  # using same ratio as Funabiki (450/1500)
    glk1 = gTot1 - gKLT1*dinf(vRest)
    glk2 = gTot2 - (gKLT2*dinf(vRest) + gNa*minf(vRest)
                    * hinf(vRest) + gKHT*ninf(vRest))

    # temperature adjustment [Funabiki Table 2]
    Q10 = 2.5  # Q10 factor
    temp = 40.  # temperature [C]
    phi = Q10**((temp-23.)/10.)

    # leak reversal potentials [so compartments are isopotential at rest]
    Elk1 = vRest+(1./glk1)*(gKLT1*dinf(vRest)*(vRest-EK))
    Elk2 = vRest+(1./glk2)*(gKLT2*dinf(vRest)*(vRest-EK) + gKHT *
                            ninf(vRest)*(vRest-EK) + gNa*minf(vRest)*hinf(vRest)*(vRest-ENa))

    # currents
    Ilk1 = glk1*(v1-Elk1)
    Ilk2 = glk2*(v2-Elk2)
    IKLT1 = gKLT1*d1*(v1-EK)
    IKLT2 = gKLT2*d2*(v2-EK)
    IKHT2 = gKHT*n*(v2-EK)
    INa2 = gNa*m*h*(v2-ENa)

    eSyn = 0
    # stimlus
    s = (DC + AC*sin(2.*pi*t*f/1000.)) * (v1 - eSyn)
    if visited:
        stim_list[t] = s

    # ODEs
    dv1 = -(Ilk1 + IKLT1 + gAx*(v1-v2) + s) / cap1
    dv2 = -(Ilk2 + IKLT2 + IKHT2 + INa2 + gAx*(v2-v1)) / cap2
    dd1 = phi * (alphad(v1)*(1.-d1) - betad(v1)*d1)
    dd2 = phi * (alphad(v2)*(1.-d2) - betad(v2)*d2)
    dn = phi * (alphan(v2)*(1.-n) - betan(v2)*n)
    dm = phi * (alpham(v2)*(1.-m) - betam(v2)*m)
    dh = phi * (hinf(v2)-h) / tauh(v2)

    dx = [dv1, dv2, dd1, dd2, dn, dm, dh]
    return dx


def main_sin(param_dict):
    """Function main_sin: plot and save voltage traces for the "sinusoidal" method

    Args:
        param_dict (dict): dictionary of parameters needed to run simulation

    Returns:
        None
    """
    complete_parameters = {}
    for key in param_dict:
        if key != 'sync_dict' and key != 'num_to_calc' and key != 'time' and key != 'gna_bisection_precision_range':
            complete_parameters[key] = param_dict[key]

    model = param_dict['model']

    global stim_list
    stim_list = {}
    global visited
    visited = 0

    # coupling parameters
    couple12 = param_dict['couple12']
    couple21 = param_dict['couple21']
    # read in other parameters
    if 'init-pass-AC' in param_dict and 'init-pass-DC' in param_dict:
        init_pass_AC = param_dict['init-pass-AC']
        init_pass_DC = param_dict['init-pass-DC']
    DC = param_dict['DC']
    AC = param_dict['AC']
    f = param_dict['freq']
    gNa = param_dict['gNa']
    hDenom = param_dict['hDenom']

    print("Generating plot for %s" % ("mode = sin | AC=%.1f | DC=%.1f | c12=%.2f | c21=%.2f | gNa=%.2f | hdenom=%.1f" % (
        AC, DC, couple12, couple21, gNa, hDenom)))

    # time parameters
    tStart = 0.
    tEnd = 20.
    # tSolve # optional. if want to solve at specific time points

    if model != 'twoCptODE':
        raise AssertionError(
            "Program not set up to accept non-twoCptODE model.")

    # Run first with no input to get initial values for "intermediate" init values
    sol = solve_ivp(twoCptODE, [0., 100.], [-68., -68., .3, .3, 0., 0., .8], args=(
        couple12, couple21, 0., 0., 0., gNa, hDenom), method='BDF', rtol=1e-6)
    x0 = sol.y[:, -1]

    # If user asked for it, get intermediate initial values
    if param_dict['init-values'] == "run-before":
        sol = solve_ivp(twoCptODE, [tStart, tEnd], x0, args=(
            couple12, couple21, init_pass_DC, init_pass_AC, f, gNa, hDenom), method='BDF', rtol=1e-6)
        x0 = sol.y[:, -1]

    # Calculate ODE in earnest with whatever x0 is
    # [may be no input initial values or intermediate initial values]
    visited = 1
    if model == 'twoCptODE':
        sol = solve_ivp(twoCptODE, [tStart, tEnd], x0, args=(
            couple12, couple21, DC, AC, f, gNa, hDenom), method='BDF', rtol=1e-6)
    elif model == 'funabikiODE':
        raise AssertionError("Program not set up to accept funabikiODE.")

    t = sol.t
    [v1, v2, d1, d2, n, m, h] = sol.y

    make_plot(t, v1, v2, couple12, couple21, hDenom, AC=AC,
              DC=DC, init_values_mode=param_dict['init-values'])


def make_plot(t, v1, v2, couple12, couple21, hDenom, AC=None, DC=None, Iteration=None, IPD=None, init_values_mode=None):
    """Function make_plot

    Args:
        t (list[float]): vector of time values
        v1 (list[float]): vector of compartment 1 voltage values
        v2 (list[float]): vector of compartment 2 voltage values
        couple12 (float): forward coupling parameter
        couple21 (float): reverse coupling parameter
        hDenom (float): hDenom parameter
        AC (float, optional): input AC value used when plotting graphs for "sinusoidal" mode. Defaults to None.
        DC (float, optional): input DC value used when plotting graphs for "sinusoidal" mode. Defaults to None.
        Iteration (int, optional): iteration number when plotting graphs with "synaptic" mode. Defaults to None.
        IPD (float, optional): IPD (takes values from 0-in-phase to 0.5-out-of-phase) when plotting graphs with "synaptic" mode. Defaults to None.
        init_values_mode (str in {'no-input', 'run-before'}, optional): the method of getting intial values. Defaults to None.

    Returns: 
        None
    """
    plt.cla()
    plot(t, v2, linewidth=1.5, color="purple", label=r"$v_2$")
    plot(t, v1, linewidth=1.5, color="orange", label=r"$v_1$")
    #for i in range(t.size):
    #    print(t[i],v1[i],v2[i])

    plt.ylim(-75, 30)
    plt.xlabel("Time (ms)")
    plt.ylabel("Voltage (mV)")
    if AC is not None:
        plt.title(title := "AC=%.2f + DC=%.2f + c12=%.2f + c21=%.2f + hD = %.2f + mode=sin + init-values-mode=%s + datetime=%s" %
                  (AC, DC, couple12, couple21, hDenom, init_values_mode, cur_time[:-4]))
    else:
        plt.title(title := "IPD=%.2f + c12=%.2f + c21=%.2f + hD=%.2f + mode=syn  datetime=%s" % (IPD,
                  couple12, couple21, hDenom, cur_time[:-4]))
    plt.legend()
    if not exists('Figures'):
        mkdir('Figures') 
    dir_listing = set([f for f in listdir("Figures/")])
    if(dir_name := cur_time.split("..")[0]) not in dir_listing:
        system("mkdir Figures/%s" % (dir_name))
    plt.savefig("Figures/%s/" % (dir_name) +
                title + ".png", bbox_inches="tight")
    # print("Finished plotting.")


def main():
    """Function main: The main user interface for this file

    Returns:
        None
    """
    global cur_time, gNa_vals
    cur_time = datetime.now().strftime(
        "DATE_%m-%d-%Y_TIME_%H.%M.%S..%f")[:-4]
    chdir(abspath(__file__)[:-14]) # Change into the lower-level directory for consistency
    gNa_vals = read_csv(open("gNa_values.csv", "r"))

    cmd_parser = ArgumentParser(
        description='Simulate Neural Voltages')

    subparsers = cmd_parser.add_subparsers()

    cmd_parser.add_argument("--mode", type=str.lower,
                            required=True, choices=['syn', 'sin'])

    cmd_parser.add_argument("--init-values", type=str.lower,
                            required=False, choices=['no-input', 'run-before'])

    cmd_parser.add_argument("-L", action='store_true', required=False)
    args = vars(cmd_parser.parse_args())

    if args['mode'] == 'sin' and args['init_values'] is None:
        cmd_parser.error("--mode sin requires --init-values to be given.")

    if args['mode'] == 'syn' and args['init_values'] is not None:
        cmd_parser.error("--mode syn does not take --init-values argument.")

    if args['L']:
        # Only use Latex if user explicitly asked for it
        plt.rcParams['text.usetex'] = True

    if args['mode'] == "syn":
        #system("cd ../C; make; cd ../Plotting")
        if not exists('C_Intermediate_Output'):
            mkdir('C_Intermediate_Output') 
        system("make;")
        for ipd_arr in arange(0.,0.51,0.1):
            args_dict = {
                'freq': 4000,
                'couple12': 0.9,
                'couple21': 0.5,
                'hDenom': 7.7,
                'ipd': ipd_arr,
                'mode': args['mode'],
                'iteration-number': 1,
                'lin_interp_fact': 1 # This should stay at 1; the base linear interpolation factor for synaptic files.
            }
            gNa = get_gNa_value(
                        args_dict['couple12'], args_dict['couple21'], args_dict['hDenom'])

            args_dict['gNa'] = gNa
            main_syn(args_dict['iteration-number'], args_dict)

    elif args['mode'] == "sin":
        # IMPORTANT --- Put desired arguments here:
        for dc in arange(0, 1):
            for ac in arange(20, 80, 10):
                args_dict = {
                    'freq': 4000,
                    'AC': ac,
                    'DC': dc,
                    'couple12': 0.9,
                    'couple21': 0.5,
                    'model': 'twoCptODE',
                    'hDenom': 7.7,
                    'mode': args['mode'],
                    'init-values': args['init_values'],
                    'init-pass-AC': ac*2,
                    'init-pass-DC': dc
                }
                gNa = get_gNa_value(
                    args_dict['couple12'], args_dict['couple21'], args_dict['hDenom'])
                args_dict['gNa'] = gNa
                main_sin(args_dict)


if __name__ == "__main__":
    main()
