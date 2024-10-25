%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% It implements modeled tremor suppression using co-contraction           %
%                                                                         %
%                                                                         %
%=========================================================================%
function [Ua, Upw, Uf] = OF_strategy(t)

    f=9;
    theta=[0, pi];
  
    % Saídas de controle
    Ua(1)=0;%20e-3*max(square(2*pi*f*t+theta(1)),0);
    
    Ua(2)=20e-3*max(square(2*pi*f*t+theta(1)),0); %extensor

    Ua(3)=20e-3*max(square(2*pi*f*t+theta(2)),0); %flexor

    Ua(4)=0;%20e-3*max(square(2*pi*f*t+theta(1)),0);
    
    
    Uf = 20;
    Upw = 250e-6;%pw;


end