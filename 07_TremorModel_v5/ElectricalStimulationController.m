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
function [ues] = ElectricalStimulationController(E,SimuInfo,t)


if t<SimuInfo.TStim_ON || strcmp(SimuInfo.FESProtocol,'none') % it avoids electrical stimulation starts almost simultaneously to tremor. 

    freq=0; %Hz
    A=[ 0;... %sup
        0;... %ecrl
        0;... %ecrb
        0;... %ecu
        0;... %fcr
        0;... %fcu
        0];   %pq
    
    pw=0;

else
    switch SimuInfo.FESProtocol
        
        case 'RL'

            freq=SimuInfo.Action(1);
            pw=SimuInfo.Action(2);
    
            A=[ SimuInfo.Action(6);... %sup
                SimuInfo.Action(3);... %ecrl
                SimuInfo.Action(3);... %ecrb
                0;... %ecu
                SimuInfo.Action(4);... %fcr
                SimuInfo.Action(4);... %fcu
                SimuInfo.Action(5)];   %pq


        case 'ESC'
            [Ua, Upw, Uf] = ESC_law(t, E, SimuInfo)

            freq=Uf;
            pw=Upw;
            
            % A=[ Ua(1);... %sup
            %     Ua(2);... %ecrl
            %     0;... %ecrb
            %     0;... %ecu
            %     Ua(3);... %fcr
            %     0;... %fcu
            %     Ua(4)];   %pq

            A=[ 0*Ua(1);... %sup % funcionou legal 
                1*Ua(2);... %ecrl
                1*Ua(2);... %ecrb
                0*Ua(2);... %ecu
                0*Ua(3);... %fcr
                1*Ua(3);... %fcu
                1*Ua(4)];   %pq

        case 'CC'
            [Ua, Upw, Uf] = CC_strategy()

            freq=Uf;
            pw=Upw;
            
            % A=[ Ua(1);... %sup
            %     Ua(2);... %ecrl
            %     0;... %ecrb
            %     0;... %ecu
            %     Ua(3);... %fcr
            %     0;... %fcu
            %     Ua(4)];   %pq

            A=[ 0*Ua(1);... %sup % funcionou legal 
                1*Ua(2);... %ecrl
                1*Ua(2);... %ecrb
                0*Ua(2);... %ecu
                0*Ua(3);... %fcr
                1*Ua(3);... %fcu
                1*Ua(4)];   %pq

        case 'OF'
            [Ua, Upw, Uf] = OF_strategy(t)

            freq=Uf;
            pw=Upw;
            
            % A=[ Ua(1);... %sup
            %     Ua(2);... %ecrl
            %     0;... %ecrb
            %     0;... %ecu
            %     Ua(3);... %fcr
            %     0;... %fcu
            %     Ua(4)];   %pq

            A=[ 0*Ua(1);... %sup % funcionou legal 
                1*Ua(2);... %ecrl
                1*Ua(2);... %ecrb
                0*Ua(2);... %ecu
                0*Ua(3);... %fcr
                1*Ua(3);... %fcu
                1*Ua(4)];   %pq

        case 'MPC'
            [Ua, Upw, Uf] = MPC_law(t, E, SimuInfo);

                        freq=Uf;
            pw=Upw;
            
            A=[ Ua(1);... %sup
                Ua(2);... %ecrl
                0;... %ecrb
                0;... %ecu
                Ua(3);... %fcr
                0;... %fcu
                Ua(4)];   %pq

    end


end





        
        
        
        % if t==0
        %     pyenv('Version', 'C:\Users\engwe\anaconda3\envs\mat_py\python.exe');
        % end

        

    






    

    ues=[A, pw*ones(7,1), freq*ones(7,1)];
    % Python Parsing data
    % Xk_py=py.numpy.array(SimuInfo.Xk);
    % [result]=pyrunfile("MPCteste.py", "ReturnList", xk=Xk_py, time=t);
    % StimuliCommand=double(result)';
    % 
    % ues=[StimuliCommand(1:7), StimuliCommand(8)*ones(7,1), StimuliCommand(9)*ones(7,1),];
end