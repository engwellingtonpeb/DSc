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
function u_control = OsimControlsFcn(osimModel, osimState,t,SimuInfo)

    
    % Check Size
    if(SimuInfo.Ncontrols < 1)
       error('OpenSimPlantControlsFunction:InvalidControls', ...
           'This model has no controls.');
    end

    % Get a reference to current model controls
    % modelControls = osimModel.updControls(osimState);

%% Read plant angles for feedback and avoid NaN 

global ERR_POS

persistent xk1
persistent u




   
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

e=r-x;

err_pos=[phi_ref-phi ; psi_ref-psi];


eps_phi=rad2deg(err_pos(1));
eps_psi=rad2deg(err_pos(2));

ERR_POS=[ERR_POS; [eps_phi eps_psi]];


%% Control Signal Generation    

if length(xk1)<(length(SimuInfo.Ak))
    xk1=zeros(length(SimuInfo.Ak),1);
end

xplus=(SimuInfo.Ak*xk1)+(SimuInfo.Bk*e); % based on J. Ji and Y. Liu, "H-infinity Controller for Discrete-Time Systems," doi: 10.1109/MVHI.2010.98.
u=SimuInfo.Ck*xk1+SimuInfo.Dk*e;
xk1=xplus;
if any(isnan(u))
    disp('ERRO AQUI')
    u(isnan(u))=0;
    xk1=zeros(length(SimuInfo.Ak),1);
end
    %

%% Reciprocal Inhibition

ALPHA1=((-0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5);
ALPHA2=(0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5;

ALPHA3=(0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+.5;
ALPHA4=(-0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+0.5;


%% Tremor CPG


persistent X
persistent V
persistent Y1


persistent Kf
persistent j1

    % B=SimuInfo.ModelParams(7); %beta
    % h=SimuInfo.ModelParams(8); %h
    % rosc=SimuInfo.ModelParams(9); %r
    % tau1=SimuInfo.ModelParams(10);%tau1
    % tau2=SimuInfo.ModelParams(19);%tau2


    tau1=.1;
    tau2=.1;
    B=2.5;
     A=5;
    h=2.5;
    rosc=1;

if (t==0)
    j1=0;
    Kf=2;

else

if (rem(j1,1000)==0)
        P=randsample(SimuInfo.P,1);
%         Tosc=1/P;
%         Kf=(Tosc)/.1051;
        Kf=(1/(2*pi*P))*sqrt(1/(tau1*tau2)); % Zhang, Dingguo, et al. "Neural 
        % oscillator based control for pathological tremor suppression via 
        % functional electrical stimulation." Control Engineering Practice 19.1 (2011): 74-88.
     
end
    j1=j1+1;
 
end
    





    %dh=0.0001;
    dh=SimuInfo.Ts;
    s1=0;%osimModel.getMuscles().get('ECRL').getActivation(osimState); %activation
    s2=0;%osimModel.getMuscles().get('FCU').getActivation(osimState);%activation

    if (t==0)
        x_osc=[normrnd(.5,0.25) normrnd(.5,0.25)]; %valor inicial [0,1]
        v_osc=[normrnd(.5,0.25) normrnd(.5,0.25)];
        X=[x_osc(1,1);x_osc(1,2)];
        V=[v_osc(1,1);v_osc(1,2)];
    end


    %%Implemented as (Zhang, Dingguo, et al. "Neural oscillator based control for 
    % pathological tremor suppression via functional electrical stimulation." 
    % Control Engineering Practice 19.1 (2011): 74-88.)

    x1=X(1,end)+dh*((1/(Kf*tau1))*((-X(1,end))-B*V(1,end)-h*max(X(2,end),0)+A*s1+rosc));
    y1=max(x1,0);
    v1=V(1,end)+dh*((1/(Kf*tau2))*(-V(1,end)+max(X(1,end),0)));

    x2= X(2,end)+dh*((1/(Kf*tau1))*((-X(2,end))-B*V(2,end)-h*max(X(1,end),0)-A*s2+rosc));
    y2=max(x2,0);
    v2=V(2,end)+dh*((1/(Kf*tau2))*(-V(2,end)+max(X(2,end),0)));


    X=[x1;x2];
    V=[v1;v2];
    Y1=[y1;y2];


    d(1)=Y1(1,end);
    d(2)=Y1(2,end);










%     du = ode1(@MatsuOscillator,[t t+SimuInfo.Ts],xosc_0,SimuInfo);
%     xosc_0=du(end,:);
%     d=[max(0,xosc_0(1)) max(0,xosc_0(2))];


%% Tremor Affected Muscle Excitation 

if t<.1 %initializing model
    u(1)=.1;
    u(2)=0;
    u(3)=.1;
    u(4)=0.01;

elseif t<2 && t>=0.1
    u(1)=2e6*ALPHA1*u(1); %ECRL
    u(2)=1e6*ALPHA2*u(2); %FCU
    u(3)=1e6*ALPHA3*u(3); %PQ
    u(4)=1e6*ALPHA4*u(4); %SUP
else

    u(1)=(1e6*ALPHA1*u(1))+0.5*d(1)+0*d(2); %ECRL
    u(2)=(1e6*ALPHA2*u(2))+0*d(1)+.5*d(2); %FCU
    u(3)=(1e6*ALPHA3*u(3))+.5*d(1)+0*d(2); %PQ
    u(4)=(1e6*ALPHA4*u(4))+0*d(1)+.5*d(2); %SUP

end



%% Actuators saturation (muscle excitation limits 0<=u<=1)


for i=1:length(u)
    if u(i)>=1
        u(i)=1;
    end
    
    if u(i)<0
        u(i)=0;
    end
end


%% Control Vector (muscle excitations)

    u_control=[u(4) u(1) 0.01 0.01 0.01 u(2) u(3)]; %[u_sup u_ecrl u_ecrb u_ecu u_fcr u_fcu u_pq]

  

end




