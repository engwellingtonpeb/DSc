%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% Prep to run a RL agent training                                         %
%                                                                         %
%=========================================================================%

clc
clearvars
close all hidden
global opt
pathconfig

datestr(now)
SimuInfo=struct; %information about simulation parameters
import org.opensim.modeling.*

SimuInfo.DummySimulation='false'; 

if strcmp(SimuInfo.DummySimulation,'true')
    disp('[!!!RUNNING A DUMMY SIMULATION!!!]')
end

% %pacitente 01
% load('29_Oct_2023_20_15_55_GA.mat') % sintonia do oscilador 2 dias 
% ModelParams=x(12,:);% sintonia do oscilador 2 dias 

% Prompt user to choose how to provide ModelParams
choice = input('Choose option:\n1 - Load vector of parameters from a file\n2 - Type the vector manually\nEnter choice (1 or 2): ');

switch choice
    case 1
        % Option 1: Load vector of parameters from a file
        [fileName, pathName] = uigetfile('*.mat', 'Select the parameter file');
        if isequal(fileName, 0)
            disp('File selection canceled. Exiting...');
            return;
        end
        fullFilePath = fullfile(pathName, fileName);
        data = load(fullFilePath);

        % Ensure the file contains 'cost' and 'history' variables
        if isfield(data, 'cost') && isfield(data, 'history')
            % Find the minimum cost and corresponding index for each run (column)
            [minCostValues, minIndices] = min(data.cost, [], 1); % Min along the first dimension (rows)
            
            % Identify the parameter set with the absolute minimum cost
            [minCost, bestColumn] = min(minCostValues);
            bestRow = minIndices(bestColumn);

            % Extract the parameter vector from 'history' for the best row and column
            ModelParams = data.history(bestRow, :, bestColumn);
            disp('Loaded ModelParams from file with minimum cost.');
            
            % Display the minimum cost
            fprintf('Minimum cost: %f\n', minCost);
        else
            error('The selected file does not contain the required ''cost'' and ''history'' variables.');
        end
        
    case 2
        % Option 2: Type the vector manually
        ModelParams = input('Enter the parameter vector (e.g., [1, 2, 3, ...]): ');
        
    otherwise
        error('Invalid choice. Please choose either 1 or 2.');
end

% Now ModelParams is set based on the selected option
disp('ModelParams set as:');
disp(ModelParams);


%% Controller Synthesis


[LinStabilityFlag, K] = ControllerSynthesis(SimuInfo, ModelParams);



