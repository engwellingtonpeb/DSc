%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This function implements Model Predictive Control Law to the electrical %
% stimulation protocol. Manipulating amplitudes, pulse width and freq to  %
% minimize tremor Energy                                                  %
%                                                                         %
%                                                                         %
%=========================================================================%
function [Ua, Upw, Uf] = MPC_law(t, E, SimuInfo)

    %% Define MPC Parameters
    Ts = SimuInfo.Ts; % Sampling time [s]
    PredictionHorizon = 20;
    ControlHorizon = 10;

    % Limits for the output variables: [f; pw; I_ch1; I_ch2; I_ch3; I_ch4]
    LowerLimit = [10; 150e-6; 4e-3; 4e-3; 4e-3; 4e-3];
    UpperLimit = [40; 500e-6; 40e-3; 40e-3; 40e-3; 40e-3];


    %% Plant Setup
    % Define a non-linear model for wrist dynamics
    % For simplicity, we use a linear approximation in the MPC controller design
    A = [0 1 0 0;
         0 -0.1 0 0;
         0 0 0 1;
         0 0 -0.1 0]; % Linearized state matrix
    B = [0 0 0 0 0 0;
         1 1 1 1 1 1;
         0 0 0 0 0 0;
         1 1 1 1 1 1]; % Linearized input matrix
    C = eye(4); % Output matrix
    D = zeros(4, 6); % Direct transmission matrix

    % Define state-space representation
    plant = ss(A, B, C, D);

    %% Create Optimization Problem
    % Define cost function weights
    Q = diag([1 1 1 1]); % Weight matrix for state variables
    R = diag([1 1 1 1 1 1]); % Weight matrix for control inputs

end