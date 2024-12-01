%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% It implements modeled tremor suppression using out of phase             %
%                                                                         %
%   [1] Maneski LP, Jorgovanović N, Ilić V, Došen S, Keller T, Popović MB,%
% et al. Electrical stimulation for the suppression of pathological       %
% tremor. Med Biol Eng Comput. 2011;49(10):1187–93.                       %
%                                                                         %
%                                                                         %
%=========================================================================%
function [Ua, Upw, Uf] = OF_strategy(t)

    f=40;
    theta=[0, pi];
    A=20e-3;

    % Saídas de controle
    Ua(1)=A*max(square(2*pi*f*t+theta(1)),0);
    
    Ua(2)=A*max(square(2*pi*f*t+theta(1)),0); %extensor

    Ua(3)=A*max(square(2*pi*f*t+theta(2)),0); %flexor

    Ua(4)=A*max(square(2*pi*f*t+theta(2)),0);
    
    
    Uf = f;
    Upw = 250e-6;%pw;


end