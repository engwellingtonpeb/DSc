%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This function implements the control law for FES tremor suppression     %
%                                                                         %
%                                                                         %
%=========================================================================%
function [ues] = ElectricalStimulationController(SimuInfo,t)


    % if t>2.5 && t<=4
    %     ues=[1 250e-6 1.5];
    % elseif   t>4 && t<=6
    %     ues=[1 250e-6 10];
    % elseif   t>6 && t<=7    
    %     ues=[1 250e-6 5];
    % else
    %     ues=[1 100e-6 20];
    % end


    A=zeros(7,1);

    freq=20; %Hz
    f=freq*ones(7,1);
    
    if t<2
        pw=[250e-6;... %sup
            100e-6;... %ecrl
            100e-6;... %ecrb
            100e-6;... %ecu
            100e-6;... %fcr
            100e-6;... %fcu
            100e-6];   %pq

    else
        pw=[100e-6;... %sup
            100e-6;... %ecrl
            100e-6;... %ecrb
            100e-6;... %ecu
            100e-6;... %fcr
            100e-6;... %fcu
            100e-6];   %pq

    
    end




    ues=[A, pw, f];

end