%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% Implements Matsuoka's Oscillator based on:                              %
%                                                                         %
% [1] MATSUOKA, Kiyotoshi. Analysis of a neural oscillator.               %
% Biological cybernetics, v. 104, p. 297-304, 2011.                       %
%                                                                         %
% [2] ZHANG, Dingguo et al. Neural oscillator based control for           %
% pathological tremor suppression via functional electrical stimulation.  %
% Control Engineering Practice, v. 19, n. 1, p. 74-88, 2011.              %
%                                                                         %
% [3] GRIMALDI, Giuliana; MANTO, Mario (Ed.). Mechanisms and Emerging     %
% Therapies in Tremor Disorders. Springer Science & Business Media, 2012. %
%=========================================================================%

function [xosc_dot] = MatsuokaOscilator(t,SimuInfo)

switch SimuInfo.Tremor
    case 'on'

        persistent Kf
        persistent j1
        
        % B=SimuInfo.ModelParams(7); %beta
        % h=SimuInfo.ModelParams(8); %h
        % rosc=SimuInfo.ModelParams(9); %rosc
        % tau1=SimuInfo.ModelParams(10);%tau1
        % tau2=SimuInfo.ModelParams(19);%tau2
        
        y1=SimuInfo.du(1);
        y2=SimuInfo.du(2);
        
        x1=SimuInfo.Xk(55);
        v1=SimuInfo.Xk(56);
        x2=SimuInfo.Xk(57);
        v2=SimuInfo.Xk(58);
        
        tau1=.01;
        tau2=.01;
        B=2.5;
        A=5;
        h=2.5;
        rosc=1;
        
        if (t==0)
            j1=0;
            Kf=4;
        
            x1=normrnd(.5,0.25);
            x2=normrnd(.5,0.25); %valor inicial [0,1]
            v1=normrnd(.5,0.25);
            v2=normrnd(.5,0.25);
        
        elseif (rem(j1,1000)==0)
        
            P=randsample(SimuInfo.P,1);
            Kf=(1/(2*pi*P))*sqrt(1/(tau1*tau2)); 
        
        
        end
            j1=j1+1;
        
        
        
        s1=0;
        s2=0;
        
        
        x1dot=(1/(Kf*tau1))*(-x1-B*v1-h*y2+A*s1+rosc);
        v1dot=(1/(Kf*tau2))*(-v1+y1);
        
        x2dot=(1/(Kf*tau1))*(-x2-B*v2-h*y1-A*s2+rosc);
        v2dot=(1/(Kf*tau2))*(-v2+y2);
        
        
        xosc_dot=[x1dot;...
                  v1dot;...
                  x2dot;...
                  v2dot];

    otherwise
        xosc_dot=zeros(4,1);
end