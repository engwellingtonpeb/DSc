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
%Ua - Amplitudes
%Upw - pulse widths
%Uf - frequency
    
    if t=0
        % Inicialização dos parâmetros
        amp = zeros(4,1); % Amplitudes iniciais [amp1; amp2; amp3; amp4]
        pw = 0;           % Largura de pulso inicial
        freq = 0;         % Frequência inicial
    


        % Parâmetros do controlador
        omega = [1; 1; 1; 1; 1; 1]; % Frequências das perturbações (rad/s)
        k = 0.1;                    % Ganho do controlador
        % Sinais de perturbação
        a = 0.01; % Amplitude das perturbações
    
        % Inicialização dos registros
        N = length(t);
        amp_history = zeros(4,N);
        pw_history = zeros(1,N);
        freq_history = zeros(1,N);
        J_history = zeros(1,N);
    
        % Inicialização das variáveis filtradas
        grad_amp_filt = zeros(4,1);
        grad_pw_filt = 0;
        grad_freq_filt = 0;

    end

        % Sinais de perturbação
        d_amp = a * sin(omega(1:4) * t(i));
        d_pw = a * sin(omega(5) * t(i));
        d_freq = a * sin(omega(6) * t(i));
        
        % Parâmetros perturbados
        amp_perturbed = amp + d_amp;
        pw_perturbed = pw + d_pw;
        freq_perturbed = freq + d_freq;

    % Demodulação
    y = E; % Supondo que J é escalar
    for j = 1:4
        grad_amp(j) = y * sin(omega(j) * t(i));
    end
    grad_pw = y * sin(omega(5) * t(i));
    grad_freq = y * sin(omega(6) * t(i));
    
    % Filtragem (opcional)
    % if i > 1
    %     grad_amp_filt = filter(b, a_filt, grad_amp);
    %     grad_pw_filt = filter(b, a_filt, grad_pw);
    %     grad_freq_filt = filter(b, a_filt, grad_freq);
    % else
        grad_amp_filt = grad_amp;
        grad_pw_filt = grad_pw;
        grad_freq_filt = grad_freq;
    % end

    % Atualização dos parâmetros (integração)
    amp = amp - k * grad_amp_filt * dt;
    pw = pw - k * grad_pw_filt * dt;
    freq = freq - k * grad_freq_filt * dt;
    
    % Armazenamento dos dados
    amp_history(:,i) = amp;
    pw_history(i) = pw;
    freq_history(i) = freq;
    J_history(i) = J;

end