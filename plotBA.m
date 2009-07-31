function plotBA(data,param,k,l)

% function plotBA(data,param,k,l)
% 
% k = cuvette with background
% l = cuvette with sample in
%
% Created 25.9.2008 UV, to plot easily the data and background

multbg = 0.8;

subplot(1,1,1)
handl = plot(data(k).q,data(k).Intensity,'--',...
    data(l).q,data(l).Intensity,'o',...
    data(l).q,data(l).Intensity-data(k).Intensity,'-r');
%    data(l).q,data(l).Intensity-multbg*data(k).Intensity,'-.m');
set(handl(2),'MarkerFaceColor','g')
set(handl(2),'MarkerSize',4)
set(gca,'FontSize',14)
legend(param(k).Title,param(l).Title,sprintf('%s - %s, 1*bg',param(l).Title,param(k).Title),sprintf('%s - %s, %.3f*bg',param(l).Title,param(k).Title,multbg),3)
xlabel(sprintf('q (1/%c)',197))
ylabel('Intensity (1/cm)') 
set(gca,'YMinorTick','on')
set(gca,'XMinorTick','on')
legend boxoff
%subplot(2,1,2)
%handl = semilogy(data(l).q.^2,data(l).Intensity-multbg*data(k).Intensity);
%title('Guinier plot')
%xlabel(sprintf('q^2 (1/%c^2)',197))

