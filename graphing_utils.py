"""
PURPOSE: Read an NM library file into a list
PARAMETERS: iteration --- the iteration number of the NM library file
			IPD --- the IPD value of the NM library file
			lin_interp_fact --- the factor by which to linearly interpolate the NM library file
RETURNS: g --- the list of conductance values from the NM library file
"""
def txt_to_list(iteration, IPD, lin_interp_fact):
    """Function txt_to_list: Read an NM library file into a list

    Args:
        iteration (int in [0, 5]): the iteration number of the NM library file 
        IPD (float in [0, 0.5]): the IPD value of the NM library file
        lin_interp_fact (int): the factor by which to linearly interpolate the NM library file

    Returns:
        list[float]: the list of conductance values from the NM library file
    """
    filename = None
    try:  # try to open the file
        filename = "%d_ITD_%.2f.nmlib" % (iteration, IPD)
        fp = open(filename, "r")
    except Exception as e:
        print("Error:", e)
        print("Error: cannot find path to the NM library files. Exiting. (Tried to open '%s')" % (filename))
        exit(0)
    g = []  # list of conductance values
    this_line_val = None
    last_line_val = float(fp.readline().split(" ")[1])
    g.append(last_line_val)
    for line in fp:  # read the rest of the file
        this_line_val = float(line.split(" ")[1])
        for i in range(lin_interp_fact):
            g.append(last_line_val + i *
                     ((this_line_val - last_line_val)/lin_interp_fact))
        last_line_val = this_line_val
    return g
