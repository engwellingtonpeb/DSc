function [c,ceq] = gaConstrain(ModelParams)
    c=[]; 
    ceq=[]; 

%% HInf Synthesis

    x1=ModelParams(1); %W1
    x2=ModelParams(2); %W1
    x3=ModelParams(3); %W1

    x4=ModelParams(4);
    x5=ModelParams(5);
    x6=ModelParams(6);
 
%     x7=ModelParams(7);
% 
    [LinStabilityFlag, K, wc] = ControllerSynthesis4Tunning(ModelParams);


    if isempty(wc)
        x7=-1;
    else
        x7=1;
    end

    c(3)=x7; % if x7 negative Jaime's book (pg198) condition of W1, W3 is met.


    




  %% Matsuoka Oscillator [beta h r tau1 tau2]

    % B=SimuInfo.ModelParams(7); %beta
    % h=SimuInfo.ModelParams(8); %h
    % rosc=SimuInfo.ModelParams(9); %rosc
    % tau1=SimuInfo.ModelParams(10);%tau1
    % tau2=SimuInfo.ModelParams(11);%tau2
    % A1=SimuInfo.ModelParams(12);
    % A2=SimuInfo.ModelParams(13);

    x8=ModelParams(7);   %beta
    x9=ModelParams(8);   %h
    x10=ModelParams(9); %r
    x11=ModelParams(10); %tau1
    x12=ModelParams(11); %tau2

    % Stable oscilation conditions from Matsuoka, Kiyotoshi. "Analysis of a 
    % neural oscillator." Biological cybernetics 104 (2011): 297-304.
    c(1)=x9-1-x8;
    c(2)=(x11/x12)+1-x9; %



 




end