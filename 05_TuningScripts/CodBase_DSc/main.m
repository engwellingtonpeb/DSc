clc
clear all
close all hidden

pathconfig

SimuInfo=struct; %information about simulation parameters
import org.opensim.modeling.*


%pacitente 01
load('29_Oct_2023_20_15_55_GA.mat') % sintonia do oscilador 2 dias 
ModelParams=x(12,:);% sintonia do oscilador 2 dias 
%% Controller Synthesis


 [LinStabilityFlag, K] = ControllerSynthesis();


if LinStabilityFlag
    %% Tremor Simulation for Tunning 



    SimuInfo.Tend=10;
    SimuInfo.Ts=1e-3;
    SimuInfo.PltFlag='on'; %[on | off]
    SimuInfo.PltResolution=100;
    SimuInfo.FES='on'; %[on | off]
    SimuInfo.Tremor='on' %[on | off]
    SimuInfo.ModelParams=ModelParams;
    
    %Config Simulations using Matlab Integrator
    SimuInfo.timeSpan = [0:SimuInfo.Ts:SimuInfo.Tend];
    integratorName = 'ode1'; %fixed step Dormand-Prince method of order 5
    integratorOptions = odeset('RelTol', 1e-3, 'AbsTol', 1e-3,'MaxStep', 10e-3);
    
    
    
    
    %Distribuição de um paciente especíico
    load('distrib_tremor_paciente01.mat') % paciente
    SimuInfo.w_tremor=0.1;
    
% Distribuição Genérica de frequências do tremor
%     X = makedist('Normal','mu',5.6,'sigma',1);%generico
%     P=[];
%     N=570;
%     
%     for i=1:N
%         P(i)=random(X,1,1);
%     end
    
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
    
    

    
    %% Run Simulation
        tic
        motionData = IntegrateOsimPlant(osimModel,integratorName,SimuInfo,integratorOptions);
        elapsedTime=toc
        SimuInfo.elapsedTime=elapsedTime;
end