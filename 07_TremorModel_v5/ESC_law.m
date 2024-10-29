%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This function implements Extremum Seeking Control Law to the electrical %
% stimulation protocol. Manipulating amplitudes, pulse width and freq to  %
% minimize tremor Energy                                                  %
%                                                                         %
%                                                                         %
%=========================================================================%
function [Ua, Upw, Uf] = ESC_law(t, E, SimuInfo)

persistent amp_history pw_history counter freq_history J_history a k omega amp pw freq phase_shift_amp

    if t == SimuInfo.TStim_ON
        counter = 0;
        
        % Inicialização dos parâmetros
        amp = 20e-3.*ones(4,1);  % Amplitudes iniciais [amp1; amp2; amp3; amp4] [mA]
        pw = 250e-6;             % Largura de pulso inicial [microsegundos]
        freq = 20;               % Frequência inicial [Hz]
        
        % Parâmetros do controlador (ajustados)
        omega = [100 100 100 100 100 100];  % Frequências de perturbação ajustadas
        k = [1e-1 1e-2 1e-2];                 % Ganho do controlador ajustado
        a = [1e-3 10e-6 0.5];                % Amplitude das perturbações ajustadas
        
        % Inicialização das defasagens (fase) para cada amplitude
        %phase_shift_amp = [0 pi/2 0 0];    % Defasagem inicial de 0 para cada amplitude
    end
    
    % Inicialização das variáveis filtradas
    grad_amp_filt = zeros(4,1);
    grad_pw_filt = 0;
    grad_freq_filt = 0;

    % Perturbações com defasagem independente para cada amplitude
    d_amp(1) = a(1) * sin(omega(1) * t );
    d_amp(2) = a(1) * sin(omega(2) * t );
    d_amp(3) = a(1) * sin(omega(3) * t );
    d_amp(4) = a(1) * sin(omega(4) * t );

    d_pw = a(2) * sin(omega(5) * t);
    d_freq = a(3) * sin(omega(6) * t);
    
    % Atualização de parâmetros com perturbações
    amp = amp + d_amp';
    pw= pw + d_pw;
    freq = freq + d_freq;

    % Função de custo unificada que combina energia do tremor e erro de setpoint
    Q1 = diag([1e3, 1e3, 1e3, 1e3]);
    Q2 = diag([1e2, 1e2, 1e2, 1e2]);
    tremor_cost = E(1:4) * Q1 * E(1:4)';          % Custo baseado na energia do tremor
    error_cost = E(5:end) * Q2 * E(5:end)';       % Custo baseado no erro de setpoint
    J = tremor_cost + error_cost;                % Função de custo combinada

    % Cálculo dos gradientes de forma independente para cada amplitude
    for j = 1:4
        grad_amp(j) = J * sin(omega(j) * t);
    end
    grad_pw = J * sin(omega(5) * t);
    grad_freq = J * sin(omega(6) * t);

    % Aplicação de filtragem para suavizar os gradientes
    alpha = .99;  % Constante de filtragem
    grad_amp_filt = alpha * grad_amp_filt + (1 - alpha) * grad_amp';
    grad_pw_filt = alpha * grad_pw_filt + (1 - alpha) * grad_pw;
    grad_freq_filt = alpha * grad_freq_filt + (1 - alpha) * grad_freq;

    % Atualização dos parâmetros de controle de forma independente
    amp =   amp - k(1) * grad_amp_filt * SimuInfo.Ts;
    pw =    pw - k(2) * grad_pw_filt * SimuInfo.Ts;
    freq =  freq - k(3) * grad_freq_filt * SimuInfo.Ts;
    
    % Saturação para garantir que os sinais de controle não sejam negativos ou excedam os limites
    amp =  max(min(amp, 40e-3), 0);    % Saturação das amplitudes entre 0 e 40 mA
    pw =   max(min(pw, 500e-6), 0);     % Saturação da largura de pulso entre 0 e 500 µs
    freq = max(min(freq, 50), 0);     % Saturação da frequência entre 0 e 50 Hz

    % Saídas de controle
    Ua = amp;    %20e-3.*ones(4,1); %amp;  % Amplitudes independentes
    Uf = freq;
    Upw = pw;    %250e-6;%pw;

    counter = counter + 1;

end
