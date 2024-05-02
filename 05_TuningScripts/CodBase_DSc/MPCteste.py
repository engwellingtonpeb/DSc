#=========================================================================#
#                   Federal University of Rio de Janeiro                  #
#                  Biomedical Engineering Program - COPPE                 #
#                   https://www.peb.ufrj.br/index.php/pt/                 #
#                                                                         #
# Advisor: Prof. Dr. Luciano L. Menegaldo                                 #
# Doctoral Candidate: Wellington C. Pinheiro MSc.                         #
#                                                                         #
#                                                                         #
# Description: This script is a test for the MPC class. To be called from #
#              the MATLAB main script. After all simulation work it will  #
#              be deployable on Raspberry PI.                             #
#=========================================================================#


import numpy as np



def PulseGenerator(time):
    # Pulse generator
    # Pulse width   

    if time<2:

        pw=np.array([250e-6, 100e-6, 100e-6, 100e-6, 100e-6, 100e-6,100e-6])

    else:

        pw=np.array([100e-6, 100e-6, 100e-6, 100e-6, 100e-6, 100e-6, 100e-6])

    return pw


pw= PulseGenerator(time)
ReturnList=[pw]