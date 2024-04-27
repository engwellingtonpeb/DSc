%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This function implements a first order activation dynamics for the      %
% matlab opensim interfaced simulations                                   %
%                                                                         %
% Sources:                                                                %
%[1] ME/BIOE 481: ASSIGNMENT 3 - Muscle Tug-of-War                        %
% https://courses.physics.illinois.edu/me481/sp2021/                      %
% ME481-Assignment3V2.pdf                                                 %
%                                                                         %
%[2] Adjustment of Muscle Mechanics Model Parameters to Simulate Dynamic  %
%Contractions in Older Adults (https://doi.org/10.1115/1.1531112)         %
%                                                                         %
%[3] https://opensimconfluence.atlassian.net/wiki/spaces/OpenSim/pages/   %
% 53090590/First-Order+Activation+Dynamics                                %
%                                                                         %
%[4] Pandy, M. G. (2001). Computer Modeling and Simulation of Human       %
% Movement. Annual Review of Biomedical Engineering, 3(1), 245–273.       %
%=========================================================================%

function [a_dot] = FirstOrderActivationDynamics(u,x)

% Pandy, M. G. (2001). Computer Modeling and Simulation of Human Movement. 
% Annual Review of Biomedical Engineering, 3(1), 245–273.

% "Values of these constants range from 12–20 ms for rise
% time, τrise, and from 24–200 ms for relaxation time."

t_act  = 12e-3; %[ms]
t_deact= 40e-3; %[ms]


a=x(48:54,1);

i=1;
a_dot=zeros(length(a),1);

% Limits on Activation and Excitation
a(a>1)=1;
a(a<0)=0;

u(u>1)=1;
u(u<0)=0;

    while i<=length(a)
        ui=u(i);
        ai=a(i);
    
        if ui>ai
            tau_au=t_act*(0.5+1.5*ai);
        
        elseif ui<=ai
            tau_au=t_deact/(0.5+1.5*ai);
       
        end

        a_dot(i)=(ui-ai)/tau_au;
        i=i+1;
    end



end