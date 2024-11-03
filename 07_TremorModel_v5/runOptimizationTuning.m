%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo, DSc.                              %         
%  Date: 31/10/2024                                                       %
%  Last Update:                                                           %
%  DSc - Version 3.0                                                      %
%-------------------------------------------------------------------------%
%   GA optimization to Hinf sinthesis                                     %
%                                                                         %
%                                                                         %
%------------------------------------------------------------------------ %



%Initial Gain Guess
ModelParams=zeros(1,25);
nvars=length(ModelParams);

% ModelParams = [x1-x6]  -  Hinf controller synthesis
% ModelParams = [x7-x13] - [B  h   rosc  tau1 tau2 A1 A2] params matsuoka's oscillator
% ModelParams = [x14-21] - CPG coupling gains
% ModelParams = [x22-25] - excitation gains


global countersubs SimuInfo
countersubs=0;


A=[];

b=[];

Aeq = [];
beq = [];

%Hinf Synthesis
lb = [1.01  20  1e-3    1e-3 20  1];
ub = [30    35  0.99    0.1  35 30];

%Oscillator Tunning
lb = [lb   1   1  .5  .01 .01  0 0  ];
ub = [ub  10  10   2  .5   .5  1 1  ];


%CPG coupling gains
lb = [lb 0 0 0 0 0 0 0 0];
ub = [ub 1 1 1 1 1 1 1 1];

%excitation gains
lb = [lb 0    0   0   0];
ub = [ub 2e6 2e6 2e6 2e6];


intcon=[];%[13 14 15 16 17 18 19 20];

ConstraintFunction = @gaConstrain;
rate=0.35;

FirstGuess=[10 30 .01 .01 30 1 2.5 2.5 1 .01 .01 0 0 .1 0 0 .1 .1 0 0 .1 2e6 1e6 1e6 1e6];   

options = optimoptions(@ga,...
    'CrossoverFraction',0.6,...
    'Display','iter',...
    'FunctionTolerance',1e-4,...
    'PopulationSize',10,...
    'MaxGenerations',2000,...
    'MutationFcn', {@mutationadaptfeasible,rate},...
    'MaxStallGenerations',10,...
    'OutputFcn', @gaOutputFunc,...
    'UseParallel', false,...
    'CreationFcn',{@gacreationnonlinearfeasible},...
    'PlotFcn',{@gaPlotFunc},...
    'ConstraintTolerance',1e-4,...
    'InitialPopulationMatrix', FirstGuess)


% Define the current date and time format
date_str = datestr(datetime('now'), 'yyyy_mm_dd_HH_MM');

% Set the base address to the current folder and define the output folder path
base_address = pwd; % Current folder
output_folder = fullfile(base_address, 'IndividualizedModels');
if ~exist(output_folder, 'dir')
    mkdir(output_folder); % Create folder if it does not exist
end

% Set up log file name using the formatted date and variable name structure
global logFilename
logFilename = fullfile(output_folder, strcat(SimuInfo.PatientID, date_str, '_GA.txt'));

% Uncomment the following line if you need to open the log file
% fid = fopen(logFilename, 'w');

% Define optimization function and parameters
fun = @CostFcn;

[x, fval, exitflag, output, population, scores] = ga(fun, nvars, A, b, Aeq, beq, lb, ub, ConstraintFunction, intcon, options);


