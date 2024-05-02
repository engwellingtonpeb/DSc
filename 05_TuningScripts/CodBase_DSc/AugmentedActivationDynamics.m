%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This function implements an augmented activation dynamics to            %
% matlab-opensim interfaced simulations of SURFACE ELECTRICALLY           %
% STIMULATED MUSCLES                                                      %
%                                                                         %
% Sources:                                                                %
% [1] ZHANG, Dingguo et al. Neural oscillator based control for           %
% pathological tremor suppression via functional electrical stimulation.  %
% Control Engineering Practice, v. 19, n. 1, p. 74-88, 2011.              %
%                                                                         %
% [2] Pandy, M. G. (2001). Computer Modeling and Simulation of Human      %
% Movement. Annual Review of Biomedical Engineering, 3(1), 245–273.       %
%                                                                         %
% [3] ME/BIOE 481: ASSIGNMENT 3 - Muscle Tug-of-War                       %
% https://courses.physics.illinois.edu/me481/sp2021/                      %
% ME481-Assignment3V2.pdf                                                 %
%                                                                         %
% [4] Adjustment of Muscle Mechanics Model Parameters to Simulate Dynamic %
% Contractions in Older Adults (https://doi.org/10.1115/1.1531112)        %
%                                                                         %
% [5] https://opensimconfluence.atlassian.net/wiki/spaces/OpenSim/pages/  %
% 53090590/First-Order+Activation+Dynamics                                %
%                                                                         %
% [6] SHARMA, Nitin et al. A non-linear control method to compensate for  %
% muscle fatigue during neuromuscular electrical stimulation. Frontiers   %
% in Robotics and AI, v. 4, p. 68, 2017.                                  %
%                                                                         %
% [7] RIENER, Robert; FUHR, Thomas. Patient-driven control of             %
% FES-supported standing up: a simulation study. IEEE Transactions on     %
% rehabilitation engineering, v. 6, n. 2, p. 113-124, 1998.               %
%=========================================================================%
function [a0_dot, ae_dot, p_dot] = AugmentedActivationDynamics(t,xk,u0,ues,SimuInfo)

% xk - x(k) - state vector at step k
% u0 - excitation signal from nervous system - voluntary-specific tremor generated
% ues (Ncontrols x 3) vector [Amp pw freq]- electrical stimulation excitation signal



StatusFES=SimuInfo.FES;
switch StatusFES

    case 'off'

        a0_dot = FirstOrderActivationDynamics(u0,xk);
        ae_dot=zeros(SimuInfo.Ncontrols,1);
        p_dot=zeros(SimuInfo.Ncontrols,1);


    case 'on'
   %------ parameters------------------------------------ 
        % Electrical Stimulated Activation
        % pw0=ues(1,2); % ues (Ncontrols x 3) vector [Amp pw freq]
        % f=ues(1,3);

        % pw0=200e-6; %Developing...
        % f=20; %Developing...
        
     
        tau_ac=40e-3;   %[ms]
        tau_da=70e-3; %[ms]
    
        pmin=0.2; %[dimensionless]
        pwd=100e-6; %[microsec]
        pws=500e-6; %[microsec]
    
        tau_fat=18e-3; %[ms]
        tau_rec=40e-3; %[ms]
    

        beta=0.6;%[dimensionless]
        It=10e-3; %[mA]
        Is=40e-3; %[mA]
   %-----------------------------------------------------


        a0=xk(48:54,1);
        ae=xk(59:65,1);
        p=xk(66:72,1);
        
        a0_dot=zeros(SimuInfo.Ncontrols,1);
        ae_dot=zeros(SimuInfo.Ncontrols,1);
        p_dot=zeros(SimuInfo.Ncontrols,1);

    % Limits on Activation and Excitation
        a0(a0>1)=1;
        a0(a0<0)=0;
        
        ae(ae>1)=1;
        ae(ae<0)=0;

        u0(u0>1)=1;
        u0(u0<0)=0;

        i=1;

    %% Muscle Recruitment Curves (by electrical stim)
        while i<=SimuInfo.Ncontrols
            
            % ues (Ncontrols x 3) vector [Amp pw freq]
            pw0=ues(i,2);
            f=ues(i,3);
            a=ae(i);
            
            % Pulse Width Characteristic
            if pw0<=pwd
                ar=0;
            elseif (pwd<pw0) && (pw0<pws)
                ar= (1/(pws-pwd))*(pw0-pwd);
            else % pw0>= pws
                ar=1;
            end

            % Frequency Characteristic
            q=((0.1*f)^2)/(1+(.1*f)^2);

            % Muscle Fatigue
            lambda=1-beta+beta*(f/100)^2;
           
            p_dot=(((pmin-p)*a*lambda)/tau_fat)+((1-p)*(1-a*lambda))/tau_rec;

            % Calcium Dynamics 
            u=ar*q;
            ae_dot(i)=(1/tau_ac)*(u^2-u*a)+(1/tau_da)*(u-a); %[2] Pandy, M. G. (2001).
            
            % t_act  = 12e-3; %[ms]
            % t_deact= 40e-3; %[ms]
            % ui=u;
            % ai=ae(i);
            % 
            % if ui>ai
            %     tau_au=t_act*(0.5+1.5*ai);
            % 
            % elseif ui<=ai
            %     tau_au=t_deact/(0.5+1.5*ai);
            % 
            % end
            % 
            % ae_dot(i)=(ui-ai)/tau_au;
            I=It+u*(Is-It);

            a0_dot = FirstOrderActivationDynamics(u0,xk);

            i=i+1;
        end


end



    

      
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    











    
    
    
   





end