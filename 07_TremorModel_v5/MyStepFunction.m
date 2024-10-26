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

global episode
global n
global States

global E

Ts=SimuInfo.Ts;
t=n*Ts;


if t==0
    States=SimuInfo.InitStates;
end

% e-stim parameter by RL parsing to pulse generator
SimuInfo.Action=Action;
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
divergencePHI=logical(abs(rad2deg(States(18)))>=20);
divergencePSI=logical(rad2deg(States(16))>=35 || rad2deg(States(16))<=10);
BoundFlag= logical(divergencePHI || divergencePSI) ;
[divergencePHI divergencePSI];

Beta=1;
Q1=diag([1,1,1,1]);
Q2=diag([1,1,1,1]);



if t<3
    Reward=0;
    IsDone=0;

elseif(t>=3 && ~BoundFlag)
    % Reward=-(E(1:4)*Q2*E(1:4)');

    % Função de custo unificada que combina energia do tremor e erro de setpoint
    Q1 = diag([1e0, 1e0, 1e0, 1e0]);
    Q2 = diag([1e0, 1e0, 1e0, 1e0]);
    tremor_cost = E(1:4) * Q1 * E(1:4)';          % Custo baseado na energia do tremor
    error_cost = E(5:end) * Q2 * E(5:end)';       % Custo baseado no erro de setpoint
    Reward = -(tremor_cost + error_cost);                 % Função de custo combinada

    IsDone=0;

elseif(t>=3 && BoundFlag) 
    Reward=-1e3;
    IsDone=1;
    episode=episode+1;
    osimState=osimModel.initSystem();

elseif (t>=10)
    Reward=1e2;
    IsDone=1;
    osimState=osimModel.initSystem();
end




n=n+1;
end

