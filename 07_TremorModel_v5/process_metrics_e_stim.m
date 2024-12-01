% Selecionar manualmente múltiplos arquivos .mat
[fileNames, pathName] = uigetfile('*.mat', 'Selecione os arquivos .mat', 'MultiSelect', 'on');

% Verificar se apenas um arquivo foi selecionado e ajustá-lo para um cell array
if ischar(fileNames)
    fileNames = {fileNames};
end

% Inicializar a tabela final vazia
tableFinal = table();

% Loop sobre cada arquivo selecionado
for i = 1:length(fileNames)
    % Carregar o arquivo .mat
    filePath = fullfile(pathName, fileNames{i});
    matData = load(filePath);
    
    % Verificar se a variável do arquivo é uma tabela
    varNames = fieldnames(matData);
    for j = 1:length(varNames)
        if istable(matData.(varNames{j}))
            currentTable = matData.(varNames{j});
            
            % Normalizar os dados importados
            dataArray = table2array(currentTable);
            
            % Normalizar colunas 3-9 entre si
            dataArray(:, 3:9) = dataArray(:, 3:9)./max(dataArray(:, 3:9));
            
            % Normalizar colunas 10-13 entre si
            dataArray(:, 10:13) = dataArray(:, 10:13)./max(dataArray(:, 10:13));
            
            % Normalizar colunas 14-17 entre si
            dataArray(:, 14:17) = dataArray(:, 14:17)./max(dataArray(:, 14:17));
            
            % Converter de volta para tabela
            currentTable = array2table(dataArray, 'VariableNames', currentTable.Properties.VariableNames);
            
            % Empilhar a tabela atual na tabela final
            tableFinal = [tableFinal; currentTable];
        end
    end
end

% Mostrar a tabela empilhada
disp(tableFinal);

% Salvar a tabela empilhada se necessário
% save('tableFinal.mat', 'tableFinal');
