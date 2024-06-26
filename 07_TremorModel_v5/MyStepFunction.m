function [NextObs,Reward,IsDone,LoggedSignals,SimuInfo] = MyStepFunction(Action,LoggedSignals,SimuInfo,osimModel,osimState)
import org.opensim.modeling.*
global episode
global n
persistent ErrorVec
persistent ErrorInt
persistent u
Ts=SimuInfo.Ts;
t=n*Ts;

global States

if t==0
    States=SimuInfo.InitStates;
end
 
% call plant
SimuInfo.Action=Action;
%[x_dot, controlValues] = OpenSimPlantFunction(t,States,osimModel,osimState,SimuInfo);


% ODE Solver

% Create a anonymous handle to the OpenSim plant function.
    plantHandle = @(t,x) OsimPlantFcn(t, x, osimModel, osimState, SimuInfo);

    [LoggedSignals.State]=ode4(plantHandle, [t t+Ts], States);

    


States=LoggedSignals.State(end,:)';

NextObs=[0; 0; 0];

% Reward
if (t>=10)
    Reward = 1;
    IsDone=1;
    episode=episode+1;
else
    Reward = -1;
    IsDone=0;
end


n=n+1;
end

