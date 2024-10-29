%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This script runs FD simulation of individualized tremor handling        %
% OpenSim as a control theory plant and applying CLOSED-LOOP E-Stim       %
% to selected muscles                                                     %
%                                                                         %
%=========================================================================%



 %% Run Simulation
tic
motionData = IntegrateOsimPlant(osimModel,integratorName,SimuInfo,integratorOptions);
elapsedTime=toc


% Nome do campo a ser verificado
fieldName = 'StoreStim';
% Verifica a existência do campo e se o conteúdo é 'on'
if isfield(SimuInfo, fieldName) && strcmp(SimuInfo.(fieldName), 'on')

    % Declarando a variável global
    global e_stim;
    motionData.e_stim=e_stim;

end


SimuInfo.elapsedTime=elapsedTime;