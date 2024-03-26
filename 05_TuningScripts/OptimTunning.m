%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo, DSc.                              %         
%  Date: 15/10/2023                                                       %
%  Last Update:                                                           %
%  DSc - Version 2.0                                                      %
%-------------------------------------------------------------------------%
%   GA optimization to Hinf sinthesis                                     %
%                                                                         %
%                                                                         %
%------------------------------------------------------------------------ %

clc
clear
close all hidden

import org.opensim.modeling.*
addpath('C:\Users\Wellington\Downloads\BiomechanicsModeling\DSc2023_v2\03_ODE_Solvers')
addpath('C:\Users\Wellington\Downloads\BiomechanicsModeling\DSc2023_v2\02_2017Coleta')

%Initial Gain Guess
ModelParams=zeros(1,10);
nvars=length(ModelParams);

% ModelParams = [x1-x7] -  Hinf controller synthesis
% ModelParams = [x8-x12] - [B  h   rosc    tau1 tau2] params matsuoka's oscillator
% ModelParams = [x13-20] - flags ON/OFF oscillator channel aading to
% control signal

global countersubs
countersubs=0;

A=[];

b=[];

Aeq = [];
beq = [];

%Hinf Synthesis
% lb = [1.01  20  1e-3    1e-3 20  1  1  ];
% ub = [30    35  0.99    0.1  35 30  2  ];

%Oscillator Tunning

lb = [ 1  1   .5  .01 .01   0.6  0 0 0 0 ];
ub = [10  10  2  .5   .5    2  .5 .5 .5 .5];

intcon=[];%[13 14 15 16 17 18 19 20];

ConstraintFunction = @gaConstrain;
rate=0.35;

options = optimoptions(@gamultiobj,'CrossoverFraction',0.6,'Display','iter',...
    'FunctionTolerance',1e-4,'PopulationSize',100,'MaxGenerations',2000,...
    'MutationFcn', {@mutationadaptfeasible,rate},'MaxStallGenerations',10,'OutputFcn',...
    [], 'UseParallel', true, 'CreationFcn',{@gacreationnonlinearfeasible},...
    'PlotFcn',{@gaplotscores,@gaplotpareto,@gaplotrankhist},'ConstraintTolerance',1e-4)



date = datestr(datetime('now')); 
date=regexprep(date, '\s', '_');
date=strrep(date,':','_');
date=strrep(date,'-','_');
date=strcat(date,'_');
address='C:\Users\Wellington\Downloads\BiomechanicsModeling\DSc2023_v2\ModelTunning\Tuning_Feature\';
global logFilename
logFilename=strcat(address,date,'GA','.txt');



% fid=fopen(logFilename, 'w');



fun=@CostFcn;      

[x,fval,exitflag,output,population,scores] = gamultiobj(fun,nvars,A,b,Aeq,beq,lb,ub,ConstraintFunction,intcon,options)

filename=strcat(address,date,'GA','.mat');
save(filename, 'x','fval','exitflag','output','population','scores')

fclose('all')

%Salvar resultados da simulaçao, controlador, parametros usados e fcusto.