if LinStabilityFlag
    %% Tremor Simulation for Tunning 

    %Time
    SimuInfo.Ts=1e-3;
    SimuInfo.Tend=30;
    SimuInfo.TStim_ON=5; %e-stim initial time on the simulations


    %Plotting 
    SimuInfo.PltFlag='on'; %[on | off]
    SimuInfo.PltResolution=50;
    
    %Params tuned by optimization
    SimuInfo.ModelParams=ModelParams;

    %Tremor
    SimuInfo.Tremor='on' %[on | off]

    %Electrical Stimulation
    SimuInfo.FES='on'; %[on | off]
    SimuInfo.FESProtocol='RL' %[cc - O.L. co-contraction | op - O.L. out-of-phase...
    %                      RL - Reinforcement Learning]
    
    SimuInfo.TremorEnergy=[];
    SimuInfo.StoreStim='on';


    
    %Config Simulations using Matlab Integrator
    SimuInfo.timeSpan = [0:SimuInfo.Ts:SimuInfo.Tend];
    integratorName = 'ode1'; 
    SimuInfo.integratorName=integratorName;
    integratorOptions = odeset('RelTol', 1e-3, 'AbsTol', 1e-3,'MaxStep', 10e-3);
    
    
     %Distribuição de um paciente especíico


    % Save the current working directory
    originalFolder = pwd;
    
    % Change to the target folder
    cd(targetFolder);
    
    % Prompt the user to select the tremor distribution .mat file
    [file2, path2] = uigetfile('*.mat', 'Select the tremor distribution .mat file');
    
    % Return to the original directory
    cd(originalFolder);
    
    % Load the selected file if the user didn't cancel the selection
    if ischar(file2)
        fullPath2 = fullfile(path2, file2);
        data2 = load(fullPath2); % Load the tremor distribution file
    else
        error('File selection was canceled. Please try again.');
    end
    
    % Assign P field of data2 to SimuInfo.P if it exists
    if isfield(data2, 'P')
        SimuInfo.P = data2.P;
    else
        error('Field "P" not found in the selected file.');
    end


    SimuInfo.P=data2.P;






    SimuInfo.Kz=c2d(K,SimuInfo.Ts);
    
    [Ak,Bk,Ck,Dk]=ssdata(SimuInfo.Kz);
    
    SimuInfo.Ak=Ak;
    SimuInfo.Bk=Bk;
    SimuInfo.Ck=Ck;
    SimuInfo.Dk=Dk;
    

    
    
    PhiRef=0;%makedist('Normal','mu',0,'sigma',4);
    PsiRef=20;%makedist('Normal','mu',60,'sigma',0);
    
    SimuInfo.Setpoint=[PhiRef, PsiRef];
  
    
    osimState=osimModel.initSystem();
    
    %% Model elements identification
    
    Nstates       = osimModel.getNumStateVariables();
    Ncontrols     = osimModel.getNumControls();
    Ncoord        = osimModel.getNumCoordinates(); 
    Nbodies       = osimModel.getNumBodies();
    model_muscles = osimModel.getMuscles();
    Nmuscles      = model_muscles.getSize();
    
    SimuInfo.Nstates=Nstates;
    SimuInfo.Ncontrols=Ncontrols;
    SimuInfo.Ncoord=Ncoord;
    SimuInfo.Nbodies=Nbodies;
    SimuInfo.model_muscles=model_muscles;
    SimuInfo.Nmuscles=Nmuscles;
    
    % get model states
    states_all = cell(Nstates,1);
    for i = 1:Nstates
    states_all(i,1) = cell(osimModel.getStateVariableNames().getitem(i-1));
    end


    % adjust number of states considering activation dynamics implemented
    % on MATLAB
    SimuInfo.Nstates=Nstates+25;

    % Create the Initial State matrix from the Opensim state
    numVar = osimState.getY().size();
    SimuInfo.numVar=numVar;
    InitStates = zeros(numVar,1);
    for i = 0:1:numVar-1
        InitStates(i+1,1) = osimState.getY().get(i); 
    end
      activations=zeros(7,1);
      oscillator=zeros(4,1);
      activationsFES=zeros(7,1);
      fatigueDynamics=ones(7,1);


      InitStates=[InitStates;...
                  activations;...
                  oscillator;...
                  activationsFES;...
                  fatigueDynamics];
      
      SimuInfo.InitStates=InitStates;
    

  
    
    SimuInfo.states_all=states_all;
    
    % get model muscles (controls)
    Muscles = osimModel.getMuscles();  
    controls_all = cell(Ncontrols,1);
    for i = 1:Ncontrols
        currentMuscle = Muscles.get(i-1);
        controls_all(i,1) = cell(currentMuscle.getName());
    end
    
    SimuInfo.controls_all=controls_all;
    
    
    % get model coordinates
    Coord = osimModel.getCoordinateSet();
    Coord_all = cell(Ncoord,1);
    for i = 1:Ncoord
        currentCoord = Coord.get(i-1);
        Coord_all(i,1) = cell(currentCoord.getName());
    end
    
    SimuInfo.Coord_all=Coord_all;
    

    %% Prep Simulation
    osimModel.computeStateVariableDerivatives(osimState);
    osimModel.equilibrateMuscles(osimState); %solve for equilibrium similiar
    
    %Controls function
    controlsFuncHandle = @OsimControlsFcn;





%% Environment for RL Training

eStimInputs=6; % parameter number of electrical stimulator
numStatesFromPatient=4; % number of states from biomechanical model or voluntary+observer

%Observation Info
obsInfo= rlNumericSpec([numStatesFromPatient 1]);
obsInfo.Name = 'observation';
obsInfo.Description = 'Phi, Psi, Phidot, Psidot';

%Action Info
actInfo=rlNumericSpec([eStimInputs 1], 'LowerLimit', [4e-3;  4e-3;  4e-3;  4e-3; 150e-6; 10],...
                                       'UpperLimit', [40e-3; 40e-3; 40e-3; 40e-3;500e-6; 40]);
actInfo.Name = 'action';
actInfo.Description = 'I_ch1, I_ch2, I_ch3, I_ch4, pw, f ';


StepHandle=@(Action,LoggedSignals)MyStepFunction(Action,LoggedSignals,SimuInfo,osimModel,osimState);
ResetHandle=@()MyResetFunction(osimModel,osimState,SimuInfo);

env = rlFunctionEnv(obsInfo,actInfo,StepHandle,ResetHandle)


end