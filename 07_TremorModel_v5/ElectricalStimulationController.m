%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This function selects the control law for FES tremor suppression        %
%                                                                         %
% It also includes the cross-coupled stimulation dynamics among           %
% electrodes                                                              %
%=========================================================================%
function [ues] = ElectricalStimulationController(SimuInfo,t)



switch SimuInfo.RLTraining

    case 'on'
        if t>=3

            freq=SimuInfo.Action(1);
            pw=SimuInfo.Action(2);
    
            A=[ SimuInfo.Action(6);... %sup
                SimuInfo.Action(3);... %ecrl
                0;... %ecrb
                0;... %ecu
                SimuInfo.Action(4);... %fcr
                0;... %fcu
                SimuInfo.Action(5)];   %pq
        else

            A=[ 0;... %sup
                0;... %ecrl
                0;... %ecrb
                0;... %ecu
                0;... %fcr
                0;... %fcu
                0];   %pq
    
            pw=0;
            freq=40; %Hz
          
        end

    case 'ESC'
        [Ua, Upw, Uf] = ESC_law(t, E, SimuInfo)




    otherwise
        % if t==0
        %     pyenv('Version', 'C:\Users\engwe\anaconda3\envs\mat_py\python.exe');
        % end

        freq=40; %Hz

    
        if t<3 % it avoids electrical stimulation starts almost simultaneously to tremor. 
    
            A=[ 0;... %sup
                0;... %ecrl
                0;... %ecrb
                0;... %ecu
                0;... %fcr
                0;... %fcu
                0];   %pq
    
            pw=0;
    
        else
    
            A=[ 0;... %sup
                0;... %ecrl
                0;... %ecrb
                0;... %ecu
                0;... %fcr
                0;... %fcu
                0];   %pq
    
            pw=0;
    
    
        end

end



    ues=[A, pw*ones(7,1), freq*ones(7,1)];



 % Python Parsing data
    % Xk_py=py.numpy.array(SimuInfo.Xk);
    % [result]=pyrunfile("MPCteste.py", "ReturnList", xk=Xk_py, time=t);
    % StimuliCommand=double(result)';
    % 
    % ues=[StimuliCommand(1:7), StimuliCommand(8)*ones(7,1), StimuliCommand(9)*ones(7,1),];
end