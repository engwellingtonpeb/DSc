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

pathconfig

datestr(now)
SimuInfo=struct; %information about simulation parameters
import org.opensim.modeling.*


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


 [LinStabilityFlag, K] = ControllerSynthesis();


if LinStabilityFlag
    %% Tremor Simulation for Tunning 

    %Time
    SimuInfo.Ts=1e-3;
    SimuInfo.Tend=10;
    SimuInfo.TStim_ON=3; %e-stim initial time on the simulations


    %Plotting 
    SimuInfo.PltFlag='on'; %[on | off]
    SimuInfo.PltResolution=20;
    
    %Params tuned by optimization
    SimuInfo.ModelParams=ModelParams;

    %Tremor
    SimuInfo.Tremor='on' %[on | off]

    %Electrical Stimulation
    SimuInfo.FES='on'; %[on | off]
    SimuInfo.FESProtocol='RL' %[cc - O.L. co-contraction | op - O.L. out-of-phase...
    %                      RL - Reinforcement Learning]
    
    SimuInfo.TremorEnergy=[];


    
    %Config Simulations using Matlab Integrator
    SimuInfo.timeSpan = [0:SimuInfo.Ts:SimuInfo.Tend];
    integratorName = 'ode1'; 
    SimuInfo.integratorName=integratorName;
    integratorOptions = odeset('RelTol', 1e-3, 'AbsTol', 1e-3,'MaxStep', 10e-3);
    
    
    
    
    %Distribuição de um paciente especíico
    load('distrib_tremor_paciente01.mat') % paciente
    SimuInfo.w_tremor=0.1;


    SimuInfo.Kz=c2d(K,SimuInfo.Ts);
    
    [Ak,Bk,Ck,Dk]=ssdata(SimuInfo.Kz);
    
    SimuInfo.Ak=Ak;
    SimuInfo.Bk=Bk;
    SimuInfo.Ck=Ck;
    SimuInfo.Dk=Dk;
    
    SimuInfo.P=P;
    pd = makedist('Uniform','lower',1,'upper',length(P));
    SimuInfo.pd=pd;
    
    
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
      fatigueDynamics=zeros(7,1);


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
actInfo=rlNumericSpec([eStimInputs 1], 'LowerLimit', [10; 150e-6; 4e-3;  4e-3;  4e-3;  4e-3;],...
                                       'UpperLimit', [40; 500e-6; 40e-3; 40e-3; 40e-3; 40e-3;]);
actInfo.Name = 'action';
actInfo.Description = 'f, pw, I_ch1, I_ch2, I_ch3, I_ch4';


StepHandle=@(Action,LoggedSignals)MyStepFunction(Action,LoggedSignals,SimuInfo,osimModel,osimState);
ResetHandle=@()MyResetFunction(osimModel,osimState,SimuInfo);

env = rlFunctionEnv(obsInfo,actInfo,StepHandle,ResetHandle)

%% Creating DDPG trained agent
% 
% obsInfo = getObservationInfo(env);
% numObs = obsInfo.Dimension(1);
% actInfo =getActionInfo(env);
% numAct = actInfo.Dimension(1);
% 
% %CRITIC NETWORK
% L = 5; % number of neurons
% 
% 
% 
% statePath = [
%     featureInputLayer(numStatesFromPatient,'Normalization','none','Name','observation')
%     fullyConnectedLayer(L,'Name','fc1')
%     reluLayer('Name','relu1')
%     fullyConnectedLayer(L,'Name','fc2')
%     additionLayer(2,'Name','add')
%     reluLayer('Name','relu2')
%     fullyConnectedLayer(L,'Name','fc3')
%     reluLayer('Name','relu3')
%     fullyConnectedLayer(1,'Name','fc4')];
% 
% actionPath = [
%     featureInputLayer(eStimInputs,'Normalization','none','Name','action')
%     fullyConnectedLayer(L, 'Name', 'fc5')];
% 
% criticNetwork = layerGraph(statePath);
% criticNetwork = addLayers(criticNetwork, actionPath);
% 
% criticNetwork = connectLayers(criticNetwork,'fc5','add/in2');
% 
% %plot(criticNetwork)
% 
% criticOptions = rlRepresentationOptions('LearnRate',1e-3,'GradientThreshold',1,'L2RegularizationFactor',1e-4,'UseDevice',"cpu");
% 
% critic = rlQValueRepresentation(criticNetwork,obsInfo,actInfo,...
%     'Observation',{'observation'},'Action',{'action'},criticOptions);
% 
% % ACTOR
% 
% 
% actorNetwork = [
%     featureInputLayer(numStatesFromPatient,'Normalization','none','Name','observation')
%     fullyConnectedLayer(L,'Name','fc1')
%     reluLayer('Name','relu1')
%     fullyConnectedLayer(L,'Name','fc2')
%     reluLayer('Name','relu2')
%     fullyConnectedLayer(L,'Name','fc3')
%     reluLayer('Name','relu3')
%     fullyConnectedLayer(eStimInputs,'Name','fc4')
%     tanhLayer('Name','tanh1')
%     scalingLayer('Name','ActorScaling1','Scale',(max(actInfo.UpperLimit)),'Bias',.5)];
% 
% 
% 
% actorOptions = rlRepresentationOptions('LearnRate',1e-3,'GradientThreshold',1,'L2RegularizationFactor',1e-4,'UseDevice',"cpu");
% actor = rlDeterministicActorRepresentation(actorNetwork,obsInfo,actInfo,...
%     'Observation',{'observation'},'Action',{'ActorScaling1'},actorOptions);
% 
% 
% 
% 
% 
% % 3) DDPG algorithm for learning
% 
% agentOpts = rlDDPGAgentOptions(...
%     'SampleTime',SimuInfo.Ts,...
%     'TargetSmoothFactor',1e-1,...
%     'ExperienceBufferLength',1e6,...
%     'DiscountFactor',0.95,...
%     'NumStepsToLookAhead',4,...
%     'MiniBatchSize',32);
% agentOpts.NoiseOptions.Variance   = .1 ;
% agentOpts.NoiseOptions.VarianceDecayRate   = 1e-6;
% 
% % effectively creating the agent
% agent = rlDDPGAgent(actor,critic,agentOpts);
% 
% 
% 
% 
% %% Treinamento
% 
% % training the agent 
% 
% trainOpts = rlTrainingOptions(...
%     'MaxEpisodes', 5000, ...
%     'MaxStepsPerEpisode', 2e6, ...
%     'Verbose', true, ...
%     'Plots','none',...
%     'StopTrainingCriteria','AverageReward',...
%     'StopTrainingValue',66e6,...
%     'UseParallel',0,...
%     'SaveAgentCriteria',"EpisodeReward",...
%     'SaveAgentValue',1e5,...
%     'SaveAgentDirectory', pwd + "\Agents");
% 
% %close all hidden
end