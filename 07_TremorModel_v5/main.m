%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% v5 - Individualized tremor model and simulation scripts.                %
%      The model is parametrized using GA optimization, electrical        %
%      stimulation dynamics was embbeded and it can be used as            %
%      environment for RL agent training. RL agent will control           %
%      electrical stimulator                                              %
%=========================================================================%

clc
clear all
close all hidden
pathconfig
import org.opensim.modeling.*

prompt="Select an operation mode:\n" + ...
    "(1) - Individualized Tremor Model Tuning \n" + ...
    "(2) - Individualized Tremor Model Simulation \n" + ...
    "(3) - Open-Loop e-stim Simulation \n" + ...
    "(4) - e-stim RL controller Training \n" + ...
    "(5) - e-stim MPC/RL controller design \n \n" + ...
    "Option:";

opt=input(prompt);


switch opt

    case 1 
    %Individualized Tremor Model TUNING

        % get and prepare patient data
        getPatientSignals;

        % get Optimization Routine to run
        runOptimizationTuning;

        % save results
        saveTunedPTModel;

    case 2 
    %Individualized Tremor Model SIMULATION

        % get patient parameters or use a dummy parameter vector
        getSimulationParams;

        % run only tremor simulation without ES inputs
        runIndividualizedTremorSimulation;

    case 3 
    %OPEN LOOP e-stim Simulation

        % run only tremor simulation PRESET ES inputs
        runIndividualizedTremorSimulationwithES;

    case 4 
    %e-stim RL CONTROLLER TRAINNING

        %get patient parameters or use a dummy parameter vector
        getSimulationParams;

        %RL Controller Trainning
        runRLControllerTrainning



    case 5

        disp('Module still being developed...')
        disp('   ')

end

disp("That's all folks!")
disp('PEB/COPPE/UFRJ')