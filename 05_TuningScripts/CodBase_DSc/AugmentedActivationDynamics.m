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
%=========================================================================%
function [a0_dot, ae_dot, p_dot] = AugmentedActivationDynamics(xk,u0,ues,StatusFES)

% xk - x(k) - state vector at step k
% u0 - excitation signal from nervous system - voluntary-specific tremor generated
% ues (Ncontrols x 3) vector [Amp pw freq]- electrical stimulation excitation signal

%if ~isempty(ues)
switch StatusFES

    case 'noFES'

        % Activations due to physiological muscle control
        
        % [2] "Values of these constants range from 12–20 ms for risetime, 
        % τrise, and from 24–200 ms for relaxation time."
        
        t_act  = 10e-3; %[s]
        t_deact= 40e-3; %[s]
        
        
        a0=xk(48:54,1);
        ae=xk(59:65,1);
        p=xk(66:72,1);
        
        a0_dot=zeros(length(a0),1);
        ae_dot=zeros(length(a0),1);
        p_dot=zeros(length(a0),1);
        
        % Limits on Activation and Excitation
        a0(a0>1)=1;
        a0(a0<0)=0;
        
        u0(u0>1)=1;
        u0(u0<0)=0;
        
        i=1;
        while i<=length(a0)
            ui=u0(i);
            ai=a0(i);
        
            if ui>ai
                tau_au=t_act*(0.5+1.5*ai);
            end
            
            if ui<=ai
                tau_au=t_deact/(0.5+1.5*ai);
            end
        
            a0_dot(i)=(ui-ai)/tau_au;
            i=i+1;
        end


    case 'FES'
        % parameters 
        % Electrical Stimulated Activation
        z=1; %Developing...
        f=1; %Developing...
        p_dot=0; %Developing...
    
        tau_ac=40;   %[ms]
        tau_da=70; %[ms]
    
        pmin=0.2; %[dimensionless]
        pwd=100; %[microsec]
        pws=500; %[microsec]
    
        tau_fat=18; %[ms]
        tau_rec=30; %[ms]
    
        eps=0.4; %[dimensionless]
        beta=0.6;%[dimensionless]


end



    

      
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    %% Muscle Recruitment Curves
    % Pulse Width Characteristic

    % if z<=pwd
    %     ar=0;
    % elseif pwd<=z<=pws
    %     ar= (1/(pws-pwd))*(z-pwd);
    % else
    %     ar=1;
    % end
    % 
    % % Frequency Characteristic
    % 
    % q=((0.1*f)^2)/(1+(.1*f)^2);
    % 
    % 
    % % Calcium Dynamics 
    % ue=ar*q;
    % a_dot=(1/tau_ac)*(u^2-u*a0)+(1/tau_da)*(u-a0)
    % 
    % % Muscle Fatigue
    % lambda=1-beta+beta*(f/100)^2;
    % p_dot=(((pmin-p)*a0*lambda)/tau_fat)+((1-p)*(1-a0*lambda))/tau_rec;




    
    
    
   





end