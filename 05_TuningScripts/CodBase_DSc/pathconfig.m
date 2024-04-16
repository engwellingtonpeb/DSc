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


name = getenv('COMPUTERNAME'); 


if name == 'ENGWELLPC'

    addpath('..\Tuning_Feature')
    addpath('\Users\engwe\Desktop\DSc_v4\02_Coletas')
    addpath('\Users\engwe\Desktop\DSc_v4\03_ODE_Solvers')
    addpath('\Users\engwe\Desktop\DSc_v4\04_DMDc_IDTF\simulations')

elseif name=='MARCOPOLO'

    addpath('..\Tuning_Feature')
    addpath('\Users\Wellington\Desktop\DSc_v4\02_Coletas\')
    addpath('\Users\Wellington\Desktop\DSc_v4\03_ODE_Solvers\')


elseif name=='ENGWELLSURFACE'

    addpath('..\Tuning_Feature')
    addpath('\02_DSc_v4\02_Coletas\')
    addpath('\02_DSc_v4\03_ODE_Solvers\')
    addpath('\02_DSc_v4\04_DMDc_IDTF\simulations\')
end