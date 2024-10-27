%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This function methods to calculate tremor energy into an specific time  %
% sliding window                                                          %
%                                                                         %
%=========================================================================%
function [E] = SlidingWindowEnergies(newData, SimuInfo)

   persistent signalBuffer bufferIndex bufferSize

   newData=newData((5:8),1)';

    % Inicializa o buffer na primeira chamada
    if isempty(signalBuffer)
        Ts = SimuInfo.Ts;    % Período de amostragem
        Fs = 1 / Ts;         % Frequência de amostragem
        samplesInOneSecond = round(Fs * 1); % Número de amostras em 1 segundo

        bufferSize = samplesInOneSecond;
        signalBuffer = zeros(bufferSize, size(newData, 2)); % Pré-aloca o buffer
        bufferIndex = 1;
    end

    % Determina o número de novas amostras
    numNewSamples = size(newData, 1);

    % Atualiza o buffer circularmente
    for i = 1:numNewSamples
        signalBuffer(bufferIndex, :) = newData(i, :);
        bufferIndex = bufferIndex + 1;
        if bufferIndex > bufferSize
            bufferIndex = 1;
        end
    end

    % Retorna o buffer reorganizado
    if bufferIndex == 1
        lastOneSecondSignal = signalBuffer;
    else
        lastOneSecondSignal = [signalBuffer(bufferIndex:end, :); signalBuffer(1:bufferIndex - 1, :)];
    end


E=bandpower((lastOneSecondSignal-mean(lastOneSecondSignal)),1/SimuInfo.Ts,[3 8]);
% SimuInfo.TremorEnergy=E;

end


