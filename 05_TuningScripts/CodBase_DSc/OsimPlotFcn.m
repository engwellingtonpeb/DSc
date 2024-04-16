%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This function implements simulation plots                               %
%                                                                         %
%=========================================================================%


function OsimPlotFcn(t,x,u,SimuInfo)


phi=x(18);
phi_ref=SimuInfo.Setpoint(1);

psi=x(16);
psi_ref=SimuInfo.Setpoint(2);



persistent j
if (t==0)
    j=0;
else


 if (rem(j,100)==0) && (SimuInfo.PltFlag==1)


    subplot(4,1,1)
    plot(t,phi_ref,'go',t,rad2deg(phi),'r.')
    axis([t-3 t -50 50])
    %drawnow;
    grid on;
    hold on;


    subplot(4,1,2)
    plot(t,u(2),'b.',t,u(6),'r.')
    %legend('ecrl', 'fcu')
    axis([t-3 t -1 1])
    %drawnow;
    grid on;
    hold on;
    

    subplot(4,1,3)
    plot(t,psi_ref,'go',t,rad2deg(psi),'k.')
    axis([t-3 t -40 60])
    %drawnow;
    grid on;
    hold on;

    subplot(4,1,4)
    plot(t,u(1),'b.',t,u(7),'r.')
    %plot(t,SimuInfo.du(1),'b.',t,SimuInfo.du(2),'r.') %%VER OSCILADOR
    %legend('sup', 'pq')
    axis([t-3 t -1 1])
    drawnow;
    grid on;
    hold on;
    

 end
 j=j+1;


end