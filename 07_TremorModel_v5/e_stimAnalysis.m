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
    Phi_simu=[Phi_simu; rad2deg(motionData.data(1000:end,18))]; %~2000 é o numero da amostra onde entra o oscilador
    Psi_simu=[Psi_simu; rad2deg(motionData.data((1000:end),16))];
    Phidot_simu=[Phidot_simu; rad2deg(motionData.data((1000:end),38))];
    Psidot_simu=[Psidot_simu; rad2deg(motionData.data((1000:end),36))];
    a_ecrl=[a_ecrl; motionData.data((1000:end),44)];  %ativ ECRL
    a_fcu=[a_fcu; motionData.data((1000:end),52)];  %ativ FCU
else
    Phi_simu=[Phi_simu; rad2deg(motionData.data(1000:end,19))]; %~2000 é o numero da amostra onde entra o oscilador
    Psi_simu=[Psi_simu; rad2deg(motionData.data((1000:end),17))];
    Phidot_simu=[Phidot_simu; rad2deg(motionData.data((1000:end),39))];
    Psidot_simu=[Psidot_simu; rad2deg(motionData.data((1000:end),37))];
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

% Display the table
disp(metrics_table);
%% Energy applied for suppression
A=motionData.e_stim(:,1:7);
pw=motionData.e_stim(:,8);
f=motionData.e_stim(:,9);
T=1./f;
% Initialize energy matrix
% E_pulse = zeros(length(Phi_simu), 1); % Energy for each row

% Compute the squared amplitudes and sum along the columns for each row
E_pulse = 2.*(A.^2).*pw; % 1000x1 vector with row-wise sums of squared amplitudes

NumPulse=t_simu(end)/T(7000);
E_total=NumPulse.*sum(E_pulse,1)
Pavg=E_pulse/T(7000);
 
% Pavg=E_pulse/T

%% Fatigue Indications (state)
fatigue=motionData.data(1000:end,66);

figure

plot(t_simu,fatigue)

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