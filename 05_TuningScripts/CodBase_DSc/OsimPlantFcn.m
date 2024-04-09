%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 04/10/2023                                                       %
%  Last Update: DSc - Version 2.0                                         %
%-------------------------------------------------------------------------%
% OsimPlantFcn
%   x_dot = OpenSimPlantFunction(t, x, controlsFuncHandle, osimModel, 
%   osimState) converts an OpenSimModel and an OpenSimState into a 
%   function which can be passed as a input to a Matlab integrator, such as
%   ode45, or an optimization routine, such as fmin.
%
% Input:
%   t is the time at the current step
%   x is a Matlab column matrix of state values at the current step
%   controlsFuncHandle is a handle to a function which computes thecontrol
%   vector
%   osimModel is an org.opensim.Modeling.Model object 
%   osimState is an org.opensim.Modeling.State object
%
% Output:
%   x_dot is a Matlab column matrix of the derivative of the state values
% ----------------------------------------------------------------------- 
function [x_dot] = OsimPlantFcn(t, x, osimModel, osimState,SimuInfo)


    % Update state with current values  
    osimState.setTime(t);
    numVar = SimuInfo.Nstates;
    UpdVar=osimState.updY();
    % for i = 0:1:numVar-1
    for i = 0:1:numVar-8
        UpdVar.set(i, x(i+1,1));
    end
    


    %Update the derivative calculations in the State Variable
    osimModel.computeStateVariableDerivatives(osimState);


    % Update model with control values
    SimuInfo.Xk=x;
    u = OsimControlsFcn(osimModel,osimState,t,SimuInfo); %control effort
    %[u_sup u_ecrl u_ecrb u_ecu u_fcr u_fcu u_pq]



    osimModel.getMuscles().get(0).setActivation(osimState,x(48))
    osimModel.getMuscles().get(1).setActivation(osimState,x(49))
    osimModel.getMuscles().get(5).setActivation(osimState,x(53))
    osimModel.getMuscles().get(6).setActivation(osimState,x(54))
    

    % Plotting Results
    OsimPlotFcn(t,x,u,SimuInfo)


   
    %Update the derivative calculations in the State Variable
    osimModel.computeStateVariableDerivatives(osimState);
    x_dot=osimState.getYDot().getAsMat();
    a_dot = FirstOrderActivationDynamics(u,x); %[a_sup a_ecrl a_ecrb a_ecu a_fcr a_fcu a_pq]

    t
    x_dot=[x_dot;...
           a_dot];
end


