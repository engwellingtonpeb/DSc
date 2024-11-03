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


%pacitente 01
load('29_Oct_2023_20_15_55_GA.mat') % sintonia do oscilador 2 dias 
ModelParams=x(12,:);% sintonia do oscilador 2 dias 

%% Controller Synthesis


 [LinStabilityFlag, K] = ControllerSynthesis();


if LinStabilityFlag
    %% Tremor Simulation for Tunning 

    %Time
    SimuInfo.Ts=1e-3;
    SimuInfo.Tend=10;
    SimuInfo.TStim_ON=3; %e-stim initial time on the simulations


    %Plotting 
    SimuInfo.PltFlag='off'; %[on | off]
    SimuInfo.PltResolution=100;
    
    %Params tuned by optimization
    SimuInfo.ModelParams=ModelParams;

    %Tremor
    SimuInfo.Tremor='on'; %[on | off]

    %Electrical Stimulation
    SimuInfo.FES='on'; %[on | off]
    SimuInfo.FESProtocol='RL'; %[cc - O.L. co-contraction | op - O.L. out-of-phase...
    %                      RL - Reinforcement Learning]
    
    SimuInfo.TremorEnergy=[];


    
    %Config Simulations using Matlab Integrator
    SimuInfo.timeSpan = [0:SimuInfo.Ts:SimuInfo.Tend];
    integratorName = 'ode1'; 
    SimuInfo.integratorName=integratorName;
    integratorOptions = odeset('RelTol', 1e-3, 'AbsTol', 1e-3,'MaxStep', 10e-3);
    
    
    
    
    %Distribui��o de um paciente espec�ico
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
    
    SimuInfo
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


%% Creating DDPG trained agent

obsInfo = getObservationInfo(env);
numObs = obsInfo.Dimension(1);
actInfo =getActionInfo(env);
numAct = actInfo.Dimension(1);

% Optimized Number of Neurons per Layer
L = 64; % Increase number of neurons per layer for more expressive capacity

% CRITIC NETWORK
statePath = [
    featureInputLayer(numStatesFromPatient, 'Normalization', 'none', 'Name', 'observation')
    fullyConnectedLayer(L, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(L, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(L, 'Name', 'fc3')
    additionLayer(2, 'Name', 'add')
    reluLayer('Name', 'relu3')
    fullyConnectedLayer(1, 'Name', 'fc4')];

actionPath = [
    featureInputLayer(eStimInputs, 'Normalization', 'none', 'Name', 'action')
    fullyConnectedLayer(L, 'Name', 'fc5')];

criticNetwork = layerGraph(statePath);
criticNetwork = addLayers(criticNetwork, actionPath);
criticNetwork = connectLayers(criticNetwork, 'fc5', 'add/in2');

% Critic Representation Options
criticOptions = rlRepresentationOptions('LearnRate', 5e-4, ... % Reduced learning rate for better stability
                                        'GradientThreshold', 5, ... % Increased gradient threshold
                                        'L2RegularizationFactor', 5e-4, ... % Increased regularization to avoid overfitting
                                        'UseDevice', "cpu"); % Use CPU for now to avoid GPU issues

critic = rlQValueRepresentation(criticNetwork, obsInfo, actInfo, ...
    'Observation', {'observation'}, 'Action', {'action'}, criticOptions);

% ACTOR NETWORK
actorNetwork = [
    featureInputLayer(numStatesFromPatient, 'Normalization', 'none', 'Name', 'observation')
    fullyConnectedLayer(L, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(L, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(L, 'Name', 'fc3')
    reluLayer('Name', 'relu3')
    fullyConnectedLayer(eStimInputs, 'Name', 'fc4')
    tanhLayer('Name', 'tanh1')
    scalingLayer('Name', 'ActorScaling1', 'Scale', (actInfo.UpperLimit - actInfo.LowerLimit) / 2, 'Bias', (actInfo.UpperLimit + actInfo.LowerLimit) / 2)];

% Actor Representation Options
actorOptions = rlRepresentationOptions('LearnRate', 1e-4, ... % Lower learning rate to improve convergence stability
                                       'GradientThreshold', 5, ... % Increased gradient threshold
                                       'L2RegularizationFactor', 5e-4, ... % Increased regularization to prevent overfitting
                                       'UseDevice', "cpu"); % Use CPU for now to avoid GPU issues

actor = rlDeterministicActorRepresentation(actorNetwork, obsInfo, actInfo, ...
    'Observation', {'observation'}, 'Action', {'ActorScaling1'}, actorOptions);


% DDPG Agent Options for Faster Convergence
agentOpts = rlDDPGAgentOptions(...
    'SampleTime', SimuInfo.Ts, ...
    'TargetSmoothFactor', 1e-2, ... % Lower value for smoother target network updates
    'ExperienceBufferLength', 2e6, ... % Increase buffer size to improve learning from past experiences
    'DiscountFactor', 0.99, ... % Increased discount factor to prioritize long-term rewards
    'MiniBatchSize', 64, ... % Larger batch size for better gradient estimation
    'NumStepsToLookAhead', 5, ... % Increase lookahead steps to better estimate future rewards
    'ResetExperienceBufferBeforeTraining', false); % Avoid resetting buffer to keep accumulated experiences

% Adjust Noise for Exploration-Exploitation Balance
agentOpts.NoiseOptions.Variance = 0.2; % Increased initial noise for better exploration
agentOpts.NoiseOptions.VarianceDecayRate = 1e-4; % Faster decay rate to encourage more exploitation over time

% Creating the DDPG Agent
agent = rlDDPGAgent(actor, critic, agentOpts);


% Get current date and time
currentDateTime = datetime('now', 'Format', 'yyyyMMddHHmm');

% Define training options
trainOpts = rlTrainingOptions(...
    'MaxEpisodes', 3000, ... % Reduced max episodes for faster training cycles
    'MaxStepsPerEpisode', 1e4, ... % Reduced steps per episode for more frequent updates
    'Verbose', true, ...
    'Plots', 'training-progress', ... % Enable training plot to monitor progress
    'StopTrainingCriteria', 'AverageReward', ...
    'StopTrainingValue', 1e5, ... % Adjusted stop value for convergence criteria
    'UseParallel', false, ... % Disable parallel for now, can enable after stability
    'SaveAgentCriteria', 'EpisodeSteps', ... % Save agent based on steps per episode
    'SaveAgentValue', 8000, ... % Save agents with more than 5000 steps per episode
    'SaveAgentDirectory', fullfile(pwd, sprintf('%s_Agents', currentDateTime))); % Directory to save agents with current date and time




end