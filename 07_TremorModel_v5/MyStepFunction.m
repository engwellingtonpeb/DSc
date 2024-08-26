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
import org.opensim.modeling.*
global episode
global n

Ts=SimuInfo.Ts;
t=n*Ts;

global States

if t==0
    States=SimuInfo.InitStates;
end
 
% e-stim parameter by RL parsing to pulse generator
SimuInfo.Action=Action;
SimuInfo.RLTraining='on'; %[on | off]


% ODE Solver
% Create a anonymous handle to the OpenSim plant function.
plantHandle = @(t,x) OsimPlantFcn(t, x, osimModel, osimState, SimuInfo);

[LoggedSignals.State]=ode1(plantHandle, [t t+Ts], States);
States=LoggedSignals.State(end,:)';

NextObs=[States(18); States(16); States(38); States(36)]; % [Phi[rad]; Psi[rad]; Phidot[rad/s]; Psidot[rad/s]]


phi_ref=deg2rad(SimuInfo.Setpoint(1));
psi_ref=deg2rad(SimuInfo.Setpoint(2));

%references 
r=[phi_ref psi_ref 0 0]';
erro=r-NextObs;

% Reward
divergencePHI=logical(abs(rad2deg(States(18)))>=20);
divergencePSI=logical(rad2deg(States(16))>=35 || rad2deg(States(16))<=10);
BoundFlag= logical(divergencePHI || divergencePSI) ;
[divergencePHI divergencePSI];

Beta=1;
Q=diag([1,1,1,1]);

if t>=3
    Reward=-Beta*(erro'*Q*erro)-1000*BoundFlag
    SimuInfo.Action
else
    Reward=0;
end

if (t>=10 || (BoundFlag && t>3))
    IsDone=1;
    episode=episode+1;
else
    IsDone=0;
end


n=n+1;
end

