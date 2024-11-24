 %% Sinais do Modelo

    t_simu=[];
    Phi_simu=[];
    Psi_simu=[];
    Phidot_simu=[];
    Psidot_simu=[];
    a_ecrl=[];
    a_fcu=[];



Phi_simu=[Phi_simu; rad2deg(motionData.data((2000:end),19))]; %~2000 é o numero da amostra onde entra o oscilador
Psi_simu=[Psi_simu; rad2deg(motionData.data((2000:end),17))];
Phidot_simu=[Phidot_simu; rad2deg(motionData.data((2000:end),39))];
Psidot_simu=[Psidot_simu; rad2deg(motionData.data((2000:end),37))];
a_ecrl=[a_ecrl; motionData.data((2000:end),44)];  %ativ ECRL
a_fcu=[a_fcu; motionData.data((2000:end),52)];  %ativ FCU



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
    w1=(floor(N/3));

%spectrogram from simulation


for ij=1:3 %6 JANELAS DE 10 SEGUNDOS
    
    F=0:.1:20;
    overlap=.5*Njan; % 50% overlap
    [s,w,t] =spectrogram(Phidot_simu(((w1*ij-w1+1):(w1*(ij+1)-w1-1)),1),h,overlap,F,Fs_gyro,'yaxis');
    s=abs((s)); %(ANALISE DE JANELAS DE 10 SEGUNDOS)
    s=s./max(max(s)); %normaliza a amplitude (q nao é importante na analise)
    figure(6+ij)
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
  
     
end       