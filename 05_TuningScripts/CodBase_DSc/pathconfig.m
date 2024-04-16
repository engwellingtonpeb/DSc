%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% Set paths and configurations to run on different PCs the FD simulations %
%                                                                         %
%=========================================================================%


clear all
clc
close all

import org.opensim.modeling.*

name = getenv('COMPUTERNAME'); 


if name == 'ENGWELLPC'

    addpath('..\Tuning_Feature')
    addpath('\Users\engwe\Desktop\DSc_v4\02_Coletas')
    addpath('\Users\engwe\Desktop\DSc_v4\03_ODE_Solvers')
    addpath('\Users\engwe\Desktop\DSc_v4\04_DMDc_IDTF\simulations')

    osimModel=Model('C:\Users\engwe\Desktop\DSc_v4\01_ModelFilesOsim41\MoBL-ARMS Upper Extremity Model\Benchmarking Simulations\4.1 Model with Millard-Schutte Matched Curves\MOBL_ARMS_module2_4_allmuscles_ignoreactivation.osim');
    

elseif name=='MARCOPOLO'

    addpath('..\Tuning_Feature')
    addpath('\Users\Wellington\Desktop\DSc_v4\02_Coletas\')
    addpath('\Users\Wellington\Desktop\DSc_v4\03_ODE_Solvers\')
    addpath('\Users\Wellington\Desktop\DSc_v4\04_DMDc_IDTF\simulations\')

    osimModel=Model('C:\Users\Wellington\Desktop\DSc_v4\01_ModelFilesOsim41\MoBL-ARMS Upper Extremity Model\Benchmarking Simulations\4.1 Model with Millard-Schutte Matched Curves\MOBL_ARMS_module2_4_allmuscles_ignoreactivation.osim');
    

elseif name=='ENGWELLSURFACE'

    addpath('..\Tuning_Feature')
    addpath('\02_DSc_v4\02_Coletas\')
    addpath('\02_DSc_v4\03_ODE_Solvers\')
    addpath('\02_DSc_v4\04_DMDc_IDTF\simulations\')

    osimModel=Model('D:\02_DSc_v4\01_ModelFilesOsim41\MoBL-ARMS Upper Extremity Model\Benchmarking Simulations\4.1 Model with Millard-Schutte Matched Curves\MOBL_ARMS_module2_4_allmuscles_ignoreactivation.osim');
    
end