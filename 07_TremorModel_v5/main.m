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

datestr(now)


prompt="Select an operation mode:\n" + ...
    "(1) - TUNE individualized tremor model \n" + ...
    "(2) - SIMULATE individualized tremor model\n" + ...
    "(3) - TEST Open-Loop Electrical Stimulation (CC/OP)\n" + ...
    "(4) - IDENTIFICATE e-stim TO tremor dynamics\n"+...
    "(5) - TRAIN RL  e-stim Controller \n" + ...
    "(6) - TEST RL e-stim Controller\n" + ...
    "(7) - MPC Controller Design and Simulation \n" + ...
    "(8) - TEST ESC Controller\n \n" + ...
    "Option:";
global opt
opt=input(prompt);


switch opt

    case 1 

        pathconfig

        % Individualized Tremor Model TUNING
        
        % get and prepare patient data
        getPatientSignals;
        
        % get Optimization Routine to run
        runOptimizationTuning;
        
        % save results
        saveTunedPTModel; 
         

    case 2 
        pathconfig
        %Individualized Tremor Model SIMULATION
        
        % set patient parameters or use a dummy parameter vector
        setOnlyTremorSimulationParams;

        % run only tremor simulation without ES inputs
        runIndividualizedTremorSimulation;


   
    case 3 
    %OPEN LOOP CC e-stim Simulation
        pathconfig
        % set patient parameters for e-stim
        setFESParamsSimulation;

        % run only tremor simulation PRESET ES inputs
        runFESOLSimulation;
        
        %Suppression Metrics
        e_stimAnalysis

    case 4
    % e-stim 2 tremor - Identification Dynamics
        pathconfig
        %Run e-stim simulation an save data
        IDTFConfig_estim2tremor
        runFESCLSimulation

        %DMDc
        DMDc_estim2tremor

        %SINDYc


        %Save model


    case 5 
    %e-stim RL CONTROL LAW TRAINNING
        pathconfig
        %get patient parameters or use a dummy parameter vector
        getSimulationParams_V2;
        %RL Controller Trainning
        runRLControllerTrainning

    case 6 
    %e-stim RL CONTROL LAW TESTING
        pathconfig
        %get patient parameters or use a dummy parameter vector
        getSimulationParams;
        %RL Controller Testing
        runRLControllerTesting

        %Suppression Metrics
        e_stimAnalysis



    case 7
        pathconfig
        disp('Module still being developed...')
        disp('   ')


    case 8
        %e-stim ESC CONTROL LAW 
        pathconfig
        setFESParamsSimulation
        runFESCLSimulation
        
        %Suppression Metrics
        e_stimAnalysis


end

disp("That's all folks!")
disp('PEB/COPPE/UFRJ')