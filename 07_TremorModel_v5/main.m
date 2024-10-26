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
    "(3) - Open-Loop CC e-stim Simulation \n" + ...
    "(4) - Pathological Tremor / ES - Identification \n"+...
    "(5) - e-stim RL controller Training and Simulation \n" + ...
    "(6) - e-stim RL controller TEST and Simulation \n" + ...
    "(7) - e-stim MPC/RL controller design and Simulation \n" + ...
    "(8) - e-stim ESC controller \n \n" + ...
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
    % Tremor/FES - Identification Dynamics
        

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