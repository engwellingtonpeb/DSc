function [InitialObservation, LoggedSignal] = MyResetFunction(osimModel,osimState, SimuInfo)
% clearvars -except agent env trainOpts osimModel osimState
global States n episode 


    osimState=osimModel.initSystem();



    %% Model elements identification
    
    % Create the Initial State matrix from the Opensim state
    numVar = SimuInfo.numVar;
    InitStates = zeros(numVar,1);
    for i = 0:1:numVar-1
        InitStates(i+1,1) = 0; %osimState.getY().get(i); 
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
    
%% Prep Simulation

    
States=InitStates;
n=0;


% Return initial environment state variables as logged signals.
LoggedSignal.State = InitStates;

phi=osimState.getY().get(17); % wrist flexion angle (rad)
psi=osimState.getY().get(15); % pro_sup angle (rad)

phi_dot=osimState.getY().get(37);% wrist flexion velocity (rad/s)
psi_dot=osimState.getY().get(35);% pro_sup velocity (rad/s)

InitialObservation = [phi; psi; phi_dot; psi_dot];


%close all
episode
end