function [data,param] = readintnormtheor(fsns)

% function [data,param] = readintnormtheor(fsns)
%
%
% Created 11.11.2007 UV

counter = 1;
for(k = 1:length(fsns))
   temp = readintfile(sprintf('intnormtheor%d.dat',fsns(k)));
   if(isstruct(temp))
       temp2 = readlogfile(sprintf('intnormtheor%d.log',fsns(k)));
      if(isstruct(temp2))
        data(counter) = temp;
        param(counter) = temp2;
        counter = counter + 1;
      end;
   end;
end;