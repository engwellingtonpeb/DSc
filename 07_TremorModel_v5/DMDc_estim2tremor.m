%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo, DSc.                              %         
%  Date: 15/10/2023                                                       %
%  Last Update: DSc - Version 2.0                                         %
%-------------------------------------------------------------------------%
%   Identificação de Sistemas usando DMDc para uso no MPC                 % 
%                                                                         %
%  e-stim-->[MODELO]-->x=[a,Theta]                                        %
%                                                                         %
%-------------------------------------------------------------------------%
clearvars -except motionData


addpath('D:\02_DSc_v5\DSc\04_DMDc_IDTF\simulations\')
addpath('D:\02_DSc_v5\DSc\04_DMDc_IDTF\utils\')

% Define as saídas selecionadas
x = [motionData.data(1:9001, 19), motionData.data(1:9001, 17), ...
     motionData.data(1:9001, 39), motionData.data(1:9001, 37), ...
     motionData.data(1:9001, 60:73)];

% Define as entradas do sistema a partir de e_stim
u = motionData.e_stim(1:9001, 2:10);

% Define o vetor de tempo
t = motionData.data(1:9001, 1);
ti = motionData.data(1, 1);
tf = motionData.data(end, 1);

% Estado de referência
Nvar = size(x, 2);
xref = zeros(1, Nvar)';
T = length(t);
dt = 1e-3;

% Treinamento do Modelo usando DMDc
Hu = getHankelMatrix_MV(u, 1);
xmean = xref'; 
X = x - repmat(xmean, [T, 1]);
Hx = getHankelMatrix_MV(X, 1);
numOutputs = size(Hx, 1); 
numInputs = size(Hu, 1); 
r1 = size(Hx, 1);
r2 = size(Hx, 1);
[sysDMDc, U, Up] = DelayDMDc_MV(Hx, Hu, size(Hx, 1), size(Hx, 1), dt, size(Hx, 1), size(Hu, 1), 2);



sysDMDc.StateName={'phi','psi','phidot','psidot',...
                    'ae_sup ','ae_ecrl ','ae_ecrb ','ae_ecu ','ae_fcr ','ae_fcu ','ae_pq ',...
                    'p_sup ','p_ecrl ','p_ecrb ','p_ecu ','p_fcr ','p_fcu ','p_pq '};
sysDMDc.InputName={'A_sup','A_ecrl','A_ecrb','A_ecu','A_fcr','A_fcu','A_pq','pw','f'}


% Verificação do modelo treinado
x0 = x(1, :);
[xDMDc, ~] = lsim(sysDMDc, u, t, x0);

% Validação
tval = 9:dt:tf-dt;
uval = motionData.e_stim(9001:end, 2:10);
xval = [motionData.data(9001:end-1, 19), motionData.data(9001:end-1, 17), ...
        motionData.data(9001:end-1, 39), motionData.data(9001:end-1, 37), ...
        motionData.data(9001:end-1, 60:73)];
x0val = xval(1, :);

[xDMDcVal, ~] = lsim(sysDMDc, uval, tval, x0val);

% Plotagem dos resultados e cálculo do erro
figure(1)
set(gcf, 'color', 'w');

% Realize o loop ou crie subplots para cada saída conforme necessário
for i = 1:size(x, 2)
    subplot(6, 3, i)
    output_data = motionData.data(:, [19, 17, 39, 37, 59:72]); % Extraia as colunas especificadas uma vez
    plot(motionData.data(:, 1), output_data(:, i), 'k--', 'Linewidth', 2)
    hold on
    grid
    plot(t, xDMDc(:, i), 'r-.')
    plot(tval, xDMDcVal(:, i), 'g-.', 'Linewidth', 1.5)
    legend('osim', 'trainning', 'validation')
    title(['Saída ' num2str(i)], 'interpreter', 'latex')
end
% 
% % Cálculo do RMSE para validação
% RMSE = sqrt(mean((motionData.data(9001:end, [17, 19, 37, 39, 59:72]) - xDMDcVal).^2));
% meanRMSE = mean(RMSE);
% 
% % Exibe os valores de RMSE
% disp('RMSE para cada saída:');
% disp(RMSE);
% disp('RMSE médio:');
% disp(meanRMSE);
% 
% % Salvar o modelo treinado
% formatOut = 'yyyy/mm/dd/HH/MM/SS';
% date = datestr(now, formatOut);
% date = strrep(date, '/', '_');
% 
% indir = 'D:\06_BiomechCodeRepo\BiomechanicsModeling\DSc2023_v2\simulations';
% filename = strcat(date, '_DMDmodel');
% extension = '.mat';
% modelfilename = fullfile(indir, [filename extension]);
% 
% save(modelfilename, 'sysDMDc');
