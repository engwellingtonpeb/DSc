close all
clc

%% Sinais do Modelo

t_simu=[];
Phi_simu=[];
Psi_simu=[];
Phidot_simu=[];
Psidot_simu=[];
a_ecrl=[];
a_fcu=[];
ij=1;

if strcmp(SimuInfo.FESProtocol,'RL')
    Phi_simu=[Phi_simu; rad2deg(motionData.data(1000:end-100,18))]; %~2000 é o numero da amostra onde entra o oscilador
    Psi_simu=[Psi_simu; rad2deg(motionData.data((1000:end-100),16))];
    Phidot_simu=[Phidot_simu; rad2deg(motionData.data((1000:end-100),38))];
    Psidot_simu=[Psidot_simu; rad2deg(motionData.data((1000:end-100),36))];
    a_ecrl=[a_ecrl; motionData.data((1000:end-100),44)];  %ativ ECRL
    a_fcu=[a_fcu; motionData.data((1000:end-100),52)];  %ativ FCU
else
    Phi_simu=[Phi_simu; rad2deg(motionData.data(1000:end-100,19))]; %~2000 é o numero da amostra onde entra o oscilador
    Psi_simu=[Psi_simu; rad2deg(motionData.data((1000:end-100),17))];
    Phidot_simu=[Phidot_simu; rad2deg(motionData.data((1000:end-100),39))];
    Psidot_simu=[Psidot_simu; rad2deg(motionData.data((1000:end-100),37))];
    a_ecrl=[a_ecrl; motionData.data((1000:end),44)];  %ativ ECRL
    a_fcu=[a_fcu; motionData.data((1000:end),52)];  %ativ FCU


end


Ts=SimuInfo.Ts;
t_simu=0:Ts:(length(Phi_simu)-1)*Ts;

% spectrogram from simulation
Fs_simu=1/Ts;
ts_simu=Ts;
Tjan=1;
Njan=round(Tjan/ts_simu); %qtd ptos na janela
r=rectwin(Njan);%Define janela RETANGULAR de comprimento Njan
h=hamming(Njan);%Define janela HAMMING de comprimento Njan
N=length(Phidot_simu);
specwin=round(N/(10*Njan));

w1=N;%(floor(N/specwin));

%% spectrogram flexion-extension
figure(1)
F=0:.1:20;
overlap=.5*Njan; % 50% overlap
[s,w,t] =spectrogram(Phidot_simu(((w1*ij-w1+1):(w1*(ij+1)-w1-1)),1),h,overlap,F,Fs_simu,'yaxis');
s=abs((s)); %(ANALISE DE JANELAS DE 10 SEGUNDOS)
s=s./max(max(s)); %normaliza a amplitude (q nao é importante na analise)

% Configure the figure background color to white
set(gcf, 'Color', 'w');

surf( t, w, s );
% Set view to 2D by rotating to look directly at the 'xy' plane
view(-90.2, 90); % This sets the view to look directly down from above

ylabel('Frequência(Hz)')
xlabel('Tempo(s)')
zlabel('Amplitude')
colormap jet
% Customize the axes
set(gca, 'FontSize', 36); % Set font size

% Add a dashed vertical line at SimuInfo.TStim_ON
hold on; % Ensure the line is added on the same plot
line([SimuInfo.TStim_ON-1 SimuInfo.TStim_ON-1], [min(w) max(w)], [1 1], ...
'LineStyle', '-.', 'Color', 'r', 'LineWidth', 3); % Dashed line
hold off;
 

%% Suppression percentile
s1=s(:,15:end); % remove max parte no inicio da simulacao que eh igual a 1 (normalizado)
suppression_flex_mean=100*(1-max(max(s1)));


%% spectrogram pronation-suppination
figure(2)   
F=0:.1:20;
overlap=.5*Njan; % 50% overlap
[s,w,t] =spectrogram(Psidot_simu(((w1*ij-w1+1):(w1*(ij+1)-w1-1)),1),h,overlap,F,Fs_simu,'yaxis');
s=abs((s)); %(ANALISE DE JANELAS DE 10 SEGUNDOS)
s=s./max(max(s)); %normaliza a amplitude (q nao é importante na analise)

