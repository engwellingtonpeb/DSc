%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 04/10/2023                                                       %
%  Last Update: DSc - Version 2.0                                         %
%-------------------------------------------------------------------------%
% OpenSimPlantControlsFunction_control  
%   outVector = OpenSimPlantControlsFunction(osimModel, osimState)
%   This function computes a control vector which for the model's
%   actuators.  The current code is for use with the script
%   DesignMainStarterWithControls.m
%
% Input:
%   osimModel is an org.opensim.Modeling.Model object 
%   osimState is an org.opensim.Modeling.State object
%
% Output:
%   outVector is an org.opensim.Modeling.Vector of the control values
% -----------------------------------------------------------------------
function u_control = OsimControlsFcn(osimState,t,SimuInfo)

    
    % Check Size
    if(SimuInfo.Ncontrols < 1)
       error('OpenSimPlantControlsFunction:InvalidControls', ...
           'This model has no controls.');
    end

    % Get a reference to current model controls
    % modelControls = osimModel.updControls(osimState);

%% Read plant angles for feedback and avoid NaN 

persistent ERR_POS

persistent xk1
persistent u


d=SimuInfo.du;

   
%% Plant control implementation 

    phi_ref=deg2rad(SimuInfo.Setpoint(1));
    psi_ref=deg2rad(SimuInfo.Setpoint(2));


%references 
r=[0.01 0.01 0.01 0.01 phi_ref psi_ref 0 0]'; % asup aecrl afcu apq phi psi phidot psidot


% states

phi=osimState.getY().get(17); % wrist flexion angle (rad)
psi=osimState.getY().get(15); % pro_sup angle (rad)
phi_dot=osimState.getY().get(37);
psi_dot=osimState.getY().get(35);

%[a_sup a_ecrl a_ecrb a_ecu a_fcr a_fcu a_pq]
%[Xk(48) Xk(49) Xk(50) Xk(51) Xk(52) Xk(53) Xk(54)]

asup = SimuInfo.Xk(48);
aecrl= SimuInfo.Xk(49);
% aecrb= SimuInfo.Xk(50);
% aecu = SimuInfo.Xk(51);
% afcr = SimuInfo.Xk(52);
afcu = SimuInfo.Xk(53);
apq  = SimuInfo.Xk(54);

%[osimModel.getMuscles().get('ECRL').getActivation(osimState) aecrl]
%CHECKED OK


x=[asup aecrl afcu apq phi psi phi_dot psi_dot]';

if any(isnan(x))
    disp('state feedback error')
    pause(20)
end

e=r-x;




eps_phi=rad2deg(e(5));
eps_psi=rad2deg(e(6));

ERR_POS=[ERR_POS; [eps_phi eps_psi]];


%% Control Signal Generation    

if length(xk1)<(length(SimuInfo.Ak))
    xk1=zeros(length(SimuInfo.Ak),1);
end

xplus=(SimuInfo.Ak*xk1)+(SimuInfo.Bk*e); % based on J. Ji and Y. Liu, "H-infinity Controller for Discrete-Time Systems," doi: 10.1109/MVHI.2010.98.
u=SimuInfo.Ck*xk1+SimuInfo.Dk*e;
xk1=xplus;
if any(isnan(u))
    disp('ERRO 101')
    u(isnan(u))=0;
    xk1=zeros(length(SimuInfo.Ak),1);
end
    %

%% Reciprocal Inhibition

ALPHA1=((-0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5);
ALPHA2=(0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5;

ALPHA3=(0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+.5;
ALPHA4=(-0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+0.5;




%% Tremor Affected Muscle Excitation 

if t<.1 %initializing model
    u(1)=.1;
    u(2)=0.01;
    u(3)=.1;
    u(4)=0.01;

elseif t<2 && t>=0.1
    u(1)=2e6*ALPHA1*u(1); %ECRL
    u(2)=1e6*ALPHA2*u(2); %FCU
    u(3)=1e6*ALPHA3*u(3); %PQ
    u(4)=1e6*ALPHA4*u(4); %SUP
else

    u(1)=(1e6*ALPHA1*u(1))+0.15*d(1)+0*d(2); %ECRL
    u(2)=(1e6*ALPHA2*u(2))+0*d(1)+.15*d(2); %FCU
    u(3)=(1e6*ALPHA3*u(3))+.15*d(1)+0*d(2); %PQ
    u(4)=(1e6*ALPHA4*u(4))+0*d(1)+.15*d(2); %SUP

end



%% Actuators saturation (muscle excitation limits 0<=u<=1)


    u(u>1)=1;
    u(u<0)=0;


%% Control Vector (muscle excitations)

    u_control=[u(4) u(1) 0.01 0.01 0.01 u(2) u(3)]; %[u_sup u_ecrl u_ecrb u_ecu u_fcr u_fcu u_pq]

    
end




