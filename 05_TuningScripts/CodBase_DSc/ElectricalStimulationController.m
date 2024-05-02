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

    if t==0
        pyenv('Version', 'C:\Users\engwe\anaconda3\envs\mat_py\python.exe');
    end

    A=zeros(7,1);

    freq=20; %Hz
    f=freq*ones(7,1);
    % 
    % if t<2
    %     pw=[250e-6;... %sup
    %         100e-6;... %ecrl
    %         100e-6;... %ecrb
    %         100e-6;... %ecu
    %         100e-6;... %fcr
    %         100e-6;... %fcu
    %         100e-6];   %pq
    % 
    % else
    %     pw=[100e-6;... %sup
    %         100e-6;... %ecrl
    %         100e-6;... %ecrb
    %         100e-6;... %ecu
    %         100e-6;... %fcr
    %         100e-6;... %fcu
    %         100e-6];   %pq
    % 
    % 
    % end


    Xk=SimuInfo.Xk;

    Xk_py=py.numpy.array(Xk);
    time=t;

    [result]=pyrunfile("MPCteste.py", "ReturnList", xk=Xk_py, time=t);
    class(result);


    ues=[A, double(result{1})', f];

end