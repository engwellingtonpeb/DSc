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
function [Ua, Upw, Uf] = CC_strategy()

  
  
    % Saídas de controle
    Ua = 20e-3.*ones(4,1); %amp;  % Amplitudes independentes
    Uf = 20;
    Upw = 250e-6;%pw;


end