% Configure the figure background color to white
set(gcf, 'Color', 'w');

surf( t, w, s );
% Set view to 2D by rotating to look directly at the 'xy' plane
view(-90.2, 90); % This sets the view to look directly down from above

ylabel('Frequência(Hz)')
xlabel('Tempo(s)')
zlabel('Amplitude')
colormap jet
% Customize the axes
set(gca, 'FontSize', 36); % Set font size

% Add a dashed vertical line at SimuInfo.TStim_ON
hold on; % Ensure the line is added on the same plot
line([SimuInfo.TStim_ON-1 SimuInfo.TStim_ON-1], [min(w) max(w)], [1 1], ...
'LineStyle', '-.', 'Color', 'r', 'LineWidth', 3); % Dashed line
hold off;

%% Suppression percentile
s2=s(:,15:end); % remove max parte no inicio da simulacao que eh igual a 1 (normalizado)
suppression_pro_mean=100*(1-max(max(s2)));

% Create a table
metrics_table = table(suppression_flex_mean, suppression_pro_mean, ...
    'VariableNames', {'Percent_Suppress_Flexion', 'Percent_Suppress_Prosup'});

%% Energy applied for suppression
idx=round(SimuInfo.TStim_ON/SimuInfo.Ts);
A=motionData.e_stim(idx:end,1:7);
pw=motionData.e_stim(idx:end,8);
f=motionData.e_stim(idx:end,9);
T=1./f;
% Check for infinite or zero frequencies
T(isinf(T)) = 1e-6; % Avoid invalid values

%2-Norm per period
t_inicial= SimuInfo.TStim_ON;
N=length(pw);
t_final=(N*SimuInfo.Ts)+t_inicial;
t_norm=t_inicial:SimuInfo.Ts:t_final;

Nperiodos=floor((t_final-t_inicial)/mean(T));
norm2_W=[];
for i=1:Nperiodos
idx_i=((i-1)*(T(10)/SimuInfo.Ts))+1;
idx_f=(i)*(T(10)/SimuInfo.Ts);

    norma=[];
    for ch=1:size(A,2)
    
        A_n=mean(A(idx_i:idx_f,ch)); %mean of a constant
        pw_n=mean(pw(idx_i:idx_f));
        
        norm2_win=A_n*(sqrt(2*pw_n));
        
        norma=[norma,norm2_win];
    
    
    end
norm2_W=[norm2_W; norma];
end

%2-Norm full stim
norm2_fullStim=mean(A)*sqrt(2*Nperiodos*mean(pw));


% Append new metrics to the existing table
new_metrics = table(norm2_fullStim(1), norm2_fullStim(2), norm2_fullStim(3), norm2_fullStim(4), norm2_fullStim(5), ...
    norm2_fullStim(6), norm2_fullStim(7), 'VariableNames', ...
    {'N2_ch1_sup', 'N2_ch2_ecrl', 'N2_ch3_ecrb', 'N2_ch4_ecu', 'N2_ch5_fcr', 'N2_ch6_fcu', 'N2_ch7_pq'});
metrics_table = [metrics_table, new_metrics];



%% Activation and Fatigue Metrics

fatigue = motionData.data(1000:end-100, 66:72);

figure;
set(gcf, 'Color', 'w'); % Configure the figure background color to white
hold on;
plot(t_simu, fatigue(:, 1), 'LineWidth', 2);
plot(t_simu, fatigue(:, 2), 'LineWidth', 2);
plot(t_simu, fatigue(:, 3), 'LineWidth', 2);
plot(t_simu, fatigue(:, 4), 'LineWidth', 2);
plot(t_simu, fatigue(:, 5), 'LineWidth', 2);
plot(t_simu, fatigue(:, 6), 'LineWidth', 2);
plot(t_simu, fatigue(:, 7), 'LineWidth', 2);
hold off;

legend({'SUP', 'ECRL', 'ECRB', 'ECU', 'FCR', 'FCU', 'PQ'});
xlabel('Time (s)');
ylabel('Fatigue Level');
grid on;



a0=motionData.data(5000:end-100, 48:54); % physiologic base activation perturbed by oscillator
ae=motionData.data(5000:end-100, 59:65); % activation due to electrical stimulation
p=motionData.data(5000:end-100, 66:72); % fatigue weighting function

