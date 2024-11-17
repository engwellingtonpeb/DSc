function [Metrics] = ModelMetrics(x1,y1,w,edges,w1,edges1)
% This function to calculate Jeffrey Divergence, Kullback-Liebler
% Divergence and calculate Match Distance between P and Q.
% All as difined at [1]
%
%   [1] Rubner, Yossi, Carlo Tomasi, and Leonidas J. Guibas. "The earth mover's 
%   distance as a metric for image retrieval." International journal of 
%   computer vision 40.2 (2000): 99-121.
%
%
%   x - Time domain signal from patient;
%   y - Time domain signal from model

%Getting P(x) and Q(x)

if w<=0
    w=w1;
end

% Temporarily disable figure creation
set(0, 'DefaultFigureVisible', 'off');

Metrics=struct;
hist1=histogram(x1,'BinLimits',edges,'BinWidth',w,'Normalization','probability', 'Visible','off');
h=hist1.BinCounts;
% hold on
hist2=histogram(y1,'BinLimits',edges,'BinWidth',w,'Normalization','probability','Visible','off');
k=hist2.BinCounts;

% Re-enable figure creation
set(0, 'DefaultFigureVisible', 'on');




if (length(h)> length(k))
    h=h(1:length(k));
end

if (length(k)> length(h))
    k=k(1:length(h));
end

h=h./sum(h); %normalization
k=k./sum(k);

%% error of Intersection Distance = 1- Intersection Distance

num=[];
for i=1:length(h)
    num(i)= min(h(i),k(i));
end


if any([all(isnan(h)), all(isnan(k))])
    Metrics.dI=1;
else
   Metrics.dI=1-(sum(num)/sum(h));
end




%% L-1 distance (Manhattan)
% H=cumsum(h);
% K=cumsum(k);
% Metrics.dL1=sum(abs(H-K));



%% Jensen-Shannon Divergence or https://web.math.ku.dk/~topsoe/ISIT2004JSD.pdf
M=0.5*(h+k);

dKL1=(h.*log2(h./M)); %% (P||M)
%dKL1(isnan(dKL1))=0; % 0/0 problem
DKL1=sum(dKL1,'omitnan');

dKL2=(k.*log2(k./M)); %% (Q||M)
%dKL2(isnan(dKL2))=0; % 0/0 problem
DKL2=sum(dKL2,'omitnan');

JSD=0.5*DKL1+0.5*DKL2;

if all(isnan(M))
    Metrics.JSD=1;
else
    Metrics.JSD=JSD;
end



% %% Kullback-Liebler Divergence
% k(k==0) = 1e6; % division by zero problem
% 
% dKL=(h.*log2(h./k));
% dKL(isnan(dKL))=0; %0/0 problem
% Metrics.dKL=sum(dKL);
% 
% 
% 
% %% Stat Moments
% Metrics.var=[var(x1) var(y1)];
% 
% Metrics.Kurtosis=[kurtosis(x1) kurtosis(y1)];
% Metrics.Skewness=[skewness(x1) skewness(y1)];
% % 
%% centroid
% [yip,xip] = histcounts(x1,'Normalization', 'probability');%paciente
% [yiq,xiq] = histcounts(y1,'Normalization', 'probability');%modelo
% yip(end+1)=yip(end);
% yiq(end+1)=yiq(end);
% centroid_P=[sum(xip.*yip)/sum(yip) sum(yip.*xip)/sum(xip)];
% centroid_Q=[sum(xiq.*yiq)/sum(yiq) sum(yiq.*xiq)/sum(xiq)];
% 
% centroid_P=sum((xip.^2).*yip)/sum(xip.*yip); %posquali xip^2*yip = xip*Area
% centroid_Q=sum((xiq.^2).*yiq)/sum(xiq.*yiq);


% Histograma para paciente
[yip, xip_edges] = histcounts(x1, 'Normalization', 'probability');
xip_centers = (xip_edges(1:end-1) + xip_edges(2:end)) / 2; % Calcular os centros das barras
centroid_paciente = sum(xip_centers .* yip) / sum(yip);    % Cálculo do centróide

% Histograma para modelo
[yiq, xiq_edges] = histcounts(y1, 'Normalization', 'probability');
xiq_centers = (xiq_edges(1:end-1) + xiq_edges(2:end)) / 2; % Calcular os centros das barras
centroid_modelo = sum(xiq_centers .* yiq) / sum(yiq);      % Cálculo do centróide

% Exibição dos resultados
% fprintf('Centróide do histograma do paciente: %.4f\n', centroid_paciente);
% fprintf('Centróide do histograma do modelo: %.4f\n', centroid_modelo);


Metrics.RelativeCentroidError=abs(centroid_paciente-centroid_modelo)/abs(max(x1)-min(x1));
Metrics.CentroidError=abs(centroid_paciente-centroid_modelo);


% close all
end

