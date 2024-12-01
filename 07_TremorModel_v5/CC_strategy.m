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
% parameters based on 
%[1] Gallego JA, Rocon E, Manuel Belda‑Lois J, Pons JL. A neuroprosthesis for
%    tremor management through the control of muscle co‑contraction. J
%    Neuroeng Rehabil. 2013;10:36
%
%[2] Bó APL, Azevedo‑Coste C, Geny C, Poignet P, Fattal C. On the use of fixed‑
%   intensity functional electrical stimulation for attenuating essential tremor.
%   Artif Organs. 2014;38(11):984–91.%                                                                         %
%=========================================================================%
function [Ua, Upw, Uf] = CC_strategy()
    

  
  
    % Saídas de controle
    Ua = 20e-3.*ones(4,1); %amp;  % Amplitudes independentes
    Uf = 40;
    Upw = 250e-6;%pw;


end
