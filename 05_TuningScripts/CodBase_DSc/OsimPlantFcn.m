%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% OsimPlantFcn                                                            %
%   x_dot = OpenSimPlantFunction(t, x, controlsFuncHandle, osimModel,     %
%   osimState) converts an OpenSimModel and an OpenSimState into a        %
%   function which can be passed as a input to a Matlab integrator, such  %
%   as ode45, or an optimization routine, such as fmin.                   %
%                                                                         %
% Input:                                                                  %
%   t is the time at the current step                                     %
%   x is a Matlab column matrix of state values at the current step       %
%   controlsFuncHandle is a handle to a function which computes the       %
%   control vector                                                        %
%                                                                         %
%   osimModel is an org.opensim.Modeling.Model object                     %
%   osimState is an org.opensim.Modeling.State object                     %
%                                                                         %
% Output:                                                                 %
%   x_dot is a Matlab column matrix of the derivative of the state values %
%=========================================================================%
function [x_dot] = OsimPlantFcn(t, x, osimModel, osimState,SimuInfo)

    % Update state with current values  
    osimState.setTime(t);
    numVar = SimuInfo.Nstates;
    
    %opção 01 

    UpdVar=osimState.updY();
    % for i = 0:1:numVar-1
    for i = 0:1:numVar-26
        UpdVar.set(i, x(i+1,1));
    end
      




    SimuInfo.du=[max(x(55),0) max(x(57),0)];

    %Update the derivative calculations in the State Variable
    osimModel.computeStateVariableDerivatives(osimState);
    % Update model with control values
    SimuInfo.Xk=x;
    % Inner loop (physiological muscle control)
    %[u_sup u_ecrl u_ecrb u_ecu u_fcr u_fcu u_pq]
    u0 = OsimControlsFcn(osimState,t,SimuInfo);
    %Outter loop (Electrical Stimulation Control)
    ues = ElectricalStimulationController(SimuInfo,t);

    %-----activations and fatigue------------
    switch SimuInfo.FES
        case 'off'
            a0 = x(48:54,1);% physiologic base activation perturbed by oscillator
            a=a0;
        case 'on'
            a0 = x(48:54,1); % physiologic base activation perturbed by oscillator
            ae = x(59:65,1); % activation due to electrical stimulation
            p  = x(66:72,1); % fatigue weighting function

            p=p-.25; %offset voluntaries with pathological tremor already presents
        
            aes=ae.*p;
            a=aes+a0;
            [a0,ae,p]

    end
    
    %----Saturation Block--------------------
    a(a>1)=1;
    a(a<0)=0;
    %----------------------------------------

    osimModel.getMuscles().get(0).setActivation(osimState,a(1));%sup
    osimModel.getMuscles().get(1).setActivation(osimState,a(2));%ecrl
    osimModel.getMuscles().get(2).setActivation(osimState,a(3));%ecrb
    osimModel.getMuscles().get(3).setActivation(osimState,a(4));%ecu
    osimModel.getMuscles().get(4).setActivation(osimState,a(5));%fcr
    osimModel.getMuscles().get(5).setActivation(osimState,a(6));%fcu
    osimModel.getMuscles().get(6).setActivation(osimState,a(7));%pq


    % Update the derivative calculations in the State Variable
    osimModel.computeStateVariableDerivatives(osimState);
    x_dot=osimState.getYDot().getAsMat();
    
    
    [a0_dot, ae_dot, p_dot] = AugmentedActivationDynamics(t,x,u0,ues,SimuInfo);    
    xosc_dot = MatsuokaOscilator(t,SimuInfo);



    % Derivatives Vector
    x_dot=[x_dot;...
           a0_dot;... %48[asup] 49[aecrl] 50[aecrb] 51[aecu] 52[afcr] 53[afcu] 54[apq]
           xosc_dot;... %55[x1_osc] 56[v1_osc] 57[x2_osc] 58[v2_osc]
           ae_dot;... %59[ae_sup] 60[ae_ecrl] 61[ae_ecrb] 62[ae_ecu] 63[ae_fcr] 64[ae_fcu] 65[ae_pq]
           p_dot];    %66[p_sup] 67[p_ecrl] 68[p_ecrb] 69[p_ecu] 70[p_fcr] 71[p_fcu] 72[p_pq]







    % Plotting Results
    OsimPlotFcn(t,x,u0,a,a0,ae,p,SimuInfo)
end


