function [state, options, optchanged] = gaOutputFunc(options, state, flag)
    persistent history cost lastTime bestCost bestParams
    optchanged = false;
    
    % Abrir arquivo de log global
    global logFilename
    fid = fopen(logFilename, 'a');
    
    % Registro de tempo
    currentTime = datetime('now');
    if isempty(lastTime)
        lastTime = currentTime; % Inicializa o tempo na primeira chamada
    else
        elapsedTime = seconds(currentTime - lastTime);
        fprintf('Tempo entre chamadas: %.2f segundos\n', elapsedTime);
        lastTime = currentTime; % Atualiza o último tempo
    end
    
    % Imprimir população e custo da geração atual no log
    Gen = [state.Population, state.Score];
    for i = 1:length(state.Score)
        fprintf(fid, '%s\n', mat2str(Gen(i, :)));
    end
    fclose(fid);
    
    % Determinar o melhor custo e parâmetros até o momento
    [currentBestCost, idx] = min(state.Score);
    currentBestParams = state.Population(idx, :);
    
    if isempty(bestCost) || currentBestCost < bestCost
        bestCost = currentBestCost;
        bestParams = currentBestParams;
    end
    
    % Exibir o melhor vetor de parâmetros e custo até o momento
    fprintf('Melhor custo até agora: %.4f\n', bestCost);
    fprintf('Melhor vetor de parâmetros: %s\n', mat2str(bestParams));
    
    % Armazenar histórico conforme o estado da otimização
    switch flag
        case 'init'
            history(:,:,1) = state.Population;
            cost(:,1) = state.Score;
        case {'iter', 'interrupt'}
            ss = size(history, 3);
            history(:,:,ss + 1) = state.Population;
            cost(:,ss + 1) = state.Score;
        case 'done'
            ss = size(history, 3);
            history(:,:,ss + 1) = state.Population;
            cost(:,ss + 1) = state.Score;
            
            % Salvar o histórico e o custo
            global GAResultsPath PatientID

            dateStr = datestr(datetime('now'), 'yyyy_mm_dd_HH_MM_SS');
            folderPath = fullfile(GAResultsPath, [dateStr,PatientID,'_GA.mat']);
            save(folderPath, 'history', 'cost');
            %save('history.mat', 'history', 'cost');


% Close any open file identifiers
fclose('all');
    end
    
    % Função de plotagem opcional
    gaPlotFunc(state.Generation, cost);
end




% function[state, options, optchanged]= gaOutputFunc(options,state,flag)
% %UNTITLED Summary of this function goes here
% %   Detailed explanation goes here
% persistent history
% persistent cost
% optchanged = false;
% 
% Gen=[state.Population,state.Score];
%  global logFilename
% 
%  fid=fopen(logFilename, 'a')
%  for i=1:length(state.Score)
%     %fprintf(fid, '%.5s %.5s %.5s %.5s %.5s %.5s %.5s %.5s - %.5s\n',Gen{i,1},Gen{i,2},Gen{i,3},Gen{i,4},Gen{i,5},Gen{i,6},Gen{i,7},Gen{i,8},Gen{i,9});
%      fprintf(fid, '%s\n',mat2str(Gen(i,:)));
%  end
% 
% 
% 
% 
% switch flag
%     case 'init'
%         history(:,:,1) = state.Population;
%         cost(:,1) = state.Score;
%     case {'iter','interrupt'}
%         ss = size(history,3);
%         history(:,:,ss+1) = state.Population;
%         cost(:,ss+1) = state.Score;
%     case 'done'
%         ss = size(history,3);
%         history(:,:,ss+1) = state.Population;
%         cost(:,ss+1) = state.Score;
% 
%         date = datestr(datetime('now')); 
%         date=regexprep(date, '\s', '_');
%         date=strrep(date,':','_');
%         date=strrep(date,'-','_');
%         date=strcat(date,'_');
%         string1=strcat(date,'GA')
% 
% 
%         folder1=strcat('D:\02_DSc_v5\DSc\07_TremorModel_v5\Tuning_Feature',string1);
% 
%         save(folder1,'history', 'cost')
% 
%         save history.mat history cost
%         %close all hidden
% 
% 
% 
% 
%         %save history.mat history cost
% end
% 
% gaPlotFunc(state.Generation,cost)
% 
% 
% 
% end