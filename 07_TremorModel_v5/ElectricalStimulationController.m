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


    % if t==0
    %     pyenv('Version', 'C:\Users\engwe\anaconda3\envs\mat_py\python.exe');
    % end



    freq=40; %Hz
    f=freq*ones(7,1);

    if t>7

        A=[ .1e-3;... %sup
            40e-3;... %ecrl
            40e-3;... %ecrb
            .1e-3;... %ecu
            .1e-3;... %fcr
            .1e-3;... %fcu
            .1e-3];   %pq



        pw=200e-6;

    else

        A=[ 0;... %sup
            0;... %ecrl
            0;... %ecrb
            0;... %ecu
            0;... %fcr
            0;... %fcu
            0];   %pq

        pw=


    end
    ues=[A, ones(7,1)*pw, f];



 % Python Parsing data
    % Xk_py=py.numpy.array(SimuInfo.Xk);
    % [result]=pyrunfile("MPCteste.py", "ReturnList", xk=Xk_py, time=t);
    % StimuliCommand=double(result)';
    % 
    % ues=[StimuliCommand(1:7), StimuliCommand(8)*ones(7,1), StimuliCommand(9)*ones(7,1),];
end