%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This script sets all parameters to run a FD ONLY tremor simulation      %
%                                                                         %
%=========================================================================%


SimuInfo=struct; %information about simulation parameters
SimuInfo.DummySimulation='false'; 

if strcmp(SimuInfo.DummySimulation,'true')
disp('[!!!RUNNING A DUMMY SIMULATION!!!]')
end

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
        
        % Check if the file follows the new structure with 'x' and 'fval'
        if isfield(data, 'x') && isfield(data, 'fval')
            % New structure: Assign 'x' to ModelParams and 'fval' to minimum cost
            ModelParams = data.x;
            minimum_cost = data.fval;
            disp('Loaded ModelParams and minimum cost from file (new structure).');
            fprintf('Minimum cost: %f\n', minimum_cost);
        
        % Check if the file follows the old structure with 'cost' and 'history'
        elseif isfield(data, 'cost') && isfield(data, 'history')
            % Old structure: Find the minimum cost and corresponding parameters
            [minCostValues, minIndices] = min(data.cost, [], 1); % Min along the first dimension (rows)
            [minimum_cost, bestColumn] = min(minCostValues);
            bestRow = minIndices(bestColumn);
            ModelParams = data.history(bestRow, :, bestColumn);
            disp('Loaded ModelParams from file with minimum cost (old structure).');
            fprintf('Minimum cost: %f\n', minimum_cost);

else
    % Error if neither structure is found
    error('The selected file does not contain the required variables for either structure.');
end

        
    case 2
        % Option 2: Type the vector manually
        ModelParams = input('Enter the parameter vector ([1, 2, 3, ...]): ');
        
    otherwise
        error('Invalid choice. Please choose either 1 or 2.');
end

% Now ModelParams is set based on the selected option
disp('ModelParams set as:');
disp(ModelParams);


if strcmp(SimuInfo.DummySimulation, 'true')
% %pacitente 01
    load('29_Oct_2023_20_15_55_GA.mat') % sintonia do oscilador 2 dias 
    ModelParams=x(12,:);% sintonia do oscilador 2 dias 
end

%% Controller Synthesis


 
[LinStabilityFlag, K] = ControllerSynthesis(SimuInfo, ModelParams);


if LinStabilityFlag
 %% Tremor Simulation for Tunning 
    

    %Time
    SimuInfo.Ts=1e-3;
    SimuInfo.Tend=60;
    SimuInfo.TStim_ON=3; %e-stim initial time on the simulations


    %Plotting 
    SimuInfo.PltFlag='on'; %[on | off]
    SimuInfo.PltResolution=100;
    
    %Params tuned by optimization
    SimuInfo.ModelParams=ModelParams;

    %Tremor
    SimuInfo.Tremor='on'; %[on | off]

    %Electrical Stimulation
    SimuInfo.FES='off'; %[on | off]
    SimuInfo.FESProtocol='none'; %[cc - O.L. co-contraction | op - O.L. out-of-phase]
    
    %sliderapp()
    
    %Config Simulations using Matlab Integrator
    SimuInfo.timeSpan = [0:SimuInfo.Ts:SimuInfo.Tend];
    integratorName = 'ode1'; 
    SimuInfo.integratorName=integratorName;
    integratorOptions = odeset('RelTol', 1e-3, 'AbsTol', 1e-3,'MaxStep', 10e-3);
        
    SimuInfo.RLTraining='off';
    
    SimuInfo.TremorEnergy=[];
    
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
    
    SimuInfo.Coord_all=Coord_all
    

    %% Prep Simulation
    osimModel.computeStateVariableDerivatives(osimState);
    osimModel.equilibrateMuscles(osimState); %solve for equilibrium similiar
    
    %Controls function
    controlsFuncHandle = @OsimControlsFcn;

end