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

[LoggedSignals.State]=ode1(plantHandle, [t t+Ts], States);
States=LoggedSignals.State(end,:)';

NextObs=[States(18); States(16); States(38); States(36)]; % [Phi[rad]; Psi[rad]; Phidot[rad/s]; Psidot[rad/s]]

if any(isnan(NextObs)) || any(isinf(NextObs))
    error('Invalid values detected in NextObs');
end

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
Q1=diag([1,1,1,1]);
Q2=diag([1,1,1,1]);



if t<3
    Reward=0;
    IsDone=0;

elseif(t>=3 && ~BoundFlag)
    Reward=-(E(1:4)*Q2*E(1:4)');
    IsDone=0;
    
elseif(t>=3 && BoundFlag) 
    Reward=-1e3;
    IsDone=1;
    episode=episode+1;

elseif (t>=10)
    Reward=1e2;
    IsDone=1;
end




n=n+1;
end

