%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%=========================================================================%
%                                                                         %
% This fuction works as step function of RL environment                   %
%                                                                         %
%=========================================================================%

function [NextObs,Reward,IsDone,LoggedSignals,SimuInfo] = MyStepFunction(Action,LoggedSignals,SimuInfo,osimModel,osimState)

global episode n States E data


Ts=SimuInfo.Ts;
t=n*Ts;


if t==0
    States=SimuInfo.InitStates;
    data=[];
end

% e-stim parameter by RL parsing to pulse generator
SimuInfo.Action=Action;
Act=[SimuInfo.Action(1);...
     SimuInfo.Action(2);...
     SimuInfo.Action(3);...
     SimuInfo.Action(4)];
pw=SimuInfo.Action(5);
freq=SimuInfo.Action(6);

% SimuInfo.RLTraining='on'; %[on | off]


% ODE Solver
% Create a anonymous handle to the OpenSim plant function.
plantHandle = @(t,x) OsimPlantFcn(t, x, osimModel, osimState, SimuInfo);


% Integrate the system equations
integratorFunc = str2func(SimuInfo.integratorName);

[LoggedSignals.State]=integratorFunc(plantHandle, [t t+Ts], States); %Sem a func integrate
States=LoggedSignals.State(end,:)';

%%using function integrate
% SimuInfo.timeSpan = [t:Ts:t+Ts];
% integratorName = 'ode1'; 
% integratorOptions = odeset('RelTol', 1e-3, 'AbsTol', 1e-3,'MaxStep', 10e-3);
% [LoggedSignals.State]=IntegrateOsimPlant(osimModel,integratorName,SimuInfo,integratorOptions);
% States=LoggedSignals.State.data(end,:)';



NextObs=[States(18); States(16); States(38); States(36)]; % [Phi[rad]; Psi[rad]; Phidot[rad/s]; Psidot[rad/s]]
%rad2deg(NextObs)


if any(isnan(NextObs)) || any(isinf(NextObs))
    error('Invalid values detected in NextObs');
end



%% Reward

divergencePHI=logical(abs(rad2deg(States(18)))>=25);
divergencePSI=logical(rad2deg(States(16))>=35 || rad2deg(States(16))<=10);
BoundFlag= logical(divergencePHI || divergencePSI) ;
[divergencePHI divergencePSI];

Beta=1;
Q1=diag([1,1,1,1]);
Q2=diag([1,1,1,1]);


if t<3
    Reward=0;
    IsDone=0;

elseif(t>=3 && t<10 && ~BoundFlag)
    % Reward=-(E(1:4)*Q2*E(1:4)');

    % Funcao de custo unificada que combina energia do tremor e erro de setpoint
    Q1 = diag([1e1, 1e1, 1e2, 1e2]);
    Q2 = diag([1e-1, 1e-1, 1e-1, 1e-1]);    
    Q3 = diag([1e6*pw, 1e6*pw, 1e6*pw, 1e6*pw]);   
    tremor_cost = E(1:4) * Q1 * E(1:4)' ;         % Custo baseado na energia do tremor
    error_cost = E(5:end) * Q2 * E(5:end)'  ;     % Custo baseado no erro de setpoint
    

                        

    energy_cost=Act'*Q3*Act;

    sparReward=5e2*t;


    Reward = -(tremor_cost+error_cost+energy_cost)+sparReward;          % Funcao de custo combinada
    % [t, Reward]
    IsDone=0;

elseif(t>=3 && BoundFlag) 
    Reward=-1e6;
    IsDone=1;
    episode=episode+1;
    osimState=osimModel.initSystem();

elseif (t>=10)
    Reward=1e3;
    IsDone=1;
    osimState=osimModel.initSystem();
end

data=[data; States']; 

n=n+1;
end

