%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This script runs FD simulation of individualized tremor handling        %
% OpenSim as a control theory plant and applying OPEN-LOOP E-Stim         %
% to selected muscles                                                     %
%                                                                         %
%=========================================================================%



 %% Run Simulation
tic
    motionData = IntegrateOsimPlant(osimModel,integratorName,SimuInfo,integratorOptions);
elapsedTime=toc
SimuInfo.elapsedTime=elapsedTime;