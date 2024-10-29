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
opengl('save', 'software');

clc
clear all
close all hidden
pathconfig
import org.opensim.modeling.*
datestr(now)


prompt="Select an operation mode:\n" + ...
    "(1) - Individualized Tremor Model Simulation \n" + ...
    "(2) - Individualized Tremor Model Tuning \n" + ...
    "(3) - Open-Loop e-stim (TEST) \n" + ...
    "(4) - E-STIM 2 TREMOR Identification \n"+...
    "(5) - RL Controller for e-stim (TRAINING)  \n" + ...
    "(6) - RL Controller for e-stim (TEST) \n" + ...
    "(7) - MPC Controller Design and Simulation \n" + ...
    "(8) - ESC Controller (TEST) \n \n" + ...
    "Option:";

opt=input(prompt);


switch opt

    case 1 
    %Individualized Tremor Model SIMULATION
        
        % set patient parameters or use a dummy parameter vector
        setOnlyTremorSimulationParams;

        % run only tremor simulation without ES inputs
        runIndividualizedTremorSimulation;
        

    case 2 
    % Individualized Tremor Model TUNING
        
        % get and prepare patient data
        getPatientSignals;

        % get Optimization Routine to run
        runOptimizationTuning;

        % save results
        saveTunedPTModel;


    case 3 
    %OPEN LOOP CC e-stim Simulation

        % set patient parameters for e-stim
        setFESParamsSimulation;

        % run only tremor simulation PRESET ES inputs
        runFESOLSimulation;

    case 4
    % e-stim 2 tremor - Identification Dynamics
        
        %Run e-stim simulation an save data
        IDTFConfig_estim2tremor
        runFESCLSimulation

        %DMDc


        %SINDYc


        %Save model


    case 5 
    %e-stim RL CONTROL LAW TRAINNING

        %get patient parameters or use a dummy parameter vector
        getSimulationParams_V2;

        %RL Controller Trainning
        runRLControllerTrainning

    case 6 
    %e-stim RL CONTROL LAW TESTING

        %get patient parameters or use a dummy parameter vector
        getSimulationParams;

        %RL Controller Testing
        runRLControllerTesting



    case 7

        disp('Module still being developed...')
        disp('   ')


    case 8
        %e-stim ESC CONTROL LAW 

        setFESParamsSimulation
        runFESCLSimulation

end

disp("That's all folks!")
disp('PEB/COPPE/UFRJ')