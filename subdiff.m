function datadiff = subdiff(datauni,paramuni,samplename,E1,E2,subconst)

% function datadiff = subdiff(datauni,paramuni,samplename,E1,E2,subconst)
% 
% Subtracts intensities measured at two energies from each other
% subconst is the constant subracted from E2 measurement (fluorescence etc)
%
% Created 27.2.2009 UV

sd = size(datauni);

for(k = 1:sd(2))
  if(strcmp(paramuni(k).Title,samplename)) 
    if(round(paramuni(k).Energy) == E1)
        data1 = datauni(k);
        param1 = datauni(k);
    elseif(round(paramuni(k).Energy) == E2)
        data2 = datauni(k);
        param2 = datauni(k);
    end;
  end;
end; hold off
if(data1.q ~= data2.q)
    disp('The different intensities have different q-range! Cannot do!');
    return
end;
datadiff = struct('q',data1.q,'Intensity',data1.Intensity-(data2.Intensity-subconst),'Error',sqrt(data1.Error.^2+(data2.Error).^2),'Title',samplename)
loglog(data1.q,data1.Intensity,'-b'); hold on
loglog(data2.q,data2.Intensity-subconst,'-g');
handl = errorbar(data1.q,datadiff.Intensity,datadiff.Error,'o-r');
set(handl,'MarkerSize',5,'MarkerFaceColor','r');
hold off
set(gca,'FontSize',14)
title(samplename)
legend(sprintf('E_1 = %d eV',E1),sprintf('E_2 = %d eV, const = %.3f',E2,subconst),'Difference',3)
xlabel(sprintf('q (1/%c)',197))
ylabel('Intensity (1/cm)') 
set(gca,'YMinorTick','on')
set(gca,'XMinorTick','on')
legend boxoff