aes=ae.*p;
a=aes+a0;



% Append new metrics to the existing table
new_metrics = table(norm(a(:,1),2), norm(a(:,2),2), norm(a(:,3),2), norm(a(:,4),2), norm(a(:,5),2), ...
    norm(a(:,6),2), norm(a(:,7),2), 'VariableNames', ...
    {'N2_asup', 'N2_aecrl', 'N2_aecrb', 'N2_aecu', 'N2_afcr', 'N2_afcu', 'N2_apq'});
metrics_table = [metrics_table, new_metrics];


% Append new metrics to the existing table
new_metrics = table(norm(aes(:,1),2), norm(aes(:,2),2), norm(aes(:,3),2), norm(aes(:,4),2), norm(aes(:,5),2), ...
    norm(aes(:,6),2), norm(aes(:,7),2), 'VariableNames', ...
    {'N2_aessup', 'N2_aesecrl', 'N2_aesecrb', 'N2_aesecu', 'N2_aesfcr', 'N2_aesfcu', 'N2_aespq'});
metrics_table = [metrics_table, new_metrics];


% Display the table
disp(metrics_table);


%% Limit Cycles ON/OFF and Time series - ON/OFF
   
% First plot
figure
set(gcf, 'Color', 'w'); % Configure the figure background color to white

% Define variables
sampleStimStarts = (SimuInfo.TStim_ON - 1) / SimuInfo.Ts; % Sample index where stimulation starts
fontSize = 14; % Font size for all axes

% Plot 1: Phi_simu vs Phidot_simu
subplot(2, 2, 1)
plot(Phi_simu(1:sampleStimStarts), Phidot_simu(1:sampleStimStarts), ...
    'b', 'LineWidth', 1.5, 'Color', [0, 0, 1, 0.1]); % Before stimulation
hold on
plot(Phi_simu(sampleStimStarts:end), Phidot_simu(sampleStimStarts:end), ...
    'r', 'LineWidth', 1.5, 'Color', [1, 0, 0, 0.9]); % After stimulation
grid on
set(gca, 'FontSize', fontSize);

% Plot 2: Psi_simu vs Psidot_simu
subplot(2, 2, 3)
plot(Psi_simu(1:sampleStimStarts), Psidot_simu(1:sampleStimStarts), ...
    'b', 'LineWidth', 1.5, 'Color', [0, 0, 1, 0.1]); % Before stimulation
hold on
plot(Psi_simu(sampleStimStarts:end), Psidot_simu(sampleStimStarts:end), ...
    'r', 'LineWidth', 1.5, 'Color', [1, 0, 0, 0.9]); % After stimulation
grid on
set(gca, 'FontSize', fontSize);

% Plot 3: t_simu vs Phi_simu
subplot(2, 2, 2)
plot(t_simu(1:sampleStimStarts), Phi_simu(1:sampleStimStarts), ...
    'b', 'LineWidth', 1); % Before stimulation
hold on
plot(t_simu(sampleStimStarts:end), Phi_simu(sampleStimStarts:end), ...
    'r', 'LineWidth', 1); % After stimulation
grid on
set(gca, 'FontSize', fontSize);

% Plot 4: t_simu vs Psi_simu
subplot(2, 2, 4)
plot(t_simu(1:sampleStimStarts), Psi_simu(1:sampleStimStarts), ...
    'b', 'LineWidth', 1); % Before stimulation
hold on
plot(t_simu(sampleStimStarts:end), Psi_simu(sampleStimStarts:end), ...
    'r', 'LineWidth', 1); % After stimulation
grid on
set(gca, 'FontSize', fontSize);

%% 

% Save the table with the specified filename format
paciente = input('Digite o nome do paciente: ', 's');
time_str = datestr(now, 'YYYY_mm_DD_HHMM');
tecnica = SimuInfo.FESProtocol;
filename = sprintf('%s_%s_%s_%s_%s', time_str(1:4), time_str(6:7), time_str(9:10), time_str(12:end), paciente, tecnica);
filename = strcat(filename, '.mat');
save(filename, 'metrics_table');