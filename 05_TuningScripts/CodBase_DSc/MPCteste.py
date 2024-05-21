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
         
         # stim = [1x7 Amplitudes | 1x1 pulse width| 1x1 frequency]
         
         stimu = [0, 40e-3, 40e-3, 0, 0, 0, 0, 250e-6, 30]


    else:
        stimu = [0, 0, 0, 0, 0, 0, 0, 250e-6, 30]


    return stimu


ReturnList = PulseGenerator(time)
