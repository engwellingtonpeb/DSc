clc
clear all
close all

addpath('Tuning_Feature')
addpath('..\03_ODE_Solvers')

% load('27_Oct_2023_21_23_29_GA.mat') %sintonia Hinf?

%pacitente 01
% load('29_Oct_2023_20_15_55_GA.mat') % sintonia do oscilador 2 dias 
% ModelParams=x(12,:)% sintonia do oscilador 2 dias 

% paciente 01
% load('03_Nov_2023_15_31_31_GA.mat') %sintonia do oscilador e ganhos s/alpha 
% ModelParams=x(10,:);


% 
% %paciente 02
% load('08_Nov_2023_13_26_46_GA.mat') %sintonia do oscilador e ganhos s/alpha
% ModelParams=x(18,:)

%paciente 03
load('19_Nov_2023_15_51_19_GA.mat') %29 %4
ModelParams=x(29,:)



fval(:,4)=sqrt(fval(:,1).^2+fval(:,2).^2+fval(:,3).^2);



ModelParams(7)=0.5*ModelParams(7);
ModelParams(8)=0.5*ModelParams(8);
ModelParams(9)=0.5*ModelParams(9);
ModelParams(10)=0.5*ModelParams(10);


[J] = CostFcn(ModelParams)
