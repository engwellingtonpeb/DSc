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


function OsimPlotFcn(t,x,u,a,a0,ae,p,SimuInfo)

persistent j
phi=x(18);
phi_ref=SimuInfo.Setpoint(1);

psi=x(16);
psi_ref=SimuInfo.Setpoint(2);


switch SimuInfo.PltFlag

    case 'on'
        if rem(t,1)==0
            percent=(t/SimuInfo.Tend)*100;
            msg_status=['Simulation Running:', num2str(percent) ,'%'];
            disp(msg_status)
        end
        
        
        
        if (t==0)
            j=0;

        elseif (rem(j,100)==0) && strcmp(SimuInfo.PltFlag,'on')
        
        
            subplot(5,1,1)
            plot(t,phi_ref,'go',t,rad2deg(phi),'r.')
            axis([t-3 t -50 50])
            %drawnow;
            grid on;
            hold on;
        
        
            subplot(5,1,2)
            plot(t,a(2),'b.',t,a(6),'r.')
            %legend('ecrl', 'fcu')
            axis([t-3 t -1 1])
            %drawnow;
            grid on;
            hold on;
            
        
            subplot(5,1,3)
            plot(t,psi_ref,'go',t,rad2deg(psi),'k.')
            axis([t-3 t -40 60])
            %drawnow;
            grid on;
            hold on;
        
            subplot(5,1,4)
            plot(t,a(1),'b.',t,a(7),'r.')
            %plot(t,SimuInfo.du(1),'b.',t,SimuInfo.du(2),'r.') %%VER OSCILADOR
            %legend('sup', 'pq')
            axis([t-3 t -1 1])
            drawnow;
            grid on;
            hold on;

            subplot(5,1,5)
            plot(t,ae(3),'b.',t,p(3),'r.')
            axis([t-3 t -1 1])
            drawnow;
            grid on;
            hold on;
         end
         j=j+1;



    otherwise
            t
end






end