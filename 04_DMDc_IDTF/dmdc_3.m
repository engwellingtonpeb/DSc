%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo, DSc.                              %         
%  Date: 15/10/2023                                                       %
%  Last Update: DSc - Version 2.0                                         %
%-------------------------------------------------------------------------%
%   Identificação de Sistemas usando DMDc                                 % 
%                                                                         %
%  U-->[MODELO]-->x=[a,Theta]                                             %
%                                                                         %
%                                                                         %
%-----------------------------fi--------------------------------------------%

clc
clear 
close all

addpath('D:\02_DSc_v5\DSc\04_DMDc_IDTF\simulations\')
addpath('D:\02_DSc_v5\DSc\04_DMDc_IDTF\utils\')

load('2023_10_15_17_45_17_DScQuali_IDTFVector.mat')

x=[motionData.data(1:9001,42) motionData.data(1:9001,44) motionData.data(1:9001,52)...
   motionData.data(1:9001,54) motionData.data(1:9001,19) motionData.data(1:9001,17)...
   motionData.data(1:9001,39) motionData.data(1:9001,37)];
Uin=U;
u=Uin(1:9001,:);
t=motionData.data(1:9001,1);

ti=motionData.data(1,1);
tf=motionData.data(end,1);

% Reference state
Nvar = size(x,2);
xref = zeros(1,Nvar)';
T = length(t);
dt=1e-3;

%% Treinamento do Modelo

% DMDc assuming B = unknown and x may be augmented with time-delayed states
% Identify A, B from xdot = Ax + Bu

Hu = getHankelMatrix_MV(u,1);
xmean = xref'; 
X   = x - repmat(xmean,[T 1]);
Hx  = getHankelMatrix_MV(X,1);
numOutputs = size(Hx,1); 
numInputs = size(Hu,1); 
r1 = size(Hx,1);
r2 = size(Hx,1);
[sysDMDc,U,Up] = DelayDMDc_MV(Hx,Hu,size(Hx,1),size(Hx,1),dt,size(Hx,1),size(Hu,1),2);


% verificaçao do modelo treinado
x0=x(1,:);
[xDMDc,~] = lsim(sysDMDc,u,t,x0);


%% Validação
tval=9:dt:tf;
uval=Uin(9001:end,:);
xval=[motionData.data(9001:end,42) motionData.data(9001:end,44) motionData.data(9001:end,52) motionData.data(9001:end,54) motionData.data(9001:end,19) motionData.data(9001:end,17) motionData.data(9001:end,39) motionData.data(9001:end,37)];
x0val=xval(1,:);

[xDMDcVal,~] = lsim(sysDMDc,uval,tval,x0val);




figure(1)

set(gcf,'color','w');

subplot(4,2,1)

plot(motionData.data(:,1), motionData.data(:,42),'k--', 'Linewidth', 2 )
hold on
grid
plot(t, xDMDc(:,1), 'r-.')
plot(tval, xDMDcVal(:,1), 'g-.', 'Linewidth', 1.5 )
legend('osim', 'trainning', 'validation')
title('$a_{sup}$', 'interpreter', 'latex')

subplot(4,2,2)
plot(motionData.data(:,1), motionData.data(:,44),'k--', 'Linewidth', 2 )
hold on
grid
plot(t, xDMDc(:,2), 'r-.')
plot(tval, xDMDcVal(:,2), 'g-.', 'Linewidth', 1.5 )
legend('osim', 'trainning', 'validation')
title('$a_{ecrl}$', 'interpreter', 'latex')

subplot(4,2,3)
plot(motionData.data(:,1), motionData.data(:,52),'k--', 'Linewidth', 2 )
hold on
grid
plot(t, xDMDc(:,3), 'r-.')
plot(tval, xDMDcVal(:,3), 'g-.', 'Linewidth', 1.5 )
legend('osim', 'trainning', 'validation')
title('$a_{fcu}$', 'interpreter', 'latex')

subplot(4,2,4)
plot(motionData.data(:,1), motionData.data(:,54),'k--', 'Linewidth', 2 )
hold on
grid
plot(t, xDMDc(:,4), 'r-.')
plot(tval, xDMDcVal(:,4), 'g-.', 'Linewidth', 1.5 )
legend('osim', 'trainning', 'validation')
title('$a_{pq}$', 'interpreter', 'latex')

subplot(4,2,5)
plot(motionData.data(:,1), motionData.data(:,19),'k--', 'Linewidth', 2 )
hold on
grid
plot(t, xDMDc(:,5), 'r-.')
plot(tval, xDMDcVal(:,5), 'g-.', 'Linewidth', 1.5 )
legend('osim', 'trainning', 'validation')
title('$\phi$', 'interpreter', 'latex')

subplot(4,2,6)
plot(motionData.data(:,1), motionData.data(:,17),'k--', 'Linewidth', 2 )
hold on
grid
plot(t, xDMDc(:,6), 'r-.')
plot(tval, xDMDcVal(:,6), 'g-.', 'Linewidth', 1.5 )
legend('osim', 'trainning', 'validation')
title('$\psi$', 'interpreter', 'latex')

subplot(4,2,7)
plot(motionData.data(:,1), motionData.data(:,39),'k--', 'Linewidth', 2 )
hold on
grid
plot(t, xDMDc(:,7), 'r-.')
plot(tval, xDMDcVal(:,7), 'g-.', 'Linewidth', 1.5 )
legend('osim', 'trainning', 'validation')
title('$\dot{\phi}$', 'interpreter', 'latex')

subplot(4,2,8)
plot(motionData.data(:,1), motionData.data(:,37),'k--', 'Linewidth', 2 )
hold on
grid
plot(t, xDMDc(:,8), 'r-.')
plot(tval, xDMDcVal(:,8), 'g-.', 'Linewidth', 1.5 )
legend('osim', 'trainning', 'validation')
title('$\dot{\psi}$', 'interpreter', 'latex')

%% calculate idtf error (validation fase)

RMSE_asup=sqrt(mean((motionData.data(9001:end,42)-xDMDcVal(:,1)).^2));
RMSE_aecrl=sqrt(mean((motionData.data(9001:end,44)-xDMDcVal(:,2)).^2));
RMSE_afcu=sqrt(mean((motionData.data(9001:end,52)-xDMDcVal(:,3)).^2));
RMSE_apq=sqrt(mean((motionData.data(9001:end,54)-xDMDcVal(:,4)).^2));
RMSE_phi=sqrt(mean((motionData.data(9001:end,19)-xDMDcVal(:,5)).^2));
RMSE_psi=sqrt(mean((motionData.data(9001:end,17)-xDMDcVal(:,6)).^2));
RMSE_phidot=sqrt(mean((motionData.data(9001:end,39)-xDMDcVal(:,7)).^2));
RMSE_psidot=sqrt(mean((motionData.data(9001:end,37)-xDMDcVal(:,8)).^2));

RMSE=[RMSE_asup RMSE_aecrl RMSE_afcu RMSE_apq RMSE_phi RMSE_psi RMSE_phidot RMSE_psidot]
mean(RMSE)


sysDMDc.StateName={'asup','aecrl','afcu','apq','phi','psi','phidot','psidot'}
sysDMDc.InputName={'uecrl','ufcu','upq','usup'}

formatOut = 'yyyy/mm/dd/HH/MM/SS';
date=datestr(now,formatOut);
date=strrep(date,'/','_');

indir='D:\06_BiomechCodeRepo\BiomechanicsModeling\DSc2023_v2\simulations';
filename=strcat(date,'_DMDmodel');
extension='.mat';
modelfilename=fullfile(indir,[filename extension]);


save(modelfilename,'sysDMDc');